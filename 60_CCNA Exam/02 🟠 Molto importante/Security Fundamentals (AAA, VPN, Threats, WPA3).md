---
tags: [ccna, exam, security]
priorita: molto-importante
dominio: Security Fundamentals
stato: da-ripassare
---

## Obiettivo
Concetti di sicurezza che l'esame chiede a parole, senza CLI complessa. Pesa circa il **15%**. Le funzioni L2 di switch sono in [[DHCP Snooping]], [[DAI (Dynamic ARP Inspection)]], [[Port Security (Layer 2)]].

## 1. Terminologia
| Termine | Significato |
|---|---|
| **Asset** | Ciò che va protetto |
| **Vulnerability** | Debolezza (bug, config errata, password debole) |
| **Threat** | Chi/cosa potrebbe sfruttarla |
| **Exploit** | Il metodo/codice che la sfrutta |
| **Risk** | Probabilità × impatto che la minaccia sfrutti la vulnerabilità |
| **Mitigation** | Contromisura che riduce il rischio |

**CIA triad**: *Confidentiality*, *Integrity*, *Availability*.

## 2. Attacchi comuni
- **Reconnaissance** (ping sweep, port scan), **DoS/DDoS**, **spoofing** (IP/MAC/ARP), **reflection/amplification**, **man-in-the-middle**.
- **Social engineering**: phishing, spear phishing, whaling, vishing, smishing, pretexting, tailgating.
- **Malware**: virus (serve un ospite), worm (si auto-replica in rete), trojan (finto legittimo), ransomware.
- **Password attacks**: brute force, dictionary. Difesa: **MFA**, password lunghe, lockout.

## 3. AAA
| | Funzione | Esempio |
|---|---|---|
| **Authentication** | *Chi sei?* | Username/password, certificato |
| **Authorization** | *Cosa puoi fare?* | Livello di privilegio, comandi |
| **Accounting** | *Cosa hai fatto?* | Log di sessione e comandi |

| | RADIUS | TACACS+ |
|---|---|---|
| Standard | Aperto (IETF) | Cisco |
| Trasporto | **UDP** 1812/1813 | **TCP 49** |
| Cifratura | Solo la password | **Intero pacchetto** |
| AAA | Autenticazione + autorizzazione combinate | **Separate** (più granulare) |

**802.1X** = port-based access control: *supplicant* (client) → *authenticator* (switch/AP) → *authentication server* (RADIUS).

## 4. Password e accesso ai device
- `enable secret` (hash, sicuro) > `enable password` (in chiaro; `service password-encryption` è solo tipo 7, reversibile).
- `login local` + `username … secret …` per console/VTY; `exec-timeout`; banner.
- SSH invece di Telnet.

## 5. VPN
| | Site-to-Site | Remote Access |
|---|---|---|
| Tra | Due reti (router/firewall) | Utente ↔ rete |
| Tecnologia | **IPsec** (spesso + GRE) | **SSL/TLS** (AnyConnect) o IPsec |
| Client | Non serve (trasparente agli host) | Software client |

**IPsec**: **ESP** (cifra + autentica) vs AH (solo autentica); modalità *tunnel* vs *transport*; IKE negozia le SA.

## 6. Firewall / IPS
- **Firewall stateful**: tiene traccia delle connessioni (ACL = stateless).
- **NGFW**: aggiunge application awareness, IPS, URL filtering, malware protection.
- **IPS** = *inline*, blocca. **IDS** = *passivo*, solo alert.

## 7. Wireless security
| | Auth | Cifratura | Note |
|---|---|---|---|
| WEP | — | RC4 | Rotto |
| WPA | PSK / 802.1X | TKIP | Legacy |
| **WPA2** | PSK / 802.1X | **AES-CCMP** | Standard attuale |
| **WPA3** | **SAE** (al posto di PSK) / 802.1X | **AES-GCMP** | Forward secrecy, PMF obbligatorio |

`Personal` = PSK/SAE; `Enterprise` = 802.1X con RADIUS. Dettagli: [[Day 57 — Wireless Security (WPA-WPA2-WPA3)]].

## 8. Security program elements
Un programma di sicurezza non è solo tecnologia: coinvolge le persone.

| Elemento | Scopo | Esempi |
|---|---|---|
| **User awareness** | Rendere gli utenti *consapevoli* di minacce e regole | Campagne anti-phishing, promemoria, policy d'uso |
| **User training** | Formazione *formale* e periodica | Corsi obbligatori, formazione per ruolo, simulazioni di phishing |
| **Physical access control** | Impedire l'accesso fisico a sale e apparati | Badge, serrature, **biometria**, videosorveglianza, guardie, **mantrap**, armadi rack chiusi |

> [!INFO] Perché conta
> Molti attacchi (phishing, social engineering, tailgating) aggirano la tecnologia: l'anello debole è l'utente. Il controllo fisico protegge anche la **console** degli apparati.

