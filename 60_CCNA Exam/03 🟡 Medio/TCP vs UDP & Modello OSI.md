---
tags: [ccna, exam, fondamenti]
priorita: medio
dominio: Network Fundamentals
stato: da-ripassare
---

## Obiettivo
Teoria che l'esame dà per scontata: modelli, incapsulamento, TCP vs UDP e porte note.

## 1. OSI vs TCP/IP
| # | OSI | PDU | TCP/IP | Esempi |
|---|---|---|---|---|
| 7 | Application | Data | Application | HTTP, DNS, DHCP |
| 6 | Presentation | Data | ↑ | TLS, JSON |
| 5 | Session | Data | ↑ | — |
| 4 | **Transport** | **Segment** (TCP) / **Datagram** (UDP) | Transport | porte |
| 3 | **Network** | **Packet** | Internet | IP, router |
| 2 | **Data Link** | **Frame** | Network Access | MAC, switch |
| 1 | Physical | Bit | ↑ | cavi, Wi-Fi |

Mnemonico (7→1): **A**ll **P**eople **S**eem **T**o **N**eed **D**ata **P**rocessing.
**Incapsulamento**: Data → Segment → Packet → Frame → Bits. Il *de-incapsulamento* è l'inverso.

## 2. TCP vs UDP
| | TCP | UDP |
|---|---|---|
| Connessione | **Connection-oriented** (3-way handshake) | Connectionless |
| Affidabilità | ACK, ritrasmissione, ordinamento | Nessuna |
| Controllo | **Flow control** (window), congestion control | Nessuno |
| Overhead | Header 20+ B | Header **8 B** |
| Usi | HTTP(S), SSH, FTP, SMTP | DNS query, DHCP, TFTP, SNMP, NTP, VoIP |

**3-way handshake**: SYN → SYN-ACK → ACK. Chiusura: FIN/ACK (o RST).
**Windowing**: la finestra dice quanti byte si possono inviare prima di attendere un ACK.

## 3. Porte note (da sapere a memoria)
| Porta | Servizio | Protocollo |
|---|---|---|
| 20/21 | FTP dati/controllo | TCP |
| 22 | SSH | TCP |
| 23 | Telnet | TCP |
| 25 | SMTP | TCP |
| 53 | DNS | UDP (query) · **TCP** (trasferimenti zona/risposte grandi) |
| 67/68 | DHCP server/client | UDP |
| 69 | TFTP | UDP |
| 80 / 443 | HTTP / HTTPS | TCP |
| 110 / 143 | POP3 / IMAP | TCP |
| 123 | NTP | UDP |
| 161 / 162 | SNMP / trap | UDP |
| 514 | Syslog | UDP |

Intervalli: **well-known** 0–1023, **registered** 1024–49151, **dynamic/ephemeral** 49152–65535.

## 4. Altri fondamentali da ripassare
- Cavi: **UTP** (100 m) vs **fibra** (multimode/single-mode); straight-through vs crossover.
- Tipi di indirizzo IPv4: unicast, broadcast, multicast (224.0.0.0/4); privati RFC 1918 (10/8, 172.16/12, 192.168/16); APIPA 169.254/16.

## Common Mistakes
- **DNS usa anche TCP** (non solo UDP).
- UDP non significa "inaffidabile e inutile": DNS, DHCP e VoIP lo usano perché la velocità conta più della consegna garantita.
- PDU: frame = L2, packet = L3, segment = L4.

## 🎯 Synthesis
TCP garantisce (handshake, ACK, window), UDP corre (8 byte, nessuna garanzia); ogni livello OSI incapsula il PDU del livello superiore.

Approfondimenti: [[DAY 30 — TCP vs UDP – Layer 4 Basics]] · [[Ports and Protocols]] · [[Protocol vs Port]]
