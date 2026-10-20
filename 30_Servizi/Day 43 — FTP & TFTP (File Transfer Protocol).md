
### What is it

**FTP** (File Transfer Protocol) e **TFTP** (Trivial File Transfer Protocol) sono protocolli **Application layer** usati per **trasferire file su rete**.

Uso tipico CCNA:

- **upgrade IOS**
    
- **backup / restore file di configurazione**
    
- trasferimento file da/verso dispositivi Cisco
    

---

### What does / How it works

#### TFTP

- Protocollo **semplice e leggero**
    
- Solo:
    
    - copia **da server**
        
    - copia **verso server**
        
- Nessuna autenticazione
    
- Nessuna cifratura
    
- Comunicazione **lock-step** con ACK
    
- Usa **UDP**
    

#### FTP

- Protocollo **più completo**
    
- Supporta:
    
    - autenticazione (username/password)
        
    - navigazione directory
        
    - lista file
        
    - upload / download
        
- Usa **TCP**
    
- Due connessioni:
    
    - **control**
        
    - **data**
        

---

### Key rules / exam points

- Exam topic **4.9**
    
- Conoscere **differenze FTP vs TFTP**
    
- **TFTP**
    
    - UDP
        
    - port **69**
        
    - nessuna sicurezza
        
- **FTP**
    
    - TCP
        
    - port **21** (control)
        
    - port **20** (data)
        
    - active vs passive mode
        
- Client dietro firewall → **FTP passive**
    
- **TFTP = più semplice ma insicuro**
    
- **FTP = più funzionalità ma ancora plain-text**
    
- File system Cisco:
    
    - **flash:** → IOS image
        
    - **NVRAM:** → startup-config
        

---

### FTP vs TFTP (sintesi rapida)

|FTP|TFTP|
|---|---|
|TCP|UDP|
|Porte 20 / 21|Porta 69|
|Autenticazione|Nessuna autenticazione|
|Directory listing|No directory listing|
|Più complesso|Molto semplice|
|Active / Passive|N/A|

---

### CLI (solo comandi)

**Visualizzare file system**

`show file systems`

**Visualizzare flash**

`show flash`

---

#### TFTP — copiare IOS in flash

`copy tftp: flash:`

**Impostare IOS di boot**

`boot system flash:<ios-image>`

**Salvare configurazione**

`copy running-config startup-config`

**Riavvio**

`reload`

**Cancellare vecchio IOS**

`delete flash:<old-ios-image>`

---

#### FTP — configurazione credenziali

```
ip ftp username cisco
ip ftp password cisco
```


**Copia file via FTP**

`copy ftp: flash:`

---

### Common mistakes / notes

- Dimenticare che **TFTP non può listare file**
    
- Pensare che TFTP sia affidabile come TCP (non lo è)
    
- Dimenticare `boot system` → router avvia IOS sbagliato
    
- Non salvare config prima del reload
    
- FTP **active** fallisce dietro firewall → usare **passive**
    
- Confondere:
    
    - **FTP control** (21)
        
    - **FTP data** (20)