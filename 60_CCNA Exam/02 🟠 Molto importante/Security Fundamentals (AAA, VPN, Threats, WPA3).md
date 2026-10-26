---
tags: [ccna, exam, security]
priorita: molto-importante
dominio: Security Fundamentals
stato: da-ripassare
---

> [!ABSTRACT] Cosa serve per l'esame
> Dominio **5** (circa il 15% dell'esame): 5.1 concetti chiave (minacce, vulnerabilità, exploit, mitigazione), 5.2 elementi di un programma di sicurezza, 5.3 accesso ai dispositivi con password locali, 5.4 password policy e alternative (MFA, certificati, biometria), 5.5 VPN IPsec site-to-site e remote access, 5.8 AAA, 5.9 WPA, WPA2 e WPA3.
> Quasi tutto si chiede a parole: definizioni, confronti, "quale attacco è questo". La CLI serve solo per le password locali. Gli altri punti del dominio hanno note proprie: ACL (5.6) in [[ACL - Access Control Lists (Standard & Extended)]], sicurezza Layer 2 (5.7) in [[Port Security (Layer 2)]], [[DHCP Snooping]] e [[DAI (Dynamic ARP Inspection)]], WLAN dalla GUI (5.10) in [[Wireless]].

## 1. Concetti chiave

| Termine | Significato | Esempio |
| :--- | :--- | :--- |
| **Vulnerability** | una debolezza | software non aggiornato, password debole |
| **Threat** | chi o cosa potrebbe sfruttarla | un attaccante, un malware |
| **Exploit** | il mezzo con cui la si sfrutta | il codice che usa un bug noto |
| **Mitigation** | la contromisura che riduce il rischio | aggiornamento, ACL, MFA |
| Risk | probabilità che la minaccia sfrutti la vulnerabilità, per l'impatto | |

La **CIA triad** riassume gli obiettivi: confidentiality (solo chi è autorizzato legge), integrity (i dati non vengono alterati), availability (il servizio resta disponibile).

## 2. Gli attacchi

| Attacco | Come funziona |
| :--- | :--- |
| **DoS / DDoS** | sommerge un servizio di traffico (TCP SYN flood: tante connessioni aperte e mai completate). Nel DDoS l'attacco parte da molti host, spesso una **botnet** |
| **Spoofing** | falsifica l'indirizzo sorgente: IP, MAC (es. DHCP starvation) o ARP |
| **Reflection / amplification** | l'attaccante manda richieste con l'IP sorgente della vittima: le risposte (più grandi delle richieste, nell'amplification) vanno tutte alla vittima |
| **Man-in-the-middle** | l'attaccante si mette tra due host e legge o modifica il traffico (es. ARP poisoning) |
| **Reconnaissance** | raccolta di informazioni prima dell'attacco: ping sweep, port scan, ricerche pubbliche (whois, nslookup) |
| **Malware** | **virus** (infetta altri file, si diffonde con l'azione dell'utente), **worm** (si diffonde da solo in rete), **trojan** (si presenta come software legittimo), ransomware |
| **Social engineering** | sfrutta le persone: **phishing** (email di massa), **spear phishing** (mirato), **whaling** (mirato ai dirigenti), **vishing** (telefono), **smishing** (SMS), watering hole (sito compromesso visitato dalle vittime), **tailgating** (entrare dietro a qualcuno con badge) |
| **Password attack** | indovinare le password: **dictionary** (parole comuni) o **brute force** (tutte le combinazioni) |

## 3. Programma di sicurezza

La tecnologia non basta: molti attacchi colpiscono le persone.

| Elemento | Cos'è | Esempi |
| :--- | :--- | :--- |
| **User awareness** | tenere gli utenti informati, in modo continuo e informale | email di avviso, campagne di phishing simulate, poster |
| **User training** | formazione **formale** e periodica | corsi obbligatori, formazione per ruolo |
| **Physical access control** | impedire l'accesso fisico a sale e apparati | badge, serrature, biometria, videosorveglianza, mantrap, rack chiusi |

Il controllo fisico protegge anche la **console**: chi ha accesso fisico a un router può recuperarne la password.

## 4. Password policy e alternative

Una password policy definisce:

- **Gestione**: cambio periodico, niente riuso, blocco dopo troppi tentativi, salvataggio come hash.
- **Complessità**: lunghezza minima (meglio lunga che complicata), maiuscole, minuscole, numeri e simboli, niente parole del dizionario o dati personali.

Le alternative alle sole password:

- **MFA** (multi-factor): almeno due fattori di tipo **diverso**, tra qualcosa che sai (password, PIN), che hai (smartphone, token) e che sei (impronta, volto). Password più PIN non è MFA: sono due cose che sai.
- **Certificati digitali**: una CA (certification authority) firma il certificato che prova l'identità. Si usano per esempio con 802.1X (EAP-TLS).
- **Biometria**: impronta, volto, iride.

## 5. Password locali sui dispositivi Cisco

```ios
! Password per la modalità privilegiata, salvata come hash
R1(config)# enable secret Cisco123!

! Utente locale con password in hash
R1(config)# username admin secret Admin123!

! Console: chiede l'utente locale, disconnette dopo 5 minuti di inattività
R1(config)# line console 0
R1(config-line)# login local
R1(config-line)# exec-timeout 5 0

! Linee remote: solo SSH, con utenti locali
R1(config)# line vty 0 15
R1(config-line)# login local
R1(config-line)# transport input ssh

! Cifra le password scritte in chiaro (tipo 7: debole)
R1(config)# service password-encryption

! Lunghezza minima delle password
R1(config)# security passwords min-length 10

! Dopo 3 tentativi falliti in 60 s, blocca i login per 120 s
R1(config)# login block-for 120 attempts 3 within 60
```

| Comando o tipo | Come è salvata | Sicuro? |
| :--- | :--- | :--- |
| `enable password` | in chiaro (o tipo 7) | no |
| **Tipo 7** (`service password-encryption`) | cifratura **reversibile** | no: si decifra in un attimo |
| **Tipo 5** (`enable secret`, default) | hash MD5 | discreto |
| **Tipo 8 / 9** | hash PBKDF2 / scrypt | sì, il migliore |

- Se ci sono sia `enable secret` sia `enable password`, **vince `enable secret`**.
- Sulle linee: `password` + `login` chiede solo una password; `login local` chiede utente e password definiti con `username`.

## 6. AAA

| | Domanda | Esempio |
| :--- | :--- | :--- |
| **Authentication** | chi sei? | utente e password, certificato |
| **Authorization** | cosa puoi fare? | livello di privilegio, comandi permessi |
| **Accounting** | cosa hai fatto? | registro di accessi e comandi |

Con AAA centralizzato gli utenti stanno su un server, non su ogni dispositivo.

| | RADIUS | TACACS+ |
| :--- | :--- | :--- |
| Standard | aperto (IETF) | Cisco |
| Trasporto | **UDP** 1812 (autenticazione), 1813 (accounting) | **TCP 49** |
| Cosa cifra | solo la **password** | **tutto il pacchetto** |
| Autenticazione e autorizzazione | insieme | **separate** (più controllo) |
| Uso tipico | accesso degli **utenti alla rete** (802.1X, VPN, Wi-Fi) | accesso degli **amministratori** ai dispositivi |

Il server AAA di Cisco è **ISE** (Identity Services Engine).

**802.1X** controlla l'accesso alla rete porta per porta, in tre ruoli:

1. **Supplicant**: il client che vuole accedere.
2. **Authenticator**: lo switch o l'AP, che fa da intermediario.
3. **Authentication server**: il server RADIUS che decide.

Il supplicant parla con l'authenticator con **EAP** (EAPoL sulla LAN); l'authenticator inoltra al server con RADIUS.

## 7. VPN

Una VPN crea un tunnel cifrato su una rete non sicura (Internet).

| | Site-to-site | Remote access |
| :--- | :--- | :--- |
| Collega | **due reti** (router o firewall ai due capi) | **un singolo host** alla rete aziendale |
| Durata | permanente | quando l'utente si collega |
| Protocollo | **IPsec** | di solito **TLS** (es. Cisco AnyConnect), anche IPsec |
| Software sugli host | nessuno: il tunnel è trasparente | serve un client VPN |

Nella site-to-site, gli host mandano pacchetti normali; il router li cifra, li incapsula in un nuovo pacchetto IP verso l'altro router, che li decifra e li consegna.

- **IPsec da solo** porta solo traffico **unicast**: niente multicast, quindi niente protocolli di routing come OSPF.
- **GRE over IPsec**: GRE incapsula anche multicast e broadcast (ma non cifra), IPsec poi cifra il tutto.
- **DMVPN** (Cisco): crea in automatico i tunnel diretti tra le filiali, senza configurare a mano una full mesh. Si configura una topologia hub-and-spoke.

Dettagli sulle WAN in [[Cloud, Virtualizzazione & WAN]].

## 8. Firewall e IPS

- **ACL**: stateless, controlla ogni pacchetto da solo.
- **Firewall stateful**: ricorda le connessioni aperte dall'interno e lascia rientrare solo le risposte.
- **NGFW** (next-generation firewall): aggiunge il riconoscimento delle applicazioni, IPS, filtro URL e protezione da malware.
- **IPS**: in linea, blocca il traffico sospetto. **IDS**: riceve una copia del traffico e avvisa soltanto.

## 9. Sicurezza del wireless

| | Autenticazione | Cifratura | Stato |
| :--- | :--- | :--- | :--- |
| WEP | chiave statica | RC4 | rotto |
| WPA | PSK o 802.1X | **TKIP** | superato |
| **WPA2** | PSK o 802.1X | **CCMP** (AES) | lo standard più diffuso |
| **WPA3** | **SAE** o 802.1X | **GCMP** (AES) | il più sicuro |

- **Personal** usa una password condivisa (PSK in WPA2, SAE in WPA3); **Enterprise** usa 802.1X con un server RADIUS.
- WPA3 aggiunge **SAE** (protegge dagli attacchi a dizionario sulla password), **forward secrecy** (una password scoperta non decifra il traffico registrato prima) e **PMF** obbligatorio (frame di gestione protetti).

Dettagli in [[Wireless]], sezione 7.

## 10. Le tre protezioni Layer 2 a confronto

| | Port Security | DHCP snooping | DAI |
| :--- | :--- | :--- | :--- |
| Controlla | i **MAC** su una porta | i **messaggi DHCP** sulle porte untrusted | i **messaggi ARP** sulle porte untrusted |
| Ferma | MAC flooding, dispositivi non autorizzati | rogue server DHCP, starvation | ARP poisoning (man-in-the-middle) |
| Non vede | gli IP: un IP statico falso passa | gli host con IP statico | un MAC clonato con ARP coerenti |
| Dipende da | niente | niente; crea la binding table | la **binding table** di DHCP snooping |

Si usano insieme: ognuna copre ciò che le altre non vedono. DHCP snooping va attivato **prima** di DAI.

## ⚠️ Trappole d'esame

> [!WARNING] Gli errori più frequenti
> 1. **Threat e vulnerability**: la vulnerabilità è la debolezza, la minaccia è chi la sfrutta.
> 2. **RADIUS e TACACS+**: RADIUS è UDP e cifra solo la password; TACACS+ è TCP 49 e cifra tutto.
> 3. **`service password-encryption`**: tipo 7, reversibile. Per l'enable si usa `enable secret`.
> 4. **IDS e IPS**: l'IDS non blocca.
> 5. **Awareness e training**: l'awareness è continua e informale, il training formale.
> 6. **MFA**: due fattori dello **stesso** tipo (password e PIN) non sono MFA.
> 7. **IPsec e multicast**: IPsec da solo non porta multicast; serve GRE over IPsec.
> 8. **Virus e worm**: il worm si diffonde da solo, il virus ha bisogno di un file ospite e dell'utente.

## Esercizi

> [!QUESTION]- Un'email finta, indirizzata solo al direttore finanziario, chiede un bonifico urgente. Che attacco è?
> Whaling (spear phishing mirato a un dirigente).

> [!QUESTION]- L'attaccante manda query DNS con l'IP sorgente della vittima a molti server, che rispondono con pacchetti grandi. Che attacco è?
> Reflection e amplification (un DDoS).

> [!QUESTION]- Serve un AAA per gli amministratori dei router, con autorizzazione comando per comando e il pacchetto interamente cifrato. RADIUS o TACACS+?
> TACACS+.

> [!QUESTION]- Un dipendente in viaggio deve accedere alla rete aziendale dal portatile. Che VPN, con che protocollo tipico?
> Remote access, con TLS (client come AnyConnect).

> [!QUESTION]- Nella config compaiono `enable password Cisco` e `enable secret Class`. Che password chiede il router per entrare in modalità privilegiata?
> `Class`: `enable secret` ha la precedenza.

> [!QUESTION]- In 802.1X, che ruolo ha lo switch?
> Authenticator: inoltra le credenziali del supplicant al server RADIUS.

## Check da esame

- [ ] Tre elementi della CIA triad? **Confidentiality, integrity, availability**.
- [ ] Porta e trasporto di TACACS+? **TCP 49**.
- [ ] RADIUS cifra? **Solo la password**.
- [ ] I tre fattori dell'MFA? **Qualcosa che sai, che hai, che sei**.
- [ ] VPN tra due sedi? **Site-to-site, con IPsec**.
- [ ] Cifratura di WPA2? **CCMP (AES)**. E di WPA3? **GCMP (AES), con SAE**.
- [ ] Password tipo 7? **Reversibile, debole**.
- [ ] I tre ruoli di 802.1X? **Supplicant, authenticator, authentication server**.

## 🎯 Synthesis

Il rischio nasce da una minaccia che sfrutta una vulnerabilità; lo si riduce con tecnologia (AAA, VPN, firewall e IPS, protezioni Layer 2) e con le persone (awareness, training, controllo fisico). Le password locali vanno in hash (`enable secret`, `username … secret`), meglio con MFA o certificati. TACACS+ (TCP 49, cifra tutto) per gli amministratori, RADIUS (UDP) per gli utenti. IPsec per le site-to-site, TLS per il remote access. Wi-Fi: WPA2 con CCMP, WPA3 con GCMP e SAE.

Approfondimenti: [[Day 48 — Security Fundamentals]], [[Day 53 — WAN Architectures & VPNs]], [[Day 57 — Wireless Security (WPA-WPA2-WPA3)]].
