---
tags: [ccna, exam]
priorita: medio
stato: da-ripassare
---

> [!ABSTRACT] Cosa serve per l'esame
> Blueprint **2.4**: configurare e verificare EtherChannel Layer 2 e Layer 3 con LACP.
> Devi sapere perché serve, quali combinazioni di modalità formano il canale (LACP, PAgP, statico), cosa deve coincidere tra le porte, come si bilancia il traffico e come si legge `show etherchannel summary`. Le basi di STP sono in [[STP (802.1D) & Rapid-PVST+ (802.1w)]].

## 1. Il problema

Tra due switch colleghi più cavi per avere più banda. Ma più link paralleli formano un loop, e STP li blocca tutti **tranne uno**: la banda in più resta inutilizzata.

Un **EtherChannel** raggruppa fino a **8** porte fisiche in un'unica interfaccia logica, il **port-channel**. STP vede un solo link e non blocca niente:

- la banda si somma (4 link da 1 Gbit/s = 4 Gbit/s complessivi);
- se un cavo si rompe il canale resta su, con un link in meno, senza attendere STP.

## 2. Bilanciamento del carico

Il traffico non viene diviso frame per frame: lo switch calcola un hash su indirizzi del frame e manda sempre **lo stesso flusso sullo stesso link**, così i frame non arrivano in disordine.

Gli input possibili: MAC sorgente, MAC destinazione, entrambi; IP sorgente, IP destinazione, entrambi.

Conseguenza: un singolo flusso non va mai più veloce di un link. Se tutto il traffico va verso lo stesso MAC (il router) e l'hash usa solo `dst-mac`, un link solo fa tutto il lavoro: meglio `src-dst-ip` o `src-dst-mac`.

```ios
! Metodo di bilanciamento: globale, vale per tutti i port-channel
SW1(config)# port-channel load-balance src-dst-ip

! Metodo in uso
SW1# show etherchannel load-balance
```

## 3. Protocolli e modalità

| Metodo | Standard | Modalità |
| :--- | :--- | :--- |
| **LACP** | **IEEE 802.3ad** (802.1AX), multivendor | **active** (avvia la negoziazione), **passive** (risponde) |
| PAgP | Cisco | **desirable** (avvia), **auto** (risponde) |
| Statico | nessun protocollo | **on** |

Quali combinazioni formano il canale:

| Lato A | Lato B | Si forma? |
| :--- | :--- | :--- |
| active | active o passive | **sì** |
| passive | passive | **no**: nessuno avvia |
| desirable | desirable o auto | sì |
| auto | auto | no |
| on | on | sì |
| on | active o desirable | **no**: un lato non negozia |
| LACP | PAgP | no |

La regola: almeno un lato deve **avviare**, ed entrambi devono usare lo stesso protocollo. `on` va solo con `on`.

LACP è il più usato perché è standard. La modalità statica è rischiosa: se un lato è configurato male non c'è negoziazione che se ne accorga, e si può creare un loop.

## 4. Cosa deve coincidere

Tutte le porte del gruppo, su entrambi i lati, devono avere la **stessa configurazione**:

- **velocità e duplex**;
- modalità **access o trunk**;
- VLAN di accesso (se access); **VLAN permesse e native VLAN** (se trunk);
- tipo di porta: tutte switchport (Layer 2) o tutte routed (Layer 3).

Una porta diversa dalle altre viene esclusa dal canale (stato suspended). Per evitarlo, dopo aver creato il canale si configura **l'interfaccia port-channel**: le impostazioni vengono copiate sulle porte membro.

## 5. Configurazione

### Layer 2 (tra switch, come trunk)

```ios
! Porte membro: stesso gruppo, LACP active
SW1(config)# interface range g0/1 - 4
SW1(config-if-range)# channel-group 1 mode active

! Il port-channel si crea da solo: qui si configura il trunk
SW1(config)# interface port-channel 1
SW1(config-if)# switchport mode trunk
SW1(config-if)# switchport trunk allowed vlan 10,20,30
```

Sullo switch di fronte la stessa cosa, con `mode active` o `mode passive`. Il numero del gruppo è locale: non deve coincidere tra i due switch (anche se per chiarezza si usa lo stesso).

### Layer 3 (tra switch multilayer, con IP)

