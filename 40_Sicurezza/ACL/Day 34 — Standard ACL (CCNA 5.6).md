
### What is it

- **ACL (Access Control List)** = lista ordinata di regole (ACE: Access Control Entries) che dice al router se **permettere** o **negare** traffico.
    
- Scopo principale qui: **sicurezza** (controllare chi può accedere a cosa).  
    Nota: ACL possono avere anche altri usi (verranno dopo).

### Why / When

- Il router **di default** inoltra un pacchetto se ha una route verso la destinazione.
    
- Con un’ACL puoi forzare eccezioni: _anche se la route esiste_, il pacchetto può essere **droppato**.

## How it works (logica ACL) ⚙️

### 1) Due fasi sempre

1. **Crei l’ACL** in **global config** (non fa nulla da sola).
    
2. **Applichi l’ACL** a una interfaccia in direzione **in** o **out**.
    

### 2) Inbound vs Outbound (cosa significa)

- **in**: controlla pacchetti **che entrano** nell’interfaccia.
    
- **out**: controlla pacchetti **che escono** dall’interfaccia.
    

### 3) Processing: ordine e “stop”

- Il router valuta le ACE **dall’alto verso il basso**.
    
- **Prima match vince**: appena un pacchetto matcha una ACE, il router applica l’azione (**permit/deny**) e **smette** di controllare le righe sotto.
    

### 4) Implicit deny (il punto che frega tutti)

- In fondo a **qualsiasi ACL** esiste sempre un:
    
    - `deny any` **invisibile**
        
- Se un pacchetto **non matcha** nessuna riga → viene droppato.
    

### 5) Vincolo: quante ACL per interfaccia

- Max **1 ACL inbound** + **1 ACL outbound** per interfaccia (massimo 2).
    
- Se applichi un’altra ACL **stessa direzione**, **rimpiazza** la precedente.

## ACL types (solo ciò che serve qui)

- **Standard ACL**
    
    - match: **Source IP only**
        
    - varianti: **numbered** e **named**
        
- **Extended ACL** (Day 35)
    
    - match: Source/Destination IP, porte L4, ecc.

# Standard Numbered ACL ✅

### Ranges (da ricordare)

- Standard ACL numbers:
    
    - **1–99**
        
    - **1300–1999**
        
- (Quindi **100** NON è Standard.)
    

### Syntax (una ACE)

`access-list <N> {permit|deny} <source-ip> <wildcard>`

### Host / Any shortcut

- Host singolo (equivalenti):
    

```
access-list 1 deny 1.1.1.1 0.0.0.0
access-list 1 deny 1.1.1.1
access-list 1 deny host 1.1.1.1
```


- Tutti (equivalenti):
    

```
access-list 1 permit any
access-list 1 permit 0.0.0.0 255.255.255.255
```


### Remark (solo commento)

`access-list 1 remark <testo>`

# Standard Named ACL ✅

### Entry mode + sequence numbers

- Entri in modalità ACL:
    

`ip access-list standard <NAME>`

- Poi inserisci le ACE (con o senza sequence number):
    

```
<seq> {permit|deny} <source-ip> <wildcard>
remark <testo>
```


- Se non specifichi il numero, IOS usa 10, 20, 30…
    

📌 Nota dai sub: IOS **può riordinare internamente** alcune entry **/32 (host)** per efficienza; in Packet Tracer può non vedersi. Effetto logico invariato.

## Apply to interface (abilita davvero l’ACL)

> Comando in **interface config**, è **access-group**, non access-list.

```
interface g0/2
ip access-group 1 out
```


Oppure, per named:

```
interface g0/1
ip access-group BLOCK_BOB in
```

## Placement rule-of-thumb (solo standard ACL)

- Standard ACL (source-only) → applicale **più vicino possibile alla DESTINAZIONE**  
    (così eviti di bloccare traffico “di passaggio” non correlato).

## Show / Verify 🔎

```
show access-lists
show ip access-lists
show running-config | include access-list
show running-config | section access-list

```

## Common mistakes / traps ⚠️

- Dimenticare `permit any` quando non vuoi bloccare tutto (implicit deny).
    
- Mettere `permit any` in alto → rende inutili i deny sotto.
    
- Applicare l’ACL sull’interfaccia/direzione sbagliata (in/out).
    
- Provare a mettere 2 ACL inbound sulla stessa interfaccia → la seconda **sovrascrive**.
    
- Usare subnet mask invece di **wildcard mask**.
    

---

|Operazione|Standard Numbered ACL|Standard Named ACL|
|---|---|---|
|Entrare in modalità ACL||`ip access-list standard ACL_STD`|
|Aggiungere regola permit|`access-list 1 permit 192.168.1.0 0.0.0.255`|`10 permit 192.168.1.0 0.0.0.255`|
|Aggiungere regola deny|`access-list 1 deny any`|`20 deny any`|
|Inserire regola in posizione specifica||`15 deny host 192.168.1.50`|
|Visualizzare regole con ordine|`show access-lists`|`do show access-lists ACL_STD`|
|Rimuovere una singola regola||`no 10`|
|Rimuovere l’intera ACL|`no access-list 1`|`no ip access-list standard ACL_STD`|
|Applicare ACL a interfaccia|`ip access-group 1 in`|`ip access-group ACL_STD in`|

## Synthesis (da ripasso veloce)

- ACL = lista ordinata di ACE, valutata **top→bottom**, **first match wins**.
    
- Sempre presente **implicit deny**.
    
- Crei in global config, poi **applichi** su interfaccia **in/out** con `ip access-group`.
    
- Standard ACL: **solo source IP**.
    
- Numero Standard: **1–99, 1300–1999**.
    
- Standard ACL: piazzala **vicino alla destinazione**.