## What is it

Approfondimento operativo di **Spanning Tree Protocol (IEEE 802.1D)**: stati delle porte, timer e struttura dei BPDU usati per prevenire loop Layer 2.

## How it works

### Port States
![[Screenshot_1 2.png]]
**Stati stabili**

- **Blocking** (Non-designated)
    
    - Non inoltra traffico normale
        
    - Riceve BPDUs
        
    - Non forwarda BPDUs
        
    - Non apprende MAC address
        
- **Forwarding** (Root / Designated)
    
    - Inoltra traffico normale
        
    - Invia e riceve BPDUs
        
    - Apprende MAC address
        

**Stati transitori** (solo Root e Designated ports)

- **Listening** (15s – Forward Delay)
    
    - Solo BPDUs
        
    - Nessun traffico normale
        
    - Nessun MAC learning
        
- **Learning** (15s – Forward Delay)
    
    - Solo BPDUs
        
    - Nessun traffico normale
        
    - **Apprende MAC address**
        

**Disabled**

- Porta amministrativamente shutdown
    
- Non partecipa a STP

### STP Timers (default)

- **Hello**: 2s  
    Frequenza con cui il root bridge invia BPDUs
    
- **Forward Delay**: 15s  
    Durata di Listening **e** Learning (30s totali)
    
- **Max Age**: 20s  
    Tempo massimo senza ricevere BPDU prima di ricalcolare la topologia

![[Screenshot_2 2.png]]

**Convergenza classica**

- Max Age (20s)
    
- Listening (15s)
    
- Learning (15s)  
    → fino a **~50s** per passare da Blocking a Forwarding

### Propagazione BPDU

- Dopo la convergenza:
    
    - **Solo il root bridge origina BPDUs**
        
    - Gli altri switch **forwardano BPDUs solo sulle Designated Ports**
        
- Root ports e Non-designated ports **si aspettano di ricevere** BPDUs

### BPDU – informazioni rilevanti

- **MAC destination**
    
    - STP standard: `0180.c200.0000`
        
    - Cisco **PVST+**: `0100.0ccc.cccd`
        
- Contiene:
    
    - Root ID
        
    - Bridge ID
        
    - Root Path Cost
        
    - Port ID
        
    - Timers (Hello, Max Age, Forward Delay)
        
- I **timer del root bridge** determinano i timer per tutta la rete
    

**Port ID**

- Composto da:
    
    - Port Priority (default **128**)
        
    - Port Number
        
- Esempio `0x8002` → priority 128, port 2
    

## CLI Core

`show spanning-tree`

## Common Mistakes

- Confondere Listening e Learning (solo Learning apprende MAC)
    
- Dimenticare che STP classico è **intenzionalmente lento**
    
- Pensare che tutti gli switch originino BPDUs anche dopo la convergenza
    

## Synthesis

STP 802.1D previene loop Layer 2 usando stati transitori e timer conservativi, sacrificando velocità di convergenza per stabilità.

## Links

- [[STP 802.1D – Fondamenti e Selezione delle Porte]]