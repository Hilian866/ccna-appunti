---
tags: [ccna, exam, qos]
priorita: medio
dominio: IP Services
stato: da-ripassare
---

> [!ABSTRACT] Cosa serve per l'esame
> Blueprint **4.7**: spiegare il comportamento per hop (PHB) della QoS: classificazione, marcatura, accodamento, congestione, policing e shaping.
> Non serve configurarla. Devi conoscere le quattro caratteristiche del traffico e i limiti per la voce, i campi di marcatura (PCP/CoS, DSCP) e i valori principali (EF, AF, CS), il trust boundary, i tipi di coda (CBWFQ, LLQ), tail drop e WRED, e la differenza tra policing e shaping. Voice VLAN e PoE sono in [[VLAN - Trunking & Inter-VLAN Routing]] e [[Interfacce, Cablaggio & Troubleshooting]].

## 1. Perché serve

In una rete **convergente** voce, video e dati condividono gli stessi link. Finché c'è banda libera va tutto bene; quando un link si congestiona, i pacchetti si accodano e alcuni vengono scartati. Un download può aspettare, una telefonata no. La QoS decide **chi passa prima** e **chi viene scartato** quando c'è congestione.

| Caratteristica | Cos'è | Limite per la voce |
| :--- | :--- | :--- |
| **Bandwidth** | la capacità del link (bit/s) | — |
| **Delay** (latenza) | il tempo dalla sorgente alla destinazione (one-way) | ≤ **150 ms** |
| **Jitter** | la **variazione** del delay tra un pacchetto e l'altro | ≤ **30 ms** |
| **Loss** | la percentuale di pacchetti persi | ≤ **1%** |

## 2. Classificazione e marcatura

La **classificazione** riconosce a che tipo di traffico appartiene un pacchetto. Si basa su:

- una **ACL** (indirizzi, porte, protocollo);
- **NBAR** (Network Based Application Recognition): riconosce l'applicazione guardando dentro il pacchetto, fino al livello applicazione;
- una **marcatura** già presente nell'header.

La **marcatura** scrive la classe in un campo dell'header, così i dispositivi successivi non devono ripetere la classificazione.

| Livello | Campo | Bit | Valori |
| :--- | :--- | :--- | :--- |
| 2 | **PCP** (o **CoS**), nel tag **802.1Q** | 3 | 0-7 (voce 5, video 4, default 0) |
| 3 | **DSCP**, nel byte ToS dell'header IPv4 (Traffic Class in IPv6) | **6** | 0-63 |
| 3 | IP Precedence (vecchio, sostituito da DSCP) | 3 | 0-7 |

Il PCP esiste solo dove c'è un tag 802.1Q (trunk, voice VLAN): si perde quando il frame esce dalla LAN. Il DSCP viaggia nell'header IP fino a destinazione.

### Valori DSCP

| Nome | Valore | Uso |
| :--- | :--- | :--- |
| **DF** (default forwarding) | **0** | best effort, tutto ciò che non è classificato |
| **EF** (expedited forwarding) | **46** | **voce**: basso delay, jitter e perdita |
| **AFxy** (assured forwarding) | 8x + 2y | x = classe (1-4, più alta = più importante), y = **drop precedence** (1-3, più alta = **scartato prima**) |
| **CSx** (class selector) | 8x | compatibilità con IP Precedence (CS3 segnalazione, CS6 controllo di rete) |

Esempi AF: **AF41** = 34 (video interattivo), AF31 = 26, AF21 = 18, AF11 = 10. Tra AF41 e AF43, a parità di classe, viene scartato prima **AF43**.

### Trust boundary

Il **trust boundary** è il punto da cui la rete si fida delle marcature che riceve. Prima di quel punto le marcature vengono ignorate o riscritte.

- Un PC **non** è fidato: un utente potrebbe marcare il proprio traffico come voce.
- Un **telefono IP** sì: di solito il trust boundary si estende al telefono (lo switch lo riconosce con CDP), che marca la voce e rimarca il traffico del PC collegato dietro di lui.
- Senza telefono, il trust boundary è lo switch di accesso.

## 3. Code e congestione

Quando i pacchetti arrivano più velocemente di quanto l'interfaccia possa trasmetterli, vengono messi in **coda**.

- **FIFO**: una sola coda, in ordine di arrivo, senza priorità (il default senza QoS).
- **Tail drop**: quando la coda è piena, i pacchetti nuovi vengono scartati tutti. Questo causa la **TCP global synchronization**: tutte le sessioni TCP perdono pacchetti insieme, rallentano insieme, poi riaccelerano insieme. Il link oscilla tra congestione e sottoutilizzo.
- **RED** (random early detection): quando la coda inizia a riempirsi, scarta a caso **alcuni** pacchetti, così solo alcune sessioni TCP rallentano.
- **WRED** (weighted RED): come RED, ma scarta prima il traffico meno importante (in base al DSCP).

Con più code serve un modo per decidere da quale coda trasmettere:

