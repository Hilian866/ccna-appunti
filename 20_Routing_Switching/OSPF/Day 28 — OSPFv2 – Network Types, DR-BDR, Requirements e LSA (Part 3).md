
## What is it

OSPF cambia comportamento in base al tipo di interfaccia, che determina il network type del segmento.  
Il network type influenza: neighbor discovery, DR/BDR, chi arriva a FULL, e come si riduce il flooding.

```
Tipo di interfaccia
     ↓
OSPF network type
     ↓
DR/BDR • adiacenze • flooding
```
---

## Loopback (perché usarla)

- **Interfaccia virtuale**, di default **sempre up/up** (a meno di `shutdown`)
    
- Fornisce un IP **stabile** per **identificare** e **raggiungere** il router anche se una fisica va giù  
    (meglio di usare l’IP di una physical interface come “identità” del router)

## OSPF Network Types (CCNA)

### 1) Broadcast (default su Ethernet, anche FDDI)

- **Multi-access** (più router nello stesso segmento)
    
- Neighbor discovery: **Hello multicast 224.0.0.5**
    
- **DR/BDR eletti per ogni subnet**
    
- **FULL adjacency**:
    
    - **DR e BDR**: FULL con **tutti**
        
    - **DROTHER ↔ DROTHER**: resta **2-Way** (non FULL)
        
- Scopo DR/BDR: **ridurre LSA flooding** su segmenti multi-access  
    (DROTHER scambiano LSAs solo con DR/BDR, non tra loro)
    
- Multicast:
    
    - **224.0.0.5** = all OSPF routers
        
    - **224.0.0.6** = DR/BDR
        

### 2) Point-to-Point (default su serial PPP/HDLC)

- Neighbor discovery: Hello multicast 224.0.0.5
    
- **NO DR/BDR**
    
- I due router formano **FULL adjacency diretta**
    
- Timers default (come broadcast): **Hello 10 / Dead 40**
    
- Nota (FYI dal video): Non-broadcast (non richiesto CCNA) usa **30/120** e spesso richiede neighbor manuali

## DR / BDR (solo su Broadcast)

### Regole elezione

1. **OSPF interface priority** più alta → **DR**
    
2. Parità → **Router ID** più alto vince
    

- Default priority = **1**
    
- `priority 0` → **mai** DR/BDR
    

### Non-preemptive (importante)

- Se cambi priority **non rimpiazzi** DR/BDR già eletti
    
- Cambiano solo se:
    
    - interfaccia/neighbor **down**
        
    - **reset OSPF process**
        
- Se il **DR cade** → il **BDR diventa DR** automaticamente → poi si elegge un nuovo BDR
    

### CLI Core – DR/BDR

```
interface g0/0
 ip ospf priority 255
```

## Neighbor vs Adjacency (chi arriva a FULL)

- **Neighbor**: relazione fino a 2-Way
    
- **Adjacency**: relazione **FULL** (LSDB sincronizzata)
    

Su Broadcast:

- **DROTHER** ha neighbor con tutti, ma **adjacency FULL solo con DR/BDR**
    
- In `show ip ospf interface brief`:
    
    - **F = Full adjacencies**
        
    - **C = total neighbors**

![[Screenshot_2 16.png]]

## OSPF Neighbor / Adjacency Requirements (da troubleshooting)

Questi mismatch impediscono neighbor o impediscono OSPF “di funzionare bene”.

### Bloccano la neighbor adjacency (non vengono su)

- **Area deve combaciare**
    
- **Stessa subnet**
    
- **Hello/Dead timers uguali**
    
- **Router ID univoco**
    
- **OSPF process non shutdown**
    

### “Trappole” (neighbor può apparire ma OSPF non funziona bene)

- **MTU mismatch**: i router possono restare neighbor ma bloccarsi (es. **EXSTART**) e non arrivare a FULL
    
- **Network type mismatch**: può mostrare FULL ma avere **routing incompleto** (rotte mancanti)

## Config/CLI essenziale (troubleshooting)

```
show ip ospf neighbor
show ip ospf interface
show ip ospf interface brief
show ip ospf database
clear ip ospf process

```

### Comandi citati nel video (mismatch comuni)

```
router ospf 1
 shutdown
 no shutdown

interface g0/0
 ip ospf hello-interval 5
 ip ospf dead-interval 20
 no ip ospf hello-interval
 no ip ospf dead-interval

 ip ospf authentication-key jeremy
 ip ospf authentication
 no ip ospf authentication
 no ip ospf authentication-key

 ip mtu 1400
 no ip mtu

 ip ospf network point-to-point   ! oppure broadcast
```

## LSA Types (solo quelli CCNA)

- **Type 1 – Router LSA**
    
    - Generata da **ogni router OSPF**
        
    - Identifica il router (RID) e le reti sulle interfacce OSPF-enabled
        
- **Type 2 – Network LSA**
    
    - Generata **solo dal DR** su reti multi-access (broadcast)
        
    - Elenca i router attaccati al segmento
        
- **Type 5 – AS-External LSA**
    
    - Generata da **ASBR**
        
    - Descrive rotte **esterne** all’OSPF domain (es. default verso Internet)

## Common Mistakes

- Confondere neighbor con FULL adjacency
    
- Aspettarsi **preemption** cambiando priority
    
- Ignorare MTU mismatch (stuck in EXSTART)
    
- Fidarsi di FULL con network type mismatch (routing può essere incompleto)

## Synthesis

Network type determina **come** i router scoprono i neighbor e **chi** forma FULL.  
Su Broadcast, DR/BDR esistono per **ridurre il flooding**; i DROTHER arrivano a FULL **solo** con DR/BDR.