---
tags: [ccna, exam, fondamenti, troubleshooting]
priorita: medio
dominio: Network Fundamentals
blueprint: 1.3, 1.4, 1.1.h
stato: da-ripassare
---

> [!ABSTRACT] Cosa serve per l'esame
> Blueprint **1.3** (tipi di interfaccia e di cavo: fibra single-mode e multimode, rame; Ethernet su mezzo condiviso e punto-punto), **1.4** (problemi di interfacce e cavi: collisioni, errori, duplex e velocità diversi) e **1.1.h** (PoE).
> Devi saper scegliere il cavo giusto per una distanza, conoscere gli standard Ethernet, capire l'autonegoziazione, leggere stato e contatori di `show interfaces` e riconoscere un duplex mismatch.

## 1. Standard Ethernet su rame

| Velocità | Nome | Standard IEEE | Cavo | Distanza |
| :--- | :--- | :--- | :--- | :--- |
| 10 Mbit/s | Ethernet | 802.3i | **10BASE-T** | 100 m |
| 100 Mbit/s | Fast Ethernet | 802.3u | **100BASE-TX** | 100 m |
| 1 Gbit/s | Gigabit Ethernet | 802.3ab | **1000BASE-T** | 100 m |
| 10 Gbit/s | 10 Gigabit Ethernet | 802.3an | **10GBASE-T** | 100 m |

Nel nome: il numero è la velocità in Mbit/s, BASE = baseband, la lettera finale il mezzo (**T** = doppino di rame).

## 2. Rame e fibra

| | Rame (UTP) | Fibra multimode (MMF) | Fibra single-mode (SMF) |
| :--- | :--- | :--- | :--- |
| Segnale | elettrico | luce, da LED o laser VCSEL | luce, da **laser** |
| Nucleo | 8 fili in 4 coppie intrecciate | largo (50 o 62,5 µm) | **sottile** (circa 9 µm) |
| Distanza | **100 m** | **centinaia di metri** | **chilometri** |
| Costo | basso | medio | alto |
| Interferenze elettromagnetiche | **sensibile** | immune | immune |
| Uso tipico | PC e telefoni verso lo switch | dentro un edificio o un campus | tra edifici, WAN, provider |

Standard in fibra frequenti: 1000BASE-SX e 10GBASE-SR (multimode, corte distanze), 1000BASE-LX e 10GBASE-LR (single-mode, circa 10 km), 10GBASE-ER (single-mode, 30-40 km). La S sta per short, la L per long.

- La fibra usa **due fibre**, una per trasmettere e una per ricevere.
- Le porte **SFP** accolgono moduli intercambiabili (fibra multimode, single-mode o rame) sulla stessa porta.
- Categorie di rame: **Cat5e** per 1 Gbit/s, **Cat6a** per 10 Gbit/s a 100 m.

### Cavi dritti e incrociati

Con 10BASE-T e 100BASE-TX si usano due coppie:

| Dispositivi | Trasmettono sui pin | Ricevono sui pin |
| :--- | :--- | :--- |
| Router, PC, firewall, server | 1 e 2 | 3 e 6 |
| Switch, hub | 3 e 6 | 1 e 2 |

- **Straight-through** (dritto, pin 1 su pin 1): tra dispositivi di gruppi **diversi** (PC ↔ switch, router ↔ switch).
- **Crossover** (incrociato, 1-2 su 3-6): tra dispositivi dello **stesso** gruppo (switch ↔ switch, router ↔ router, PC ↔ PC, PC ↔ router).
- 1000BASE-T e superiori usano **tutte e 4 le coppie** in entrambe le direzioni.
- **Auto-MDIX**: la porta riconosce il cavo e scambia da sola i pin. Con auto-MDIX va bene qualsiasi cavo.

## 3. Mezzo condiviso e punto-punto

| | Mezzo condiviso | Punto-punto |
| :--- | :--- | :--- |
| Esempio | hub, vecchio cavo coassiale | porta di uno switch verso un host o un altro switch |
| Duplex | **half duplex**: o trasmetti o ricevi | **full duplex**: entrambi insieme |
| Accesso al mezzo | **CSMA/CD**: ascolta prima di trasmettere, e se c'è una collisione si ferma e riprova dopo un tempo casuale | non serve: niente collisioni |
| Dominio di collisione | uno per tutti gli host | uno per porta (in pratica nessuna collisione) |

