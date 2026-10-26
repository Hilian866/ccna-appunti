---
tags: [ccna, exam, ospf]
priorita: critico
dominio: IP Connectivity
stato: da-ripassare
---

> [!ABSTRACT] Cosa serve per l'esame
> Blueprint **3.4**: configurare e verificare OSPFv2 in una sola area. I sottopunti sono **adiacenze** (a), reti **point-to-point** (b), reti **broadcast** con elezione **DR/BDR** (c) e **Router ID** (d).
> Devi saper attivare OSPF sulle interfacce, prevedere Router ID, DR e BDR, calcolare il costo di un percorso, sapere perché due router non diventano vicini e leggere `show ip ospf neighbor`.

## 1. Come funziona un protocollo link-state

OSPF (Open Shortest Path First) è **link-state**: ogni router si costruisce la mappa completa della rete e da lì calcola i percorsi. In tre passi:

1. **Vicini**: i router sullo stesso segmento si scoprono con i pacchetti Hello.
2. **Flooding degli LSA**: ognuno descrive i propri link in LSA (Link-State Advertisement) e li inoltra a tutti. Alla fine ogni router dell'area ha lo **stesso LSDB** (Link-State Database, la mappa).
3. **SPF**: ogni router esegue l'algoritmo di Dijkstra sul LSDB e mette in tabella i percorsi a costo minimo.

- **Versioni**: OSPFv2 è per IPv4 (quello del CCNA), OSPFv3 per IPv6.
- In tabella le rotte hanno il codice `O` e **AD 110**. Usa il protocollo IP 89.

### Aree

Un'area è un gruppo di router che condividono lo stesso LSDB. Il CCNA chiede solo OSPF **single area**, ma i termini vanno riconosciuti.

- **Area 0** (backbone): tutte le altre aree devono collegarsi a lei.
- **Internal router**: tutte le interfacce nella stessa area.
- **ABR** (Area Border Router): interfacce in più aree, con un LSDB per area.
- **ASBR** (AS Boundary Router): porta in OSPF rotte esterne, per esempio la default verso Internet.

Due interfacce nella stessa subnet devono stare nella stessa area, altrimenti non diventano vicine.

## 2. Router ID (3.4.d)

Il Router ID (RID) è un numero a 32 bit scritto come un IP: identifica il router in OSPF e decide gli spareggi nell'elezione del DR. Ordine di scelta:

1. il comando **`router-id`** (il metodo consigliato);
2. l'IP più alto tra le **loopback**;
3. l'IP più alto tra le **interfacce fisiche** attive.

La loopback è sempre up (salvo `shutdown`), quindi dà un RID stabile. Un RID cambiato entra in uso solo dopo un reload o `clear ip ospf process`.

## 3. Vicini e adiacenze (3.4.a)

