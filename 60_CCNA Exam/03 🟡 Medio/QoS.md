---
tags: [ccna, exam, qos]
priorita: medio
dominio: IP Services
stato: da-ripassare
---

## Obiettivo
Dare priorità al traffico sensibile (voce, video) quando la banda è congestionata. Non serve configurarlo: serve **riconoscere i termini**.

## 1. Metriche
| Termine | Significato | Voce (limite) |
|---|---|---|
| **Bandwidth** | Capacità del link | 30–128 kbps per chiamata |
| **Delay/Latency** | Tempo one-way | ≤ 150 ms |
| **Jitter** | **Variazione** del delay | ≤ 30 ms |
| **Loss** | Pacchetti persi | ≤ 1% |

## 2. Pipeline QoS
1. **Classification** — identifica il traffico (ACL, NBAR, DSCP/CoS già presenti).
2. **Marking** — scrive il valore nel pacchetto.
3. **Queuing** — mette in coda con una policy: **CBWFQ**, **LLQ** (coda a priorità stretta per la voce).
4. **Congestion avoidance** — **WRED** scarta in anticipo per evitare il *tail drop*.
5. **Policing** vs **Shaping** — limitano il rate.

| | Policing | Shaping |
|---|---|---|
| Eccesso di traffico | **Scartato** (o ri-marcato) | **Messo in buffer** (ritardato) |
| Direzione | In e out | Solo **out** |
| Effetto | Può causare drop e ritrasmissioni | Traffico più liscio, più delay |

## 3. Marking
| Layer | Campo | Bit |
|---|---|---|
| L2 | **CoS** (802.1Q) | 3 bit (0–7) |
| L3 | **IP Precedence** | 3 bit |
| L3 | **DSCP** | 6 bit (0–63) |

| DSCP | Nome | Uso |
|---|---|---|
| **EF (46)** | Expedited Forwarding | **Voce** |
| **AF41** | Assured Forwarding | Video |
| AFxy | x = classe (1–4), y = drop precedence (1–3) | Dati prioritari |
| **CS3 / CS6** | Class Selector | Segnalazione / controllo |
| **0 (BE)** | Best Effort | Default |

**Trust boundary**: il punto dove ci si fida del marking (tipicamente lo switch d'accesso con l'IP phone).

## 4. Voice VLAN
```
interface g0/1
 switchport mode access
 switchport access vlan 10
 switchport voice vlan 150
 mls qos trust cos
```
Il phone taggato usa la **voice VLAN**, il PC dietro il phone usa la data VLAN. **PoE** alimenta il phone.

## Common Mistakes
- **Jitter ≠ delay**: è la *variazione* del delay.
- Marking senza **trust boundary** corretto: il tag viene sovrascritto o ignorato.
- Policing e shaping non sono uguali: uno scarta, l'altro ritarda.
- La voce va in **LLQ**, non in coda normale.

## 🎯 Synthesis
Classifico, marco (EF = voce), metto in coda con priorità e limito con shaping/policing per tenere basso delay e jitter della voce.

Approfondimenti: [[Day 46 — QoS, IP Phones, Voice VLANs & PoE (Part 1)]] · [[Day 47 — QoS (Part 2)]] · Lab: [[Day 46 Lab - Voice VLANs.pkt]] · [[Day 47 Lab - QoS.pkt]]
