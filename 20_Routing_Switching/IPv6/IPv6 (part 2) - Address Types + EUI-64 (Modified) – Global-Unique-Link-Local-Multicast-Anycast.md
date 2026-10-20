
## What is it

Panoramica dei **tipi di indirizzi IPv6** richiesti per CCNA (topic **1.9**) e metodo **EUI-64 (modified EUI-64)** per generare automaticamente la parte host (interface identifier) in un indirizzo IPv6 **/64**.

## How it works

### Modified EUI-64 (EUI-64)

- Scopo: convertire un **MAC 48-bit** in un **Interface Identifier 64-bit**, usabile come host portion in un IPv6 **/64**.
    
- Passi (manuali, ma su router è automatico):
    
    1. **split** del MAC in due metà
        
    2. inserire `fffe` nel mezzo
        
    3. **invertire il 7° bit (UL bit)**
        
![[Screenshot_2 8.png]]
**Nota (UL bit)**

- In MAC:
    
    - UL=0 → **UAA** (universally administered)
        
    - UL=1 → **LAA** (locally administered)
        
- In contesto EUI-64 IPv6 il significato è **invertito** (non cambia la funzione dell’IPv6 address).
    

**Config EUI-64 su interfaccia**

- Prefisso + `eui-64` → il router genera l’host portion.
    

### Global Unicast (1.9a)

- **Public** IPv6, **routable su Internet** (richiede registrazione/assegnazione).
    
- Struttura tipica mostrata:
    
    - **Global routing prefix** (es. /48 assegnato dall’ISP)
        
    - **Subnet identifier** (tipicamente 16 bit per arrivare a /64)
        
    - **Interface identifier** (host portion, 64 bit; può essere EUI-64 o manuale)
        
![[Screenshot_3 6.png]]
### Unique Local (1.9b)

- **Private** IPv6, **non routable su Internet** (ISP lo scarta), ma **routable internamente** tra subnet.
    
- Range: `fc00::/7`, ma in pratica **`fd00::/8`** (ottavo bit = 1).
    
- Struttura:
    
    - `fd` (tipo)
        
    - **Global ID** (40 bit / 10 hex) → **consigliato random** per evitare overlap quando reti si uniscono/merger
        
    - **Subnet identifier**
        
    - **Interface identifier**
        
![[Screenshot_4 5.png]]
### Link-Local (1.9c)

- Auto-generate su interfacce con IPv6 attivo.
    
- Abilitazione senza indirizzo globale:
    
    - `ipv6 enable` → genera solo link-local.
        
- Range: `fe80::/10` (in pratica inizia con **fe8** perché i bit successivi sono 0 secondo lo standard).
    
- Non vengono **routati** tra subnet (valido “nel link”).
    ![[Screenshot_5 6.png]]
- Usi citati:
    
    - **OSPFv3** neighbor adjacencies / LSA
        
    - **next-hop** per static routes
        
    - **NDP** (replacement di ARP in IPv6)
        

### Multicast (1.9e)

- Range: `ff00::/8`
    
- IPv6 **non usa broadcast**; usa multicast (es. “all nodes”).
    
- Indirizzi da sapere (pattern: ultimo numero spesso corrisponde a IPv4):
    ![[Screenshot_6 4.png]]
    


**Scopes multicast (4° hex digit)**

- `ff01` **interface-local** (node-local): non esce dal dispositivo
    
- `ff02` **link-local**: resta nella subnet, non routato
    
- `ff05` **site-local**
    
- `ff08` **organization-local**
    
- `ff0e` **global**
    
![[Screenshot_7 2.png]]


### Anycast (1.9d)

- “one to **one of many**”: più router condividono lo **stesso indirizzo**; routing lo porta al “più vicino” (metric più bassa).
    
- Non ha un range dedicato: si usa un unicast (global/unique local) marcato come **anycast**.
    
- Config: indirizzo + keyword `anycast` (mostrato in `show ipv6 interface` come `any`).
    

### Altri indirizzi

- **Unspecified**: `::` (tutti 0)
    
    - usato quando un device non conosce ancora il suo IPv6; default route IPv6 punta a `::/0` (citato per Day 33).
        
- **Loopback**: `::1`
    
    - equivalente IPv4: 127.0.0.0/8 (IPv6 usa un solo indirizzo).
        

## CLI Core

```
interface g0/0
 ipv6 address 2001:db8:1::/64 eui-64
 
show interfaces

show ipv6 interface brief

interface g0/0
 ipv6 address 2001:db8:1::1/128 anycast
 
interface g0/0
 ipv6 enable
```



## Common Mistakes

- Confondere **EUI-64** con un “tipo” di IPv6 address: è un **metodo di generazione** dell’interface ID.
    
- Pensare che **unique local** non sia routable “in assoluto”: non è routable su **Internet**, ma è routable **internamente**.
    
- Confondere **link-local address (fe80::/10)** con **multicast link-local scope (ff02::/16)**: sono concetti diversi.
    
- Dimenticare che IPv6 **non ha broadcast**: usare `ff02::1` per “tutti gli host”.
    
- Scambiare `ff01` (interface-local) per traffico “alla subnet”: per la subnet serve `ff02` (link-local).
    

## Synthesis

IPv6 usa diversi tipi di indirizzi (global/unique/link-local/multicast/anycast); EUI-64 genera automaticamente l’interface ID da MAC per un /64, e multicast sostituisce il broadcast (es. `ff02::1`, `ff02::2`).