![[Screenshot_2 6.png]]
## What is it

Un **First Hop Redundancy Protocol (FHRP)** serve a garantire un default gateway ridondante per una subnet: se il router “attivo” fallisce, un altro router prende il suo posto in pochi secondi usando un **Virtual IP (VIP)** e un **Virtual MAC (VMAC)** condivisi.

## How it works

- Problema: i PC hanno un **default gateway statico** (es. `172.16.0.254`). Se quel router cade, i PC continuano a inviare lì.
    
- Soluzione FHRP:
    
    - I router condividono un **VIP** (es. `172.16.0.252`) usato dai PC come **default gateway**.
        
    - I router negoziano i ruoli con **Hello multicast**.
        
    - Un router diventa **attivo** (terminologia varia), l’altro **standby/backup**.
        
- Quando un PC deve uscire dalla subnet:
    
    - fa **ARP** per il VIP → l’attivo risponde con il **VMAC**.
        
    - Il frame verso il gateway usa come **dest MAC il VMAC**.
        
- Failover:
    
    - se l’attivo non invia più Hello, lo standby diventa attivo.
        
    - i PC **non devono cambiare ARP** (VIP→VMAC resta uguale).
        
    - devono aggiornarsi gli **switch** (CAM table): il nuovo attivo invia **gratuitous ARP** (ARP reply non richieste, in broadcast) per far apprendere agli switch che il VMAC ora è raggiungibile tramite lui.
        
- Comportamento di default: **non-preemptive**
    
    - se il vecchio attivo torna online, **non riprende** automaticamente il ruolo.
        
    - con **preemption** abilitata, può riprendersi il ruolo (se ha priorità/IP più alto).
        

### Frame vs Packet (esempio verso 8.8.8.8)

- **IP src/dst (packet):** `PC1 (172.16.0.1)` → `8.8.8.8`
    
- **MAC src/dst (frame):** `PC1 MAC` → `VMAC (FHRP)`


![[Screenshot_1 7.png]]


## FHRP – confronto (dettagli da memorizzare per CCNA)

### HSRP (Cisco proprietary)

- Ruoli: **active / standby**
    
- Versioni:
    
    - **v1**: multicast **224.0.0.2**, gruppi **0–255**
        
    - **v2**: multicast **224.0.0.102**, gruppi **0–4095**, supporto IPv6
        
- VMAC:
    
    - **HSRP v1:** `0000.0c07.acXX` (XX = group in hex, 2 cifre)
        
    - **HSRP v2:** `0000.0c9f.fXXX` (XXX = group in hex, 3 cifre)


![[Screenshot_3 4.png]]
### VRRP (open standard)

- Ruoli: **master / backup**
    
- Multicast IPv4: **224.0.0.18**
    
- VMAC: `0000.5e00.01XX` (XX = group in hex)
    
    - Esempio: group 200 (dec) = `c8` (hex) → `0000.5e00.01c8`
        

### GLBP (Cisco proprietary)

- Load balancing **dentro la stessa subnet** (differenza principale)
    
- Ruoli:
    
    - **AVG** (Active Virtual Gateway)
        
    - **AVF** (Active Virtual Forwarder, fino a 4; AVG può essere anche AVF)
        
- Multicast IPv4: 224.0.0.102
    
- VMAC: `0007.b400.GGFF` (GG=group, FF=AVF)
    
    - Esempio: group 1, AVF 1 → `0007.b400.0101`
## ![[Screenshot_4 3.png]]CLI Core

> Nota: Jeremy indica che la **configurazione non è richiesta per l’esame** (topic “purpose”), ma mostra HSRP base per lab.

```
 interface g0/0
 standby version 2
 standby 1 ip 172.16.0.254
 standby 1 priority 200
 standby 1 preempt
```

`show standby`

## Links

## Common Mistakes

- Confondere il “default gateway ridondante” con “due gateway diversi sui PC”: **i PC usano un solo VIP**.
    
- Dimenticare che il failover richiede aggiornare le tabelle MAC degli switch: avviene via gratuitous ARP.
    
- Pensare che il router tornato online riprenda sempre il ruolo: di default non-preemptive (serve **preempt**).
    
- Usare **HSRP v1** su un router e **HSRP v2** sull’altro: **non sono compatibili**.
    
- Su exam/quiz: non scegliere “risposte plausibili”, ma la **best answer** (es. “gratuitous ARP” è più specifico di “ARP reply”).
    

## Synthesis

Un FHRP fa usare ai PC un **VIP+VMAC** come gateway; se l’attivo fallisce, lo standby diventa attivo e invia gratuitous ARP per aggiornare gli switch, mantenendo invariato il gateway visto dai PC.