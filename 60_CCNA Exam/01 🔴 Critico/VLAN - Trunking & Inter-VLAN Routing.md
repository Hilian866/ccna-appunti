---
tags: [ccna, exam]
priorita: critico
stato: da-ripassare
---

> [!ABSTRACT] Cosa serve per l'esame
> Blueprint **2.1** (VLAN su più switch: porte access per dati e voce, VLAN di default, connettività tra VLAN) e **2.2** (connessioni tra switch: trunk, 802.1Q, native VLAN).
> Devi saper creare VLAN e assegnare porte, configurare un trunk con allowed e native VLAN, scegliere e configurare un metodo di inter-VLAN routing (ROAS o SVI), e leggere `show vlan brief` e `show interfaces trunk`.

## 1. Cos'è una VLAN

Una VLAN divide uno switch in più reti di livello 2 separate. Senza VLAN, uno switch è un unico dominio di broadcast: un broadcast arriva a tutte le porte.

> [!INFO] La relazione da ricordare
> **1 VLAN = 1 dominio di broadcast = 1 subnet IP**

- Tra VLAN diverse il traffico passa **solo** attraverso un dispositivo di livello 3 (router o switch L3).
- Vantaggi: meno broadcast, sicurezza (separi reparti e servizi), traffico più ordinato.

### VLAN di default e range

- **VLAN 1**: tutte le porte ci stanno di default. Non si può eliminare. Best practice: non usarla per gli utenti.
- **VLAN 1002–1005**: esistono di default (legacy Token Ring/FDDI), non si possono eliminare.
- **ID utilizzabili**: 1–4094 (0 e 4095 sono riservati). **Normal** 1–1005, **extended** 1006–4094.

## 2. Porte access e voice VLAN

Una **porta access** appartiene a una sola VLAN e invia frame **senza tag**: di solito verso PC, stampanti, server.

Un telefono IP ha uno switch interno a 3 porte (verso lo switch, verso il PC, verso il telefono). Sulla stessa porta dello switch passano quindi due VLAN:

- **dati** (`switchport access vlan`): traffico del PC, **senza tag**;
- **voce** (`switchport voice vlan`): traffico del telefono, **con tag 802.1Q**. Lo switch comunica al telefono quale VLAN usare tramite CDP.

La porta resta una porta access: non compare in `show interfaces trunk`.

```ios
! Crea la VLAN e le dà un nome
SW1(config)# vlan 10
SW1(config-vlan)# name ENGINEERING

! Più porte insieme
SW1(config)# interface range g1/0/1 - 4

! Porta access nella VLAN 10
SW1(config-if-range)# switchport mode access
SW1(config-if-range)# switchport access vlan 10

! Sulla porta di un telefono IP: dati in VLAN 10, voce in VLAN 11
SW1(config)# interface g1/0/5
SW1(config-if)# switchport mode access
SW1(config-if)# switchport access vlan 10
SW1(config-if)# switchport voice vlan 11
```

Assegnare una porta a una VLAN che non esiste **crea** la VLAN; creare un'SVI no (vedi sezione 5).

## 3. Trunk e 802.1Q

Una **porta trunk** trasporta più VLAN su un solo link (tra switch, o tra switch e router). Per sapere a quale VLAN appartiene ogni frame, lo switch aggiunge un **tag 802.1Q** di 4 byte, inserito tra il MAC sorgente e il campo Type.

| Campo | Bit | Cosa contiene |
| :--- | :--- | :--- |
| TPID | 16 | valore fisso `0x8100`: "questo frame ha un tag" |
| PCP | 3 | priorità (Class of Service, per la QoS) |
| DEI | 1 | il frame può essere scartato per primo in caso di congestione |
| **VID** | 12 | il **VLAN ID** |

ISL è il vecchio trunking proprietario Cisco: basta riconoscerlo.

### Native VLAN

I frame della **native VLAN** viaggiano sul trunk **senza tag**, e un frame senza tag ricevuto su un trunk viene messo nella native VLAN. Di default è la VLAN 1.

- **Best practice**: native VLAN = una VLAN inutilizzata (es. 1001), per sicurezza.
- **Native VLAN mismatch**: se i due lati hanno native diverse, i frame senza tag finiscono nella VLAN sbagliata. CDP lo segnala con messaggi di errore.

### Allowed VLAN

Di default un trunk permette **tutte** le VLAN (1–4094). Si può limitare l'elenco.

