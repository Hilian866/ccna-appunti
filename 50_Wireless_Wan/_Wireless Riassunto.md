# CCNA Wireless: Dashboard Strategica

> [!abstract] Focus Esame
> 
> Cisco testa la tua capacità di distinguere le architetture (Split-MAC), i parametri fisici (Canali/Frequenze) e la sicurezza (WPA2/3). Ignora i dettagli fisici complessi (RTS/CTS), concentrati sulla **GUI del WLC**.

## 1. Fondamenta Fisiche & Standard (L1)

|Parametro|2.4 GHz|5 GHz|6 GHz (Wi-Fi 6E)|
|---|---|---|---|
|Portata / Muri|Massima (ottima penetrazione)|Media|Minima|
|Interferenze|Alte (Bluetooth, Microonde)|Basse|Quasi nulle|
|Canali No-Overlap|**1, 6, 11**|Fino a 24|Moltissimi|
|Standard 802.11|b, g, n, ax|a, n, ac, ax|ax|

### Propagazione del Segnale

- **Absorption**: Il segnale attraversa un muro e perde forza (diventa calore).
    
- **Reflection**: Rimbalza sul metallo (causa multipath).
    
- **Refraction**: Cambia direzione attraversando vetro o acqua.
    

> [!tip] CSMA/CA
> 
> Il Wi-Fi è **Half-Duplex**. Usa il _Collision Avoidance_: Ascolta → Attende → Trasmette. (Diverso dall'Ethernet cablato che usa _Collision Detection_).

## 2. Architetture Wireless & CAPWAP

### Modelli di Access Point

1. **Autonomous AP**: Standalone, configurazione manuale "per-device". Non scalabile.
    
2. **Lightweight AP (LAP)**: "Stupido", richiede un **WLC** per funzionare (Split-MAC).
    
3. **Cloud-Based (Meraki)**: Gestito da dashboard web; il traffico dati resta locale (non va nel cloud).
    

### Il Protocollo CAPWAP (DA SAPERE)

L'AP incapsula il traffico wireless dentro pacchetti UDP per spedirli al WLC.

- **Control Tunnel**: UDP **5246** (Cifrato, gestione AP).
    
- **Data Tunnel**: UDP **5247** (Traffico utenti, non cifrato di default).
    

### WLC Deployment

- **Unified**: Hardware dedicato (max 6000 AP).
    
- **Embedded**: Integrato nello switch (max 200 AP).
    
- **Mobility Express**: Un AP "master" fa da controller (max 100 AP).

## 3. Topologia Logica & Service Sets

- **SSID**: Nome della rete (es. "WiFi-Aziendale").
    
- **BSSID**: MAC address fisico della radio dell'AP.
    
- **BSS**: 1 AP + Client associati.
    
- **ESS**: Più AP con lo **stesso SSID**. Permette il Roaming (sovrapposizione consigliata **10-15%**).

## 4. Sicurezza Wireless (I Tre Pilastri)

|Generazione|Authentication|Encryption|Integrity|
|---|---|---|---|
|WPA|PSK o 802.1X|TKIP (RC4)|MIC|
|WPA2|PSK o 802.1X|**CCMP (AES)**|CBC-MAC|
|WPA3|**SAE** (Personal)|**GCMP (AES)**|GMAC|

### 802.1X (Enterprise)

- **Supplicant**: Client (es. Laptop).
    
- **Authenticator**: WLC / AP.
    
- **Authentication Server**: **RADIUS** (Database utenti).
    

> [!important] Metodi EAP
> 
> - **PEAP**: Certificato solo sul Server (più comune).
>     
> - **EAP-TLS**: Certificato su Server E Client (massima sicurezza).
>     

## 5. Configurazione Operativa (GUI WLC)

### Ports vs Interfaces

- **Ports**: Fisiche (Ethernet sul WLC). Supportano il **LAG** (Etherchannel statico).
    
- **Interfaces**: Logiche.
    
    - **Management**: Per gestire il WLC e tunnel CAPWAP.
        
    - **Dynamic**: Mappa una **VLAN** specifica a una **WLAN**.
        

### Workflow Creazione WLAN

1. **Crea Dynamic Interface**: Assegna VLAN ID e indirizzamento IP.
    
2. **Crea WLAN**: Inserisci Profile Name e SSID.
    
3. **Mappatura**: Collega la WLAN alla Dynamic Interface creata.
    
4. **Security**: Seleziona **WPA2 + PSK** (se Personal) o 802.1X (se Enterprise).
    
5. **Status**: Spunta **ENABLED** (fondamentale!).
    

### Profili QoS

- 💎 **Platinum**: Voice
    
- 🥇 **Gold**: Video
    
- 🥈 **Silver**: Best Effort (Default)
    
- 🥉 **Bronze**: Background

## Check da Esame

- [ ] Canali 2.4 GHz no-overlap? **1, 6, 11**.
    
- [ ] Porta CAPWAP Control? **UDP 5246**.
    
- [ ] Chi fa da Authenticator in 802.1X? **Il WLC/AP**.
    
- [ ] Differenza WPA2/WPA3? **CCMP vs GCMP** e introduzione di **SAE**.