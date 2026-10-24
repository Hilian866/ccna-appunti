
### What is it

Estensione di NAT vista in Day 44.  
Introduce:

- **Dynamic NAT**
    
- **PAT (NAT Overload)**
    

Completa l’argomento **NAT per CCNA 200-301 (exam topic 4.1)**.

### What does / How it works

#### Ripasso rapido — Static NAT (punto mancante)

- Static NAT è **bidirezionale**
    
- Host esterni possono raggiungere host interni tramite **inside global IP**
    
- Mapping **1:1 permanente**

### Dynamic NAT

- Mapping **automatico** inside local → inside global
    
- Sempre **1:1**, ma **temporaneo**
    
- Usa:
    
    - **ACL** → identifica traffico da tradurre
        
    - **NAT pool** → IP pubblici disponibili
        

**Comportamento ACL**

- `permit` → traffico **tradotto**
    
- `deny` → traffico **non tradotto**
    
- ❗ il pacchetto **NON viene droppato**
    

**Limite**

- Pool esaurito → **pacchetto scartato**
    
- Timeout automatico delle entry
    
- `clear ip nat translation *` → rimuove entry dinamiche

### Dynamic PAT (NAT Overload)

- Traduce **IP + porta**
    
- Mapping **many-to-one**
    
- Permette a **molti host interni** di usare **un solo IP pubblico**
    
- Router distingue i flussi tramite **numeri di porta Layer 4**
    

È il tipo di NAT:

- più usato
    
- più efficiente
    
- fondamentale per Internet domestico/aziendale

### Key rules / exam points

- **PAT = NAT Overload**
    
- PAT preserva IPv4 meglio di static/dynamic NAT
    
- Dynamic NAT:
    
    - 1 inside local ↔ 1 inside global
        
    - pool exhaustion → drop
        
- ACL in NAT **non filtra**, **identifica**
    
- Termini fondamentali:
    
    - inside local
        
    - inside global
        
    - outside local
        
    - outside global
        
- `show ip nat translations`
    
- `show ip nat statistics`

### CLI (solo comandi)

```
ip nat inside
ip nat outside

access-list 1 permit 192.168.0.0 0.0.0.255

ip nat pool POOL1 100.0.0.1 100.0.0.10 prefix-length 24

ip nat inside source list 1 pool POOL1

ip nat inside source list 1 pool POOL1 overload

ip nat inside source list 1 interface g0/0 overload

show ip nat translations
show ip nat statistics
clear ip nat translation *
```

![[Screenshot_1 13.png]]


![[Screenshot_2 11.png]]
(modo migliore con nat overload)

### Common mistakes / notes

- Confondere ACL NAT con ACL di filtraggio
    
- Usare **netmask** invece di **wildcard** nell’ACL
    
- Pensare che `deny` blocchi il traffico
    
- Pool troppo piccolo → drop silenzioso
    
- Dimenticare `overload` → PAT non funziona
    
- Interfaccia inside/outside invertite