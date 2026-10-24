## What is it

- **RSTP (802.1w)** è un’evoluzione di STP che riduce drasticamente i tempi di convergenza.
    
- **Rapid PVST+** è l’implementazione Cisco: **RSTP + un’istanza per VLAN**.

## How it works

- Usa un **meccanismo di negoziazione (handshake)** invece di lunghi timer.
    
- Tutti gli switch **generano BPDUs**, non solo il root.
    
- Le porte possono passare **direttamente a Forwarding** se le condizioni sono sicure.
    
- Mantiene le stesse regole di elezione di **root bridge, root port e designated port** di STP.
    
![[Screenshot_1 3.png]]

### Port Costs (RSTP)

RSTP usa costi **estesi** per supportare velocità moderne:

![[Screenshot_2 4.png]]

👉 Usati nel calcolo del **root cost**, come in STP classico.


## Key Differences (vs STP classico)

- **Convergenza**: pochi secondi (non 30–50s).
    
- **Port states**:
    
    - Discarding (blocking + disabled)
        
    - Learning
        
    - Forwarding
        
- **Nuovi port roles**:
    
    - **Alternate**: backup del root port (da altro switch)
        
    - **Backup**: backup del designated port (stesso switch, scenario hub)
        
- **Feature STP integrate**: PortFast, UplinkFast, BackboneFast.
    

---
![[Screenshot_4 1.png]]
## ![[Screenshot_2 3.png]]

### Port Roles (RSTP)

- **Root Port**  
    Percorso migliore verso il root bridge (1 per switch, escluso il root)
    
- **Designated Port**  
    Porta che invia il BPDU migliore su un segmento
    
- **Alternate Port**  
    Porta discarding che riceve BPDU superiore **da un altro switch**  
    → backup immediato del root port (UplinkFast integrato)
    
- **Backup Port**  
    Porta discarding che riceve BPDU superiore **dallo stesso switch**  
    → possibile solo con hub (caso raro)

![[Screenshot_5 2.png]]

![[Screenshot_6.png]]
## RSTP Link Types

- **Edge**: verso end-host → forwarding immediato  
    (configurato con `spanning-tree portfast`)
    
- **Point-to-point**: switch–switch full-duplex
    
- **Shared**: collegamento a hub (half-duplex)
    ![[Screenshot_8.png]]

## CLI Core

`spanning-tree mode rapid-pvst show spanning-tree`

Note output:

- `protocol rstp`
    
- Stato può apparire come **BLK** (equivale a _discarding_ in RSTP).

## Exam Facts

- **BPDU version**:
    
    - STP = 0
        
    - RSTP = 2
        
- **RSTP considera il neighbor perso** dopo **3 BPDUs (~6s)**.
    
- **Edge port RSTP = PortFast**.

## Common Mistakes

- Confondere **port role** (alternate / backup) con **link type** (edge / p2p / shared).
    
- Pensare che RSTP cambi le regole di elezione del root (non le cambia).
    
- Credere che “blocking” non esista più: esiste, ma si chiama **discarding**.

## Links

- [[Day 20 (Part 1) — STP 802.1D – Fondamenti e Selezione delle Porte (Part 1)]]
    
- [[Day 21 (Part 1) — PortFast (STP)]]

## Synthesis

- **RSTP accelera STP usando negoziazione invece dei timer, mantenendo la stessa logica di elezione.**