```ios
! Prima si rendono routed le porte, poi si crea il gruppo
SW1(config)# interface range g0/1 - 2
SW1(config-if-range)# no switchport
SW1(config-if-range)# channel-group 1 mode active

! L'indirizzo va sul port-channel, non sulle porte fisiche
SW1(config)# interface port-channel 1
SW1(config-if)# ip address 10.0.0.1 255.255.255.252
```

Un EtherChannel Layer 3 non partecipa a STP: è un link routed. Si usa nel core, tra switch multilayer che fanno routing (es. con OSPF sul port-channel).

## 6. Verifica

```ios
SW1# show etherchannel summary
Flags:  D - down        P - bundled in port-channel
        I - stand-alone s - suspended
        R - Layer3      S - Layer2
        U - in use      ...

Group  Port-channel  Protocol    Ports
------+-------------+-----------+---------------------------
1      Po1(SU)         LACP      Gi0/1(P)    Gi0/2(P)    Gi0/3(P)    Gi0/4(s)
```

- **Po1(SU)**: port-channel Layer 2 (S) e in uso (U). Uno Layer 3 sarebbe **RU**.
- **(P)**: la porta fa parte del canale.
- **(s)** suspended: la porta ha una configurazione diversa dalle altre. **(I)** stand-alone: non ha negoziato (l'altro lato non risponde o usa un altro protocollo). **(D)** down.
- **SD** sul port-channel: canale giù.

```ios
! Dettagli del port-channel e delle porte membro
SW1# show etherchannel port-channel

! Vicini LACP e loro modalità
SW1# show lacp neighbor

! STP deve mostrare Po1, non le singole porte
SW1# show spanning-tree
```

## ⚠️ Trappole d'esame

> [!WARNING] Gli errori più frequenti
> 1. **passive + passive** e **auto + auto**: nessuno avvia, il canale non si forma.
> 2. **on + active**: non si forma: `on` non negozia.
> 3. **LACP e PAgP**: LACP è standard (active/passive), PAgP è Cisco (desirable/auto).
> 4. **Configurazioni diverse** tra le porte: le porte non uguali vanno in suspended.
> 5. **Layer 3**: `no switchport` prima di `channel-group`, e l'IP sul port-channel.
> 6. **Bilanciamento**: un singolo flusso usa un solo link, non la somma della banda.

## Esercizi

> [!QUESTION]- SW1 ha `channel-group 1 mode passive`, SW2 `channel-group 1 mode passive`. Si forma il canale?
> No: entrambi aspettano che l'altro avvii la negoziazione LACP.

> [!QUESTION]- In `show etherchannel summary` vedi `Po1(SU)` con Gi0/3(s). Cosa significa per Gi0/3?
> È sospesa: la sua configurazione (es. VLAN permesse o velocità) non coincide con quella delle altre porte.

> [!QUESTION]- Uno switch multivendor deve fare EtherChannel con un Cisco. Che protocollo e che modalità sul Cisco?
> LACP, in modalità active (o passive se l'altro lato è active).

> [!QUESTION]- Un port-channel Layer 3 deve avere l'indirizzo 10.1.1.1/30. Su quale interfaccia lo configuri?
> Su `interface port-channel <n>`, dopo aver messo `no switchport` sulle porte fisiche.

## Check da esame

- [ ] Quante porte al massimo in un EtherChannel? **8 attive**.
- [ ] Modalità LACP? **Active e passive**. PAgP? **Desirable e auto**.
- [ ] Combinazione `on` valida? **Solo on + on**.
- [ ] Flag di un port-channel Layer 2 attivo? **SU**. Layer 3? **RU**.
- [ ] Il bilanciamento divide un flusso sui link? **No: un flusso, un link**.
- [ ] Comando per vedere il canale? **`show etherchannel summary`**.

## 🎯 Synthesis

EtherChannel unisce fino a 8 porte in un port-channel: STP vede un solo link, la banda si somma e un guasto non ferma il canale. LACP (standard, active/passive) o PAgP (Cisco, desirable/auto) negoziano: serve almeno un lato che avvii; `on` va solo con `on`. Le porte devono avere la stessa configurazione. Ogni flusso viaggia su un solo link scelto con un hash. In Layer 3: `no switchport` e IP sul port-channel.

> [!EXAMPLE] Laboratori pratici
> - [[Day 23 Lab - EtherChannel.pkt]]