```ios
SW1(config)# interface g1/0/24

! Solo su switch che supportano anche ISL: va scelto prima di "mode trunk"
SW1(config-if)# switchport trunk encapsulation dot1q

SW1(config-if)# switchport mode trunk

! Solo queste VLAN; poi se ne aggiunge e se ne toglie una
SW1(config-if)# switchport trunk allowed vlan 10,20,30
SW1(config-if)# switchport trunk allowed vlan add 40
SW1(config-if)# switchport trunk allowed vlan remove 20

! Native VLAN su una VLAN inutilizzata (uguale sui due lati)
SW1(config-if)# switchport trunk native vlan 1001
```

## 4. Leggere le verifiche

```ios
! VLAN esistenti e porte ACCESS assegnate (le porte trunk qui non compaiono)
SW1# show vlan brief

! Porte trunk: modo, encapsulation, native VLAN e VLAN permesse
SW1# show interfaces trunk

! Modo amministrativo (configurato) e operativo (reale) di una porta
SW1# show interfaces g1/0/24 switchport
```

`show interfaces trunk` ha quattro blocchi:

| Blocco | Cosa dice |
| :--- | :--- |
| Port / Mode / Encapsulation / Status / Native vlan | quali porte sono trunk e con che native |
| Vlans allowed on trunk | l'elenco configurato |
| Vlans allowed and active in management domain | le VLAN permesse **che esistono** sullo switch |
| Vlans in spanning tree forwarding state and not pruned | quelle su cui il traffico passa davvero |

Se una VLAN è nel secondo blocco ma non nel terzo, **non è stata creata** sullo switch.

## 5. Inter-VLAN routing

| Metodo | Come funziona | Limite |
| :--- | :--- | :--- |
| Router con una porta per VLAN | ogni porta del router è il gateway di una VLAN | non scala: servono troppe porte |
| **ROAS** (router on a stick) | un solo trunk verso il router, che usa una sub-interfaccia per VLAN | tutto il traffico tra VLAN passa su un cavo e torna indietro |
| **Switch L3 con SVI** | il routing lo fa lo switch, con un'interfaccia virtuale per VLAN | il metodo preferito nelle reti grandi |

### ROAS

```ios
! La fisica va accesa, ma senza IP
R1(config)# interface g0/0
R1(config-if)# no shutdown

! Una sub-interfaccia per VLAN, con il tag e l'IP del gateway
R1(config)# interface g0/0.10
R1(config-subif)# encapsulation dot1q 10
R1(config-subif)# ip address 192.168.10.1 255.255.255.0

R1(config)# interface g0/0.20
R1(config-subif)# encapsulation dot1q 20
R1(config-subif)# ip address 192.168.20.1 255.255.255.0
```

Sullo switch, la porta verso il router dev'essere un **trunk configurato a mano**: DTP non negozia con un router. Il numero della sub-interfaccia può essere diverso dalla VLAN, ma per chiarezza si fanno coincidere.

**Native VLAN sul router**: due modi corretti, che all'esame sono entrambi validi.

```ios
! Modo 1: sub-interfaccia marcata native
R1(config)# interface g0/0.1001
R1(config-subif)# encapsulation dot1q 1001 native
R1(config-subif)# ip address 192.168.99.1 255.255.255.0

! Modo 2: IP direttamente sulla fisica, senza encapsulation
R1(config)# interface g0/0
R1(config-if)# ip address 192.168.99.1 255.255.255.0
```

### Switch L3: SVI e routed port

- Un'**SVI** (`interface vlan X`) è il gateway virtuale della VLAN X.
- Una **routed port** è una porta fisica trasformata in porta L3 (`no switchport`), con un suo IP: di solito il link verso il router.

```ios
! Senza questo lo switch non instrada
SW1(config)# ip routing

! SVI = gateway della VLAN; sono spente di default
SW1(config)# interface vlan 10
SW1(config-if)# ip address 192.168.10.1 255.255.255.0
SW1(config-if)# no shutdown

! Porta fisica L3 verso il router
SW1(config)# interface g1/0/48
SW1(config-if)# no switchport
SW1(config-if)# ip address 192.168.1.193 255.255.255.252

! Tutto il resto va al router
SW1(config)# ip route 0.0.0.0 0.0.0.0 192.168.1.194
```

