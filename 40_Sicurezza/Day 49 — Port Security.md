
### What is it

**Port Security** è una feature di sicurezza di **Layer 2** sugli switch Cisco che permette di:

- limitare **quali MAC sorgente** possono usare una porta
    
- limitare **quanti MAC sorgente** possono usare una porta
    

Se arriva un frame con MAC non autorizzato → si verifica una **port-security violation**.

---

### What does / How it works

#### Funzione base

- Configurata **per interfaccia**
    
- Ogni frame in ingresso viene controllato:
    
    - se il **source MAC è autorizzato** → forward
        
    - se **non autorizzato** → azione di violazione
        

#### Default behavior

Quando abiliti solo `switchport port-security`:

- MAC consentiti: **1**
    
- MAC consentito:
    
    - se non configurato manualmente → **primo MAC visto**
        
- Violation mode: **shutdown**
    
- Effetto:
    
    - porta in **err-disabled**
        
    - traffico bloccato finché non viene riabilitata
        

---

### Why we use it (collegamento diretto all’esame)

Port Security è usata per:

- impedire accesso a **device non autorizzati**
    
- **mitigare attacchi** che usano molti MAC spoofati:
    
    - **DHCP starvation / exhaustion**
        
    - **MAC address table flooding**
        

➡️ Limita il **numero di MAC per porta**, bloccando attacchi basati su spoofing massivo.

⚠️ Non impedisce MAC spoofing in assoluto (è facile), ma **riduce l’impatto**.

---

## Condizioni NECESSARIE (tranello d’esame)

Port Security funziona **solo se la porta è statica**.

❌ NON funziona su:

- `dynamic auto`
    
- `dynamic desirable`
    

✅ Funziona su:

- `switchport mode access`
    
- `switchport mode trunk`
    

---

### Secure MAC addresses

**Secure MAC address**: MAC address appreso dinamicamente o configurato manualmente su una porta con port security, che identifica un dispositivo autorizzato a trasmettere frame su quell’interfaccia.

- I secure MAC address possono essere:
    
    - **Dynamic**: appresi automaticamente dal traffico in ingresso
        
    - **Static**: configurati manualmente
        
    - **Sticky**: appresi dinamicamente ma salvati come statici nel running-config
        
- I secure MAC address sono inseriti nella **MAC address table**:
    
    - dynamic secure MAC → tipo **dynamic**
        
    - static / sticky secure MAC → tipo **static**
        
- I secure MAC address possono:
    
    - essere soggetti ad **aging** (dynamic di default)
        
    - generare **violation** se superano limiti o non sono autorizzati

---

## Violation modes (CORE CCNA)

### 1. shutdown (**default**)

- Porta → **err-disabled**
    
- Traffico → bloccato
    
- Syslog / SNMP → **1 messaggio**
    
- Violation counter → **1**
    
- Richiede:
    
    - `shutdown / no shutdown` **oppure**
        
    - errdisable recovery
        

---

### 2. restrict

- Traffico non autorizzato → **scartato**
    
- Porta → **rimane up**
    
- Syslog / SNMP → **ogni violazione**
    
- Violation counter → **incrementa**
    

---

### 3. protect

- Traffico non autorizzato → **scartato**
    
- Porta → **rimane up**
    
- Syslog / SNMP → **nessuno**
    
- Violation counter → **non incrementa**
    

---

## Re-enabling di una porta err-disabled

### Metodo manuale

1. **Scollegare il device non autorizzato**
    
2. Sull’interfaccia:
    
    - `shutdown`
        
    - `no shutdown`
        

### Metodo automatico (errdisable recovery)

- Disabilitato di default
    
- Va abilitato **per la causa specifica**
    

⚠️ Se non scolleghi il device sbagliato:

- la porta tornerà **subito** in violazione
    

---

## Secure MAC Aging

### Concetto base

L’**aging** stabilisce **se e quando** un **secure MAC address** viene rimosso da una porta con **port-security**.

👉 **Non tutti i secure MAC fanno aging.** Dipende dal **tipo** e dalla **configurazione**.

---

