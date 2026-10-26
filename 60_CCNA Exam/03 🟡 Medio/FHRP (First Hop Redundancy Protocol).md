---
tags: [ccna, exam]
priorita: medio
stato: da-ripassare
---

> [!ABSTRACT] Cosa serve per l'esame
> Blueprint **3.5**: descrivere scopo, funzioni e concetti dei protocolli FHRP.
> Devi sapere quale problema risolvono, come funzionano indirizzo IP e MAC virtuali, come si elegge il router attivo, cosa fa la preemption, e le differenze tra HSRP, VRRP e GLBP (ruoli, standard, MAC virtuali, multicast, bilanciamento). La configurazione non è richiesta, ma aiuta a capire.

## 1. Il problema

Un PC ha **un solo** default gateway, scritto a mano o ricevuto dal DHCP. Se quel router si guasta, il PC non esce più dalla sua subnet, anche se c'è un secondo router funzionante: il gateway è un **single point of failure**. Cambiare il gateway su tutti i PC non è pensabile.

Un **FHRP** (first hop redundancy protocol) fa lavorare due o più router come un unico gateway **virtuale**.

## 2. Come funziona

1. I router condividono un **IP virtuale** (VIP, es. `192.168.1.254`): è il default gateway configurato sui PC.
2. Uno dei router è **attivo**: risponde alle richieste ARP per il VIP con un **MAC virtuale** e inoltra il traffico. Gli altri restano in attesa.
3. I router si scambiano messaggi **hello** in multicast. Se l'attivo smette di mandarli, un altro router prende il suo posto.
4. Il nuovo attivo manda un **gratuitous ARP**: gli switch aggiornano la tabella MAC e associano il MAC virtuale alla porta del nuovo router.

I PC **non si accorgono di niente**: VIP e MAC virtuale restano gli stessi, quindi la loro tabella ARP non cambia.

**Elezione**: vince la priorità più alta (default **100**); a parità, l'indirizzo IP più alto sull'interfaccia.

**Preemption**: se un router con priorità più alta torna online (o viene aggiunto), con la preemption attiva si riprende il ruolo di attivo. Senza, aspetta che l'attivo attuale si guasti.

## 3. I tre protocolli

| Caratteristica      | HSRP                                     | VRRP                     | GLBP                                     |
| ------------------- | ---------------------------------------- | ------------------------ | ---------------------------------------- |
| Standard            | Cisco                                    | **aperto** (IETF)        | Cisco                                    |
| Ruoli               | **active** / **standby**                 | **master** / **backup**  | **AVG** / **AVF**                        |
| Preemption          | **spenta** di default                    | **attiva** di default    | AVG spenta, AVF attiva                   |
| Bilanciamento       | no (si usano più gruppi su VLAN diverse) | no (come HSRP)           | **sì**, nella stessa subnet              |
| Multicast           | v1 `224.0.0.2`, v2 `224.0.0.102`         | `224.0.0.18`             | `224.0.0.102`                            |
| Hello / hold        | 3 s / 10 s                               | 1 s / 3 s circa          | 3 s / 10 s                               |

MAC virtuali (il numero del gruppo è in **esadecimale**):

