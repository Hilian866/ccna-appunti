---
tags: [ccna, exam, fondamenti]
priorita: medio
dominio: Network Fundamentals
stato: da-ripassare
---

> [!ABSTRACT] Cosa serve per l'esame
> Blueprint **1.5**: confrontare TCP e UDP. Il modello OSI non è un punto a sé, ma l'esame lo dà per scontato in molte domande ("a che livello lavora…?").
> Devi conoscere i livelli OSI e TCP/IP con le loro PDU, l'incapsulamento, cosa offre TCP che UDP non offre (handshake, sequenze, ACK, finestra), a cosa servono le porte e le porte dei servizi principali.

## 1. Modello OSI e TCP/IP

| # | OSI | PDU | TCP/IP | Cosa c'è | Dispositivi |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 7 | Application | data | Application | HTTP, DNS, DHCP, SSH | |
| 6 | Presentation | data | Application | formati, cifratura (TLS) | |
| 5 | Session | data | Application | apertura e chiusura delle sessioni | |
| 4 | **Transport** | **segment** (TCP), datagram (UDP) | Transport | **porte**, TCP, UDP | firewall |
| 3 | **Network** | **packet** | Internet | **indirizzi IP**, routing | **router**, switch multilayer |
| 2 | **Data link** | **frame** | Link | **indirizzi MAC** | **switch**, AP |
| 1 | Physical | bit | Link | cavi, segnali, connettori | hub, cavi, ripetitori |

- Mnemonico, dal 7 all'1: **A**ll **P**eople **S**eem **T**o **N**eed **D**ata **P**rocessing.
- Il modello TCP/IP riunisce i livelli 5-7 in Application e 1-2 in Link (o Network Access). Alcuni testi lo dividono in 5 livelli, tenendo separati fisico e data link.

**Incapsulamento**: ogni livello aggiunge il proprio header a quello che riceve dal livello sopra.

1. L'applicazione produce i **dati**.
2. Il livello 4 aggiunge l'header TCP o UDP (porte): **segmento**.
3. Il livello 3 aggiunge l'header IP (indirizzi IP): **pacchetto**.
4. Il livello 2 aggiunge header e trailer Ethernet (MAC, FCS per gli errori): **frame**.
5. Il livello 1 trasmette i **bit**.

Il destinatario fa il contrario (**de-incapsulamento**). Lungo il percorso, un router toglie e rifà l'header di livello 2 a ogni salto, mentre l'header IP resta (a parte TTL e checksum).

## 2. Le porte

Le porte identificano l'**applicazione** dentro un host (un indirizzo IP identifica l'host).

- **Porta di destinazione**: il servizio richiesto (es. 443 per HTTPS).
- **Porta sorgente**: scelta a caso dal client tra quelle **effimere**, per distinguere le proprie sessioni. Così un PC può avere più schede del browser aperte verso lo stesso server (**multiplexing**).
- Una sessione è identificata da IP e porta sorgente più IP e porta di destinazione (e il protocollo).

| Intervallo | Nome |
| :--- | :--- |
| 0-1023 | **well-known** (servizi standard) |
| 1024-49151 | registered |
| 49152-65535 | **dynamic / ephemeral** (porte sorgente dei client) |

## 3. TCP e UDP

| | **TCP** | **UDP** |
| :--- | :--- | :--- |
| Connessione | **connection-oriented**: three-way handshake prima di inviare dati | **connectionless**: invia subito |
| Affidabilità | **ACK** e **ritrasmissione** dei segmenti persi | nessuna |
| Ordine | **numeri di sequenza** per rimettere in ordine i segmenti | nessun ordinamento |
| Controllo di flusso | **finestra** (window size) | nessuno |
| Header | **20 byte** (minimo) | **8 byte** |
| Velocità | più lento, più overhead | più veloce |
| Usi | web, SSH, FTP, email | voce e video in tempo reale, DNS, DHCP, TFTP, SNMP, syslog, NTP |

TCP sacrifica velocità per avere affidabilità; UDP sacrifica affidabilità per avere velocità. Un'applicazione su UDP può gestire da sé l'affidabilità (TFTP conferma ogni blocco).

**Header UDP**: porta sorgente, porta destinazione, lunghezza, checksum. Nient'altro.

**Header TCP**: porte, **numero di sequenza**, **numero di ACK**, flag (SYN, ACK, FIN, RST…), window size, checksum.