> [!WARNING] Perché un'SVI resta down
> Un'SVI va up/up solo se:
> 1. la VLAN **esiste** sullo switch (creare l'SVI non la crea);
> 2. almeno una porta access di quella VLAN, o un trunk che la permette, è up/up;
> 3. né la VLAN né l'SVI sono in `shutdown`.

In `show interfaces status` una routed port appare con `routed` nella colonna VLAN.

## 6. DTP e VTP (fuori dal blueprint)

Non sono più tra gli argomenti ufficiali, ma possono comparire domande sul comportamento di default.

**DTP** (Dynamic Trunking Protocol) negozia se una porta diventa access o trunk. Best practice: disattivarlo e configurare tutto a mano.

| Lato A ↓ / Lato B → | trunk | dynamic desirable | dynamic auto | access |
| :--- | :--- | :--- | :--- | :--- |
| **dynamic desirable** | trunk | trunk | trunk | access |
| **dynamic auto** | trunk | trunk | **access** | access |

- `switchport mode access` disattiva DTP; con `mode trunk` serve anche `switchport nonegotiate`.
- `access` da un lato e `trunk` dall'altro è un errore di configurazione.

**VTP** sincronizza il **database delle VLAN** (non le assegnazioni delle porte) tra switch dello stesso dominio. Modi: **server** (default: crea VLAN e le annuncia), **client** (non può creare VLAN, si sincronizza), **transparent** (tiene le sue VLAN e inoltra gli annunci). Il rischio: uno switch con revision number più alto e lo stesso dominio sovrascrive le VLAN di tutta la rete. Mettere uno switch in transparent, o cambiarne il dominio, azzera il suo revision number.

## ⚠️ Trappole d'esame

> [!WARNING] Gli errori più frequenti
> 1. **Porte trunk "sparite"**: `show vlan brief` mostra solo le porte access. I trunk si vedono con `show interfaces trunk`.
> 2. **VLAN permessa ma non attiva**: è nell'allowed list, ma non è stata creata sullo switch.
> 3. **Allowed senza `add`**: `switchport trunk allowed vlan 40` **sostituisce** l'elenco; per aggiungere serve `add`.
> 4. **Native mismatch**: native diversa ai due capi del trunk, quindi il traffico senza tag finisce nella VLAN sbagliata.
> 5. **SVI down**: VLAN non creata, nessuna porta attiva nella VLAN, oppure SVI ancora in `shutdown`.
> 6. **Switch L3 che non instrada**: manca `ip routing`.
> 7. **ROAS senza trunk**: la porta dello switch verso il router va messa in `mode trunk` a mano.
> 8. **Voice VLAN**: la porta resta access; la voce viaggia con tag, i dati del PC senza.

## Esercizi

> [!QUESTION]- `show interfaces trunk` mostra la VLAN 30 in "allowed on trunk" ma non in "allowed and active". Perché?
> La VLAN 30 non esiste sullo switch: va creata (`vlan 30`).

> [!QUESTION]- Lato A `dynamic auto`, lato B `dynamic auto`: cosa diventa il link?
> Access: nessuno dei due propone il trunk.

> [!QUESTION]- Un PC nella VLAN 20 non raggiunge il gateway, che è l'SVI `interface vlan 20` di uno switch L3. L'SVI è down/down. Cosa controlli?
> Che la VLAN 20 esista, che ci sia almeno una porta up nella VLAN 20 (o un trunk che la permette) e che l'SVI non sia in shutdown. Per il routing tra VLAN serve anche `ip routing`.

> [!QUESTION]- Il trunk permette 10,20. Con quale comando aggiungi la 30 senza perdere le altre?
> `switchport trunk allowed vlan add 30`

## Check da esame

- [ ] Quante subnet per VLAN? **Una**.
- [ ] Campo del tag che contiene il VLAN ID? **VID, 12 bit**.
- [ ] Dimensione del tag 802.1Q? **4 byte**.
- [ ] VLAN usabili? **1–4094**.
- [ ] Come viaggia la native VLAN sul trunk? **Senza tag**.
- [ ] Comando per la voce sulla porta di un telefono? **`switchport voice vlan <id>`**.
- [ ] Sub-interfaccia ROAS: comando del tag? **`encapsulation dot1q <vlan>`**.
- [ ] Comandi chiave dello switch L3? **`ip routing`, `interface vlan X`, `no switchport`**.

## 🎯 Synthesis

Ogni VLAN è un dominio di broadcast e una subnet. Le porte access portano una VLAN senza tag (più la voice VLAN con tag); i trunk ne portano molte con tag 802.1Q, tranne la native. Tra VLAN serve il livello 3: ROAS con sub-interfacce, oppure SVI su uno switch L3 con `ip routing`.

> [!EXAMPLE] Laboratori pratici
> - [[Day 16 Lab - VLANs (Part 1).pkt]]
> - [[Day 17 Lab - VLANs (Part 2).pkt]]
> - [[Day 18 Lab - Multilayer Switching.pkt]]
> - [[Day 19 Lab - DTP & VTP.pkt]]
> - [[Day 46 Lab - Voice VLANs.pkt]]
