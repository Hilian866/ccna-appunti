
### What is it

**WAN (Wide Area Network)** = rete che collega **LAN geograficamente distanti** (città, paesi, continenti).  
Exam topics: **1.2.d (WAN)** e **5.5 (VPN site-to-site e remote-access)**.  
Livello **descrittivo**, **niente configurazioni** richieste.

### What does / How it works

#### Definizioni atomiche (termini chiave)

- **WAN**: connessioni private enterprise tra sedi (non Internet).
    
- **Hub-and-spoke**: topologia WAN con un sito centrale (**hub**) e sedi periferiche (**spoke**).
    
- **Leased line**: collegamento fisico dedicato punto-punto.
    
- **MPLS**: tecnologia WAN del service provider che usa **label** per creare VPN.
    
- **CE router**: Customer Edge (router del cliente).
    
- **PE router**: Provider Edge (router del provider a cui si collega il cliente).
    
- **P router**: Provider core (router interni al provider).
    
- **Site-to-site VPN**: VPN permanente tra **due siti**.
    
- **Remote-access VPN**: VPN tra **un singolo host** e la rete aziendale.
    
- **IPsec**: protocollo VPN che **cripta** i dati.
    
- **TLS (ex SSL)**: protocollo di sicurezza usato per remote-access VPN.
    
- **GRE**: tunneling non cifrato che supporta multicast/broadcast.
    
- **DMVPN**: soluzione Cisco per creare **mesh dinamiche IPsec**.

## WAN private

### Leased Lines

- **Collegamenti dedicati**, non condivisi
    
- Tradizionalmente:
    
    - **Serial** (PPP / HDLC)
        
- Oggi spesso sostituite da:
    
    - **Ethernet su fibra**
        
- Svantaggi:
    
    - costose
        
    - lente rispetto a Ethernet
        
    - tempi lunghi di attivazione
        

**Standard da sapere (alto livello)**

- **T1** → 1.544 Mbps (Nord America)
    
- **E1** → 2.048 Mbps (Europa)
    

⚠️ Non memorizzare tabelle complete: **concetto > numeri**

### MPLS VPN

- Infrastruttura **condivisa** del provider
    
- Isolamento clienti tramite label
    
- MPLS = spesso chiamato **Layer 2.5**
    
- **Forwarding basato su label**, non su IP
    

#### Ruoli

- **CE**: router del cliente (NON usa MPLS)
    
- **PE**: router edge del provider (usa MPLS)
    
- **P**: router core del provider (usa MPLS)
    

#### Tipi di MPLS VPN

- **Layer 3 MPLS VPN**
    
    - CE ↔ PE con routing (OSPF, BGP, static)
        
    - CE **non** parlano direttamente tra loro
        
- **Layer 2 MPLS VPN**
    
    - Provider “trasparente”
        
    - CE **si vedono come direttamente connessi**
        
    - Routing tra CE (es. OSPF) diretto
        

📌 Esame:

- CE non eseguono MPLS
    
- L2 MPLS → CE peer direttamente
    
- L3 MPLS → CE peer con PE

## Internet come WAN

### Internet access (concetti)

- **DSL**: usa linee telefoniche
    
- **Cable (CATV)**: usa cavi TV
    
- **Fiber Ethernet**: sempre più comune (enterprise & consumer)
    

#### Modem

- **Modem** = modulator/demodulator
    
- Converte dati per phone line / CATV
    
- Può essere:
    
    - separato
        
    - integrato nel router

### Ridondanza Internet (termini d’esame)

- **Single-homed**: 1 link, 1 ISP
    
- **Dual-homed**: 2 link, stesso ISP
    
- **Multihomed**: 1 link per ciascuno di 2 ISP
    
- **Dual-multihomed**: 2 link per ciascuno di 2 ISP (max resilienza)

## Internet VPNs

### Site-to-site VPN (IPsec)

- **Tra due router/firewall**
    
- **Cripta** il pacchetto originale
    
- Usata per collegare **sedi aziendali**
    
- 1 tunnel → protegge **tutti gli host** delle sedi
    

#### Limiti IPsec

- Solo **unicast**
    
- No multicast/broadcast
    
- Routing dinamico problematico

### GRE over IPsec

- **GRE**: supporta multicast/broadcast (non cifrato)
    
- **IPsec**: fornisce cifratura
    
- Combinazione:
    
    - GRE incapsula
        
    - IPsec cripta
        

📌 Serve solo sapere **perché esiste**, non come si configura.

### DMVPN

- Soluzione Cisco
    
- Obiettivo:
    
    - evitare configurazione manuale di **full mesh IPsec**
        
- Funzionamento (concetto):
    
    - hub-and-spoke iniziale
        
    - spoke creano **tunnel diretti dinamici**
        
- Vantaggi:
    
    - semplicità + efficienza

### Remote-access VPN (TLS)

- **Host singolo → rete aziendale**
    
- Tipico scenario: lavoro da remoto
    
- Usa **TLS** (HTTPS-like)
    
- Client software (es. **Cisco AnyConnect**)
    

📌 Differenza chiave:

- Site-to-site → **rete ↔ rete**
    
- Remote-access → **host ↔ rete**

## Key rules / exam points (checklist)

- WAN = connette LAN distanti
    
- Hub-and-spoke = topologia WAN comune
    
- Leased line = dedicata, legacy
    
- MPLS:
    
    - forwarding via label
        
    - CE non eseguono MPLS
        
    - L2 vs L3 VPN
        
- Internet ≠ sicuro → serve VPN
    
- IPsec = site-to-site
    
- TLS = remote-access
    
- GRE aggiunge multicast, IPsec aggiunge sicurezza
    
- DMVPN = mesh IPsec dinamica

## Common mistakes / notes

- Confondere WAN con **Internet**
    
- Pensare che CE debbano eseguire MPLS
    
- Scambiare site-to-site con remote-access
    
- Credere che IPsec supporti multicast nativamente