### Come lavora TCP

**Apertura** (three-way handshake):

1. Client → server: **SYN**.
2. Server → client: **SYN-ACK**.
3. Client → server: **ACK**. La connessione è aperta.

**Chiusura** (four-way): FIN → ACK, poi FIN → ACK nell'altra direzione. Un **RST** chiude bruscamente.

**ACK in avanti** (forward acknowledgment): l'ACK indica il **prossimo** numero di sequenza atteso. Se il client ha mandato il segmento con sequenza 27, il server risponde ACK 28. Se un ACK non arriva, il mittente ritrasmette.

**Finestra** (sliding window): il destinatario dice quanti byte possono essere inviati prima di aspettare un ACK. Se è sovraccarico la riduce, se va tutto bene la allarga: è il controllo di flusso.

## 4. Porte da sapere

| Porta | Servizio | Trasporto |
| :--- | :--- | :--- |
| 20, 21 | FTP (dati, controllo) | TCP |
| 22 | SSH | TCP |
| 23 | Telnet | TCP |
| 25 | SMTP (invio email) | TCP |
| 53 | DNS | **UDP** e **TCP** |
| 67, 68 | DHCP (server, client) | UDP |
| 69 | TFTP | UDP |
| 80 | HTTP | TCP |
| 110 | POP3 | TCP |
| 123 | NTP | UDP |
| 143 | IMAP | TCP |
| 161, 162 | SNMP (agent, trap) | UDP |
| 443 | HTTPS | TCP |
| 514 | Syslog | UDP |

Altre: TACACS+ TCP 49, RADIUS UDP 1812/1813. HTTP/3 usa UDP 443 (QUIC).

## ⚠️ Trappole d'esame

> [!WARNING] Gli errori più frequenti
> 1. **DNS solo UDP**: usa anche TCP 53 (risposte grandi, trasferimenti di zona).
> 2. **PDU**: segmento = livello 4, pacchetto = 3, frame = 2.
> 3. **ACK**: indica il prossimo byte atteso, non l'ultimo ricevuto.
> 4. **UDP "inutile"**: è una scelta voluta, dove la velocità conta più della consegna garantita.
> 5. **Porta Layer 4 e porta fisica**: sono cose diverse.
> 6. **Dimensioni degli header**: TCP 20 byte, UDP 8.

## Esercizi

> [!QUESTION]- Un PC apre due connessioni HTTPS verso lo stesso server. Cosa le distingue?
> La porta sorgente (effimera), diversa per ognuna.

> [!QUESTION]- Il server riceve un segmento con sequenza 100 e lunghezza 1 byte. Che numero di ACK manda?
> 101: il prossimo byte atteso.

> [!QUESTION]- A che livello OSI lavora uno switch che decide in base ai MAC? E un router?
> Livello 2 (data link); il router al livello 3 (network).

> [!QUESTION]- Una telefonata VoIP usa TCP o UDP? Perché?
> UDP: un pacchetto ritrasmesso arriverebbe troppo tardi per essere utile; conta il basso ritardo.

> [!QUESTION]- Quali sono i tre messaggi del three-way handshake, in ordine?
> SYN, SYN-ACK, ACK.

## Check da esame

- [ ] PDU del livello 4 con TCP? **Segmento**.
- [ ] Dimensione dell'header UDP? **8 byte**.
- [ ] Cosa offre TCP che UDP non ha? **Connessione, ACK e ritrasmissione, sequenze, controllo di flusso**.
- [ ] Intervallo delle porte effimere? **49152-65535**.
- [ ] Porta di HTTPS? **TCP 443**. Di SSH? **TCP 22**.
- [ ] Livello OSI degli indirizzi IP? **3 (network)**.

## 🎯 Synthesis

I dati scendono i livelli e vengono incapsulati in segmento (4, porte), pacchetto (3, IP), frame (2, MAC) e bit. Le porte identificano l'applicazione: destinazione = servizio, sorgente = porta effimera del client. TCP apre la connessione (SYN, SYN-ACK, ACK), numera i segmenti, conferma con ACK in avanti e regola il flusso con la finestra; UDP ha un header di 8 byte e nessuna garanzia, ed è usato dove conta la velocità.

Approfondimenti: [[DAY 30 — TCP vs UDP – Layer 4 Basics]]
