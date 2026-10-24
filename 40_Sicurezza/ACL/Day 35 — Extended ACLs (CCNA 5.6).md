
### What is it

Le **Extended ACL** sono liste di regole (ACE) che **permettono o negano** traffico in base a criteri più specifici delle Standard ACL.

- **Standard ACL**: match **solo Source IP**
    
- **Extended ACL**: match su:
    
    - **Protocollo L4/L3** (IP/TCP/UDP/ICMP, ecc.)
        
    - **Source IP**
        
    - **Destination IP**
        
    - (opzionale) **Source/Destination port** (solo se protocollo TCP/UDP)

## How it works (logica)

- Una ACL è composta da **ACE** (Access Control Entries).
    
- Il router valuta le **ACE dall’alto verso il basso**.
    
- **Primo match vince**: appena una ACE combacia → applica l’azione (permit/deny) e **stop**.
    
- **Implicit deny** finale: se nulla matcha → **deny**.
    
- Applicazione su interfaccia:
    
    - **in** = filtra i pacchetti **in ingresso** sull’interfaccia
        
    - **out** = filtra i pacchetti **in uscita** dall’interfaccia
        
- Max: **1 ACL per direzione per interfaccia** (una inbound + una outbound).
    

📌 Regola pratica (importante):

- **Standard ACL** → vicino alla **destinazione**
    
- **Extended ACL** → vicino alla **sorgente** (per bloccare presto traffico “spazzatura”)

## Numbered vs Named + “named mode” per numbered (IOS moderno)

Puoi configurare una ACL **numerata** anche in modalità “named config mode”:

- Vantaggi:
    
    1. puoi cancellare **una singola ACE**: `no <seq>`
        
    2. puoi **inserire** ACE in mezzo: scegliendo il **sequence number**
        
- Se configuri una numbered in named-mode, nel `running-config` potrebbe apparire comunque in formato “classico”.

## Resequencing (riordinare i numeri)

Serve quando i sequence number sono “stretti” (1,2,3,4…) e non puoi inserire nuove ACE.

**Sintassi**

`ip access-list resequence <ACL-ID> <start> <increment>`

**Esempio**

`ip access-list resequence 1 10 10`

Risultato: prima ACE = 10, poi 20, 30, 40…

# Extended ACL: range numeri (CCNA)

- **Extended numbered**: `100–199` e `2000–2699`
    
- (ripasso) **Standard numbered**: `1–99` e `1300–1999`

## CLI Core (configurazione estesa)

### 1) Entrare in config mode (consigliato: named-mode)

`ip access-list extended <NAME-or-NUMBER>`

### 2) ACE: struttura mentale

**Protocollo → Source → (src port?) → Destination → (dst port?) → (opzioni extra)**

Esempio base (senza porte):

```
deny tcp any 10.0.0.0 0.0.0.255
permit ip any any
```

### 3) Host / wildcard

In extended ACL, per un /32 è meglio usare:

- `host <ip>` oppure `0.0.0.0`
    

Esempio:

`deny udp 10.0.0.0 0.0.255.255 host 192.168.1.1`

## Standard vs Extended Named ACL

|Aspetto|Standard Named ACL|Extended Named ACL|
|---|---|---|
|Modalità di ingresso|`ip access-list standard <NAME>`|`ip access-list extended <NAME>`|
|Cosa può filtrare|**Solo IP sorgente**|**Protocollo + IP sorgente + IP destinazione + porte**|
|Protocollo specificabile|❌ No|✅ Sì (`ip`, `tcp`, `udp`, `icmp`, ecc.)|
|Porta TCP/UDP|❌ No|✅ Sì (`eq`, `gt`, `lt`, `range`)|
|Forma base ACE|`permit|deny `|
|Uso di `host`|✅ Sì|✅ **Obbligatorio per /32**|
|Uso di `any`|✅ Sì|✅ Sì|
|Sequence number|✅ Sì|✅ Sì|
|Editing (no )|✅ Sì|✅ Sì|
|Complessità|**Bassa**|**Media**|
|Regola di posizionamento|Vicino alla **destination**|Vicino alla **source**|

---

| Standard Named ACL                        | Extended Named ACL                                 |
| --------------------------------------------- | ------------------------------------------------------ |
| `ip access-list standard ACL_STD`             | `ip access-list extended ACL_EXT`                      |
| `10 permit 192.168.1.0 0.0.0.255`             | `10 permit ip 192.168.1.0 0.0.0.255 any`               |
| `20 deny host 192.168.1.100`                  | `20 deny tcp host 192.168.1.100 host 10.0.0.10 eq 443` |
| `30 permit any`                               | `30 permit ip any any`                                 |
| `no 20`                                       | `no 20`                                                |
| `15 deny 192.168.2.0 0.0.0.255`               | `15 deny udp 192.168.2.0 0.0.0.255 any eq 53`          |
| _(nessun protocollo)_                         | `tcp                                                   |
| _(nessuna porta)_                             | `eq                                                    |
| `interface g0/1` `ip access-group ACL_STD in` | `interface g0/1` `ip access-group ACL_EXT in`          |

## Matching porte TCP/UDP

Disponibile **solo** se scegli `tcp` o `udp`.

Operatori CCNA:

- `eq` uguale
    
- `gt` maggiore di
    
- `lt` minore di
    
- `neq` diverso da
    
- `range <a> <b>`
    

Esempio: blocca HTTP verso 1.1.1.1

`deny tcp any host 1.1.1.1 eq 80 permit ip any any`

✅ Nota operativa: un pacchetto deve matchare **tutti** i criteri della ACE (protocollo + src/dst + porte se presenti).

## Apply to interface (come si “attiva”)

Da interface config:

`ip access-group <ACL-ID> in ip access-group <ACL-ID> out`

## Show / Verify

Verifica ACL e contenuto:

`show access-lists show ip access-lists show running-config | section access-list`

Verifica quale ACL è applicata a una interfaccia:

`show ip interface g0/0`

## Esempi “CCNA-style” (quelli del video)

### Permit “tutto”

`permit ip any any`

### Blocca UDP da 10.0.0.0/16 verso host 192.168.1.1

`deny udp 10.0.0.0 0.0.255.255 host 192.168.1.1`

### Blocca ping (ICMP) da host 172.16.1.1 verso 192.168.0.0/24

`deny icmp host 172.16.1.1 192.168.0.0 0.0.0.255`

### Permetti HTTPS da 10.0.0.0/16 verso server 2.2.2.2

`permit tcp 10.0.0.0 0.0.255.255 host 2.2.2.2 eq 443`

## Pitfalls (errori tipici)

- Dimenticare `permit ip any any` → per implicit deny blocchi tutto il resto.
    
- Applicare in direzione sbagliata (in/out) → “non funziona” ma la config è corretta.
    
- Confondere **source port** vs **destination port** (classico su TFTP/HTTP/HTTPS).
    
- Usare ACL numerata “classic” e provare a cancellare una singola riga → cancelli **tutta** l’ACL.
    
- Sequenze tipo 1,2,3 → impossibile inserire regole in mezzo → serve `resequencing`.

## Mini-quiz (ripasso attivo)

1. Extended ACL viene applicata “vicino a” ________ (sorgente/destinazione)?
    
2. Se un pacchetto non matcha nessuna ACE, cosa succede?
    
3. Range numeri extended ACL?
    
4. `deny tcp any host 1.1.1.1 eq 80` sta matchando la porta source o destination?
    
5. Per cancellare solo la ACE 30 in named-mode, che comando usi?