### Default (senza configurazione di aging)

- **Aging time = 0**
    
- ❌ **Nessun secure MAC scade**
    
- I MAC restano finché:
    
    - l’interfaccia va down
        
    - il device viene riavviato
        

---

### Aging time

- Configurabile in **minuti**
    
- Indica **dopo quanto tempo** un secure MAC può essere rimosso
    

`switchport port-security aging time <minuti>`

---

### Aging type

#### `absolute`

- Il MAC viene rimosso **allo scadere del timer**
    
- ❌ **Il traffico non influisce**
    
- Scade **sempre**, anche se attivo
    

#### `inactivity`

- Il timer si **resetta se arrivano frame**
    
- Il MAC scade **solo se inattivo**
    
- Comportamento simile al **MAC address table aging**
    

`switchport port-security aging type inactivity`

---

### Static / Sticky aging (punto critico)

#### Default

- ✅ **Solo i secure MAC dinamici** possono fare aging
    
- ❌ **Statici e sticky NON scadono**
    

#### Con `aging static`

`switchport port-security aging static`

- Anche **secure MAC statici** possono scadere
    
- Il MAC viene:
    
    - rimosso dalla porta
        
    - **cancellato dal running-config**
        

⚠️ **Eccezione CCNA importante**:  
Gli **sticky MAC** sono generalmente trattati come **non-aging**, anche se `aging static` è attivo.

---

## Sticky Secure MAC Addresses

### Cos’è

- MAC **appreso dinamicamente**
    
- **Scritto automaticamente nel running-config**
    
- Si comporta come un **static secure MAC**
    

`switchport port-security mac-address sticky`

---

### Caratteristiche

- ❌ **Non fa aging** (impostazione tipica CCNA)
    
- Sopravvive a un reload **solo se**:
    
    `write memory`
    

---

### Conversioni

- Abilitando sticky:
    
    - secure MAC **dinamici → sticky**
        
- Disabilitando sticky:
    
    - sticky → **secure MAC dinamici**
        

---

## Tabella riassuntiva (da esame CCNA)

|Tipo secure MAC|Come viene creato|Aging possibile|Note|
|---|---|---|---|
|**Statico**|Configurato manualmente|❌ No (default) / ✅ con `aging static`|Presente nel running-config|
|**Dinamico**|Appreso automaticamente|✅ Sì (se aging attivo)|Non salvato in config|
|**Sticky**|Dinamico → scritto in config|❌ No (CCNA)|Diventa persistente|

---

## MAC Address Table

- I **secure MAC address** vengono **sempre inseriti** nella **MAC address table**
    
- Nella MAC table sono classificati come:
    
    - **Dynamic** → secure MAC appresi dinamicamente
        
    - **Static** → secure MAC **statici** e **sticky**
        
- Possono essere:
    
    - visualizzati **insieme agli altri MAC** con:
        
        `show mac address-table`
        
    - visualizzati **solo come secure MAC** con:
        
        `show mac address-table secure`

---

## CLI

```
show interfaces g0/1 switchport
show port-security interface g0/1
show port-security
show errdisable recovery
show interfaces status
show mac address-table secure
```


```
interface g0/1
 switchport mode access
 switchport port-security
```


```
interface g0/1
 switchport port-security maximum 2
 switchport port-security mac-address aaaa.bbbb.cccc
```

```
interface g0/1
 switchport port-security violation shutdown
 switchport port-security violation restrict
 switchport port-security violation protect
```

```
errdisable recovery cause psecure-violation
errdisable recovery interval 180
```

```
interface g0/1
 switchport port-security aging time 30
 switchport port-security aging type inactivity
 switchport port-security aging static

```

```
interface g0/1
 switchport port-security mac-address sticky

```

`write memory`

---

## Common mistakes / notes (da quiz)

- Dimenticare che **dynamic auto** blocca port security
    
- Non scollegare il device sbagliato prima del recovery
    
- Sticky senza `write memory` → persi al reboot
    
- Confondere:
    
    - **restrict** vs **protect**
        
    - aging **absolute** vs **inactivity**