- **Round robin pesato** (weighted round robin): le code vengono servite a turno, prendendo più dati da quelle più importanti.
- **CBWFQ** (class-based weighted fair queuing): garantisce a ogni classe una **percentuale minima di banda** durante la congestione.
- **LLQ** (low latency queuing): **CBWFQ più una coda a priorità stretta**, che viene sempre svuotata per prima. Ci va la **voce** (e il video interattivo). Per non affamare le altre code, il traffico della coda prioritaria viene limitato con un policer.

## 4. Policing e shaping

Entrambi limitano il traffico a una velocità stabilita (es. il contratto con l'ISP).

| | **Policing** | **Shaping** |
| :--- | :--- | :--- |
| Traffico in eccesso | **scartato** (o rimarcato con un valore peggiore) | **messo in buffer** e inviato più tardi |
| Effetto | perdite, ritrasmissioni TCP | più delay, ma traffico regolare |
| Direzione | in ingresso e in uscita | **solo in uscita** |
| Uso tipico | l'ISP fa rispettare il contratto | il cliente si adegua al contratto, per non farsi scartare il traffico dal policer dell'ISP |

Entrambi permettono un **burst**: per breve tempo si può superare il limite, se prima si è rimasti sotto.

## 5. Il percorso in un router

1. **Classificazione** del pacchetto in entrata.
2. **Marcatura** (se il dispositivo è al trust boundary o rimarca).
3. Eventuale **policing** in ingresso.
4. **Accodamento** sull'interfaccia di uscita (LLQ, CBWFQ), con **WRED** per evitare il tail drop.
5. Eventuale **shaping** in uscita.

## ⚠️ Trappole d'esame

> [!WARNING] Gli errori più frequenti
> 1. **Jitter e delay**: il jitter è la **variazione** del delay.
> 2. **Policing e shaping**: il policing scarta, lo shaping ritarda; lo shaping è solo in uscita.
> 3. **Drop precedence**: in AFxy una y più alta significa **scartato prima**, non più importante.
> 4. **DSCP e PCP**: DSCP ha 6 bit (Layer 3), PCP/CoS 3 bit (Layer 2, solo con tag 802.1Q).
> 5. **Voce**: EF (46), coda a priorità stretta (LLQ).
> 6. **Tail drop**: causa la TCP global synchronization; la soluzione è WRED.
> 7. **Trust boundary**: i PC non sono fidati; i telefoni IP sì.

## Esercizi

> [!QUESTION]- Che valore DSCP ha AF31? E quale tra AF31 e AF33 viene scartato prima?
> 8×3 + 2×1 = 26. Viene scartato prima AF33 (drop precedence più alta).

> [!QUESTION]- L'ISP accetta 50 Mbit/s e scarta il resto. Cosa configuri in uscita sul tuo router per non perdere pacchetti?
> Shaping a 50 Mbit/s: l'eccesso viene accodato invece che scartato dall'ISP.

> [!QUESTION]- Le telefonate si sentono a scatti anche se il delay medio è basso. Quale caratteristica è probabilmente fuori limite?
> Il jitter (la variazione del delay), oltre i 30 ms.

> [!QUESTION]- Che coda serve per garantire alla voce di essere trasmessa sempre per prima?
> LLQ: CBWFQ con una coda a priorità stretta.

> [!QUESTION]- Un utente marca il traffico del suo PC con DSCP 46. Cosa deve fare lo switch di accesso?
> Non fidarsi: il PC è fuori dal trust boundary, quindi la marcatura va ignorata o riscritta.

## Check da esame

- [ ] Limiti per la voce? **Delay ≤ 150 ms, jitter ≤ 30 ms, perdita ≤ 1%**.
- [ ] Valore DSCP della voce? **EF, 46**.
- [ ] Bit del DSCP? **6**. Del PCP/CoS? **3**.
- [ ] Coda per la voce? **LLQ (priorità stretta)**.
- [ ] Cosa evita il tail drop? **WRED**.
- [ ] Policing o shaping per ritardare invece di scartare? **Shaping**.

## 🎯 Synthesis

La QoS serve quando c'è congestione: classifica il traffico (ACL, NBAR), lo marca (PCP/CoS a Layer 2, DSCP a Layer 3: EF 46 per la voce, AF con drop precedence, CS), si fida delle marcature solo dal trust boundary in poi, lo accoda (LLQ per la voce, CBWFQ per garantire banda), evita il tail drop con WRED e limita la velocità con policing (scarta) o shaping (ritarda, solo in uscita). La voce chiede delay ≤ 150 ms, jitter ≤ 30 ms, perdita ≤ 1%.

Approfondimenti: [[Day 46 — QoS, IP Phones, Voice VLANs & PoE (Part 1)]] · [[Day 47 — QoS (Part 2)]]

> [!EXAMPLE] Laboratori pratici
> - [[Day 46 Lab - Voice VLANs.pkt]]
> - [[Day 47 Lab - QoS.pkt]]
