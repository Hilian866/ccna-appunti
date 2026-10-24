### What is it

PortFast è una feature di Spanning Tree che consente a una porta **collegata a un end host** di entrare **immediatamente nello stato Forwarding**, bypassando gli stati Listening e Learning.

### Why it exists (problem)

- Una porta STP normale impiega **30 secondi** prima di inoltrare traffico:
    
    - 15s Listening
        
    - 15s Learning
        
- Su una porta collegata a un PC **non esiste rischio di loop Layer 2**.
    
- Il ritardo causa una **pessima user experience** (“la rete non funziona”).

### How it works

- PortFast:
    
    - **salta Listening e Learning**
        
    - porta la porta **direttamente in Forwarding**
        
- È sicuro **solo** su porte che **non possono creare loop** (end host, router).

### Where it can be used

- ✅ Porte **access** verso PC
    
- ✅ Porte **trunk** verso:
    
    - router (ROAS)
        
    - server di virtualizzazione (VM su più VLAN)
        
- ❌ **Mai** su porte verso altri switch (rischio loop)

### STP behavior comparison

|Stato|Traffico|MAC learning|
|---|---|---|
|Default STP|dopo 30s|sì|
|PortFast|immediato|sì|

### CLI Core

**Interface-level (access port)**

`interface g0/1 spanning-tree portfast`

**Global (tutte le access port)**

`spanning-tree portfast default`

**Disabilitare PortFast su una porta specifica**

`interface g0/2 spanning-tree portfast disable`

**PortFast su trunk (caso speciale)**

`interface g0/0 spanning-tree portfast trunk`

### Verification

`show spanning-tree interface g0/1 detail`

Output rilevante:

- `portfast edge mode`
    
- `portfast edge trunk mode`

### PortFast Edge (nota d’esame)

- PortFast usato nel CCNA = **PortFast Edge**
    
- IOS moderno **aggiunge automaticamente `EDGE`**
    
- Comandi equivalenti:
    
    - `spanning-tree portfast`
        
    - `spanning-tree portfast edge`
        
- Packet Tracer **non supporta EDGE keyword** → comportamento comunque valido

### Common Mistakes

- Abilitare PortFast su link verso switch
    
- Credere che `portfast default` agisca anche sui trunk
    
- Dimenticare che **access ≠ trunk**

### Synthesis

PortFast elimina un ritardo inutile su porte che non possono creare loop, migliorando l’esperienza utente senza compromettere STP.