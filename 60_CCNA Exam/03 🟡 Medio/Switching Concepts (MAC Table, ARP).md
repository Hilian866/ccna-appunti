---
tags: [ccna, exam, fondamenti, switching]
priorita: medio
dominio: Network Fundamentals
blueprint: 1.13
stato: da-ripassare
---

> [!ABSTRACT] Cosa serve per l'esame
> Blueprint **1.13**: concetti di switching: apprendimento e aging dei MAC, inoltro dei frame, flooding, tabella MAC.
> Devi saper seguire un frame dentro uno switch (cosa impara, dove lo manda), conoscere la struttura del frame Ethernet e dell'indirizzo MAC, distinguere domini di collisione e di broadcast, e spiegare come ARP trova il MAC di un indirizzo IP. Le VLAN sono in [[VLAN - Trunking & Inter-VLAN Routing]].

## 1. Il frame Ethernet

| Campo | Byte | Cosa contiene |
| :--- | :--- | :--- |
| Preambolo + SFD | 7 + 1 | sincronizzazione (non conta nella dimensione del frame) |
| **MAC destinazione** | 6 | |
| **MAC sorgente** | 6 | |
| Tag 802.1Q (solo sui trunk) | 4 | VLAN e priorità |
| **Type** | 2 | cosa c'è dentro: `0x0800` IPv4, `0x86DD` IPv6, `0x0806` ARP |
| Dati | 46-1500 | il pacchetto; **MTU** 1500. Se sono meno di 46 si aggiunge padding |
| **FCS** | 4 | controllo errori (CRC): un frame con FCS sbagliato viene scartato |

Il frame va da **64** a **1518** byte (senza preambolo). Sotto 64 è un runt, sopra 1518 un giant (con il tag 802.1Q il massimo sale a 1522).

L'**indirizzo MAC** è di 48 bit, scritto in 12 cifre esadecimali (`0011.2233.4455` nel formato Cisco). I primi 24 bit sono l'**OUI**, il codice del produttore.

- **Unicast**: un solo destinatario.
- **Broadcast**: `ffff.ffff.ffff`, tutti gli host della VLAN.
- **Multicast**: un gruppo; il bit meno significativo del primo byte vale 1 (es. `0100.5e…` per il multicast IPv4).

## 2. Cosa fa lo switch con un frame

1. **Learning**: legge il **MAC sorgente** e lo associa alla porta e alla VLAN da cui è arrivato. Impara sempre dalla sorgente, mai dalla destinazione.
2. Poi guarda il **MAC destinazione**:
   - **noto** (known unicast): **forwarding**, lo manda solo sulla porta associata;
   - sconosciuto (unknown unicast), broadcast o multicast: **flooding**, lo manda su tutte le porte della **stessa VLAN** tranne quella di arrivo;
   - noto, ma sulla **stessa porta** da cui è arrivato: **filtering**, lo scarta.

**Esempio**. Lo switch è appena acceso, tabella vuota. PC-A (porta 1) manda un frame a PC-B (porta 2).

1. Lo switch impara: `MAC-A → porta 1`.
2. MAC-B è sconosciuto: flooding su tutte le porte della VLAN tranne la 1.
3. PC-B risponde a PC-A. Lo switch impara `MAC-B → porta 2`.
4. MAC-A è noto: il frame va solo sulla porta 1.

Da qui in poi i frame tra A e B vanno solo sulle loro porte.

**Aging**: una voce dinamica viene cancellata dopo **300 secondi** in cui non arriva traffico da quel MAC. Se un host si sposta su un'altra porta, la voce si aggiorna al primo frame che manda.

La tabella è **per VLAN** e sta nella memoria **CAM**, che è veloce ma limitata: un attacco di **MAC flooding** la riempie di MAC falsi, e lo switch inizia a fare flooding di tutto (difesa: [[Port Security (Layer 2)]]).

```ios
SW1# show mac address-table
          Mac Address Table
-------------------------------------------
Vlan    Mac Address       Type        Ports
----    -----------       --------    -----
  10    0011.2233.4455    DYNAMIC     Gi0/1
  10    0011.2233.6677    DYNAMIC     Gi0/2
  20    00aa.bbcc.ddee    STATIC      Gi0/5
   1    0050.7966.6800    DYNAMIC     Gi0/24
```

Un MAC visto sulla porta di un trunk (Gi0/24 qui sopra) significa che quell'host sta dietro un altro switch.

```ios
! Solo le voci dinamiche, o un MAC preciso
SW1# show mac address-table dynamic
SW1# show mac address-table address 0011.2233.4455

! Cancella le voci dinamiche (vengono reimparate)
SW1# clear mac address-table dynamic

! Tempo di aging (secondi) e voce statica
SW1(config)# mac address-table aging-time 300
SW1(config)# mac address-table static 00aa.bbcc.ddee vlan 20 interface g0/5
```

## 3. Metodi di inoltro

