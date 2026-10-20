
## What is it

**TCP** e **UDP** sono protocolli di **Layer 4 (Transport)**. Per la CCNA devi saper **confrontare TCP e UDP** e capire il ruolo delle **porte** (port numbers) per identificare applicazioni e gestire sessioni multiple.

## How it works

### Funzioni generali del Layer 4

- Fornisce trasferimento dati **end-to-end** (trasparente agli host rispetto ai dettagli dei layer sottostanti).
    
- Può offrire servizi alle applicazioni (TCP sì, UDP no):
    
    - **reliable data transfer**
        
    - **error recovery** (retrasmission)
        
    - **sequencing** (riordinare segmenti)
        
    - **flow control** (regolare velocità)
        

### Port numbers (Layer 4 addressing)

- **Destination port**: identifica il protocollo applicativo (es. HTTP `80`, FTP `21`).
    
- **Source port**: scelto dal client (di solito **random**) per distinguere sessioni.
    
- **Session multiplexing**: un host gestisce più sessioni contemporaneamente usando combinazioni di porte.
    
![[Screenshot_2 7.png]]
#### Range IANA

- **Well-known**: `0–1023`
    
- **Registered**: `1024–49151`
    
- **Ephemeral** (dynamic/private): `49152–65535` (tipico per **source port** random)
    

### TCP (Transmission Control Protocol)

- **Connection-oriented**: stabilisce connessione prima di inviare dati.
    
- **Reliable**: ACK obbligatori, ritrasmissione se manca ACK.
    
- **Sequencing**: usa sequence numbers per ordinare.
    
- **Flow control**: usa **window size** (sliding window).
    

#### Header TCP (campi da conoscere)

- Source port / Destination port (16 bit ciascuno)
    
- Sequence number / Acknowledgment number
    
- Flag: **SYN, ACK, FIN**
    
- **Window Size**
    
![[Screenshot_4 4.png]]
#### Three-way handshake (setup)

- **SYN → SYN-ACK → ACK**
    
![[Screenshot_5 5.png]]
#### Termination (chiusura)

- **FIN → ACK → FIN → ACK**
    
![[Screenshot_7 1.png]]
#### Forward acknowledgment (concetto)

- L’ACK indica **il prossimo sequence number atteso** (es. ricevuto 27 → ACK 28).
    

### UDP (User Datagram Protocol)

- **Connectionless**: nessuna connessione prima dei dati.
    
- **No reliability**: niente ACK, niente retransmission.
    
- **No sequencing**: nessun campo sequence.
    
- **No flow control**: niente window/sliding window.
    
- Header minimale: source port, dest port, length, checksum.
    
![[Screenshot_9.png]]
### Quando usare TCP vs UDP (criterio)

- **TCP**: quando serve affidabilità (es. download file).
    
- **UDP**: quando conta la latenza (es. voce/video real-time).
    
- Alcune app usano UDP ma implementano affidabilità “nell’app” (es. **TFTP**).
    
- Alcune usano **TCP e UDP** a seconda dei casi (es. **DNS**).
    
![[Screenshot_8 1.png]]
## CLI Core

(Nessun comando CLI mostrato nei sottotitoli per questo video.)


## Frase unica da memorizzare

> **TCP sacrifica performance per affidabilità; UDP sacrifica affidabilità per velocità.**

Se riesci a dire **le due definizioni** e questa frase, **hai coperto il requisito CCNA**.


## Common Mistakes

- Confondere “porta” L4 con “porta” fisica di uno switch/router.
    
- Dimenticare che **TCP e UDP** usano entrambi **port numbers** (addressing + multiplexing).
    
- Pensare che UDP “non funzioni”: è **best-effort** (scelta intenzionale).
    
- Sbagliare i range IANA: **ephemeral = 49152–65535**.
    
- Su TCP: dimenticare che l’ACK è **forward** (es. 27 → **28**).
    

## Synthesis

TCP aggiunge connessione, affidabilità, sequencing e flow control (più overhead); UDP è connectionless e best-effort (meno overhead), ma entrambi usano porte per identificare applicazioni e gestire sessioni.

---

## Port numbers citati (da memorizzare)

### TCP

- FTP: `20, 21`
    
- SSH: `22`
    
- Telnet: `23`
    
- SMTP: `25`
    
- HTTP: `80`
    
- POP3: `110`
    
- HTTPS: `443`
    

### UDP

- DHCP: `67, 68`
    
- TFTP: `69`
    
- SNMP: `161, 162`
    
- Syslog: `514`
    

### TCP + UDP

- DNS: `53` (di solito UDP, ma può usare TCP in alcuni casi)