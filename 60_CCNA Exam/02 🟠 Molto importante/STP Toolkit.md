---
tags: [ccna, exam]
priorita: molto-importante
stato: da-ripassare
---

> [!ABSTRACT] Cosa serve per l'esame
> Blueprint **2.5.c** (PortFast) e **2.5.d** (Root Guard, Loop Guard, BPDU Filter, BPDU Guard).
> Per ogni strumento devi sapere su quale porta va, cosa lo fa scattare, in che stato mette la porta e come si torna alla normalità. Le basi di STP sono in [[STP (802.1D) & Rapid-PVST+ (802.1w)]].

## 1. La mappa

| Strumento | Dove va | Scatta quando | Effetto | Ritorno alla normalità |
| :--- | :--- | :--- | :--- | :--- |
| **PortFast** | porte verso host | — | la porta va subito in forwarding | — |
| **BPDU Guard** | porte verso host (con PortFast) | arriva **una qualsiasi** BPDU | **err-disabled** (spenta) | manuale, o errdisable recovery |
| **BPDU Filter** | quasi mai | — | smette di inviare (e ricevere) BPDU | — |
| **Root Guard** | porte verso switch non fidati | arriva una BPDU **migliore** (un aspirante root) | **root-inconsistent** (bloccata, ma up) | automatico, quando le BPDU migliori smettono |
| **Loop Guard** | root port e porte bloccate | **smettono di arrivare** le BPDU | **loop-inconsistent** (bloccata) | automatico, quando le BPDU tornano |

La regola d'oro: verso gli host **PortFast + BPDU Guard**; verso uno switch che non controlli **Root Guard**; sui link tra switch che ricevono BPDU **Loop Guard**.

## 2. PortFast

Una porta normale impiega 30 s (listening + learning) prima di inoltrare: abbastanza perché un PC non riceva in tempo l'indirizzo dal DHCP. **PortFast** salta questi stati e porta subito la porta in forwarding.

- Solo su porte verso **host** (PC, stampanti, server): gli host non generano BPDU, quindi non possono creare loop.
- **Mai tra switch**: un loop si formerebbe prima che STP possa bloccarlo.
- In RSTP una porta PortFast è una **edge port**.
- Su un trunk verso un router (ROAS) o un server di virtualizzazione si usa `spanning-tree portfast trunk`.

## 3. BPDU Guard

Protegge le porte PortFast: se qualcuno ci collega uno switch, la porta riceve una BPDU e viene messa subito in **err-disabled**.

Per riattivarla: rimuovere la causa, poi `shutdown` e `no shutdown`. Oppure si configura il ripristino automatico (`errdisable recovery`).

## 4. BPDU Filter

Impedisce alla porta di inviare BPDU. Si comporta in modo molto diverso a seconda di dove lo attivi:

| Attivato | Comportamento |
| :--- | :--- |
| **Globale** (`portfast bpdufilter default`) | sulle porte PortFast non manda BPDU, ma se ne **riceve** una toglie filtro e PortFast e torna una porta STP normale. Più sicuro. |
| **Sull'interfaccia** (`bpdufilter enable`) | non manda e **ignora** le BPDU ricevute: STP è di fatto **spento** su quella porta. Pericoloso. |

Con il filtro sull'interfaccia, BPDU Guard non scatta mai: le BPDU vengono scartate prima che la protezione le veda.

## 5. Root Guard

Serve a impedire che uno switch esterno (di un cliente, di un altro reparto) diventi root e stravolga i percorsi. Su una porta con Root Guard, se arriva una BPDU **superiore**, la porta va in **root-inconsistent**: non inoltra, ma resta up. Torna normale da sola quando le BPDU superiori smettono.

Si mette sulle porte **designated** verso switch che non devono diventare root.

## 6. Loop Guard

