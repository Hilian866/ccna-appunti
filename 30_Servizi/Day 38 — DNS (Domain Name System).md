
### What is it

**DNS** risolve nomi leggibili (es. `youtube.com`) in **indirizzi IP**.  
I dispositivi comunicano usando IP, gli esseri umani usano nomi.

---

### Key rules / exam points

- DNS = **name → IP**
    
- I client usano DNS server:
    
    - **configurati manualmente**
        
    - oppure **appresi via DHCP**
        
- **UDP/TCP porta 53**
    
    - UDP per query standard
        
    - TCP se risposta > **512 byte**
        
- Tipi di record da conoscere:
    
    - **A** → nome → IPv4
        
    - **AAAA** → nome → IPv6
        
    - **CNAME** → nome → _altro nome_
        
- I dispositivi mantengono una **DNS cache**
    
- Un router **non deve** essere configurato per DNS solo per inoltrare traffico DNS
    

---

### What does / How it works

Flusso base:

1. Client vuole raggiungere `youtube.com`
    
2. Invia **DNS query** al DNS server
    
3. Riceve l’IP
    
4. Usa l’IP per comunicare (es. HTTP)
    

- Il router intermedio **inoltra soltanto i pacchetti**
    
- Nessuna configurazione DNS richiesta sul router per questo scenario
    

---

### DNS cache e hosts file

- I client salvano le risposte DNS in **cache**
    
- Su Windows:
    
    - `ipconfig /displaydns`
        
    - `ipconfig /flushdns`
        
- **Hosts file**:
    
    - mapping manuale nome ↔ IP
        
    - precede DNS
        
    - soluzione semplice ma **non scalabile**
        

---

### DNS su Cisco router (concetto)

Un router può essere:

- **DNS server**
    
- **DNS client**
    
- **entrambi**
    

Nella pratica:

- quasi sempre DNS server = **Windows / Linux**
    
- ma il CCNA richiede sapere **come configurarlo**
    

---

### Configurare router come DNS server

**Cosa fa**

- Il router **risponde alle query DNS** dei client
    
- Se non conosce il nome, può **chiedere a un DNS esterno**
    

**Come si configura**

- Abilita il servizio DNS
    
- Crea record statici
    
- (Opzionale) imposta un DNS esterno come fallback
    

**CLI**

```
ip dns server
ip host PC1 192.168.0.101
ip host PC2 192.168.0.102
ip name-server 8.8.8.8
```

**Flusso**

- Client → router (DNS)
    
- Record presente → risposta immediata
    
- Record assente → router interroga DNS esterno
    

---

### Configurare router come DNS client

**Cosa fa**

- Permette al router di **risolvere nomi nei comandi**
    
    - es. `ping google.com`
        

**Come si configura**

- Specifica il DNS server
    
- Abilita domain lookup (default)
    

**CLI**

```
ip name-server 8.8.8.8
ip domain lookup
```


---

### Differenza chiave (da ricordare)

- **DNS server** → risolve nomi **per altri dispositivi**
    
- **DNS client** → risolve nomi **per sé stesso**
---

### Domain name

- `ip domain name <nome>`
    
- Applica un dominio di default agli hostname
    
- Usato anche per **SSH** (verrà ripreso dopo)
    

Esempio:

- `ping PC1` → `ping PC1.jeremysitlab.com`
    

---

### CLI (solo comandi)

#### Windows (verifica client)

```
ipconfig /all
nslookup youtube.com
ipconfig /displaydns
ipconfig /flushdns
```


#### Cisco IOS — DNS server

```
ip dns server
ip host PC1 192.168.0.101
ip name-server 8.8.8.8
ip domain lookup
show hosts
```


#### Cisco IOS — DNS client

```
ip name-server 8.8.8.8
ip domain lookup
ping youtube.com
```


#### Domain name

```
ip domain name jeremysitlab.com
```


---

### Common mistakes / notes

- ❌ Pensare che il router debba “fare DNS” per inoltrare query → **no**
    
- ❌ Confondere DNS cache con hosts file
    
- ❌ Pensare che DNS usi solo UDP → usa anche TCP
    
- ❌ Cercare record IPv6 con A invece di **AAAA**
    
- ❌ Dimenticare `ip domain lookup` (anche se è default)
    

---