## 9. Password policy e accesso locale
**Elementi di una password policy**
- **Management:** cambio periodico, niente riuso, blocco dopo tentativi falliti, archiviazione con **hash + salt**, uso di un *password manager*.
- **Complexity:** lunghezza adeguata (≥ 12 caratteri), maiuscole/minuscole/numeri/simboli, niente parole del dizionario o dati personali.
- **Alternative alle sole password:**
  - **MFA** (multifactor): qualcosa che **sai** (password) + che **hai** (token, app, smartphone) + che **sei** (biometria).
  - **Certificati digitali** (PKI, es. EAP-TLS/802.1X).
  - **Biometria** (impronta, volto).

**Device access control con password locali (Cisco IOS)**
```
! hash (tipo 5/8/9), non reversibile
enable secret StrongPass1

! cifra le password in chiaro nel config (tipo 7, debole)
service password-encryption
security passwords min-length 10

! anti brute-force
login block-for 120 attempts 3 within 60

line console 0
 password ConsPass
 login
 exec-timeout 5 0
 logging synchronous
line vty 0 15
 ! usa gli utenti locali
 login local
 transport input ssh
username admin secret UserPass1
banner motd # Accesso riservato #
```
- `enable secret` **vince** su `enable password` (che resta in chiaro).
- Tipo 7 = reversibile; tipo 5 = MD5; **tipo 8/9** = PBKDF2 / scrypt (più robusti).
- Senza `login` la linea non chiede la password; con `login local` servono gli `username`.

## 10. Sicurezza Layer 2: i tre guardiani a confronto
> [!ABSTRACT] L'analogia della reception
> Lo switch è la reception di un edificio: **Port Security** = il *badge* all'ingresso (controlla l'hardware/MAC), **DHCP Snooping** = l'*assegnazione delle scrivanie* (registro ufficiale di chi ha quale IP), **DAI** = il *controllo dei cartellini* (impedisce a un ospite di dire "sono io il capo!").

| | **Port Security** | **DHCP Snooping** | **DAI** |
|---|---|---|---|
| **Cosa valida** | **MAC** sulla porta | **Messaggi DHCP** dei server (Offer/ACK) | **Pacchetti ARP** |
| **Blocca** | Cambi di PC non autorizzati, **MAC flooding** | **Rogue DHCP** (gateway falsi), starvation | **ARP spoofing / poisoning** (MITM) |
| **Punto cieco** | Non guarda gli IP: MAC clonato o IP statico falso passano | Non protegge da IP statici | Non rileva un MAC clonato |
| **Trappola di default** | — | Tutte le porte **untrusted**: imposta a mano la porta del router/server | Senza `trust` sulla porta del router **isoli la rete** |
| **Dipendenza** | Indipendente | Crea la **binding table** | **Dipende** dalla binding table |

Si attivano in quest'ordine (Snooping → DAI) e **si completano a vicenda**. Configurazioni in [[Port Security (Layer 2)]], [[DHCP Snooping]], [[DAI (Dynamic ARP Inspection)]].

> [!question] Con Port Security serve ancora il DHCP Snooping?
> **Sì.** Port Security si ferma al MAC: un utente autorizzato con un IP statico falso (es. l'IP del server) passa. Lo Snooping vincola la distribuzione degli IP.

> [!question] Con `validate src-mac` nel DAI serve ancora Port Security?
> **Sì.** Il DAI controlla solo che il MAC nell'header sia uguale a quello dentro il messaggio ARP. Se clono il MAC della vittima sul mio portatile, il pacchetto è coerente. Solo Port Security rileva il cambio fisico di macchina sulla porta.

> [!question] Differenza tra "modalità" e "target" nel DAI?
> `ip arp inspection validate …` è la **modalità** (globale: controlli più severi ma inerti da soli). `ip arp inspection vlan X` è il **target**: attiva il DAI su quella VLAN.

## Common Mistakes
- Scambiare **threat** e **vulnerability**.
- RADIUS = UDP, TACACS+ = TCP 49 e cifra tutto.
- Pensare che `service password-encryption` sia forte (è reversibile).
- IDS ≠ IPS: l'IDS non blocca.
- **Awareness ≠ training**: l'awareness è continua e informale, il training è formale e strutturato.
- `enable password` resta in chiaro: usa sempre **`enable secret`**.

## 🎯 Synthesis
Sicurezza = ridurre il rischio (vulnerabilità × minaccia) con AAA (chi/cosa/quanto), VPN per il traffico in transito e firewall/IPS per filtrare e bloccare; sullo switch, Port Security + DHCP Snooping + DAI coprono ciascuno il punto cieco dell'altro.

Approfondimenti: [[Day 48 — Security Fundamentals]]
