
### Scope CCNA

- **CORE CCNA**: concetti base Wi-Fi, RF, canali, service set
    
- **NON CORE**: dettagli fisici avanzati, RTS/CTS, channel bonding, mesh routing interno
    

---

## Wireless LAN – basi

- **Wireless LAN**: rete locale che usa **Wi-Fi (802.11)** al posto di cavi
    
- **IEEE 802.11**: standard tecnici Wi-Fi
    
- **Wi-Fi Alliance ≠ IEEE**: certifica interoperabilità, non definisce standard
    

---

## Differenze chiave vs LAN cablata

- **Broadcast fisico**: tutti i device nel raggio ricevono i frame
    
- **Half-duplex**: non TX/RX simultanei
    
- **Privacy critica**: cifratura necessaria **anche dentro la LAN**
    
- **Collisioni**: evitate, non rilevate
    

---

## CSMA

- **CSMA/CD**: Ethernet cablato (collision detection) ❌ Wi-Fi
    
- **CSMA/CA**: Wi-Fi (collision avoidance) ✅
    
    - ascolta → attende → trasmette
        
- **RTS/CTS**: opzionale → **NON CORE CCNA**
    

---

## Radio Frequency (RF)

- **RF**: onde elettromagnetiche ~30 Hz–300 GHz
    
- **Ampiezza (Amplitude)**: forza del segnale
    
- **Frequenza**: cicli al secondo (Hz)
    
- **Periodo**: tempo di un ciclo (1/f)
    

---

## Bande Wi-Fi (CORE)

- **2.4 GHz**
    
    - maggiore portata
        
    - migliore penetrazione muri
        
    - **più interferenze**
        
- **5 GHz**
    
    - meno interferenze
        
    - più canali non sovrapposti
        
- **6 GHz (Wi-Fi 6E)**: **NON CORE (menzione leggera)**
    

---

## Canali Wi-Fi

- **Canale**: sotto-porzione di una banda RF
    
- **2.4 GHz**: canali **sovrapposti**
    
    - **Non overlapping (CCNA): 1, 6, 11**
        
- **5 GHz**: canali **non sovrapposti**
    
- **Channel bonding**: **NON CORE**
    

---

## Interferenze & propagazione

Effetti che degradano il segnale:

- **Absorption**: segnale → calore (muri)
    
- **Reflection**: rimbalzo (metallo)
    
- **Refraction**: cambio direzione (vetro/acqua)
    
- **Diffraction**: aggira ostacoli → blind spot
    
- **Scattering**: dispersione (superfici irregolari)
    

---

## SSID / BSSID

- **SSID**: nome logico della WLAN (human-readable)
    
- **BSSID**: MAC address della radio AP
    
- **SSID ≠ BSSID** (confine concettuale da quiz)
    

---

## Service Sets (CORE)

### IBSS (Ad-hoc)

- Client ↔ client
    
- **Nessun AP**
    
- Poco scalabile
    

### BSS (Infrastructure)

- Client ↔ **AP**
    
- **Un AP = un BSS**
    
- **BSSID unico**
    
- **BSA**: area fisica di copertura
    

### ESS (Extended)

- **Più BSS**
    
- **Stesso SSID**
    
- **BSSID diversi**
    
- **Roaming** tra AP
    
- Canali **non sovrapposti**
    
- Overlap BSA ~10–15%
    

### MBSS (Mesh)

- AP collegati wireless (backhaul)
    
- **RAP**: root AP cablato
    
- **MAP**: mesh AP
    
- **NON CORE** (concetto)
    

---

## AP & rete cablata

- **DS (Distribution System)**: rete cablata upstream
    
- **SSID ↔ VLAN mapping**
    
- AP ↔ switch tramite **trunk**
    
- AP può fornire **più SSID → più VLAN**
    
- **Ogni SSID → BSSID distinto**
    

---

## Modalità AP

- **Repeater**
    
    - 1 radio → **–50% throughput**
        
    - 2 radio → OK
        
- **Workgroup Bridge (WGB)**
    
    - wired → wireless
        
    - **uWGB**: standard (1 device)
        
    - **Cisco WGB**: proprietario (multi-device)
        
- **Outdoor Bridge**
    
    - link wireless long-distance
        
    - **Point-to-Point / Point-to-Multipoint**
        
    - **NON CORE**
        

---

## Standard 802.11 (MEMORIZZARE)

- **802.11a** – 5 GHz
    
- **802.11b** – 2.4 GHz
    
- **802.11g** – 2.4 GHz
    
- **802.11n (Wi-Fi 4)** – 2.4 / 5 GHz
    
- **802.11ac (Wi-Fi 5)** – 5 GHz
    
- **802.11ax (Wi-Fi 6)** – 2.4 / 5 / 6 GHz
    

---

## Domande tipiche da esame

- Canali 2.4 GHz non sovrapposti → **1, 6, 11**
    
- Scopo AP → **collegare wireless al DS**
    
- Bande comuni → **2.4 GHz + 5 GHz**
    
- ESS → **stesso SSID, BSSID diversi, roaming**
    
- Più BSS → **BSSID unici**