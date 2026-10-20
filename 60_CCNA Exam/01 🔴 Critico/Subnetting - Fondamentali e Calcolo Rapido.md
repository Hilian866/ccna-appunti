---
tags: [ccna, exam, subnetting]
priorita: critico
dominio: IP Connectivity
stato: da-ripassare
---

## Core Concept

Il subnetting consiste nel "rubare" bit alla parte Host per creare più sottoreti (Subnet). Il valore del **CIDR** indica quanti bit sono accesi (1) nella maschera, partendo da sinistra.

- **Block Size (Magic Number):** È l'incremento tra una subnet e l'altra. Si ottiene sottraendo il valore dell'ultimo ottetto da **256**.
- **Host utilizzabili:** $2^n - 2$ (dove $n$ è il numero di bit rimasti a 0).

---

## 1. Tabella di Conversione (Ottetto Critico)

Questa tabella si riferisce al **quarto ottetto**. Memorizzare il legame tra bit presi, valore decimale e block size è la chiave per risolvere il subnetting in meno di 10 secondi.

|**CIDR**|**Bit Presi**|**Valore Decimale**|**Block Size (Magic #)**|**Host Totali**|
|---|---|---|---|---|
|**/24**|0|.0|**256**|254|
|**/25**|1|.128|**128**|126|
|**/26**|2|.192|**64**|62|
|**/27**|3|.224|**32**|30|
|**/28**|4|.240|**16**|14|
|**/29**|5|.248|**8**|6|
|**/30**|6|.252|**4**|**2**|

> [!IMPORTANT]
>
> **Il /30 è il "Link Point-to-Point":** Usato quasi esclusivamente per i collegamenti diretti tra router, poiché offre solo 2 IP utilizzabili (evitando sprechi).

---

## 2. Subnet Mask "Must-Know"

Questi valori devono essere riconosciuti istantaneamente nei quiz d'esame.

|**CIDR**|**Subnet Mask**|**Contesto Tipico**|
|---|---|---|
|**/8**|255.0.0.0|Class A Default|
|**/16**|255.255.0.0|Class B Default|
|**/24**|255.255.255.0|Class C Default / LAN standard|
|**/30**|255.255.255.252|WAN / Link tra Router|
|**/32**|255.255.255.255|**Host Singolo** (Loopback o ACL)|

---

## 3. Il Metodo del "Magic Number" (Algoritmo di calcolo)

Per trovare l'indirizzo di rete di un IP (es. `192.168.1.50 /27`):

1. Trova il **Block Size** del /27 $\rightarrow$ **32**.
2. Trova i multipli di 32: `0, 32, 64, 96...`
3. L'IP `.50` cade tra `32` e `64`.
4. **Network ID:** `192.168.1.32`
5. **Broadcast:** `192.168.1.63` (uno prima del blocco successivo).

---

## 4. Common Pitfalls (CCNA Trap)

- **Dimenticare il -2:** Molti quesiti chiedono "Quanti host _utilizzabili_?". La risposta non è mai una potenza di 2 (es. per /27 è 30, non 32).
- **Confusione /31:** In ambienti moderni esiste il /31 per i link punto-punto, ma per il CCNA standard, il limite operativo minimo per una subnet con host è il **/30**.
- **Ottetti diversi:** Se il CIDR è inferiore a /24 (es. /20), il calcolo si sposta nel **terzo ottetto**. La logica del Magic Number resta identica, ma applicata a `255.255.X.0`.

---

## 5. Oltre il 4° ottetto (/17–/23 e /9–/15)
Stessa logica, ma il "magic number" si calcola sull'ottetto **dove cade il confine**.

| CIDR | Ottetto | Block size | Esempio |
|---|---|---|---|
| /20 | 3° | 256 − 240 = **16** | `172.16.35.10/20` → rete `172.16.32.0`, broadcast `172.16.47.255` |
| /22 | 3° | 256 − 252 = **4** | `10.1.6.9/22` → rete `10.1.4.0`, broadcast `10.1.7.255` |
| /12 | 2° | 256 − 240 = **16** | `172.20.1.1/12` → rete `172.16.0.0` |

Passi: (1) individua l'ottetto del confine, (2) block size = 256 − valore maschera in quell'ottetto, (3) prendi il multiplo ≤ IP, (4) broadcast = rete successiva − 1 (gli ottetti a destra diventano 255).

## 6. Calcolo inverso: quanti bit servono?
Per **N host utilizzabili** trova il più piccolo *h* con 2^h − 2 ≥ N; il prefisso è **/(32 − h)**.
- 50 host → h = 6 (62) → **/26**
- 100 host → h = 7 (126) → **/25**
- 500 host → h = 9 (510) → **/23**
Per **N subnet** da una rete: bit da prendere *s* con 2^s ≥ N.

## 7. VLSM (Variable Length Subnet Masking)
Regola: **assegna dalla subnet più grande alla più piccola**, in ordine, senza sovrapposizioni.

Esempio: da `192.168.10.0/24` servono 100, 50, 20 host e due link P2P.
1. 100 host → /25 → `192.168.10.0/25` (0–127)
2. 50 host → /26 → `192.168.10.128/26` (128–191)
3. 20 host → /27 → `192.168.10.192/27` (192–223)
4. Link P2P → /30 → `192.168.10.224/30` e `192.168.10.228/30`

## 8. Domande-trappola
- **"Stessa subnet?"** → calcola il Network ID di entrambi con la stessa maschera.
- **"IP valido per un host?"** → non deve essere rete né broadcast (es. `.63/26` è broadcast).
- **Wildcard** = 255.255.255.255 − mask (per ACL/OSPF): /26 → `0.0.0.63`.
- **Summarization**: trova il prefisso comune in binario (es. `10.1.0.0`–`10.1.3.0` /24 → `10.1.0.0/22`).

## 9. Pratica
- Ogni giorno 10 esercizi cronometrati (obiettivo < 45 s). Esercizi: [[Subnetting Practice]].

## 🎯 Synthesis
Trova l'ottetto del confine, calcola 256 − mask, prendi il multiplo sotto l'IP: quello è il Network ID.
