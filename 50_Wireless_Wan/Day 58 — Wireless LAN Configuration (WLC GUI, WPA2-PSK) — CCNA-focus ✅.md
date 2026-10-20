


### Cosa vuole Cisco (exam focus)

Devi saper **configurare WLAN tramite GUI** su **WLC**, in particolare:

- **WLAN + SSID**
    
- **mappatura WLAN → VLAN (dynamic interface)**
    
- **sicurezza: WPA2-PSK (Personal)**
    
- concetti base di **split-MAC/CAPWAP** e ruoli VLAN (**management vs client**)
    

---

## 1) Topologia logica (quello che conta)

**Componenti:**

- 1 Switch (SW1)
    
- 1 WLC
    
- 2 AP (lightweight, CAPWAP)
    

**VLAN/Subnet tipiche (esempio):**

- **VLAN 10 = Management** (WLC/AP/SW mgmt) → 192.168.1.0/24
    
- **VLAN 100 = Internal (client)** → 10.0.0.0/24
    
- **VLAN 200 = Guest (client)** → 10.1.0.0/24
    

**Regola chiave (split-MAC):**

- **AP → switch = access port (management VLAN)** ✅
    
- **WLC → switch = trunk (porta tutte le VLAN necessarie)** ✅
    

---

## 2) Switch config (solo ciò che serve ricordare)

### VLAN + access ports per AP/PC di management

- Porte verso AP e PC di admin in **VLAN 10 (access)**
    

### WLC uplink: EtherChannel/LAG (statico)

- Su WLC si usa il termine **LAG**, ma è **EtherChannel**.
    
- **WLC supporta solo LAG statico** → sullo switch:
    

`interface range f0/1-2  channel-group 1 mode on`

Poi **Port-Channel trunk** con VLAN 10,100,200.

### SVI = default gateway delle VLAN

- SW1 fa da gateway (es. `.1` per ogni subnet).
    

### DHCP (per AP e client)

- DHCP pool per:
    
    - **VLAN 10** (AP mgmt)
        
    - **VLAN 100/200** (client)
        

**DHCP Option 43 (CCNA-worthy):**

- Serve per dire agli AP **l’IP del WLC** (utile quando non è nella stessa subnet).
    
- Da ricordare come concetto.
    

---

## 3) WLC initial setup (wizard via console) — essenziale

Obiettivo: dare al WLC un **Management IP** e poter entrare nel **GUI**.

Imposti nel wizard:

- **System name**, **user/pass**
    
- **Management interface**:
    
    - IP / mask
        
    - gateway
        
    - VLAN ID (Management VLAN)
        
    - DHCP server (se richiesto)
        

📌 Nota CCNA: il wizard esiste; non serve memoria di “tutte le schermate”.

---

## 4) Accesso al GUI (CCNA)

- Da PC in **VLAN 10**, apri browser su **IP management del WLC**
    
- HTTPS può dare warning certificato (irrilevante per l’esame: basta capire che si accede via web)
    

---

## 5) Concetto fondamentale: Ports vs Interfaces (WLC)

- **Ports** = fisici (dove attacchi i cavi)
    
- **Interfaces** = logiche (tipo “SVI” su switch)
    

### Tipi di interface da sapere

- **Management interface**
    
    - GUI/SSH, CAPWAP, NTP/Syslog, ecc.
        
- **Dynamic interface**
    
    - serve per **mappare WLAN → VLAN**
        
    - es: `Internal` ↔ VLAN100, `Guest` ↔ VLAN200
        
- **Virtual interface**
    
    - usata in vari casi “client-facing” (DHCP relay, web auth, ecc.)  
        (conoscenza superficiale ok)
        

---

## 6) Creazione Dynamic Interfaces (GUI)

Per ogni VLAN client crei una dynamic interface:

- **Internal** → VLAN 100 → IP/mask/gw/DHCP
    
- **Guest** → VLAN 200 → IP/mask/gw/DHCP
    

---

## 7) Configurazione WLAN/SSID (GUI) — core CCNA ✅

Devi saper fare questi passaggi:

### A) Creare/Modificare WLAN

- **Profile name** (nome interno)
    
- **SSID** (nome broadcast)
    
- **WLAN ID** (numero)
    
- **Enable**
    

### B) Mappare WLAN alla dynamic interface corretta

- Internal WLAN → **Internal interface (VLAN100)**
    
- Guest WLAN → **Guest interface (VLAN200)**
    

### C) Sicurezza: WPA2-PSK (Personal)

Nel tab Security:

- Layer 2 Security: **WPA+WPA2** (ok per CCNA)
    
- Authentication Key Management: seleziona **PSK**
    
- PSK in **ASCII**, minimo **8 caratteri** (vincolo pratico utile)
    

📌 Questo è il punto “5.10” più testabile: **WPA2 PSK via GUI**.

---

## 8) QoS profiles (da sapere “a memoria leggera”)

Sul WLC trovi 4 livelli QoS:

- **Platinum** = voice
    
- **Gold** = video
    
- **Silver** = best effort (default)
    
- **Bronze** = background
    

Non serve saperli configurare in dettaglio: serve **riconoscerli**.

---

## 9) Monitoraggio base (GUI)

- Vedere client associati (SSID, AP, IP)
    
- Vedere AP joined
    

---

## 10) ACL sul WLC (solo concetto)

- Esistono **CPU ACL** per limitare accesso **al WLC stesso** (GUI/SSH/SNMP).
    
- **Non** influenzano il traffico che attraversa il WLC (solo traffic _to WLC_).
    

Per CCNA: “sapere che esiste e cosa fa” > saper scrivere regole precise.