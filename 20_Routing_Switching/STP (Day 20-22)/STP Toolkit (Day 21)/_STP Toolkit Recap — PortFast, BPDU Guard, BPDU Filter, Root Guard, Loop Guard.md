

> **Obiettivo**: usare il _tool giusto_ sulla _porta giusta_ per il _problema giusto_.  
> Tutti questi meccanismi **non sostituiscono STP**, lo **rafforzano**.

---

## Mappa mentale rapida (prima di entrare nel dettaglio)

|Tool|Dove si usa|Problema che risolve|
|---|---|---|
|**PortFast**|Porte verso **end host**|Ridurre tempi di convergenza|
|**BPDU Guard**|Porte verso **end host**|Bloccare switch non autorizzati|
|**BPDU Filter**|Casi molto specifici|Silenziare STP (rischioso)|
|**Root Guard**|Porte verso **switch esterni**|Proteggere il root bridge|
|**Loop Guard**|Porte che **devono ricevere BPDUs**|Prevenire loop da link unidirezionali|

---

## PortFast

### What it does

- Fa entrare la porta **direttamente in Forwarding** (salta listening/learning).
    

### Where

- **Access ports verso PC, server, stampanti**.
    

### Why

- Evita delay inutili (es. DHCP timeout, boot lento).
    
- Gli end host **non generano BPDUs**, quindi è sicuro.
    

### Note chiave

- **Non usare su link tra switch**.
    
- Può essere abilitato **globalmente** (default su access).
    

---

## BPDU Guard

### What it does

- Se una porta **PortFast riceve una BPDU** → **err-disable immediato**.
    

### Where

- **Stesse porte di PortFast** (edge ports verso host).
    

### Why

- Protezione da:
    
    - switch collegati “di nascosto”
        
    - loop accidentali causati da utenti
        

### Comportamento

- **ErrDisable** → richiede intervento (manuale o recovery).
    

### Modello mentale

> “Su questa porta **non devono MAI arrivare BPDUs**.”

---

## BPDU Filter ⚠️

### What it does

- **Sopprime l’invio (e/o ricezione) di BPDUs**.
    

### Where

- **Quasi mai**. Solo scenari controllati/lab.
    

### Why (teorico)

- Silenziare STP per casi particolari.
    

### Rischio

- **Bypass totale di STP** → loop L2 possibili.
    
- **Mai consigliato** in produzione CCNA-level.
    

---

## Root Guard

### What it does

- Impedisce a una porta di diventare **Root Port**.
    
- Se riceve **superior BPDUs** → **Root Inconsistent (BKN)**.
    

### Where

- Porte verso **switch fuori dal tuo controllo**
    
    - es. customer ↔ provider
        
    - uplink verso reti terze
        

### Why

- Evitare che un altro switch **prenda il ruolo di root** e ti rovini:
    
    - topologia
        
    - path ottimali
        
    - stabilità
        

### Recovery

- **Automatico** quando cessano i superior BPDUs (≈ Max Age).
    

### Modello mentale

> “Da questa porta **non accetto root esterni**.”

---

## Loop Guard

### What it does

- Se una porta **smette di ricevere BPDUs** quando dovrebbe → **Loop Inconsistent (BKN)**.
    

### Problema reale

- **Link unidirezionali** (tipico su fibra):
    
    - BPDUs non arrivano
        
    - porta bloccata → pensa “ok, posso forwardare” → loop
        

### Where

- Porte che **devono ricevere BPDUs**:
    
    - **Root Ports**
        
    - **Non-Designated (Blocking)**
        

### Why

- Evita che una porta bloccata diventi forwarding per errore.
    

### Recovery

- **Automatico** quando i BPDUs tornano.
    

### Modello mentale

> “Se non sento più BPDUs dove dovrei, **mi blocco**.”

---

## Root Guard vs Loop Guard (confine chiave ⚠️)

|Root Guard|Loop Guard|
|---|---|
|Reagisce a **BPDUs superiori**|Reagisce a **assenza di BPDUs**|
|Protegge il **root**|Protegge da **link unidirezionali**|
|Usato su **designated ports**|Usato su **root / non-designated ports**|
|Stato: **ROOT_Inc**|Stato: **LOOP_Inc**|

🚫 **Mutuamente esclusivi**:  
non possono essere attivi sulla **stessa porta**.

---

## Regola d’oro da esame 🧠

- **End host** → PortFast + BPDU Guard
    
- **Switch non fidato** → Root Guard
    
- **Link tra switch che ricevono BPDUs** → Loop Guard
    
- **Silenziare STP** → BPDU Filter (quasi mai)
    

---

## CLI essenziale

```
spanning-tree portfast
spanning-tree bpduguard enable
spanning-tree bpdufilter enable

spanning-tree guard root
spanning-tree guard loop
spanning-tree loopguard default

show spanning-tree
show spanning-tree interface <int> detail
```


---

## Sintesi finale

Lo **STP Toolkit** non è un insieme di “feature a caso”, ma un **sistema coerente**:

- **PortFast/BPDU Guard** → proteggono l’edge
    
- **Root Guard** → protegge la _gerarchia_
    
- **Loop Guard** → protegge da _failure silenziosi_
    
- **BPDU Filter** → strumento chirurgico (e pericoloso)
    

Usarli correttamente significa **anticipare gli errori**, non solo reagire.