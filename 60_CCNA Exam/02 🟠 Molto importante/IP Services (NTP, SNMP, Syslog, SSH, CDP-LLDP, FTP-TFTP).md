---
tags: [ccna, exam, ip-services]
priorita: molto-importante
dominio: IP Services
stato: da-ripassare
---

> [!ABSTRACT] Cosa serve per l'esame
> Blueprint **2.3** (CDP e LLDP), 4.2 (NTP in modalità client e server), 4.4 (funzione di SNMP), 4.5 (syslog: facility e livelli), 4.8 (accesso remoto con SSH) e 4.9 (TFTP e FTP).
> Le domande tipiche sono "che porta?", "che versione?", "che livello?". CDP, LLDP, NTP e SSH vanno anche saputi configurare e verificare. NAT, DHCP, DNS e QoS hanno note proprie: [[NAT - Network Address Translation]], [[DHCP - Dynamic Host Configuration Protocol]], [[DNS - Domain Name System]], [[QoS]].

## 1. La mappa

| Servizio | Trasporto e porta | Da ricordare |
| :--- | :--- | :--- |
| **NTP** | UDP 123 | stratum: più basso = più affidabile |
| **SNMP** | UDP **161** (agent), **162** (trap e inform, sull'NMS) | v3 è l'unica sicura |
| **Syslog** | UDP 514 | livelli 0-7, 0 il più grave |
| **SSH** | TCP 22 | sostituisce Telnet (TCP 23, in chiaro) |
| **TFTP** | UDP 69 | nessuna autenticazione, niente elenco dei file |
| **FTP** | TCP **21** (controllo), **20** (dati) | utente e password, ma in chiaro |
| **CDP** | Layer 2, Cisco | ogni **60 s**, holdtime 180 s, attivo di default |
| **LLDP** | Layer 2, IEEE 802.1AB | ogni **30 s**, holdtime 120 s, spento di default sui Cisco |

## 2. CDP e LLDP

Servono a scoprire i **vicini diretti**: nome, modello, porta remota, indirizzo IP di gestione. Lavorano a Layer 2 con frame multicast, che uno switch non inoltra: si vedono solo i dispositivi collegati direttamente.

| | CDP | LLDP |
| :--- | :--- | :--- |
| Standard | proprietario Cisco | aperto (IEEE 802.1AB), multivendor |
| Di default sui Cisco | **attivo** | **spento** |
| Invio | ogni 60 s | ogni 30 s |
| Holdtime | 180 s | 120 s |
| Attivazione su interfaccia | un comando (`cdp enable`) | due: `lldp transmit` e `lldp receive` |

```ios
! CDP: spento in globale o su una porta (es. verso Internet: rivela informazioni)
R1(config)# no cdp run
R1(config)# interface g0/0
R1(config-if)# no cdp enable

! Timer di CDP (secondi)
R1(config)# cdp timer 60
R1(config)# cdp holdtime 180

! LLDP: acceso in globale, poi su ogni interfaccia in entrambe le direzioni
R1(config)# lldp run
R1(config)# interface g0/1
R1(config-if)# lldp transmit
R1(config-if)# lldp receive

! Timer di LLDP (secondi)
R1(config)# lldp timer 30
R1(config)# lldp holdtime 120
```

```ios
R1# show cdp neighbors
Device ID    Local Intrfce   Holdtme   Capability   Platform    Port ID
SW1          Gig 0/1         152       S I          2960        Gig 0/1
R2           Gig 0/0         163       R B          ISR4331     Gig 0/0/0
```

- **Local Intrfce** è la porta di R1; **Port ID** quella del vicino.
- **Capability**: R router, S switch, I IGMP, B bridge.
- `show cdp neighbors detail` (o `show cdp entry R2`) aggiunge l'**indirizzo IP** del vicino e la versione di IOS.
- Comandi analoghi per LLDP: `show lldp neighbors [detail]`.

## 3. NTP

Gli orologi dei dispositivi devono coincidere: senza, i timestamp di syslog non si possono confrontare e alcuni servizi (certificati, autenticazione) non funzionano.

Lo **stratum** dice quanto un orologio è lontano dalla fonte di riferimento:

| Stratum | Chi |
| :--- | :--- |
| 0 | orologi atomici, GPS (non parlano NTP direttamente) |
| 1 | server collegati direttamente a uno stratum 0 |
| 2 | client di uno stratum 1, e così via: ogni salto aggiunge 1 |
| 15 | l'ultimo valido |
| **16** | **non sincronizzato**: nessuno lo usa come fonte |

Modalità:

- **Client**: chiede l'ora a un server (`ntp server`). Un dispositivo che si sincronizza fa automaticamente anche da **server** per altri: un client di uno stratum 2 diventa stratum 3.
- **Server senza fonte esterna**: `ntp master` fa usare il proprio orologio come riferimento (stratum **8** di default).
- **Peer** (symmetric active): due dispositivi dello stesso livello si sincronizzano a vicenda, come riserva (`ntp peer`).

```ios
! Client: sincronizza da un server esterno
R1(config)# ntp server 216.239.35.0

! Server: usa il proprio orologio, stratum 8 (default)
R1(config)# ntp master

! Peer: sincronizzazione reciproca con un dispositivo dello stesso livello
R1(config)# ntp peer 10.0.0.2

! Fuso orario (nome, ore di differenza da UTC)
R1(config)# clock timezone CET 1

! Copia l'ora NTP anche nell'orologio hardware (calendar)
R1(config)# ntp update-calendar

! Sorgente fissa per i pacchetti NTP (la loopback non va mai giù)
R1(config)# ntp source loopback 0

! Autenticazione: accetta solo server con la chiave 1
R1(config)# ntp authenticate
R1(config)# ntp authentication-key 1 md5 ChiaveNTP
R1(config)# ntp trusted-key 1
R1(config)# ntp server 10.0.12.1 key 1
```

```ios
! Sincronizzato o no, e proprio stratum
R1# show ntp status

! Server conosciuti: l'asterisco (*) indica quello in uso
R1# show ntp associations

! Ora attuale
R1# show clock
```

A mano: `clock set` (orologio software) e `calendar set` (orologio hardware), dalla modalità privilegiata. Non scala: per questo si usa NTP.

## 4. SNMP

Serve a **monitorare** i dispositivi (CPU, interfacce, errori) e, se permesso, a modificarne la configurazione da un punto centrale.

- **NMS** (Network Management Station): il server di monitoraggio, con il **manager** SNMP.
- **Agent**: il software SNMP sul dispositivo gestito.
- **MIB**: la struttura delle variabili del dispositivo. Ogni variabile ha un **OID**, un identificativo numerico (es. `1.3.6.1.2.1.1.5` è il nome del dispositivo).

| Messaggio | Direzione | Scopo |
| :--- | :--- | :--- |
| **Get**, GetNext, GetBulk | NMS → agent | leggere variabili (GetBulk: tante in una volta, da v2c) |
| **Set** | NMS → agent | modificare una variabile |
| **Trap** | agent → NMS | notifica di un evento, **senza conferma** |
| **Inform** | agent → NMS | notifica **con conferma** (da v2c) |
| Response | agent → NMS | risposta a Get e Set |

| Versione | Sicurezza |
| :--- | :--- |
| v1 | community string in chiaro |
| v2c | community string in chiaro; aggiunge GetBulk e Inform |
| **v3** | utenti con **autenticazione** e **cifratura** (livelli noAuthNoPriv, authNoPriv, **authPriv**) |

```ios
! Community di sola lettura e di lettura-scrittura (v2c)
R1(config)# snmp-server community LETTURA ro
R1(config)# snmp-server community SCRITTURA rw

! Dove mandare le trap, e quali
R1(config)# snmp-server host 192.168.1.10 version 2c LETTURA
R1(config)# snmp-server enable traps
```

## 5. Syslog

Raccoglie i messaggi di log dei dispositivi.

```text
*Feb 11 12:45:20.124: %LINEPROTO-5-UPDOWN: Line protocol on Interface GigabitEthernet0/0, changed state to up
```

Formato: `numero di sequenza: timestamp: %FACILITY-SEVERITY-MNEMONIC: descrizione`. Qui la facility è LINEPROTO, la severity 5 (notification), il mnemonic UPDOWN.

| Livello | Nome | | Livello | Nome |
| :--- | :--- | :--- | :--- | :--- |
| **0** | Emergency | | 4 | Warning |
| 1 | Alert | | 5 | Notification |
| 2 | Critical | | 6 | Informational |
| 3 | Error | | **7** | Debugging |

- Mnemonico: **E**very **A**wesome **C**isco **E**ngineer **W**ill **N**eed **I**ce **C**ream.
- Un livello configurato **include tutti quelli più gravi**: `logging trap 4` manda i messaggi da 0 a 4.
- La **facility** indica la parte del sistema che ha generato il messaggio (OSPF, LINEPROTO, SYS). Verso un server esterno Cisco usa di default la facility **local7**.

Dove vanno i log:

| Destinazione | Comando | Nota |
| :--- | :--- | :--- |
| Console | `logging console 6` | attivo di default |
| Sessioni VTY (SSH/Telnet) | `logging monitor 6` | si vedono solo dopo `terminal monitor`, da ripetere a ogni connessione |
| Buffer in RAM | `logging buffered 8192 6` | si leggono con `show logging` |
| Server esterno | `logging host 192.168.1.100` + `logging trap 4` | UDP 514 |

```ios
! Timestamp precisi e numeri di sequenza nei messaggi
R1(config)# service timestamps log datetime msec
R1(config)# service sequence-numbers

! I log non interrompono a metà il comando che stai scrivendo
R1(config)# line console 0
R1(config-line)# logging synchronous
```

Syslog e SNMP sono complementari: syslog registra eventi da analizzare dopo, SNMP misura e avvisa (trap) per il monitoraggio in tempo reale.

## 6. SSH

Telnet manda tutto **in chiaro**, password comprese. SSH cifra la sessione. Si preferisce la **versione 2**.

```ios
! Nome e dominio servono a dare il nome alla chiave RSA
R1(config)# hostname R1
R1(config)# ip domain name lab.local

! Chiavi RSA: almeno 768 bit per SSHv2
R1(config)# crypto key generate rsa modulus 2048

! Utente locale e versione 2
R1(config)# username admin secret Admin123!
R1(config)# ip ssh version 2

! Linee VTY: solo SSH, utenti locali
R1(config)# line vty 0 15
R1(config-line)# login local
R1(config-line)# transport input ssh

! Facoltativo: solo la rete di gestione può collegarsi
R1(config-line)# access-class 1 in
```

```ios
! Versione attiva, chiavi, timeout
R1# show ip ssh

! Sessioni SSH aperte
R1# show ssh
```

Da un altro router: `ssh -l admin 10.0.0.1`. Uno switch Layer 2 per essere gestito da remoto ha bisogno di un indirizzo su una SVI e di `ip default-gateway`.

## 7. FTP e TFTP

Servono a copiare file da e verso i dispositivi: immagini IOS, backup della configurazione.

| | TFTP | FTP |
| :--- | :--- | :--- |
| Trasporto | **UDP 69** | **TCP 21** (controllo) e **20** (dati) |
| Autenticazione | nessuna | utente e password (in chiaro) |
| Funzioni | solo copia da e verso il server | elenco file, cartelle, rinomina, cancella |
| Affidabilità | conferma ogni blocco (lock-step) | quella di TCP |

FTP usa due connessioni: una di **controllo** (porta 21) per i comandi, una per i **dati**.

- **Active**: è il server ad aprire la connessione dati verso il client, dalla porta 20. Un firewall o un NAT davanti al client la blocca.
- **Passive**: è il client ad aprire anche la connessione dati, verso una porta indicata dal server. Funziona dietro firewall.

Aggiornamento di IOS:

```ios
! Spazio libero e immagine attuale
R1# show flash

! Copia la nuova immagine dal server TFTP (chiede indirizzo e nome del file)
R1# copy tftp: flash:

! Con FTP servono le credenziali
R1(config)# ip ftp username cisco
R1(config)# ip ftp password cisco
R1# copy ftp: flash:

! Avvio dalla nuova immagine, poi salva e riavvia
R1(config)# boot system flash:isr4300-universalk9.17.09.04a.SPA.bin
R1# copy running-config startup-config
R1# reload

! Dopo la verifica (show version), cancella la vecchia immagine
R1# delete flash:vecchia-immagine.bin
```

L'IOS sta in **flash:**, la startup-config in **NVRAM:** (`show file systems` li elenca tutti).

## ⚠️ Trappole d'esame

> [!WARNING] Gli errori più frequenti
> 1. **Timer di CDP e LLDP**: CDP 60/180 s, LLDP 30/120 s.
> 2. **LLDP su Cisco**: spento di default; per interfaccia servono `transmit` e `receive`.
> 3. **Porte SNMP**: l'agent ascolta sulla 161, le trap arrivano all'NMS sulla 162.
> 4. **Trap e inform**: solo l'inform viene confermato.
> 5. **Livelli syslog**: 0 è il più grave; `logging trap 4` include 0-4, non 4-7.
> 6. **SSH senza dominio**: `crypto key generate rsa` fallisce senza `ip domain name`.
> 7. **Stratum**: più basso è meglio; 16 significa non sincronizzato.
> 8. **TFTP**: UDP, niente autenticazione; FTP è TCP ma comunque in chiaro.
> 9. **Log via SSH**: senza `terminal monitor` non compaiono.

## Esercizi

> [!QUESTION]- R2 riceve l'ora da R1, che la riceve da un server stratum 2. Che stratum ha R2?
> 4 (server 2, R1 3, R2 4).

> [!QUESTION]- Con `logging trap warnings`, quali messaggi arrivano al server?
> Quelli dei livelli da 0 a 4.

> [!QUESTION]- Vuoi che il dispositivo avvisi l'NMS di un evento e che l'NMS confermi la ricezione. Che messaggio SNMP serve?
> Inform.

> [!QUESTION]- Sei collegato in SSH e non vedi i messaggi di log. Perché?
> Manca `terminal monitor` nella sessione.

> [!QUESTION]- `show cdp neighbors` mostra R2 con Local Intrfce Gig 0/0 e Port ID Gig 0/0/0. Su che porta di R2 sei collegato?
> Gig 0/0/0 (Port ID è la porta del vicino).

> [!QUESTION]- Un client FTP dietro un firewall non riesce a scaricare file, ma si autentica. Che modalità dovrebbe usare?
> Passive: è il client ad aprire la connessione dati.

## Check da esame

- [ ] Porta di NTP? **UDP 123**.
- [ ] Stratum di default di `ntp master`? **8**.
- [ ] Versione sicura di SNMP? **v3 (authPriv: autenticazione e cifratura)**.
- [ ] Livello syslog 7? **Debugging**. E 0? **Emergency**.
- [ ] Cosa serve prima di generare le chiavi RSA? **Hostname e `ip domain name`**.
- [ ] Porte di FTP? **TCP 21 controllo, 20 dati**. Di TFTP? **UDP 69**.
- [ ] Comando per vedere l'IP dei vicini CDP? **`show cdp neighbors detail`**.

## 🎯 Synthesis

CDP (Cisco, 60 s) e LLDP (standard, 30 s, spento di default) scoprono i vicini diretti. NTP sincronizza gli orologi per stratum (più basso è meglio, 16 = non sincronizzato). SNMP monitora: l'agent risponde sulla 161, trap e inform vanno alla 162, e solo v3 è sicuro. Syslog ha 8 livelli, 0 il più grave, e un livello include quelli più gravi. SSH sostituisce Telnet e richiede dominio, chiavi RSA e `transport input ssh`. TFTP (UDP 69) è semplice e senza autenticazione, FTP (TCP 20/21) ha utenti e comandi.

Approfondimenti: [[Day 36 - Layer 2 Discovery Protocols (CDP & LLDP)]] · [[Day 37 — NTP (Network Time Protocol)]] · [[Day 40 — SNMP (Simple Network Management Protocol)]] · [[Day 41 — Syslog]] · [[Day 42 — Secure Shell (SSH) & Device Management]] · [[Day 43 — FTP & TFTP (File Transfer Protocol)]]

> [!EXAMPLE] Laboratori pratici
> - [[Day 36 Lab - CDP & LLDP.pkt]]
> - [[Day 37 Lab - NTP.pkt]]
> - [[Day 40 Lab - SNMP.pkt]]
> - [[Day 41 Lab - Syslog.pkt]]
> - [[Day 42 Lab - SSH.pkt]]
> - [[Day 43 Lab - FTP & TFTP.pkt]]
