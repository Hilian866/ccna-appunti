
### What is it

Tecnica per **aggregare più link fisici** tra due dispositivi in **un’unica interfaccia logica** (Port-Channel / LAG).  
Risolve il “collo di bottiglia + link bloccati da STP”: **STP vede 1 link**, non N.

### How it works

- Senza EtherChannel: più link tra switch ⇒ **STP blocca tutti tranne uno** (evita loop) ⇒ **banda sprecata**
    
- Con EtherChannel:
    
    - più porte fisiche → **1 Port-Channel**
        
    - **STP tratta il Port-Channel come singolo link**, quindi non blocca i membri
        
    - traffico distribuito con **load-balancing per flow** (non per pacchetto)
        
        - stessa coppia sorgente/destinazione → **stesso member link** (evita out-of-order)
            
- Se un membro fallisce:
    
    - il Port-Channel resta su (se rimangono membri attivi)
        
![[Screenshot_1 4.png]]

### Load-balancing (flows)

- Un _flow_ = comunicazione tra due nodi (es. PC1↔SRV1)
    
- Algoritmi possibili (dipende dal modello):
    
    - src-mac / dst-mac / src-dst-mac
        
    - src-ip / dst-ip / src-dst-ip
        
    - talvolta L4 ports (TCP/UDP)

### Negotiation modes

**3 metodi per formare EtherChannel**

- **PAgP** (Cisco proprietary)
    
    - desirable ↔ auto (come DTP)
        
    - auto+auto = NO
        
    - desirable+desirable = YES
        
- **LACP** (IEEE 802.3ad) **(quello richiesto dal blueprint CCNA)**
    
    - active ↔ passive
        
    - passive+passive = NO
        
    - active+active = YES
        
- **Static**
    
    - on ↔ on = YES
        
    - on + (active/desirable) = NO
        

**Nota**: _channel-group number_ deve combaciare **solo localmente** tra member ports; **non deve** matchare l’altro switch.

### CLI Core

**Load-balance**
```
show etherchannel load-balance
port-channel load-balance {src-mac | dst-mac | src-dst-mac | src-ip | dst-ip | src-dst-ip}
```

**Creazione EtherChannel (Layer 2)**
```
interface range g0/0 - 3
 channel-group 1 mode active     ! LACP (preferito)
!
interface port-channel 1
 switchport mode trunk
```

**Verifica**

```
show etherchannel summary
show etherchannel port-channel
show interfaces trunk
show spanning-tree
```


**Layer 3 EtherChannel**

```
interface range g0/0 - 3
 no switchport
 channel-group 1 mode active
!
interface port-channel 1
 ip address X.X.X.X Y.Y.Y.Y
```

### Common Mistakes

- Config membri con parametri **non identici** ⇒ porta esclusa/suspended  
    (duplex, speed, switchport mode, allowed VLANs, native VLAN)
    
- Confondere keyword: **port-channel** (config load-balance) vs **etherchannel** (show)
    
- Pensare che EtherChannel “sommi banda per singolo flow”: no, **un flow usa 1 link**
    
- Mischiare protocolli/mode (es. active + desirable, on + active) ⇒ non si forma

### Synthesis

EtherChannel = “N link fisici, 1 link logico”: STP non spreca porte e la banda scala per flow.