I router mandano gli Hello ogni 10 secondi a **224.0.0.5**. Se per 40 secondi (dead timer, 4 volte l'hello) non ricevono nulla, considerano il vicino caduto.

### Cosa deve coincidere

| Deve combaciare | Se non combacia |
| :--- | :--- |
| Area | nessun vicino |
| Subnet (stessa rete e maschera) | nessun vicino |
| Hello e dead timer | nessun vicino |
| Autenticazione | nessun vicino |
| Router ID **univoco** (diverso tra i due) | con RID duplicato nessun vicino |
| Processo OSPF non in `shutdown` | nessun vicino |
| MTU | vicini bloccati in ExStart/Exchange, mai FULL |
| Network type | può arrivare FULL ma con rotte mancanti |

Il **process ID** (`router ospf 1`) invece **non** deve coincidere: vale solo sul router locale.

### Stati

**Down → Init → 2-Way → ExStart → Exchange → Loading → Full**

| Stato | Cosa succede |
| :--- | :--- |
| Down | nessun Hello ricevuto |
| Init | ricevo i suoi Hello, ma lui non elenca ancora il mio RID |
| 2-Way | ci vediamo a vicenda; qui si elegge il DR/BDR |
| ExStart | si decide chi è master (RID più alto) per lo scambio |
| Exchange | ci scambiamo i DBD, cioè l'elenco degli LSA che abbiamo |
| Loading | chiedo (LSR) e ricevo (LSU) gli LSA che mi mancano |
| Full | LSDB sincronizzati: adiacenza completa |

- **Vicino** (neighbor) = relazione fino a 2-Way.
- **Adiacenza** = relazione arrivata a FULL.

| Pacchetto OSPF | Tipo | Uso |
| :--- | :--- | :--- |
| Hello | 1 | scopre e mantiene i vicini |
| DBD (Database Description) | 2 | riassunto del LSDB |
| LSR (Link-State Request) | 3 | chiede gli LSA mancanti |
| LSU (Link-State Update) | 4 | contiene gli LSA |
| LSAck | 5 | conferma la ricezione |

## 4. Tipi di rete: broadcast e point-to-point (3.4.b, 3.4.c)

| | Broadcast | Point-to-point |
| :--- | :--- | :--- |
| Default su | Ethernet | seriali (HDLC, PPP) |
| DR/BDR | sì, uno per segmento | no |
| Chi arriva a FULL | DR e BDR con tutti | i due router tra loro |
| Hello/dead | 10/40 s | 10/40 s |

Il tipo **non-broadcast** (NBMA: timer 30/120 s e vicini configurati a mano) non è richiesto.

Su un link Ethernet tra due soli router l'elezione è inutile: `ip ospf network point-to-point` la elimina e l'adiacenza si forma prima. Va configurato **su entrambi i lati**.

### Elezione DR/BDR

Su un segmento broadcast con molti router, se ognuno facesse FULL con tutti gli LSA si moltiplicherebbero. Il **DR** (Designated Router) fa da centro di raccolta, il **BDR** è la sua riserva.

1. Vince la **priorità** di interfaccia più alta (default 1, range 0–255). Con priorità **0** il router non diventa mai DR né BDR.
2. A parità di priorità vince il **Router ID** più alto.
3. Il secondo classificato diventa BDR; gli altri sono **DROther**.

- **Non preemptive**: un router "più forte" aggiunto dopo non scalza il DR. Il DR cambia solo se cade (allora il BDR diventa DR e si elegge un nuovo BDR) o se si riavvia il processo OSPF.
- Tra due DROther l'adiacenza resta **2-Way**: è normale, non è un guasto.
- I DROther mandano gli aggiornamenti a **224.0.0.6** (solo DR e BDR); il DR li ridistribuisce a **224.0.0.5** (tutti).
- **Type 2 LSA**: lo genera il DR ed elenca i router del segmento.

## 5. Il costo (metrica)

**Costo = reference bandwidth / bandwidth dell'interfaccia** (i risultati sotto 1 diventano 1).

Il **costo di una rotta** è la somma dei costi delle interfacce di **uscita** lungo il percorso, compresa quella del router che ha la rete di destinazione.

| Interfaccia | Reference 100 Mbps (default) | Reference 100.000 Mbps |
| :--- | :--- | :--- |
| 10 Mbps | 10 | 10.000 |
| FastEthernet 100 Mbps | 1 | 1.000 |
| Gigabit 1 Gbps | 1 | 100 |
| 10 Gbps | 1 | 10 |

Con il default FastEthernet, Gigabit e 10G costano tutti 1: OSPF non li distingue. Si alza la reference **su tutti i router** con `auto-cost reference-bandwidth`. In alternativa si forza il costo di un'interfaccia con `ip ospf cost`; il comando `bandwidth` funziona ma è sconsigliato, perché influisce anche su altri protocolli.

## 6. Configurazione

```ios
R1(config)# router ospf 1

! RID manuale: il metodo consigliato
R1(config-router)# router-id 1.1.1.1

! Reference a 100 Gbps (valore in Mbps), uguale su tutti i router
R1(config-router)# auto-cost reference-bandwidth 100000

! Attiva OSPF sulle interfacce con IP in questo range (non "annuncia" la rete)
R1(config-router)# network 10.0.12.0 0.0.0.3 area 0

! Niente Hello verso la LAN dei PC, ma la sua rete viene comunque annunciata
R1(config-router)# passive-interface g0/1

! Propaga in OSPF la default statica di questo router (che diventa ASBR)
R1(config-router)# default-information originate
```

Il comando `network` usa la wildcard e **seleziona le interfacce** il cui IP rientra nel range: lì attiva OSPF nell'area indicata. `network 10.0.12.1 0.0.0.0 area 0` sceglie un'interfaccia precisa; `network 0.0.0.0 255.255.255.255 area 0` le prende tutte.

```ios
! Alternativa a "network": OSPF attivato direttamente sull'interfaccia
R1(config)# interface g0/0
R1(config-if)# ip ospf 1 area 0

! Priorità per l'elezione (0 = mai DR/BDR)
R1(config-if)# ip ospf priority 0

! Niente DR/BDR su un link tra due router (su entrambi i lati)
R1(config-if)# ip ospf network point-to-point

! Costo forzato su questa interfaccia
R1(config-if)# ip ospf cost 10
```

```ios
! Tutte passive, poi riattivi solo le interfacce verso altri router
R1(config-router)# passive-interface default
R1(config-router)# no passive-interface g0/0

! Applica un nuovo Router ID (azzera le adiacenze)
R1# clear ip ospf process
```

## 7. Verifica

```ios
! Vicini, stato e ruolo: il comando più importante
R1# show ip ospf neighbor

! Per interfaccia: area, costo, stato (DR/BDR/DROTH/P2P), vicini FULL/totali
R1# show ip ospf interface brief

! RID, network configurate, interfacce passive, AD
R1# show ip protocols

! Solo le rotte OSPF; il LSDB
R1# show ip route ospf
R1# show ip ospf database
```

```text
Neighbor ID   Pri  State          Dead Time  Address      Interface
2.2.2.2         1  FULL/DR        00:00:35   10.0.123.2   GigabitEthernet0/1
3.3.3.3         1  2WAY/DROTHER   00:00:38   10.0.123.3   GigabitEthernet0/1
4.4.4.4         0  FULL/  -       00:00:32   10.0.14.4    GigabitEthernet0/2
```

- `FULL/DR`: adiacenza completa con il DR del segmento.
- `2WAY/DROTHER`: due DROther tra loro; normale.
- `FULL/  -`: link point-to-point, quindi nessun DR.

`O*E2 0.0.0.0/0` sugli altri router indica la default propagata con `default-information originate`.

## 8. Tipi di LSA

| Tipo | Nome | Chi lo genera | Cosa descrive |
| :--- | :--- | :--- | :--- |
| 1 | Router | ogni router | se stesso (RID) e i suoi link |
| 2 | Network | il **DR** | i router collegati a un segmento broadcast |
| 3 | Summary | l'ABR | rotte di altre aree (multi-area) |
| 5 | AS External | l'**ASBR** | rotte esterne a OSPF, come la default |

Per il single-area contano soprattutto 1 e 2; il 5 compare con `default-information originate`.

## ⚠️ Trappole d'esame

> [!WARNING] Gli errori più frequenti
> 1. **Process ID diverso** non impedisce l'adiacenza: è locale.
> 2. **Bloccati in ExStart/Exchange**: quasi sempre MTU diversa.
> 3. **2-Way tra DROther**: normale, non è un guasto.
> 4. **Preemption**: alzare la priorità non cambia un DR già eletto.
> 5. **Priorità 0**: il router non sarà mai DR né BDR (ma forma comunque vicini).
> 6. **`network` = annuncio?** No: seleziona le interfacce su cui attivare OSPF.
> 7. **Passive-interface**: blocca gli Hello, non l'annuncio della rete.
> 8. **Reference bandwidth**: con il default 100 Mbps tutte le interfacce da 100 Mbps in su costano 1. Va cambiata su tutti i router.
> 9. **RID cambiato ma non applicato**: serve `clear ip ospf process` o un reload.

## Esercizi

> [!QUESTION]- R1 non ha `router-id`, ha Loopback0 10.1.1.1 e G0/0 192.168.1.1. Qual è il suo RID?
> 10.1.1.1: la loopback viene prima delle fisiche, anche se il suo IP è più basso.

> [!QUESTION]- Su un segmento Ethernet: R1 (priorità 1, RID 1.1.1.1), R2 (priorità 1, RID 2.2.2.2), R3 (priorità 0, RID 3.3.3.3). Chi è DR e chi BDR?
> R3 è escluso (priorità 0). Tra R1 e R2 la priorità è uguale, quindi decide il RID: DR R2, BDR R1. R3 è DROther.

> [!QUESTION]- Reference 100.000 Mbps. Da R1 alla rete 10.0.3.0/24 (attaccata a una Gigabit di R3) ci sono due strade: R1→R2→R3 su due Gigabit, oppure R1→R3 su una FastEthernet. Quale sceglie?
> Via R2: 100 + 100 + 100 (LAN di R3) = **300**.
> Diretta: 1.000 + 100 = **1.100**. Vince il percorso via R2.

> [!QUESTION]- Due router collegati hanno hello 10 e hello 5. In che stato restano?
> Nessuna adiacenza: con timer diversi gli Hello vengono scartati, quindi non diventano vicini.

> [!QUESTION]- Cosa attiva `network 10.0.0.0 0.255.255.255 area 0`?
> OSPF in area 0 su tutte le interfacce con IP che inizia per 10.

## Check da esame

- [ ] AD di OSPF? **110**.
- [ ] Ordine di scelta del RID? **`router-id`, loopback più alta, fisica più alta**.
- [ ] Hello e dead su Ethernet? **10 e 40 secondi**.
- [ ] Multicast di tutti i router OSPF e di DR/BDR? **224.0.0.5 e 224.0.0.6**.
- [ ] Criteri per il DR? **Priorità più alta, poi RID più alto**.
- [ ] Ordine degli stati? **Down, Init, 2-Way, ExStart, Exchange, Loading, Full**.
- [ ] Formula del costo e reference di default? **Reference / bandwidth, 100 Mbps**.
- [ ] Chi genera il Type 2 LSA? **Il DR**.
- [ ] Su un link point-to-point c'è il DR? **No**.

## 🎯 Synthesis

I router OSPF diventano vicini solo se area, subnet, timer e autenticazione coincidono; poi sincronizzano il LSDB fino a FULL e scelgono il percorso a costo minimo (ricordati di alzare la reference bandwidth). Su Ethernet si elegge un DR (priorità, poi RID) che non viene scalzato; sui link point-to-point non serve.

> [!EXAMPLE] Laboratori pratici
> - [[Day 26 Lab - OSPF (Part 1).pkt]]
> - [[Day 27 Lab - OSPF (Part 2).pkt]]
> - [[Day 28 Lab - OSPF (Part 3).pkt]]
