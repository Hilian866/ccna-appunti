## What is it

**Spanning Tree Protocol (IEEE 802.1D)** è un protocollo di **Layer 2** che previene loop nelle LAN ridondanti bloccando selettivamente alcune porte.

## How it works

### Perché serve STP

- Le reti **devono** essere ridondanti
    
- I loop Layer 2 causano:
    
    - **Broadcast storm** (frame che loopano all’infinito)
        
    - **MAC address flapping** (stesso MAC visto su porte diverse)
        
- Ethernet **non ha TTL**, quindi i loop non si auto-fermano
    

STP risolve il problema creando una **topologia logica senza loop**, pur mantenendo i link ridondanti come backup.

![[Screenshot_3 1.png]]

### Concetti base

- STP usa **BPDUs** (Bridge Protocol Data Units)
    
- Gli switch STP sono chiamati **bridge** (terminologia storica)
    
- Le porte possono essere:
    
    - **Forwarding** (attive)
        
    - **Blocking** (backup)

### Step 1 – Root Bridge Election

- Tutti gli switch inizialmente **si credono root**
    
- Il **root bridge** è lo switch con il **Bridge ID più basso**
    

**Bridge ID (BID)** =

- Bridge Priority (con VLAN ID incluso)
    
- MAC Address (tie-breaker)
    

Valore più basso = vince.

**Default**

- Bridge priority base: 32768
    
- VLAN 1 → **32769** (32768 + 1)
    

⚠️ Nota importante (concettuale)

La **Bridge Priority** viene **sempre valutata**, ma **di fatto non è discriminante**
finché tutti gli switch mantengono il valore di default (32768).

In assenza di un intervento dell’amministratore:
- la priority è uguale per tutti
- l’elezione del root bridge è quindi determinata dal **MAC address più basso**

La bridge priority esiste per permettere all’amministratore di **forzare
deterministicamente** l’elezione del root bridge.

![[Screenshot_1 1.png]]
![[Screenshot_2 1.png]]
👉 Per default vince lo switch con MAC address più basso

Root Bridge

- **TUTTE le sue porte sono Designated**
    
- **TUTTE in Forwarding**

### Step 2 – Root Port Selection

Ogni switch **non-root** sceglie **UNA Root Port**:

- È la porta con il **costo totale più basso verso il root**
    

**STP Path Cost (valori da sapere)**

- 10 Mbps → 100
    
- 100 Mbps (FastEthernet) → 19
    
- 1 Gbps (Gigabit) → 4
    
- 10 Gbps → 2
    

Il **root cost** = somma dei costi delle interfacce **in uscita** verso il root.

**Tie-breaker Root Port**

1. Lowest root cost
    
2. Neighbor con Bridge ID più basso
    
3. Neighbor con **Port ID più basso** (port priority + port number)
    

⚠️ Si usa il **Port ID del vicino**, non quello locale.

### Step 3 – Designated vs Non-Designated Ports

Per **ogni collision domain (link)**:

- Deve esistere **UNA sola Designated Port**
    

Criteri:

1. Switch con **root cost più basso** → Designated
    
2. Se pari → switch con Bridge ID più basso
    
3. L’altro lato diventa **Non-Designated (Blocking)**
    

**Regole chiave**

- Root Port → sempre Forwarding
    
- Designated Port → sempre Forwarding
    
- Non-Designated Port → Blocking

### Stato finale STP

- 1 Root Bridge
    
- Ogni switch non-root:
    
    - 1 Root Port
        
- Ogni link:
    
    - 1 Designated Port
        
    - 0 o 1 Non-Designated Port (bloccata)
        

Risultato: **topologia loop-free** con link di backup pronti.

## CLI Core

`show spanning-tree`

## Common Mistakes

- Dimenticare che il VLAN ID entra nel Bridge ID
    
- Usare il port ID **locale** come tie-breaker (è quello del vicino)
    
- Pensare che STP disabiliti fisicamente le porte (le mette in Blocking)
    

## Synthesis

STP elimina i loop Layer 2 eleggendo un root bridge e lasciando una sola path attiva per ogni segmento, bloccando i link ridondanti.

## Links

- [[STP 802.1D – Stati, Timer e BPDU (Part 2)]]