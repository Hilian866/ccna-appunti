

> [!ABSTRACT] Quick Summary
> Questa nota analizza i componenti del **Physical Layer (L1)**, focalizzandosi sugli standard Ethernet, la struttura dei cavi in rame (UTP) e fibra ottica, e le logiche di pinout (Straight-through vs Crossover) necessarie per la connettività di rete.

### Interfacce Fisiche e Connettori
Le reti moderne utilizzano prevalentemente lo standard Ethernet per le connessioni cablate. Il connettore standard per il rame è l'**RJ-45** (Registered Jack).

*   **Interfacce Switch**: Un tipico switch dispone di numerose porte per collegare end-host [00:53](https://youtu.be/ieTH5lVhNaY&t=53s).
*   **Connettore RJ-45**: Composto da 8 pin, utilizzato con cavi in rame a coppie intrecciate [01:53](https://youtu.be/ieTH5lVhNaY&t=113s).

> [!INFO] Definizione di Ethernet
> Ethernet non è un singolo protocollo, ma una collezione di standard e protocolli di rete definiti dall'**IEEE 802.3** [02:36](https://youtu.be/ieTH5lVhNaY&t=156s).

### Standard Ethernet su Rame (Copper)
La velocità di trasmissione si misura in **bit al secondo (bps)** [04:21](https://youtu.be/ieTH5lVhNaY&t=261s).

| Velocità | Nome Comune | Standard IEEE | Nome Informale | Max Lunghezza |
| :--- | :--- | :--- | :--- | :--- |
| 10 Mbps | Ethernet | 802.3i | 10BASE-T | 100 m |
| 100 Mbps | Fast Ethernet | 802.3u | 100BASE-T | 100 m |
| 1 Gbps | Gigabit Ethernet | 802.3ab | 1000BASE-T | 100 m |
| 10 Gbps | 10 Gig Ethernet | 802.3an | 10GBASE-T | 100 m |

[Rif. Tabella Standard 07:18](https://youtu.be/ieTH5lVhNaY&t=438s)

### Cavi UTP e Logica dei Pinout
I cavi **UTP (Unshielded Twisted Pair)** utilizzano il twist delle coppie per proteggere il segnale dalle interferenze elettromagnetiche (**EMI**) [09:18](https://youtu.be/ieTH5lVhNaY&t=558s).

#### Trasmissione vs Ricezione (10/100 Mbps)
I dispositivi si dividono in due categorie basate sui pin che usano per trasmettere (**Tx**) e ricevere (**Rx**) [17:28](https://youtu.be/ieTH5lVhNaY&t=1048s):

| Tipo Dispositivo | Pin Trasmissione (Tx) | Pin Ricezione (Rx) |
| :--- | :--- | :--- |
| Router, PC, Firewall | 1 e 2 | 3 e 6 |
| Switch, Hub | 3 e 6 | 1 e 2 |

#### Tipologie di Cavo
1.  **Straight-through Cable**: Pin 1 va al Pin 1, Pin 2 al Pin 2, ecc. Si usa per collegare dispositivi di categorie diverse (es. PC a Switch) [14:23](https://youtu.be/ieTH5lVhNaY&t=863s).
2.  **Crossover Cable**: Le coppie Tx e Rx sono invertite tra i due capi (1/2 <-> 3/6). Si usa per collegare dispositivi della stessa categoria (es. Switch a Switch) [16:10](https://youtu.be/ieTH5lVhNaY&t=970s).

> [!CAUTION] Limitazione Storica
| Nei moderni standard **1000BASE-T** e superiori, vengono utilizzati tutti gli 8 pin e la trasmissione è bidirezionale su ogni coppia [19:16](https://youtu.be/ieTH5lVhNaY&t=1156s).

#### Auto MDI-X
Funzionalità che permette alle interfacce di rilevare automaticamente il tipo di cavo e configurare i pin Tx/Rx internamente, rendendo superflua la distinzione tra cavi dritti e incrociati [18:31](https://youtu.be/ieTH5lVhNaY&t=1111s).

### Fibra Ottica
Utilizza la luce invece dell'elettricità, eliminando il problema delle EMI e permettendo distanze molto superiori [22:08](https://youtu.be/ieTH5lVhNaY&t=1328s).

| Caratteristica | Multimode (MMF) | Single-mode (SMF) |
| :--- | :--- | :--- |
| Core | Più largo (permette più "modi" di luce) | Più stretto (singolo raggio) |
| Sorgente | LED (economico) | Laser (costoso) |
| Distanza | Breve (fino a 550m) | Lunga (fino a 30km+) |
| Costo | Inferiore | Superiore |

[Confronto MMF vs SMF 22:52](https://youtu.be/ieTH5lVhNaY&t=1372s)

#### SFP (Small Form-Factor Pluggable)
I router e switch moderni usano porte **SFP** per alloggiare ricetrasmettitori intercambiabili, permettendo di scegliere tra diversi tipi di fibra o rame sulla stessa porta fisica [21:07](https://youtu.be/ieTH5lVhNaY&t=1267s).

### Riepilogo Comparativo: Rame vs Fibra
| Caratteristica | UTP (Rame) | Fibra Ottica |
| :--- | :--- | :--- |
| Costo | Basso | Alto |
| Distanza | Limitata (100m) | Molto estesa (Km) |
| Interferenze (EMI) | Vulnerabile | Immune |
| Sicurezza | Rischio di intercettazione (leak) | Molto sicura |

[Rif. Analisi Finale 26:38](https://youtu.be/ieTH5lVhNaY&t=1598s)