| Protocollo | MAC virtuale | Gruppo 10 |
| :--- | :--- | :--- |
| **HSRP v1** | `0000.0c07.acXX` | `0000.0c07.ac0a` |
| **HSRP v2** | `0000.0c9f.fXXX` | `0000.0c9f.f00a` |
| **VRRP** | `0000.5e00.01XX` | `0000.5e00.010a` |
| GLBP | `0007.b400.XXYY` (XX gruppo, YY numero dell'AVF) | `0007.b400.0a01`, `0007.b400.0a02`… |

### HSRP

- **v1**: gruppi 0-255, solo IPv4. **v2**: gruppi 0-4095, supporta IPv6. Le due versioni **non comunicano** tra loro.
- Un router attivo e uno standby per gruppo; gli altri restano in ascolto.
- Per usare entrambi i router si fa bilanciamento **per VLAN**: R1 attivo per la VLAN 10, R2 per la VLAN 20.

### VRRP

- Lo standard aperto: va bene tra router di marche diverse.
- Il **master** fa da gateway. Il VIP può anche essere l'indirizzo reale di uno dei router (che diventa master).

### GLBP

- Il bilanciamento avviene **dentro la stessa subnet**.
- L'**AVG** (active virtual gateway) risponde alle richieste ARP dei PC assegnando a turno il MAC virtuale di un **AVF** diverso (active virtual forwarder, fino a 4). Così PC diversi usano router diversi come gateway, pur avendo lo stesso VIP.

## 4. Configurazione (HSRP)

```ios
! R1: deve essere l'attivo
R1(config)# interface g0/0
R1(config-if)# ip address 192.168.1.1 255.255.255.0
R1(config-if)# standby version 2
R1(config-if)# standby 1 ip 192.168.1.254
R1(config-if)# standby 1 priority 110
R1(config-if)# standby 1 preempt

! R2: standby (priorità 100 di default)
R2(config)# interface g0/0
R2(config-if)# ip address 192.168.1.2 255.255.255.0
R2(config-if)# standby version 2
R2(config-if)# standby 1 ip 192.168.1.254
R2(config-if)# standby 1 preempt
```

Sui PC il gateway è `192.168.1.254`. Versione, numero di gruppo e VIP devono coincidere sui due router.

```ios
R1# show standby brief
                     P indicates configured to preempt.
                     |
Interface   Grp  Pri P State   Active          Standby         Virtual IP
Gi0/0       1    110 P Active  local           192.168.1.2     192.168.1.254
```

- **State Active, Active local**: R1 è l'attivo.
- **Standby 192.168.1.2**: R2 è pronto a subentrare.
- `show standby` mostra anche il MAC virtuale e i timer.

Con STP: conviene che il root bridge di una VLAN sia lo stesso switch collegato al router HSRP attivo per quella VLAN, così il traffico segue il percorso più breve (lab del Day 52).

## ⚠️ Trappole d'esame

> [!WARNING] Gli errori più frequenti
> 1. **Preemption**: spenta di default in HSRP, attiva in VRRP. Senza, un router con priorità più alta che torna online non riprende il ruolo.
> 2. **Ruoli**: HSRP active/standby, VRRP master/backup, GLBP AVG/AVF.
> 3. **Standard**: solo VRRP è aperto.
> 4. **Bilanciamento**: solo GLBP bilancia nella stessa subnet; HSRP e VRRP lo fanno con gruppi diversi per VLAN.
> 5. **MAC virtuali**: il gruppo è in esadecimale (gruppo 10 = `0a`).
> 6. **Failover**: sono gli switch ad aggiornare la tabella MAC (gratuitous ARP); i PC non cambiano niente.
> 7. **HSRP v1 e v2** non sono compatibili.

## Esercizi

> [!QUESTION]- R1 (priorità 120) è attivo HSRP senza preempt. Si riavvia: R2 (priorità 100) diventa attivo. Quando R1 torna, chi è l'attivo?
> R2: senza preemption R1 non riprende il ruolo, anche con priorità più alta.

> [!QUESTION]- Un PC ha nella tabella ARP il gateway con MAC `0000.5e00.0105`. Che protocollo e che gruppo?
> VRRP, gruppo 5.

> [!QUESTION]- Che MAC virtuale ha il gruppo HSRP v1 numero 20?
> `0000.0c07.ac14` (20 in esadecimale è 14).

> [!QUESTION]- Vuoi che i PC della stessa VLAN usino due router diversi come gateway, con un solo VIP. Che protocollo?
> GLBP.

> [!QUESTION]- Due router HSRP hanno entrambi priorità 100. Uno ha IP .2, l'altro .3. Chi diventa attivo?
> Quello con IP .3: a parità di priorità vince l'IP più alto.

## Check da esame

- [ ] Problema risolto dagli FHRP? **Il default gateway come single point of failure**.
- [ ] Priorità di default? **100**; vince la più alta.
- [ ] Protocollo FHRP standard aperto? **VRRP**.
- [ ] MAC virtuale di HSRP v1? **`0000.0c07.acXX`**.
- [ ] Unico FHRP che bilancia nella stessa subnet? **GLBP**.
- [ ] Comando per lo stato di HSRP? **`show standby brief`**.

## 🎯 Synthesis

Un FHRP fa apparire più router come un unico gateway virtuale (VIP e MAC virtuale): l'attivo inoltra, gli altri subentrano se smette di mandare hello, e un gratuitous ARP aggiorna gli switch. Vince la priorità più alta (default 100), poi l'IP più alto; la preemption permette di riprendere il ruolo. HSRP (Cisco, active/standby, preemption spenta), VRRP (aperto, master/backup, preemption attiva), GLBP (Cisco, AVG/AVF, bilancia nella stessa subnet).

> [!EXAMPLE] Laboratori pratici
> - [[Day 29 Lab - HSRP Configuration.pkt]]
> - [[Day 52 Lab - STP & HSRP Synchronization.pkt]]
