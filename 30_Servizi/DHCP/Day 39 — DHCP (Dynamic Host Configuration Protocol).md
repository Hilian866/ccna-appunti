
### What is it

**DHCP** consente agli host di **ottenere automaticamente**:

- IP address
    
- subnet mask
    
- default gateway
    
- DNS server
    
- altri parametri  
    senza configurazione manuale.
    

Usato soprattutto per **end host** (PC, telefoni).  
Router, server → di solito **statici**.

---

### Key rules / exam points

- DHCP usa **UDP**
    
    - server → **67**
        
    - client → **68**
        
- Le assegnazioni sono **lease temporanee**
    
- Processo standard = **DORA**
    
- I broadcast DHCP **non attraversano i router**
    
- Per subnet remote serve **DHCP relay**
    

---

### DHCP message flow (DORA)

1. **Discover**
    
    - client → broadcast
        
    - IP sorgente: `0.0.0.0`
        
    - IP destinazione: `255.255.255.255`
        
2. **Offer**
    
    - server → client
        
    - unicast **o** broadcast (dipende dal client)
        
3. **Request**
    
    - client → broadcast
        
    - accetta un’offerta specifica
        
4. **Ack**
    
    - server → client
        
    - conferma → IP configurato
        

Extra:

- **Release**: client → server (unicast)
    
![[Screenshot_1 10.png]]

---

### DHCP lease

- IP assegnato **non è permanente**
    
- Alla scadenza:
    
    - il client rinnova
        
    - oppure rilascia l’IP
        
- Serve a **riutilizzare indirizzi** (WiFi pubblici, reti grandi)
    

---

### DHCP Relay (fondamentale)

Problema:

- client broadcast → router
    
- router **non inoltra broadcast**
    

Soluzione:

- router configurato come **DHCP relay**
    
- trasforma broadcast → **unicast** verso server remoto
    

Comportamento:

- client ↔ router (broadcast)
    
- router ↔ server (unicast)
    

---

### Configurare router come DHCP server

**Cosa fa**

- Assegna IP e parametri ai client locali
    

**CLI**

```
ip dhcp excluded-address 192.168.1.1 192.168.1.10

ip dhcp pool LAN1
 network 192.168.1.0 255.255.255.0
 default-router 192.168.1.1
 dns-server 8.8.8.8
 domain-name jeremysitlab.com
 lease 0 5 30
```


Verifica:

`show ip dhcp binding`

![[Screenshot_2 10.png]]

---

### Configurare router come DHCP relay

**Quando**

- DHCP server **non è nella stessa subnet**
    

**Dove**

- sull’interfaccia **verso i client**
    

**CLI**

```
interface g0/1
 ip helper-address 192.168.10.10
```


Verifica:

`show ip interface g0/1`

![[Screenshot_3 9.png]]


---

### Configurare router come DHCP client

**Uso**

- raro, ma richiesto per CCNA
    

**CLI**

```
interface g0/1
 ip address dhcp
```


Verifica:

`show ip interface g0/1`

---

### Windows (verifica client)

```
ipconfig /all
ipconfig /release
ipconfig /renew
```


---

### Common mistakes / notes

- ❌ Dimenticare che i broadcast non passano i router
    
- ❌ Non configurare `ip helper-address`
    
- ❌ Confondere DNS con DHCP
    
- ❌ Pensare che DHCP assegni solo IP
    
- ❌ Lease infinite in reti dinamiche
    

---

### Mappa mentale rapida

- **DHCP server** → assegna parametri
    
- **DHCP client** → riceve parametri
    
- **DHCP relay** → attraversa subnet
    
- **DORA** → meccanismo chiave