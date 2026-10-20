---
tags: [ccna, exam, fondamenti, troubleshooting]
priorita: medio
dominio: Network Fundamentals
blueprint: 1.3, 1.4, 1.1.h
stato: da-ripassare
---

> [!ABSTRACT] Obiettivo
> Riconoscere i tipi di cavo e di collegamento, capire il PoE e leggere i contatori di `show interfaces` per individuare guasti fisici e **duplex/speed mismatch**.

## 1. Tipi di cavo

| | **Rame (UTP)** | **Fibra multimode (MMF)** | **Fibra single-mode (SMF)** |
|---|---|---|---|
| Sorgente luce | — (segnale elettrico) | LED / VCSEL | **Laser** |
| Nucleo | 8 fili in 4 coppie | 50 µm (spesso) | **9 µm** (molto sottile) |
| Distanza | **100 m** | Centinaia di m (es. 300–550 m) | **Km** (10 km LR, 40 km ER…) |
| Costo | Basso | Medio | Alto |
| Interferenze (EMI) | **Sensibile** | Immune | Immune |
| Uso tipico | Access (PC ↔ switch) | Dentro edificio/campus | Tra edifici, WAN, provider |

- **Categorie rame**: Cat5 = 100 Mbps · **Cat5e = 1 Gbps** · Cat6 / Cat6a = 10 Gbps (Cat6a fino a 100 m).
- **Straight-through**: dispositivi di tipo diverso (PC ↔ switch, router ↔ switch). **Crossover**: dispositivi uguali (switch ↔ switch). Con **Auto-MDI/MDIX** lo switch adatta da solo la coppia, quindi in pratica va bene entrambi.
- La fibra usa **due fili** (TX e RX): un TX scollegato o invertito = link down.

## 2. Tipi di collegamento Ethernet

| | **Shared media** | **Point-to-point** |
|---|---|---|
| Esempio | Hub, rete vecchia con cavo condiviso | Link switch ↔ host / switch ↔ switch |
| Duplex | **Half-duplex** | **Full-duplex** |
| Accesso al mezzo | **CSMA/CD** (rileva le collisioni) | Non serve: nessuna collisione |
| Dominio di collisione | Un unico dominio per tutti gli host | **Uno per porta** |

## 3. PoE (Power over Ethernet)
Lo switch (**PSE**) alimenta il dispositivo (**PD**: telefono IP, AP, telecamera) sullo stesso cavo.

| Standard | Nome | Potenza alla porta (PSE) |
|---|---|---|
| 802.3af | PoE (Type 1) | **15,4 W** |
| 802.3at | **PoE+** (Type 2) | **30 W** |
| 802.3bt | PoE++ (Type 3 / 4) | **60 W / 100 W** |

```
interface g0/1
 ! default
 power inline auto

 ! disattiva
 power inline never

! potenza usata/disponibile per porta
show power inline
```

## 4. Leggere lo stato dell'interfaccia
`show ip interface brief` e `show interfaces g0/1`:

| Status / Protocol | Significato |
|---|---|
| `administratively down / down` | Porta in `shutdown` |
| `down / down` | **Problema fisico**: cavo, SFP, porta remota spenta |
| `up / down` | Livello 1 ok, **livello 2 no**: encapsulation, keepalive, clocking (seriali), speed/duplex |
| `up / up` | Operativa |
| `err-disabled` | Spenta da una funzione di protezione (Port Security, BPDU Guard…) → `shutdown` + `no shutdown` |

## 5. Errori e contatori

| Contatore | Cosa indica |
|---|---|
| **CRC** / input errors | Frame corrotti: cavo difettoso, EMI, **duplex mismatch** |
| **Runts** | Frame < 64 byte (spesso da collisioni) |
| **Giants** | Frame > 1518 byte (MTU errato, jumbo non gestiti) |
| **Collisions** | Normali solo in half-duplex |
| **Late collisions** | Collisione dopo i primi 64 byte: **duplex mismatch** o cavo troppo lungo |
| Input queue drops / overruns | Congestione o CPU sovraccarica |

> [!WARNING] Duplex mismatch
> Un lato in **full-duplex** e l'altro in **half-duplex**: il link resta *up/up* ma è lentissimo.
> Il lato half vede **late collisions**; il lato full vede **CRC/runts**.
> Causa classica: un lato fissato a mano (`speed 100` + `duplex full`) e l'altro in **auto**. In auto, il lato autonegoziante rileva la velocità ma **ripiega su half-duplex** (a 10/100 Mbps).

## 6. CLI Core

```
interface g0/1
 speed 100
 duplex full
 description Uplink verso R1

! speed, duplex, VLAN, stato
show interfaces status

! contatori dettagliati
show interfaces g0/1
show interfaces counters errors
clear counters g0/1
```

## Common Mistakes
- Pensare che **up/up** significhi "tutto ok": con un duplex mismatch c'è comunque perdita di prestazioni.
- Fissare speed/duplex solo da un lato.
- Confondere **collisioni** (normali in half-duplex) con **late collisions** (sempre un problema).
- Dimenticare che il rame è limitato a **100 m**.

## 🎯 Synthesis
Rame ≤ 100 m, multimode per il campus, single-mode per le lunghe distanze; up/up non basta: i contatori (CRC, late collision) svelano duplex e speed mismatch.

Approfondimenti: [[Day 2 - Interfaces and Cables]] · [[📑 Interfacce Seriali (Legacy WAN Basics)]]