| Metodo | Inizia a inoltrare dopo | Controlla la FCS? |
| :--- | :--- | :--- |
| **Store-and-forward** | aver ricevuto **tutto** il frame | **sì**: scarta i frame corrotti |
| Cut-through | aver letto il MAC destinazione | no: latenza minima, ma inoltra anche i frame corrotti |
| Fragment-free | i primi 64 byte | in parte: evita i runt |

Gli switch Catalyst usano **store-and-forward**.

## 4. Domini di collisione e di broadcast

- **Dominio di collisione**: gli host i cui frame possono scontrarsi (solo con mezzo condiviso, half duplex).
- **Dominio di broadcast**: gli host raggiunti da un broadcast.

| Dispositivo | Domini di collisione | Domini di broadcast |
| :--- | :--- | :--- |
| Hub | **uno** per tutte le porte | uno |
| Switch | **uno per porta** | **uno per VLAN** |
| Router | uno per interfaccia | **uno per interfaccia** (non inoltra i broadcast) |

## 5. ARP

ARP trova il **MAC** che corrisponde a un **indirizzo IP** nella stessa subnet.

1. PC-A (`192.168.1.10`) deve mandare un pacchetto a `192.168.1.20`. Cerca nella sua **cache ARP**.
2. Se non c'è, manda un'**ARP request** in **broadcast** (`ffff.ffff.ffff`): "chi ha 192.168.1.20? Lo dica a 192.168.1.10".
3. Solo PC-B risponde con un'**ARP reply** in **unicast**, con il suo MAC.
4. PC-A salva la coppia nella cache e manda il pacchetto.

Se la destinazione è in **un'altra subnet**, l'host non chiede il MAC del destinatario ma quello del **default gateway**: il frame va al router, il pacchetto IP resta indirizzato alla destinazione finale. A ogni salto il router rifà l'ARP sulla rete successiva.

Un **gratuitous ARP** è una reply non richiesta, mandata in broadcast per annunciare il proprio MAC (lo usano gli FHRP dopo un cambio, e gli attaccanti nell'ARP poisoning: vedi [[DAI (Dynamic ARP Inspection)]]).

```ios
! Cache ARP del router (Age "-" = indirizzo del router stesso)
R1# show ip arp
Protocol  Address        Age (min)  Hardware Addr   Type   Interface
Internet  192.168.1.1        -      0011.2233.0001  ARPA   GigabitEthernet0/0
Internet  192.168.1.10       3      0050.7966.6800  ARPA   GigabitEthernet0/0
```

Su un PC: `arp -a` mostra la cache.

## ⚠️ Trappole d'esame

> [!WARNING] Gli errori più frequenti
> 1. **Da dove impara lo switch**: dal MAC **sorgente**.
> 2. **Flooding**: solo nella VLAN del frame, mai sulla porta di arrivo.
> 3. **Domini**: lo switch divide i domini di collisione (uno per porta), non quelli di broadcast (uno per VLAN).
> 4. **ARP verso un'altra subnet**: si chiede il MAC del gateway, non quello della destinazione.
> 5. **ARP request e reply**: request in broadcast, reply in unicast.
> 6. **Aging**: 300 secondi di default.

## Esercizi

> [!QUESTION]- Lo switch riceve sulla porta 3 un frame da MAC-C verso MAC-D, che non è in tabella. Cosa impara e cosa fa?
> Impara MAC-C sulla porta 3 e fa flooding del frame su tutte le altre porte della stessa VLAN.

> [!QUESTION]- Uno switch a 24 porte, con 3 VLAN, quanti domini di collisione e di broadcast ha?
> 24 domini di collisione (uno per porta) e 3 di broadcast (uno per VLAN).

> [!QUESTION]- PC-A (192.168.1.10/24, gateway .1) vuole raggiungere 8.8.8.8. Per quale IP fa la ARP request?
> Per 192.168.1.1, il default gateway.

> [!QUESTION]- Un frame arriva sulla porta 5 diretto a un MAC che la tabella associa proprio alla porta 5. Cosa fa lo switch?
> Lo scarta (filtering).

## Check da esame

- [ ] Aging di default della tabella MAC? **300 s**.
- [ ] Cosa fa lo switch con un unicast sconosciuto? **Flooding nella VLAN**.
- [ ] Dimensione minima e massima di un frame? **64 e 1518 byte**.
- [ ] Bit dell'OUI? **I primi 24 del MAC**.
- [ ] ARP request: broadcast o unicast? **Broadcast**. Reply? **Unicast**.
- [ ] Metodo di inoltro che controlla la FCS? **Store-and-forward**.

## 🎯 Synthesis

Lo switch impara il MAC sorgente con porta e VLAN, inoltra solo sulla porta giusta se conosce la destinazione, fa flooding nella VLAN se è sconosciuta o broadcast, e scarta se la destinazione sta sulla porta di arrivo. Le voci scadono dopo 300 s. Ogni porta è un dominio di collisione, ogni VLAN un dominio di broadcast. ARP trova il MAC di un IP con una request in broadcast e una reply in unicast; per le altre subnet si chiede il MAC del gateway.
