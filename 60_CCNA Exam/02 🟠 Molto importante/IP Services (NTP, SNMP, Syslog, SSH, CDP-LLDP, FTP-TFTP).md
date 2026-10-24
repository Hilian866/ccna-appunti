---
tags: [ccna, exam, ip-services]
priorita: molto-importante
dominio: IP Services
stato: da-ripassare
---

## Obiettivo
Riepilogo dei servizi di gestione e monitoraggio dei dispositivi. Domande tipiche: *quale porta/versione/livello?*

## Tabella riassuntiva

| Servizio | Porta | Punto chiave |
|---|---|---|
| NTP | UDP 123 | Stratum: **0** = orologio atomico/GPS, il server ha stratum basso, ogni hop +1 (max 15; 16 = non sincronizzato). |
| SNMP | UDP 161 (agent), **162 (trap)** | Manager ↔ Agent, **MIB** con **OID**. `get`, `set`, `trap`, `inform`. |
| Syslog | UDP 514 | Livelli **0–7**. |
| SSH | TCP 22 | Sostituisce Telnet (TCP 23, in chiaro). Richiede hostname + domain-name + chiavi RSA. |
| TFTP | UDP 69 | Senza autenticazione, no directory, semplice. |
| FTP | TCP 20 (dati) / 21 (controllo) | Autenticazione, comandi, directory. |
| CDP | L2 (Cisco) | Multicast 01:00:0C:CC:CC:CC, ogni **60 s**, holdtime 180 s. |
| LLDP | L2 (IEEE 802.1AB) | Multicast 01:80:C2:00:00:0E, ogni **30 s**, holdtime 120 s. Multivendor. |

## Syslog — severity
| # | Nome | | # | Nome |
|---|---|---|---|---|
| 0 | Emergency | | 4 | Warning |
| 1 | Alert | | 5 | Notification |
| 2 | Critical | | 6 | Informational |
| 3 | Error | | 7 | Debugging |

**Facility**: indica *quale sottosistema* ha generato il messaggio (es. `kern`, `user`, `mail`, `daemon`, `auth`, `syslog`, `local0`–`local7`). Cisco usa di default **`local7`**. Il campo PRI del messaggio = `facility × 8 + severity`. Il server syslog usa facility e severity per **filtrare e smistare** i log.

Mnemonico: **E**very **A**wesome **C**isco **E**ngineer **W**ill **N**eed **I**ce **C**ream. Il livello impostato include **quelli più bassi** (es. `logging trap 4` → 0–4).

```
logging host 10.0.0.50
logging trap warnings

! cambia la facility inviata al server
logging facility local6
service timestamps log datetime msec
```

## SNMP
- **v1 / v2c**: autenticazione con *community string* in chiaro.
- **v3**: aggiunge **authentication + encryption** (`noAuthNoPriv`, `authNoPriv`, `authPriv`). Se la domanda chiede sicurezza → v3.
- **Trap** = notifica senza conferma · **Inform** = con conferma (v2c/v3).

## NTP
```
ntp server 10.0.0.1
ntp master 3           ! il device diventa fonte (stratum 3)
show ntp status
show ntp associations
```

## SSH
```
hostname R1
ip domain-name lab.local
crypto key generate rsa modulus 2048
username admin secret Cisco123
ip ssh version 2
line vty 0 15
 transport input ssh
 login local
```
Verifica: `show ip ssh`, `show ssh`.

## CDP / LLDP
```
! CDP
show cdp neighbors [detail]
cdp run / no cdp run          ! globale
no cdp enable                 ! per interfaccia

! LLDP
show lldp neighbors [detail]
lldp run
lldp transmit / lldp receive  ! per interfaccia
```
Il `detail` mostra l'**IP di management** del vicino: utile per il troubleshooting.

## Common Mistakes
- Confondere **CDP** (Cisco) con **LLDP** (standard) e i loro timer (60/30 s).
- Dimenticare **domain-name** prima di generare le chiavi RSA (SSH non parte).
- `transport input ssh` senza `login local` → nessun utente valido.
- Trap su UDP **162**, non 161.
- NTP: **stratum più basso = fonte più affidabile**; un client sincronizzato con un server stratum N diventa stratum N+1.

## 🎯 Synthesis
NTP sincronizza l'orologio, Syslog registra (0–7), SNMP monitora (v3 = sicuro), SSH sostituisce Telnet, CDP/LLDP scoprono i vicini a Layer 2.

Approfondimenti: [[Day 36 - Layer 2 Discovery Protocols (CDP & LLDP)]] · [[Day 37 — NTP (Network Time Protocol)]] · [[Day 40 — SNMP (Simple Network Management Protocol)]] · [[Day 41 — Syslog]] · [[Day 42 — Secure Shell (SSH) & Device Management]] · [[Day 43 — FTP & TFTP (File Transfer Protocol)]]
