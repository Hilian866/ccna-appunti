

---

## 802.11 Frames – Overview (livello CCNA)

- **802.11 ≠ 802.3**: frame wireless più complessi di Ethernet
    
- Non tutti i campi sono presenti in ogni frame
    

### Campi principali (high-level)

- **Frame Control**  
    Tipo e sottotipo del messaggio
    
- **Duration / ID**  
    Tempo di occupazione del canale **oppure** ID di associazione
    
- **Addresses (fino a 4)**
    
    - **DA** – Destination Address
        
    - **SA** – Source Address
        
    - **RA** – Receiver Address
        
    - **TA** – Transmitter Address
        
- **Sequence Control**  
    Riordino frammenti / eliminazione duplicati
    
- **Frame Body**  
    Dati incapsulati
    
- **FCS**  
    Controllo errori
    

> Nota: non tutti i frame usano tutti i campi.

---

## 802.11 Association Process 

### Stati di connessione

1. **Non autenticato / non associato**
    
2. **Autenticato / non associato**
    
3. **Autenticato / associato**
    

### Scoperta AP (scanning)

- **Active scanning**  
    Probe request → probe response
    
- **Passive scanning**  
    Ascolto **beacon** periodici
    

### Connessione

- **Authentication**
    
- **Association request / response**
    

➡️ Solo dopo autenticazione + associazione il client può trasmettere dati.

---

## 802.11 Frame Types (DA SAPERE)

### Management frames

Usati per gestire il BSS:

- Beacon
    
- Probe request / response
    
- Authentication
    
- Association
    
### Control frames

Gestione accesso al mezzo:

- RTS / CTS
    
- ACK
    

### Data frames

Trasporto dei dati utente

---

## Wireless AP Architectures


![[Screenshot_3 13.png]]

### Autonomous AP

![[Screenshot_1 18.png]]

- **Standalone**, nessun controller
    
- Configurazione **per-AP**
    
- RF, sicurezza, QoS gestiti localmente
    
- **Nessuna gestione centralizzata**
    
- **Scalabilità bassa**
    

#### Cablaggio

- **Trunk verso lo switch**
    
- VLAN separate per:
    
    - SSID
        
    - management
        

#### Limiti principali

- VLAN estese su tutta la LAN
    
- Alto overhead operativo
    
- Poco adatto a reti medio-grandi
    


---

### Lightweight AP (Split-MAC) 

![[Screenshot_2 18.png]]

- Funzioni divise tra **AP** e **WLC**
    
- AP gestisce RF real-time
    
- WLC gestisce:
    
    - RF management
        
    - Sicurezza
        
    - QoS
        
    - Autenticazione
        
    - Roaming
        

➡️ **Split-MAC architecture**

#### Comunicazione AP–WLC: CAPWAP

- **Control tunnel**
    
    - UDP **5246**
        
    - Sempre cifrato
        
- **Data tunnel**
    
    - UDP **5247**
        
    - Traffico client incapsulato
        
    - **Non cifrato di default** (può usare DTLS)
        

#### Cablaggio

- AP → **access port**
    
- WLC → **trunk**
    

#### Data path

- Client → AP → **WLC** → rete wired
    
- Anche traffico tra client sullo stesso AP passa dal WLC
    

---

### Lightweight AP Modes (CCNA)

- **Local mode** (default)  
    AP fornisce BSS normalmente
    
- **FlexConnect**
    ![[Screenshot_4 9.png]]
    - AP può **switchare localmente** se il WLC non è raggiungibile
        

---

### Cloud-Based AP (es. Cisco Meraki)

![[Screenshot_5 10.png]]
- AP **autonomi** ma **gestiti centralmente via cloud**
    
- Configurazione, monitoring, RF tuning dal dashboard
    
- **Traffico dati NON passa dal cloud**
    
- Solo **management / control traffic** verso cloud
    

➡️ Funzionalmente a metà tra autonomous e lightweight.

---

## WLC Deployment Models (DA SAPERE)

### Unified WLC

- Appliance dedicato
    
- Fino a **~6000 AP**
    
- Enterprise campus
    

### Cloud-Based WLC

- WLC come **VM**
    
- Fino a **~3000 AP**
    
- Data center / private cloud
    

### Embedded WLC

- WLC integrato in uno **switch**
    
- Fino a **~200 AP**
    
- Campus medio-piccoli
    

### Mobility Express

- WLC integrato in un **AP**
    
- Fino a **~100 AP**
    
- Branch office / small site
    

---

## Synthesis

- **Autonomous** → semplice, non scalabile
    
- **Lightweight** → scalabile, centralizzato, usa **CAPWAP**
    
- **Cloud-based** → gestione centralizzata senza data tunneling
    
- **Unified WLC** = massima scalabilità