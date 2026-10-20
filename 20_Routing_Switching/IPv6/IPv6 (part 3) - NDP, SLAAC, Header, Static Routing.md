
## What is it

Terza parte di IPv6 (CCNA): chiude IPv6 introducendo **NDP (al posto di ARP)**, **SLAAC**, cenni di **IPv6 header**, e soprattutto **static routing IPv6** (topic 3.3).


### IPv6 Header (high-level)

- Header **fisso 40 bytes** (più semplice di IPv4).

![[Screenshot_1 8.png]]

---

## NDP (Neighbor Discovery Protocol) = “ARP replacement” in IPv6

## What is it

Protocollo IPv6 che sostituisce **ARP** e fornisce:

- risoluzione **IPv6 → MAC**
    
- scoperta dei router sul link
    
- **Duplicate Address Detection (DAD)**
    

---

## How it works

### 1) Risoluzione IPv6 → MAC (equivalente ARP)

Quando un host/router deve inviare un frame Ethernet a un **neighbor IPv6 sullo stesso link**:

1. conosce l’**IPv6 unicast** del neighbor
    
2. **non conosce il MAC**
    
3. invia un **Neighbor Solicitation (NS)**
    
4. l’NS **NON è broadcast**
    
5. l’NS è inviato al **solicited-node multicast address** del target
    
6. il target risponde con un **Neighbor Advertisement (NA)** contenente il MAC

![[Screenshot_3 8.png]]
Per CCNA è **sufficiente** fissare _che cosa fa_ e _quando entra in gioco_, non _tutti i passi_.

👉 Questo è **il punto chiave**:  
**NDP usa il solicited-node multicast per fare ciò che ARP faceva con broadcast.**

---

### 2) Solicited-node multicast (legame diretto con NDP)

- Ogni IPv6 unicast address ha un **solicited-node multicast address** associato
    
- Viene usato **solo** da NDP (NS, DAD)
    

**Formato**

- `ff02::1:ff` + **ultimi 6 hex** dell’IPv6 unicast
    

**Perché esiste**

- limita il traffico: solo il nodo “interessato” ascolta
    
- evita il broadcast a tutti gli host del link
    
![[Screenshot_2 9.png]]
---

### 3) Messaggi NDP (ICMPv6)

|Funzione|Messaggio|Tipo|Destinazione|
|---|---|---|---|
|IPv6 → MAC|**NS**|135|solicited-node multicast|
|Risposta MAC|**NA**|136|unicast al richiedente|
|Scoperta router|**RS**|133|`ff02::2` (all-routers)|
|Annuncio router|**RA**|134|`ff02::1` (all-nodes)|
|DAD|**NS**|135|solicited-node multicast (proprio)|
### Show / verify

ARP Table sostituita da IPv6 neighbor table:

`show ipv6 neighbor`

![[Screenshot_4 6.png]]
---

## SLAAC (Stateless Address Auto-Configuration)

### What does

- Host impara il **prefix** via **RS/RA**, poi si auto-configura un IPv6 address (interface ID via EUI-64 o random, dipende dal device).
    
![[Screenshot_6 5.png]]
### Cisco IOS (example)

``` 
interface g0/0  
ipv6 address autoconfig
```



---

## IPv6 Static Routing 

Configurazione manuale di rotte IPv6 che dicono al router **dove inoltrare i pacchetti** quando la rete di destinazione non è direttamente connessa.

1. Un pacchetto IPv6 arriva al router.
    
2. Il router guarda la **IPv6 routing table**.
    
3. Cerca la **migliore corrispondenza** (longest prefix).
    
4. Se trova una **static route**, usa:
    
    - un **next-hop IPv6 address**
        
    - e/o una **exit interface**
        
5. Se non trova nulla → pacchetto scartato (a meno di default route).
    

⚠️ IPv4 e IPv6 usano **tabelle separate**, ma la logica è identica.

---

## Requirements

Su Cisco, **IPv6 routing è disabilitato di default**.

`ipv6 unicast-routing`

Se manca questo comando:

- il router **parla IPv6**
    
- ma **non inoltra** traffico IPv6 tra subnet
    

---

## Static Route – Concetti base

### 1) Tipi di route (cosa raggiungo)

- **Network route** → una subnet (`/64`)
    
- **Host route** → un singolo host (`/128`)
    
- **Default route** → tutto il resto (`::/0`)
    
- **Floating static** → backup (AD più alta)
    
![[Screenshot_7 3.png]]
---

### 2) Forme di configurazione (come la scrivo)

|Forma|Cosa specifico|Nota|
|---|---|---|
|Directly attached|solo interfaccia|⚠️ **NON funziona su Ethernet in IPv6**|
|Recursive|solo next-hop|✅ più comune|
|Fully specified|interfaccia + next-hop|✅ obbligatoria con link-local|
![[Screenshot_8 2.png]]
---

## CLI Core

### Abilitare routing IPv6

`ipv6 unicast-routing`

### Network route (recursive)

`ipv6 route 2001:db8:0:3::/64 2001:db8:0:12::2`

### Host route

`ipv6 route 2001:db8:0:1::10/128 2001:db8:0:12::1`

### Default route

`ipv6 route ::/0 2001:db8:0:23::2`

### Floating static (backup)

`ipv6 route 2001:db8:0:3::/64 2001:db8:0:12::2 200`

---

## Link-local next-hop (regola importante)

Se il **next-hop è link-local**, il router **non sa su quale interfaccia si trovi**.

👉 Devi specificare **entrambi**.

`ipv6 route 2001:db8:0:3::/64 g0/0 fe80::2`

Questa è una **fully specified static route**.

---

## Show / Verify

```
show ipv6 route
show ipv6 interface brief
```

---

## Common IPv6 Static Routing Mistakes

- Dimenticare `ipv6 unicast-routing`
    
- Usare solo l’interfaccia su Ethernet (IPv6) → route non funziona
    
- Usare link-local come next-hop **senza** interfaccia
    
- Confondere:
    
    - tipo di route (network / host / default)
        
    - forma di configurazione (recursive / fully specified)

---

## Exam focus (memorize)

- IPv6 **non usa ARP** → usa **NDP** (NS/NA) + solicited-node multicast.
    
- RS(133) → `ff02::2`, RA(134) → `ff02::1`.
    
- Default route IPv6: `::/0`.
    
- Abilita routing IPv6: `ipv6 unicast-routing`.
    
- Link-local come next-hop → serve anche exit interface.