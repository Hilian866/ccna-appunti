## What is it

- **BPDU Guard**: disabilita automaticamente una porta se riceve un BPDU.
    
- **BPDU Filter**: impedisce a una porta di **inviare** BPDUs e, in certi casi, di **processare** quelli ricevuti.
    

Entrambe sono feature dello **STP toolkit**, usate tipicamente **insieme a PortFast** su porte verso end host.

## Context: PortFast behavior recap

- Una porta con **PortFast**:
    
    - entra subito in **Forwarding**
        
    - **continua a inviare BPDUs**
        
    - se **riceve un BPDU**, torna a comportarsi come una porta STP normale
        

Problema:  
se un utente collega **uno switch** a una porta pensata per host, può **alterare la topologia STP** (root bridge, percorsi, link bloccati).

## BPDU Guard

### What it does

- La porta continua a inviare BPDUs
    
- **Se riceve un BPDU → err-disabled**
    
- La porta viene **disabilitata** (non traffico, non BPDUs)
    

Scopo:

- impedire che **switch non autorizzati** influenzino STP

### Typical use

- Porte PortFast verso:
    
    - PC
        
    - stampanti
        
    - router
        
- ❌ **mai** verso altri switch legittimi

### Configuration

**Per-port**

`interface g0/1 spanning-tree bpduguard enable`

**Default (consigliato)**

`spanning-tree portfast bpduguard default`

⚠️ Nota CCNA:

- **BPDU Guard default ≠ tutte le access port**
    
- si attiva **solo sulle porte con PortFast**
    

**Disabilitare su una porta**

`interface g0/1 spanning-tree bpduguard disable`

### Err-Disable behavior

- Alla violazione:
    
    - porta → **err-disabled**
        
- Il cavo scollegato **non basta**
    
- Due metodi di recovery:
    

**Manuale**

`interface g0/1 shutdown no shutdown`

**Automatico (ErrDisable Recovery)**

`errdisable recovery cause bpduguard`

- Timer default: **300 secondi**
    
- Comando di verifica:
    

`show errdisable recovery`

⚠️ Regola chiave:

> **se non risolvi la causa, la porta verrà disabilitata di nuovo**

## BPDU Filter

### What problem it solves

- Una porta verso host:
    
    - invia BPDUs ogni 2s
        
    - inutile
        
    - potenziale leakage di info STP
        
- **BPDU Filter** impedisce l’invio dei BPDUs

### Two behaviors (critico per CCNA)

#### 1️⃣ Per-port (rischioso)

`interface g0/1 spanning-tree bpdufilter enable`

Effetto:

- **non invia BPDUs**
    
- **ignora BPDUs ricevuti**
    
- STP **disabilitato sulla porta**
    

⚠️ Pericoloso:

- può causare **loop permanenti**
    
- broadcast storm

#### 2️⃣ Default (raccomandato)

`spanning-tree portfast bpdufilter default`

Effetto:

- non invia BPDUs
    
- **se riceve un BPDU**:
    
    - BPDU Filter disabilitato
        
    - PortFast disabilitato
        
    - la porta torna **STP normale**
        

→ **best practice**

Disabilitare su una porta

`interface g0/1 spanning-tree bpdufilter disable`

## BPDU Guard + BPDU Filter together

Dipende **da come** BPDU Filter è configurato:

|Configurazione BPDU Filter|BPDU ricevuto|Risultato|
|---|---|---|
|per-port|ignorato|BPDU Guard **non scatta**|
|default|processato|BPDU Guard → **err-disable**|

Conclusione:

> **BPDU Filter per-port annulla BPDU Guard**

## Common Mistakes

- Usare BPDU Filter per-port “per comodità”
    
- Pensare che BPDU Guard protegga sempre
    
- Confondere _access port_ con _PortFast-enabled port_
    
- Riabilitare una porta err-disabled senza risolvere la causa

## Synthesis

- **PortFast** accelera
    
- **BPDU Guard** protegge
    
- **BPDU Filter default** riduce rumore **senza spegnere STP**
    
- **BPDU Filter per-port** = rischio serio

## Links

- [[Day 21 (Part 1) — PortFast (STP)]]
    
- [[Day 21 (Part 3) — Root Guard]]
- [[Day 21 (part 4) —  Loop Guard]]