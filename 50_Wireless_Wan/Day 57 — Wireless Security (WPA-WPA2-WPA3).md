

## Perché la sicurezza wireless è critica

- Il segnale wireless è **ricevibile da chiunque sia nel raggio**
    
- A differenza delle LAN cablate, **il traffico deve essere sempre cifrato**
    
- La sicurezza wireless si basa su **tre pilastri distinti**:
    

> **Authentication** → Chi sei  
> **Encryption** → Chi può leggere  
> **Integrity** → Il messaggio è stato alterato?

## 1️⃣ Authentication — _Chi sei_

### Concetto chiave

Un client **deve essere autenticato prima di avere accesso alla rete**.  
Idealmente:

- l’AP autentica il client
    
- **il client autentica anche l’AP** (anti rogue AP)

### Metodi di autenticazione (panoramica)

⚠️ **Non tutti sono ugualmente rilevanti o sicuri**

### Open Authentication

- Nessuna credenziale richiesta
    
- L’AP accetta tutti
    
- **Non sicuro**
    
- Ancora usato come _primo passo_ (es. WiFi pubblico + captive portal)

### ❌ WEP Authentication (Wired Equivalent Privacy)

- Basato su **shared key**
    
- Usa **RC4**
    
- **Facilmente crackabile**
    
- **Obsoleto, non usare**

    ![[Screenshot_1 19.png]]

## Enterprise Authentication — 802.1X + EAP

### Architettura 802.1X (fondamentale CCNA)

|Ruolo|Descrizione|
|---|---|
|Supplicant|Client (laptop, telefono)|
|Authenticator|AP o WLC|
|Authentication Server|Server RADIUS|

📌 In WLAN:

- Client = supplicant
    
- AP/WLC = authenticator
    
- RADIUS = authentication server

    ![[Screenshot_2 19.png]]

### EAP: Extensible Authentication Protocol

EAP = **contenitore di metodi**

### Metodi EAP da conoscere

#### 🟡 LEAP (Lightweight EAP)

- Username + password
    
- Mutual authentication
    
- Dynamic WEP keys
    
- **Vulnerabile → obsoleto**

#### 🟡 EAP-FAST (EAP Flexible Authentication via Secure Tunneling)

- Usa **PAC** (Protected Access Credential)
    
- Crea un **tunnel TLS**
    
- Autenticazione _dentro_ il tunnel
    
- Più sicuro di LEAP, ma poco diffuso

#### ✅ PEAP (Protected EAP)

- **Certificato solo sul server**
    
- Crea tunnel TLS
    
- Client autenticato _dentro_ il tunnel (es. MS-CHAP)
    
- **Buon compromesso sicurezza / complessità**

#### EAP-TLS (EAP Transport Layer Security)

- Certificato **su server e client**
    
- Mutual authentication
    
- Nessuna password
    
- **Massima sicurezza**
    
- Più complesso da gestire
    

📌 **Per l’esame**:

- **PEAP vs EAP-TLS** → differenza sui certificati

## 2️⃣ Encryption — _Chi può leggere_

### Regola fondamentale

- Tutti i client usano **lo stesso protocollo**
    
- Ogni client ha **una chiave unica**
    
- Esiste una **group key** per traffico broadcast

### Linea temporale dell’encryption (IMPORTANTISSIMA)

`WEP → TKIP → CCMP → GCMP`

|Protocollo|Usato in|Algoritmo|Stato|
|---|---|---|---|
|WEP|—|RC4|Rotto|
|TKIP|WPA|RC4+|Transitorio|
|CCMP|WPA2|AES|Standard|
|GCMP|WPA3|AES|Migliore|

### TKIP (Temporal Key Integrity Protocol)

- Evoluzione temporanea di WEP
    
- MIC
    
- IV più lungo
    
- Anti replay
    
- **Non più consigliato**

### CCMP (Counter/CBC-MAC Protocol)

- AES (counter mode)
    
- CBC-MAC per integrità
    
- **Sicuro**
    
- Richiede hardware compatibile

### GCMP (Galois/Counter Mode Protocol)

- AES counter mode
    
- GMAC per integrità
    
- Più efficiente e sicuro di CCMP

## 3️⃣ Integrity — _Il messaggio è stato modificato?_

### Concetto

- Usa un **MIC (Message Integrity Check)**
    
- Il messaggio viene scartato se alterato
    

| Protocollo | Metodo                                                       |
| ---------- | ------------------------------------------------------------ |
| TKIP       | MIC (Message Integrity Check)**                              |
| CCMP       | CBC-MAC  (Cipher Block Chaining Message Authentication Code) |
| GCMP       | GMAC (Galois Message Authentication Code)                    |

📌 Cambia il nome, **la funzione è la stessa**

## 4️⃣ WPA — _Il contenitore_

WPA **non è un protocollo singolo**, ma una **certificazione** che combina:

- autenticazione
    
- encryption
    
- integrità

### Modalità WPA

|Modalità|Uso|
|---|---|
|Personal|PSK (password)|
|Enterprise|802.1X + EAP|

### WPA versions (da ricordare a memoria)

|WPA|Encryption|
|---|---|
|WPA|TKIP|
|WPA2|CCMP|
|WPA3|GCMP|

### Extra WPA3 (solo i principali)

- **PMF** → protegge management frames (obbligatorio)
    
- **SAE** (Simultaneous Authentication of Equals) → protegge 4-way handshake (personal)
    
- **Forward Secrecy** → traffico passato non decifrabile

## Sintesi finale (mentale)

- **Authentication** → EAP (PEAP / EAP-TLS)
    
- **Encryption** → CCMP (WPA2) / GCMP (WPA3)
    
- **Integrity** → sempre MIC
    
- **WPA** → pacchetto standard