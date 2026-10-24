
### What is it

**Dynamic ARP Inspection (DAI)** è una feature di sicurezza Layer 2 sugli switch Cisco che **ispeziona e filtra messaggi ARP** sui **port untrusted** per prevenire ARP poisoning / MITM.  
Fa parte di **exam topic 5.7**, insieme a **Port Security** e **DHCP Snooping**.

### What does / How it works

#### Definizioni atomiche (ripasso rapido)

- **DAI (Dynamic ARP Inspection)**: meccanismo che valida i messaggi ARP confrontando **IP e MAC** con una fonte attendibile (binding DHCP o ARP ACL).
    
- **Trusted port (DAI)**: porta su cui i messaggi ARP **non vengono ispezionati**.
    
- **Untrusted port (DAI)**: porta su cui i messaggi ARP **vengono ispezionati e validati**.
    
- **ARP poisoning**: attacco che altera le ARP table delle vittime per dirottare il traffico verso l’attaccante.
    
- **Gratuitous ARP (GARP)**: ARP reply **non richiesto**, inviato in broadcast, usato legittimamente (es. init interfaccia) ma anche negli attacchi.
    

#### Richiamo ARP (solo ciò che serve a DAI)

- ARP risolve **IP → MAC** in LAN
    
- Campi rilevanti nel messaggio ARP:
    
    - **Sender IP / Sender MAC**
        
    - **Target IP / Target MAC**
        
- ARP **non** usa IP header (resta in LAN)

## Attacco mitigato (core CCNA)

### ARP poisoning (MITM)

- L’attaccante invia **gratuitous ARP** usando l’IP del gateway
    
- Le vittime aggiornano le ARP table → traffico inviato all’attaccante
    
- L’attaccante può **leggere e/o modificare** il traffico e poi inoltrarlo

## Logica di funzionamento DAI (CORE)

### Trusted vs Untrusted

- Tutte le porte sono **untrusted di default**
    
- Tipicamente:
    
    - **Trusted** → uplink verso switch/router
        
    - **Untrusted** → downlink verso end-host
        

### Comportamento

- ARP su trusted → **forward**, nessuna ispezione
    
- ARP su untrusted → **inspection**
    

### Validazione principale

Su untrusted, DAI:

- confronta **Sender IP + Sender MAC** del messaggio ARP con:
    
    - **DHCP snooping binding table** (default)
        
    - **ARP ACL** (per host senza DHCP)
        

Esito:

- match → forward
    
- no match → **drop**
    

⚠️ DAI **dipende normalmente da DHCP Snooping** (per la binding table).

## DHCP Snooping binding table (richiamo)

DAI usa la tabella creata da DHCP Snooping:

- IP
    
- MAC
    
- VLAN
    
- Interfaccia
    
- Lease time
    

Se un host **non usa DHCP** → **nessuna entry** → ARP droppati (serve ARP ACL).

## ARP ACL (overkill ma concettualmente richiesto)

Usate per:

- host con **IP statico**
    
- casi senza DHCP Snooping
    

Funzione:

- mappano **IP ↔ MAC** manualmente
    
- se match → ARP consentito
    

Nota esame:

- **concetto sì**
    
- **config dettagliata no**

## DAI Rate Limiting

### Concetto

- Limita il **numero di ARP ricevuti** su una porta
    
- Se superato → porta in **err-disabled**
    

### Default (diverso da DHCP Snooping)

- **Untrusted**: **abilitato di default**
    
- Rate: **15 packet/sec**
    
- **Trusted**: disabilitato di default
    

### Burst interval

- Permette **X packet / Y secondi**
    
- Più flessibile rispetto a DHCP Snooping
    

Recovery:

- `shutdown / no shutdown`
    
- `errdisable recovery cause arp-inspection`

## Optional validation checks (DAI)

### Comando unico (importante)

Le validazioni **si sovrascrivono** se inserite separatamente.  
Vanno configurate **tutte in un solo comando**.

### Tipi di validazione

- **DST-MAC**
    
    - Ethernet destination MAC == ARP target MAC
        
- **SRC-MAC**
    
    - Ethernet source MAC == ARP sender MAC
        
- **IP**
    
    - IP validi (no 0.0.0.0, broadcast, multicast)
        

⚠️ Tutti i check configurati devono **passare**.

## Key rules / exam points (alta densità)

- DAI = **ARP filtering su untrusted**
    
- Tutte le porte untrusted di default
    
- Trusted → nessuna ispezione
    
- Untrusted → check contro:
    
    - DHCP snooping binding table
        
    - ARP ACL
        
- Mitiga ARP poisoning / MITM
    
- Rate limiting:
    
    - attivo di default su untrusted
        
    - 15 pkt/sec
        
    - supporta burst interval
        
- Validation checks:
    
    - **un solo comando** per più opzioni

## CLI (solo comandi)

`ip arp inspection vlan 1`

```
interface g0/0
 ip arp inspection trust
```


```
show ip arp inspection interfaces
show ip arp inspection
```


```
show ip arp inspection interfaces
show ip arp inspection
```

```
interface g0/1
 ip arp inspection limit rate 25 burst interval 2
```

```
errdisable recovery cause arp-inspection
show errdisable recovery
```

```
arp access-list ARP-ACL-1
 permit ip host 192.168.1.100 mac host aaaa.bbbb.cccc
```

`ip arp inspection filter ARP-ACL-1 vlan 1`

## Common mistakes / notes (da quiz)

- Dimenticare che **tutte le porte sono untrusted** quando abiliti DAI
    
- Abilitare più `ip arp inspection validate` separati → resta solo l’ultimo
    
- Host con IP statico senza ARP ACL → ARP sempre droppati
    
- Confondere:
    
    - **rate limiting DHCP vs DAI**
        
    - **binding table** vs ARP ACL