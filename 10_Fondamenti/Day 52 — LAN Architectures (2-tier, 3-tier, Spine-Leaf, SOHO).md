
### What is it

**LAN architectures** = modi standard per collegare **switch/router/host/server** in una LAN (campus o data center).  
Exam topics: **1.2.a, b, c, e** (2-tier, 3-tier, spine-leaf, SOHO).

---

### What does / How it works

#### Definizioni atomiche (termini ricorrenti)

- **Star topology**: molti device collegati a **un device centrale**.
    ![[Screenshot_1 17.png]]
- **Full mesh**: ogni device è collegato a **tutti gli altri**.
    ![[Screenshot_3 12.png]]
- **Partial mesh**: alcuni device sono collegati tra loro, **non tutti**.
    ![[Screenshot_2 15.png]]

---

## Campus LAN design (enterprise)

### 2-tier (Collapsed Core)

**2-tier** = **Access + Distribution** (core “collassato” dentro distribution).  
Alias: **collapsed core** / **core-distribution**.

![[Screenshot_4 8.png]]
#### Access layer (cosa fa)

- Dove si collegano gli **end host** (PC, printer, IP phone, AP, camere, ecc.)
    
- Tipicamente include:
    
    - **PoE** per IP phone / AP
        
    - **QoS marking** (marcare “prima possibile”)
        
    - **L2 security** (port security, DHCP snooping, DAI)
        

#### Distribution layer (cosa fa)

- **Aggrega** gli access switch (alias: **aggregation layer**)
    
- Tipicamente è il **confine L2 ↔ L3**
    
    - Access↔Distribution spesso **L2** (STP per loop)
        
    - Default gateway degli host spesso su **SVI** nei distribution switch
        
- Connette a **servizi**: Internet / WAN / altre parti del campus
    
- Ridondanza tipica:
    
    - coppia di distribution switch
        
    - **FHRP** (HSRP/VRRP) per default gateway virtuale
        

#### Punti d’esame (2-tier)

- Loop L2 tra access↔distribution → **STP** blocca link
    
- Distribution può fare routing (OSPF ecc.) + switching L2
    

---

### 3-tier

**3-tier** = **Access + Distribution + Core**

![[Screenshot_7 5.png]]
#### Quando serve (idea)

Quando aumentano i distribution layer, fare full mesh tra distribution diventa **poco scalabile**.  
Soluzione: aggiungere **Core layer**.

#### Core layer (cosa fa)

- Connette i distribution layer = **backbone**
    
- Focus: **speed / fast transport**
    
- Evitare operazioni “pesanti”:
    
    - no security features
        
    - no QoS marking/classification
        
- Link **tutti Layer 3**
    
- **No STP** nel core
    
- Alta ridondanza (device + link)
    

#### Punti d’esame (3-tier)

- **Boundary L2/L3** tipicamente: **Distribution**
    
- **STP non in core** (core = L3)

![[ezgif.com-optimize (1).gif]]

---

![[Screenshot_8 4.png]]

---

## Data Center: Spine-Leaf (Clos)

### Definizioni atomiche

- **Spine-Leaf**: architettura data center a due livelli con regole fisse di cablaggio per ridurre bottleneck e rendere latenza più consistente.
    
- **North–South traffic**: traffico “verso fuori” (Internet/altre zone della rete).
    
- **East–West traffic**: traffico **server↔server** dentro il data center.
    ![[Screenshot_10 1.png]]

### Perché nasce

Nel data center moderno aumenta l’**east–west** (app distribuite/virtualizzazione) → 3-tier tradizionale crea:

- **bottleneck** di banda
    
- **latenza variabile** server↔server
    ![[Screenshot_9 2.png]]

### Regole (CORE CCNA)

- Ogni **leaf** è connesso a **ogni spine**
    
- **Leaf non** si collegano tra loro
    
- **Spine non** si collegano tra loro
    
- Gli **end host/servers** si collegano **solo ai leaf**
    
- Percorsi bilanciati tra spine → load balancing
    
- Latenza più uniforme: stesso numero di hop tra server (salvo stesso leaf)
    

### Scalabilità

- Aggiungi server → aggiungi **leaf** e lo colleghi a tutti gli spine
    

---

## SOHO (Small Office / Home Office)

### Definizione atomica

- **SOHO**: rete piccola dove un singolo dispositivo (“home router / wireless router”) integra più funzioni.
    

### Caratteristiche

Un solo device spesso fa:

- **Router** (verso Internet)
    
- **Switch** (porte LAN)
    
- **Firewall** base (blocca inbound, permette outbound)
    
- **Wireless AP**
    
- a volte **modem** (oppure modem separato)
    

---

## Key rules / exam points (checklist rapida)

- 2-tier = Access + Distribution (collapsed core)
    
- 3-tier = Access + Distribution + Core
    
- Access: PoE + QoS marking + L2 security
    
- Distribution: aggregation + boundary L2/L3 + SVI gateway + FHRP
    
- Core: speed, L3 only, **no STP**
    
- Spine-leaf: leaf↔all spines, no leaf↔leaf, no spine↔spine, host solo su leaf
    
- SOHO: “wireless router” = device multipurpose
    

---

## Common mistakes / notes

- Confondere **core** (3-tier) con “distribution” (collapsed core)
    
- Dimenticare che **STP non deve stare in core**
    
- Spine-leaf: errore tipico da quiz → **leaf non collega leaf**