## 4. Velocità, duplex e autonegoziazione

Di default le porte negoziano velocità e duplex (`speed auto`, `duplex auto`) e scelgono il massimo che entrambe supportano.

Se una porta è fissata a mano e l'altra è in auto, la negoziazione non avviene. La porta in auto:

- **rileva la velocità** dal segnale;
- per il **duplex** usa: **half** se la velocità è 10 o 100 Mbit/s, **full** se è 1000 o più.

Esempio classico: un lato `speed 100` e `duplex full`, l'altro in auto. Il lato in auto rileva 100 Mbit/s e sceglie **half duplex**: si crea un **duplex mismatch**.

> [!WARNING] Duplex mismatch
> Il link resta **up/up**, ma è lentissimo e perde pacchetti.
> - Il lato **half** vede **late collisions** (e collisioni): rileva traffico mentre trasmette.
> - Il lato **full** vede **CRC** e **runts**: riceve frame interrotti a metà.
> Soluzione: lasciare entrambi in auto, oppure fissare velocità e duplex su entrambi i lati.

Se è sbagliata la **velocità** (es. 100 da un lato, 1000 fisso dall'altro), il link non sale affatto (down/down).

## 5. Stato dell'interfaccia

```ios
R1# show ip interface brief
Interface            IP-Address      OK? Method Status                Protocol
GigabitEthernet0/0   10.0.0.1        YES manual up                    up
GigabitEthernet0/1   10.0.1.1        YES manual administratively down down
GigabitEthernet0/2   unassigned      YES unset  down                  down
```

| Status / Protocol | Significato |
| :--- | :--- |
| up / up | funziona |
| **administratively down** / down | c'è `shutdown` sull'interfaccia |
| **down / down** | problema **fisico**: cavo, modulo SFP, porta remota spenta, velocità diverse |
| **up / down** | livello 1 ok, livello 2 no: incapsulamento diverso o keepalive (sulle seriali, anche il clock) |
| **err-disabled** (su uno switch) | spenta da una protezione (port security, BPDU guard): `shutdown` e `no shutdown` dopo aver tolto la causa |

## 6. Contatori di errore

```ios
SW1# show interfaces g0/1
GigabitEthernet0/1 is up, line protocol is up (connected)
  Full-duplex, 100Mb/s, media type is 10/100/1000BaseTX
  ...
     5 runts, 0 giants, 0 throttles
     312 input errors, 298 CRC, 0 frame, 0 overrun, 0 ignored
     ...
     0 output errors, 0 collisions, 0 interface resets
     0 late collision, 0 deferred
```

| Contatore | Cosa significa | Cause tipiche |
| :--- | :--- | :--- |
| **Runts** | frame sotto i **64 byte** | collisioni, duplex mismatch |
| **Giants** | frame sopra i **1518 byte** | MTU diversi, jumbo frame non supportati |
| **CRC** | frame con FCS sbagliata (corrotti) | cavo danneggiato, interferenze, **duplex mismatch** (lato full) |
| Input errors | il totale degli errori in ingresso (runts, giants, CRC…) | |
| **Collisions** | collisioni | normali solo in half duplex |
| **Late collisions** | collisioni dopo i primi 64 byte | **duplex mismatch** (lato half), cavo troppo lungo |
| Output errors | frame non trasmessi | |

Nell'esempio: full duplex a 100 Mbit/s, molti CRC e qualche runt. È il lato full di un duplex mismatch (o un cavo danneggiato).

## 7. PoE

Lo switch (**PSE**, power sourcing equipment) alimenta il dispositivo (**PD**, powered device: telefono IP, AP, telecamera) sullo stesso cavo Ethernet.

| Nome | Standard | Potenza per porta |
| :--- | :--- | :--- |
| PoE | 802.3af | 15,4 W |
| **PoE+** | 802.3at | 30 W |
| UPoE / UPoE+ | 802.3bt | 60 W / 100 W (usa 4 coppie) |

Prima di alimentare, lo switch verifica che dall'altra parte ci sia un dispositivo PoE e quanta potenza gli serve. Il **power policing** controlla che il dispositivo non assorba più del previsto: se succede, la porta va in err-disabled o viene registrato un messaggio.

```ios
! Default: alimenta se trova un dispositivo PoE
SW1(config)# interface g0/1
SW1(config-if)# power inline auto

! Non alimentare mai su questa porta
SW1(config-if)# power inline never

! Potenza disponibile, usata e per porta
SW1# show power inline
```

## 8. Comandi

```ios
! Velocità e duplex fissati (vanno fissati su entrambi i lati)
SW1(config)# interface g0/1
SW1(config-if)# speed 100
SW1(config-if)# duplex full
SW1(config-if)# description Uplink verso R1

! Porta, stato, VLAN, duplex e velocità di tutte le interfacce dello switch
SW1# show interfaces status

! Solo gli errori, per tutte le porte
SW1# show interfaces counters errors

! Azzera i contatori, per vedere se gli errori aumentano ancora
SW1# clear counters g0/1
```

## ⚠️ Trappole d'esame

> [!WARNING] Gli errori più frequenti
> 1. **up/up non significa tutto ok**: con un duplex mismatch il link è su ma perde pacchetti.
> 2. **Lato half e lato full**: late collisions sul lato half, CRC e runts sul lato full.
> 3. **Autonegoziazione contro porta fissa**: il lato auto sceglie half duplex a 10/100 Mbit/s.
> 4. **Collisioni e late collisions**: le prime sono normali in half duplex, le seconde sono sempre un problema.
> 5. **Distanze**: rame 100 m; multimode centinaia di metri; single-mode chilometri.
> 6. **Single-mode e multimode**: il single-mode ha il nucleo più sottile e usa un laser.
> 7. **down/down e up/down**: il primo è fisico, il secondo di livello 2.

## Esercizi

> [!QUESTION]- Due edifici distano 5 km. Che cavo usi?
> Fibra single-mode (es. 1000BASE-LX o 10GBASE-LR).

> [!QUESTION]- SW1 ha `speed 100` e `duplex full`, SW2 è in auto. Cosa succede, e che contatori vedi?
> SW2 rileva 100 Mbit/s e sceglie half duplex: duplex mismatch. SW2 (half) vede late collisions; SW1 (full) vede CRC e runts.

> [!QUESTION]- Un'interfaccia è `down/down` e il cavo è collegato. Tre possibili cause?
> Cavo guasto, porta remota spenta o in errore, velocità fissate diverse ai due lati (o modulo SFP sbagliato).

> [!QUESTION]- Colleghi due switch vecchi senza auto-MDIX. Che cavo serve?
> Crossover (dispositivi dello stesso gruppo).

> [!QUESTION]- `show interfaces` mostra molti giants. Che causa cerchi?
> MTU diversi tra i due lati (o jumbo frame che la porta non accetta).

## Check da esame

- [ ] Distanza massima del rame UTP? **100 m**.
- [ ] Fibra per lunghe distanze? **Single-mode**.
- [ ] Standard di PoE+? **802.3at, 30 W**.
- [ ] Contatore tipico del lato half in un duplex mismatch? **Late collisions**.
- [ ] Frame più corto di 64 byte? **Runt**. Più lungo di 1518? **Giant**.
- [ ] Interfaccia `administratively down`? **C'è `shutdown`**.
- [ ] Metodo di accesso del mezzo condiviso? **CSMA/CD**.

## 🎯 Synthesis

Rame fino a 100 m, multimode per centinaia di metri, single-mode (laser, nucleo sottile) per chilometri. Il mezzo condiviso è half duplex con CSMA/CD, il punto-punto full duplex. Se un lato è fisso e l'altro in auto, il lato auto sceglie half duplex a 10/100 Mbit/s: duplex mismatch, con late collisions sul lato half e CRC/runts sul lato full, anche con il link up/up. down/down è un problema fisico, up/down di livello 2. Il PoE alimenta i dispositivi dallo switch (802.3af 15,4 W, 802.3at 30 W, 802.3bt fino a 100 W).

Approfondimenti: [[Day 2 - Interfaces and Cables]]
