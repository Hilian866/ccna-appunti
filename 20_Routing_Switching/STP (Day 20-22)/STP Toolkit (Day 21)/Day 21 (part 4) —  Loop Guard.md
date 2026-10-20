
### What it does

- **Difesa extra contro loop L2**: blocca una porta se **smette inaspettatamente di ricevere BPDUs**.
    
- Problema tipico: **link unidirezionale** (spesso fibra) → un _blocking/non-designated_ smette di ricevere BPDUs e, senza protezione, potrebbe **diventare designated/forwarding** ⇒ loop.
    

### Trigger & State

- Se una porta con Loop Guard **non riceve BPDUs** e il **Max Age scade** (default ~ **20s**):
    
    - entra in **Broken (BKN)** / **Loop Inconsistent (LOOP_Inc)**
        
    - la porta resta **up/up** ma **STP la blocca** (non forwarda data frames).
        

### When to use (regola pratica)

- Su porte che **devono ricevere BPDUs**:
    
    - **Root Ports** e **Non-Designated (Blocking)**
        
- _Non_ è pensato per designated verso host; è per link tra switch dove ti aspetti BPDUs in ingresso.
    

### Config

**Per-interfaccia**

- `spanning-tree guard loop`
    

**Globale (default su tutte le porte)**

- `spanning-tree loopguard default`
    

**Disabilitare su una porta specifica (se globale attivo)**

- `spanning-tree guard none`
    

### Recovery behavior

- **Auto-recovery**: appena la porta **riprende a ricevere BPDUs**, esce da **LOOP_Inc** senza intervento manuale.
    

### Verify

- `show spanning-tree` → stato **BKN** + motivo **LOOP_Inc**
    
- `show spanning-tree interface <int> detail` → conferma loop guard (anche “by default” se globale)
    

### Relazione con Root Guard (mutually exclusive) ⚠️

- **Non possono coesistere sulla stessa porta**.
    
    - Root Guard: evita che una **designated** diventi **root port** (blocca su **superior BPDUs**).
        
    - Loop Guard: evita che una **root/non-designated** diventi **designated** (blocca quando **mancano BPDUs**).
        
- Configurare uno **rimpiazza** l’altro sulla porta.
    

### Core mental model

- Loop Guard = “se questa porta dovrebbe _sentire_ BPDUs e non li sente, **non fidarti**: blocca.”
    

---

## Mini-aggiunta “Common Mistakes” (1 riga) 🧷

- Confondere **LOOP_Inc** (mancano BPDUs) con **ROOT_Inc** (arrivano superior BPDUs).