
### What is it

Panoramica dei **fondamentali di sicurezza** richiesti dal CCNA (non è una cert “cybersecurity”): concetti base, attacchi comuni, password/MFA, **AAA**, e elementi di **security program** aziendale.

---

### What does / How it works

#### Obiettivo “security” (CIA triad)

- **Confidentiality (C)**: dati accessibili solo ad **autorizzati**
    
- **Integrity (I)**: dati **non alterati** da non autorizzati (corretti/autentici)
    
- **Availability (A)**: sistemi **operativi e accessibili** agli autorizzati
    

#### Termini chiave

- **Vulnerability**: debolezza potenziale (da sola non è “un incidente”)
    
- **Exploit**: metodo/strumento che può sfruttare una vulnerability
    
- **Threat**: possibilità reale che una vulnerability venga sfruttata
    
- **Mitigation technique**: contromisura (tecnica, procedurale, fisica)
    

> Nota operativa: “zero rischio” non esiste; si ragiona per **riduzione** del rischio.

---

## Common attacks (categorie + CIA colpita)

### DoS / DDoS (Availability)

- **DoS**: saturare risorse (es. **TCP SYN flood** → riempie la TCP connection table con handshake incompleti)
    
- **DDoS**: stesso concetto ma con **botnet** (molti host infetti)
    
**SYN flood** (idea):

- Attaccante invia molti **SYN**
    
- Target risponde **SYN-ACK** e aspetta **ACK** finale che non arriva
    
- Tabella connessioni si riempie → **servizio indisponibile**
    
- Spesso con **IP spoofing** (source fake)
    
![[Screenshot_1 16.png]]
### Spoofing (dipende: A / C / I)

- “Spoof” = falsificare **source** (MAC/IP).
    
- Esempio: **DHCP exhaustion/starvation**
    
    - flood di DHCP Discover con **MAC spoofate**
        
    - pool DHCP si esaurisce → DoS per client legittimi (**Availability**)
        
![[Screenshot_2 14.png]]
### Reflection / Amplification (Availability)

- Attaccante manda traffico a un **reflector** (es. DNS/NTP) con **source IP spoofato = IP del target**
    
- Il reflector risponde al target → se volume alto → DoS
    
- “Amplification” quando piccola richiesta genera **risposta enorme** verso la vittima
    
![[Screenshot_3 11.png]]
### Man-in-the-middle (Confidentiality + Integrity)

- Attaccante “in mezzo” per **sniffare** o **modificare** traffico.
    
- Esempio: **ARP spoofing/poisoning**
    
    - invia ARP reply fasulli
        
    - vittima aggiorna ARP table con MAC dell’attaccante per IP del server/gateway
        
    - traffico passa dall’attaccante → può leggere e/o alterare
        
![[ezgif.com-optimize 1.gif]]
### Reconnaissance (preparazione)

- Raccolta info pubbliche per attacchi futuri:
    
    - **nslookup** (IP/record)
        
    - probing porte aperte
        
    - **whois** (contatti, dati registrazione)
        
![[Screenshot_10.png]]
### Malware (C/I/A, dipende dal payload)

- **Virus**: si “attacca” a host program, si diffonde via file/software
    
- **Worm**: standalone, si diffonde da solo (può congestionare rete + payload)
    
- **Trojan**: mascherato da software legittimo, tipicamente via azione utente
    

### Social engineering (colpisce “people layer”)

- **Phishing**: email massiva → sito fake/login rubato
    
- **Spear phishing**: target specifico (azienda/gruppo)
    
- **Whaling**: target “VIP” (dirigenza)
    
- **Vishing**: telefonate
    
- **Smishing**: SMS
    
- **Watering hole**: comprometti siti che la vittima visita spesso
    
- **Tailgating**: entrare in area protetta “dietro” persona autorizzata
    

### Password attacks

- **Guessing**
    
- **Dictionary attack**
    
- **Brute force** (tutte le combinazioni)
    

---

## Passwords & MFA

### Strong password (regole)

- **>= 8** caratteri (meglio di più)
    
- mix **maiuscole/minuscole**
    
- mix **lettere/numeri**
    
- **special chars**
    
- cambio periodico (policy aziendale)
    

### Multi-factor authentication (MFA)

Usa almeno **2 categorie diverse**:

- **Something you know**: password/PIN
    
- **Something you have**: telefono/app/badge
    
- **Something you are**: biometria (fingerprint/retina/face)
    

⚠️ Due biometriche (retina + fingerprint) = **non** MFA (stessa categoria “are”).

### Digital certificates (concetto)

- Servono a verificare l’identità (tipicamente siti web)
    
- Richiesta: **CSR** → **CA** firma e rilascia cert
    
- Browser indica cert valido → riduce rischio di sito “clone”
    

---

## AAA (framework)

- **Authentication**: verifica identità (login/MFA)
    
- **Authorization**: permessi (cosa può fare/vedere)
    
- **Accounting**: logging delle attività (login/logout, azioni)
    

AAA server (esempio Cisco): **ISE**

Protocolli AAA:

- **RADIUS**: UDP **1812/1813**
    
- **TACACS+**: TCP **49**
    

---

## Security program elements (azienda)

- **User awareness**: “sensibilizzazione” (es. phishing simulato)
    
- **User training**: formazione strutturata (policy, password, minacce)
    
- **Physical access control**: controllo accessi fisici (badge, biometria, aree ristrette)
    
    - badge: permessi revocabili centralmente
        

---

## Key rules / exam points (alta priorità)

- CIA triad: definizioni **precise**
    
- Vulnerability vs exploit vs threat vs mitigation (distinzione netta)
    
- Attacchi: associare **categoria → impatto CIA**
    
- MFA: categorie “know/have/are” + esempio “falso MFA”
    
- AAA: definizioni + esempi
    
- RADIUS/TACACS+ + **porte** (da sapere “a memoria”)
    

---

## CLI

_(Nessun comando in questo video)_

---

## Common mistakes / notes

- Confondere **vulnerability** (debolezza) con **threat** (possibilità reale di sfruttamento)
    
- Pensare che “due fattori” = “due step”: no, devono essere **categorie diverse**
    
- Trattare “spoofing” come attacco unico: è una **tecnica** usata in più attacchi
    
- Overkill per CCNA: dettagli profondi su DNS/NTP amplification, mitigazioni specifiche, implementazioni AAA avanzate