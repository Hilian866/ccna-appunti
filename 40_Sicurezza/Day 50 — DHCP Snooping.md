
### What is it

**DHCP Snooping** è una feature di sicurezza **Layer 2** sugli switch Cisco che **filtra messaggi DHCP** sui **port untrusted** per mitigare attacchi DHCP-based (es. starvation, rogue DHCP/poisoning).  
È in **exam topic 5.7** (con port security e DAI).

---

### What does / How it works

#### Definizioni atomiche (da ripasso)

- **Trusted port**: porta su cui lo switch **non ispeziona** i messaggi DHCP (tipicamente uplink verso infrastruttura/DHCP server/relay).
    
- **Untrusted port**: porta su cui lo switch **ispeziona/filtra** i messaggi DHCP (tipicamente downlink verso host).
    
- **Spurious/Rogue DHCP server**: DHCP server **illegittimo** che risponde ai client e può alterare parametri (es. default gateway).
    
- **DHCP snooping binding table**: tabella creata dallo switch con i binding **IP–MAC–VLAN–interfaccia–lease** dei client che hanno ottenuto IP via DHCP.
    

#### Regola fondamentale

- DHCP snooping **agisce solo sui messaggi DHCP**.  
    Traffico non-DHCP → **non** viene toccato.
    

#### Trusted vs Untrusted (default + design)

- **Tutte le porte sono untrusted di default**
    
- Si marcano **trusted** di norma le **uplink** (verso rete/infrastruttura)
    
- Le **downlink** (verso end-host) restano untrusted
    

#### Comportamento per porta

- Messaggio DHCP su **trusted** → **forward** senza inspection
    
- Messaggio DHCP su **untrusted** → **inspection** + decisione (forward/drop)
    

---

## Attacchi mitigati (focus CCNA)

### 1) DHCP starvation / exhaustion (DoS)

- Flood di **DHCP Discover** usando **MAC spoofate**
    
- Obiettivo: esaurire il pool DHCP → client legittimi non ottengono IP
    

Nota da sottotitoli:

- DHCP usa campo **CHADDR (Client Hardware Address)** per identificare il client (utile quando c’è relay e il source MAC del frame non è quello del client).
    

### 2) DHCP poisoning (MITM via rogue DHCP)

- Un **rogue DHCP server** risponde ai Discover e assegna come **default gateway** l’attaccante
    
- Il client tende ad accettare il **primo OFFER** ricevuto
    
- Risultato: traffico verso reti esterne passa dall’attaccante → **eavesdrop/modify** (MITM)
    

---

## DHCP message types (core per quiz)

### Server messages (drop su untrusted)

- **OFFER**
    
- **ACK**
    
- **NAK**
    

### Client messages (ispezionati su untrusted)

- **DISCOVER**
    
- **REQUEST**
    
- **RELEASE**
    
- **DECLINE**
    

---

## DHCP Snooping: logica di filtro (core CCNA)

### Se arriva su trusted

- **Forward** (mai drop per snooping)
    

### Se arriva su untrusted

1. **Se è server message (OFFER/ACK/NAK)** → **DROP sempre**
    
2. **Se è client message** → controlli:
    

**DISCOVER / REQUEST**

- check: **Ethernet source MAC** == **DHCP CHADDR**
    
    - match → forward
        
    - mismatch → drop  
        (mitiga spoof del CHADDR; aggirabile se l’attaccante spoof anche source MAC)
        

**RELEASE / DECLINE**

- check: **source IP** + **ingress interface** devono combaciare con la **binding table**
    
    - match → forward
        
    - mismatch → drop  
        (impedisce RELEASE/DECLINE “per conto di altri”)
        

---

## DHCP Snooping binding table (cosa contiene)

Contiene (da output/quiz):

- **MAC**
    
- **IP**
    
- **Lease time**
    
- **VLAN**
    
- **Interface**
    

Non contiene:

- **Default gateway** (domanda tipica)
    

Comando:

- `show ip dhcp snooping binding`
    

---

## Rate limiting (funzione d’esame)

**DHCP rate limiting** limita il numero di messaggi DHCP per secondo su una porta.

- Se supera la soglia → porta in **err-disabled**
    
- Recovery:
    
    - manuale: `shutdown` / `no shutdown`
        
    - automatico: `errdisable recovery cause dhcp-rate-limit`
        

Use-case:

- anche se l’attaccante spoof MAC+CHADDR per bypassare check Discover/Request,  
    il flood può far scattare il **rate limit** → difesa contro starvation.
    

---

## Option 82 (DHCP relay agent information option)

- **Option 82** aggiunge info su relay/porta/VLAN ecc.
    
- Con DHCP snooping **di default** gli switch Cisco possono **inserire Option 82** anche se non sono relay.
    
- Problemi tipici:
    
    - switch può **droppare** messaggi con Option 82 ricevuti su untrusted (scenario multi-switch)
        
    - il DHCP server può droppare per **“inconsistent relay information”** (Option 82 presente quando non dovrebbe)
        

Mitigazione (quando necessario nei lab/topologia):

- disabilitare l’inserimento Option 82:
    
    - `no ip dhcp snooping information option`
        

⚠️ Esame: probabilmente non va troppo in profondità, ma in pratica di lab è un “gotcha” reale.

---

## Key rules / exam points (checklist rapida)

- DHCP snooping: **global + per VLAN** + definire **trusted ports**
    
- Su **untrusted**:
    
    - server messages (OFFER/ACK/NAK) → **drop**
        
    - Discover/Request → check **source MAC vs CHADDR**
        
    - Release/Decline → check **binding table** (IP + interface)
        
- Binding table contiene **IP/MAC/VLAN/interface/lease**, **non** default gateway
    
- Rate limit può mandare porta in **err-disabled**
    
- Option 82 può rompere i lab → `no ip dhcp snooping information option`
    

---

## CLI (solo comandi)

`ip dhcp snooping ip dhcp snooping vlan 1 no ip dhcp snooping information option`

`interface g0/0  ip dhcp snooping trust`

`show ip dhcp snooping binding`

`interface g0/1  ip dhcp snooping limit rate 1`

`errdisable recovery cause dhcp-rate-limit show errdisable recovery`

`interface g0/1  shutdown  no shutdown`

---

## Common mistakes / notes

- Abilitare solo `ip dhcp snooping` e dimenticare `ip dhcp snooping vlan X` → non funziona dove serve
    
- Dimenticare di marcare trusted l’uplink verso DHCP server/relay → drop dei server messages
    
- Confondere cosa viene droppato su untrusted: **server messages sempre**, client messages dipende dai check
    
- Rate limit troppo basso → err-disable anche con traffico legittimo
    
- Option 82: topologie multi-switch possono droppare se non gestita