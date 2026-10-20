
## What is it

**IPv6** è il successore di IPv4. Usa indirizzi **128-bit** scritti in **esadecimale**, con **prefix length** in notazione `/x` (niente subnet mask dotted-decimal). Per CCNA: configurare/verificare IPv6 addressing/prefix e confrontare i tipi di indirizzo (in video successivo).

## How it works

### Hexadecimal (ripasso essenziale)

- Sistemi numerici:
    
    - **Binary (base 2)**: prefisso `0b`
        
    - **Decimal (base 10)**: prefisso `0d`
        
    - **Hex (base 16)**: prefisso `0x`
        
- Hex digits: `0–9` + `A B C D E F` (10–15).
    
- **1 hex digit = 4 bit** → utile per conversioni.
    
- Conversione bin↔hex: spezza in gruppi da **4 bit**.
    

### Perché IPv6 

- IPv4 = **32 bit** → ~4.29 miliardi di indirizzi.
    
- Tecniche per “tirare avanti” IPv4: **VLSM**, **private IPv4 + NAT** (short-term).
    
- Motivazione principale: **IPv4 exhaustion** (RIR quasi/esauriti).
    
- IPv6 = **128 bit** → spazio indirizzi enorme (non da memorizzare il numero).
    

### Formato di un IPv6 address

- 128 bit = **32 caratteri hex**.
    
- Scritto come **8 gruppi (quartets) da 4 hex** separati da `:`  
    Esempio struttura: `xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx`
    
- Si usa la notazione **/prefix** (es. `/64`) anche su IOS.
    
    - `/64` tipico: metà **network**, metà **host**.
        

### Abbreviazione IPv6

1. **Rimuovere leading 0s** dentro ogni quartet
    
    - Solo 0 **all’inizio** del quartet (es. `00ab` → `ab`).
        
2. **Sostituire quartets consecutivi “0000” con `::`**
    
    - `::` si può usare **una sola volta** per indirizzo (altrimenti ambiguità).
        
3. Si possono combinare i due metodi.
    

### Espansione (da abbreviato a completo)

- Ogni quartet deve tornare a **4 hex** (aggiungi leading 0s).
    
- `::` va espanso in abbastanza `0000` da arrivare a **8 quartets** totali.
    

### Trovare il prefix (network address) da un host address

- Come IPv4: **host bits → 0**.
    
- Se `/` è multiplo di **4**, è diretto (ogni hex = 4 bit).
    
- Se `/` **non** è multiplo di 4 (es. `/93`):
    
    - devi convertire il nibble (hex digit) in **binario**
        
    - azzerare i bit host dentro quel nibble
        
    - riconvertire in hex (es. `B` → `8` nell’esempio del video)
        

### Struttura “tipica” (esempio del video)

- Enterprise riceve spesso un **/48** dall’ISP (**global routing prefix**).
    
- Tipico subnetting: **/64**
    
    - 16 bit per **subnet identifier** (tra /48 e /64)
        
    - 64 bit per **host**
        

### 2001:db8::/32

- Range riservato per **documentazione/esempi** (usabile nei lab, non in reti reali).
    

## CLI Core

`ipv6 unicast-routing`

`interface g0/0  ipv6 address 2001:db8:0:0::/64  no shutdown`

`interface g0/1  ipv6 address 2001:db8:0:1::/64  no shutdown`

`interface g0/2  ipv6 address 2001:db8:0:2::/64  no shutdown`

`show ipv6 interface brief`

`ipv6 route 2001:db8:2::/64 2001:db8:1::2`


## Common Mistakes

- Usare caratteri non hex negli indirizzi IPv6 (es. **G** → invalido).
    
- Scrivere **9 quartets** (IPv6 deve avere **8**).
    
- Usare `::` **due volte** nello stesso indirizzo.
    
- Rimuovere 0 che **non** sono leading 0s (cambia il network prefix).
    
- Dimenticare `ipv6 unicast-routing`: il router **non inoltra** pacchetti IPv6.
    
- In prefix non-multiplo di 4: non convertire in binario → errore sul nibble (es. `B` che deve diventare `8`).
    

## Synthesis

IPv6 usa indirizzi 128-bit in hex con prefix `/x`; puoi abbreviare con leading-0 removal e un solo `::`, e per trovare il network prefix azzeri gli host bits (con binario se il prefix non è multiplo di 4).