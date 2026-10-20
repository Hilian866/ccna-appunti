
### What it does

- **Protegge il root bridge “desiderato”** impedendo che una porta diventi **Root Port**.
    
- Se una porta con Root Guard riceve **superior BPDUs** (cioè BPDUs che “promuovono” un root migliore), la porta entra in stato:
    
    - **Root Inconsistent (ROOT_Inc)** / **Broken (BKN)**
        
    - Effetto: **non forwarda frame** (traffico tagliato su quel link).
        

### When to use

- Su **porte verso switch fuori dal tuo controllo** (provider↔customer, uplink verso terzi).
    
- Obiettivo: evitare che switch esterni “rubino” il ruolo di root e ti cambino la topologia (path subottimali / congestione).
    

### Config

- **Solo per-interfaccia** (non globale):
    
    - `spanning-tree guard root`
        

### Recovery behavior

- **Auto-recovery** quando smettono di arrivare superior BPDUs:
    
    - tipicamente dopo **Max Age ~ 20s** (default) → i BPDUs “migliori” scadono.
        
- Nota: **non è errdisable** come BPDU Guard → non richiede errdisable recovery.
    

### Verify

- `show spanning-tree`
    
    - colonna stato: **BKN**
        
    - reason: **ROOT_Inc**
        

### Core mental model

- Root Guard = “su questa porta _non voglio_ che il mio switch scelga un root esterno”.
    

---

## Micro-correzioni/precisioni utili (2 righe) 🔧

1. **“Collision domain”**: ok, ma per STP pensa “**ogni link/segment tra due switch** → 1 designated port”.
    
2. **BPDUs dopo convergenza** (se non l’hai già patchato):
    
    - root **genera** BPDUs; gli altri **inoltrano** (su designated).
        

---

## Common mistakes (aggiunta rapida) ⚠️

- Confondere Root Guard con BPDU Guard:
    
    - **BPDU Guard**: protegge _access ports/PortFast_ → errdisable se riceve BPDU.
        
    - **Root Guard**: protegge _topologia_ → root-inconsistent finché arrivano superior BPDUs.