Protegge dai **link unidirezionali**, tipici della fibra (un filo trasmette, l'altro no). Una porta bloccata che smette di ricevere BPDU crede che il link sia libero e passa in forwarding: si crea un loop. Con Loop Guard, invece, la porta va in **loop-inconsistent** e resta bloccata finché le BPDU non tornano.

Si mette sulle porte che **devono ricevere** BPDU: root port e porte alternate/bloccate.

Root Guard e Loop Guard sono **mutuamente esclusivi** sulla stessa porta.

| | Root Guard | Loop Guard |
| :--- | :--- | :--- |
| Reagisce a | BPDU **migliori** | BPDU **assenti** |
| Protegge | la scelta del root | da link unidirezionali |
| Porte | designated | root e alternate |
| Stato | root-inconsistent | loop-inconsistent |

## 7. Configurazione e verifica

```ios
! Su una porta verso un PC
SW1(config)# interface g0/5
SW1(config-if)# spanning-tree portfast
SW1(config-if)# spanning-tree bpduguard enable

! Oppure in globale: PortFast su tutte le porte access, BPDU Guard su tutte quelle PortFast
SW1(config)# spanning-tree portfast default
SW1(config)# spanning-tree portfast bpduguard default

! Riattivazione automatica delle porte spente da BPDU Guard (default dopo 300 s)
SW1(config)# errdisable recovery cause bpduguard

! Root Guard su una porta verso uno switch non fidato
SW1(config)# interface g0/24
SW1(config-if)# spanning-tree guard root

! Loop Guard su una porta, oppure in globale
SW1(config)# interface g0/23
SW1(config-if)# spanning-tree guard loop
SW1(config)# spanning-tree loopguard default

! BPDU Filter: sull'interfaccia (sconsigliato) o in globale sulle porte PortFast
SW1(config-if)# spanning-tree bpdufilter enable
SW1(config)# spanning-tree portfast bpdufilter default
```

```ios
! Ruoli e stati, con "Edge" sulle porte PortFast
SW1# show spanning-tree

! Dettaglio di una porta: PortFast, BPDU Guard, BPDU inviate e ricevute
SW1# show spanning-tree interface g0/5 detail

! Porte bloccate da Root Guard o Loop Guard
SW1# show spanning-tree inconsistentports

! Porte err-disabled e la causa
SW1# show interfaces status err-disabled
```

## ⚠️ Trappole d'esame

> [!WARNING] Gli errori più frequenti
> 1. **BPDU Guard e Root Guard**: BPDU Guard **spegne** la porta (err-disabled, serve un intervento); Root Guard la **blocca** e si ripristina da sola.
> 2. **PortFast tra switch**: rischio di loop. Solo verso host.
> 3. **Cosa fa scattare cosa**: BPDU Guard qualsiasi BPDU; Root Guard una BPDU migliore; Loop Guard la mancanza di BPDU.
> 4. **BPDU Filter sull'interfaccia**: disattiva STP sulla porta, e BPDU Guard non scatta più.
> 5. **Root Guard e Loop Guard** non vanno sulla stessa porta.

## Esercizi

> [!QUESTION]- Un utente collega uno switch di casa alla presa della sua scrivania, che ha PortFast e BPDU Guard. Cosa succede?
> Lo switch di casa manda BPDU: la porta va in err-disabled. Per riattivarla: togliere lo switch, poi `shutdown` / `no shutdown`, oppure aspettare l'errdisable recovery se configurato.

> [!QUESTION]- La porta verso lo switch di un cliente riceve una BPDU con priorità 0. C'è Root Guard. In che stato va?
> Root-inconsistent: bloccata ma up. Torna forwarding da sola quando quelle BPDU smettono.

> [!QUESTION]- Su un link in fibra un filo si rompe: la porta alternate di SW3 non riceve più BPDU. Senza protezioni cosa succede? E con Loop Guard?
> Senza: la porta passa in forwarding e crea un loop. Con Loop Guard: va in loop-inconsistent e resta bloccata.

## Check da esame

- [ ] Strumento che spegne una porta PortFast se riceve BPDU? **BPDU Guard**.
- [ ] Stato in cui va la porta con BPDU Guard? **Err-disabled**.
- [ ] Strumento che impedisce a uno switch esterno di diventare root? **Root Guard**.
- [ ] Protezione contro i link unidirezionali? **Loop Guard**.
- [ ] Comando per PortFast su tutte le porte access? **`spanning-tree portfast default`**.
- [ ] PortFast in RSTP si chiama? **Edge port**.

## 🎯 Synthesis

Verso gli host: PortFast (subito in forwarding) più BPDU Guard (err-disabled se arriva una BPDU). Verso switch non fidati: Root Guard (blocca chi vuole diventare root). Sui link tra switch: Loop Guard (blocca se smettono di arrivare BPDU). BPDU Filter sull'interfaccia spegne STP: quasi mai.

> [!EXAMPLE] Laboratori pratici
> - [[Day 21 Lab - Configuring Spanning Tree.pkt]]
