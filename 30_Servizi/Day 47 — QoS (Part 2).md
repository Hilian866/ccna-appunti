> [!ABSTRACT]  Core Logic
Questa nota approfondisce i meccanismi avanzati di Quality of Service (QoS), focalizzandosi sui processi di Classification, Marking (Layer 2 e Layer 3) e sulle tecniche di gestione della congestione come Queuing e Traffic Conditioning (Shaping e Policing). L'obiettivo è comprendere come identificare il traffico e applicare policy per garantire le performance delle applicazioni critiche.

### Classification & Marking
La Classification è la fase fondamentale in cui i router/switch identificano i pacchetti per organizzarli in classi [01:43](https://youtu.be/4vurfhVjcMM&t=103s). Il Marking invece consiste nel modificare un campo nell'header per "etichettare" la priorità del pacchetto [05:34](https://youtu.be/4vurfhVjcMM&t=334s).

> [!INFO] Metodi di Classificazione
> - **ACL**: Identifica il traffico in base a IP, porte o protocolli.
> - **NBAR (Network Based Application Recognition)**: Esegue una **Deep Packet Inspection (DPI)** fino al Layer 7 per identificare app specifiche come Skype o Facebook [02:45](https://youtu.be/4vurfhVjcMM&t=165s).

#### Layer 2 Marking: PCP (CoS)
Utilizzato nei tag **802.1Q**, il campo **Priority Code Point (PCP)** occupa 3 bit, permettendo 8 valori (0-7) [03:57](https://youtu.be/4vurfhVjcMM&t=237s).

| Valore PCP (CoS) | Tipo di Traffico |
| :--- | :--- |
| 0 | Best Effort (Default) |
| 4 | Video |
| 5 | Voice |
| 6-7 | Internetwork Control |

#### Layer 3 Marking: DSCP
Il campo **Type of Service (ToS)** nell'header IPv4 è stato aggiornato per supportare il **Differentiated Services Code Point (DSCP)** [07:58](https://youtu.be/4vurfhVjcMM&t=478s).
- **DSCP**: 6 bit (64 valori possibili).
- **ECN**: 2 bit (Explicit Congestion Notification).

> [!ABSTRACT] Standard DSCP comuni [10:34](https://youtu.be/4vurfhVjcMM&t=634s)
> - **Default Forwarding (DF)**: Valore 0, traffico best effort.
> - **Expedited Forwarding (EF)**: Valore 46, priorità massima (Voice).
> - **Assured Forwarding (AF)**: 12 valori per definire priorità e probabilità di scarto (Drop Precedence).
> - **Class Selector (CS)**: 8 valori per retrocompatibilità con **IP Precedence**.

### Trust Boundaries
Il **Trust Boundary** definisce il punto della rete in cui i dispositivi iniziano a fidarsi dei marking QoS ricevuti [13:06](https://youtu.be/4vurfhVjcMM&t=786s).

> [!CAUTION] Best Practice
> Generalmente, il traffico proveniente dai PC **non è fidato** (un utente esperto potrebbe marcare il proprio traffico gaming come priorità 7). Si raccomanda di posizionare il trust boundary sugli **IP Phones** [14:18](https://youtu.be/4vurfhVjcMM&t=858s).

### Congestion Management: Queuing
Quando il traffico eccede la capacità di un'interfaccia, i pacchetti vengono messi in coda (Queuing) [15:26](https://youtu.be/4vurfhVjcMM?t=926s). Se la coda è piena, avviene il **Tail Drop** (scarto degli ultimi pacchetti).

#### Meccanismi di Scheduling:
1. **Weighted Round Robin (WRR)**: Cicla tra le code prelevando più dati da quelle ad alta priorità [18:02](https://youtu.be/4vurfhVjcMM&t=1082s).
2. **CBWFQ (Class-Based Weighted Fair Queuing)**: Garantisce una larghezza di banda minima a ogni classe [18:18](https://youtu.be/4vurfhVjcMM&t=1098s).
3. **LLQ (Low Latency Queuing)**: Aggiunge una coda di **Strict Priority** a CBWFQ, ideale per Voice/Video per ridurre jitter e delay [19:18](https://youtu.be/4vurfhVjcMM&t=1158s).

### Traffic Conditioning: Shaping vs Policing
Entrambi limitano il traffico a un bitrate configurato, ma con metodi diversi [21:02](https://youtu.be/4vurfhVjcMM&t=1262s).

| Funzione | Shaping | Policing |
| :--- | :--- | :--- |
| Azione | Bufferizza i pacchetti in eccesso | Scarta o rimarca i pacchetti |
| Effetto | Crea delay, ma riduce i drop | Provoca drop immediati o re-marking |
| Direzione | Tipicamente Outbound | Inbound e Outbound |
| Obiettivo | Smoothing del traffico | Enforcement rigido del limite |