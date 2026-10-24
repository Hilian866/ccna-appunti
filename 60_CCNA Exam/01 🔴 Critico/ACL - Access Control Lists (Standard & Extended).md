---
tags: [ccna, exam, acl]
priorita: critico
dominio: Security Fundamentals
stato: da-ripassare
---

## Obiettivo

Agire come un firewall _stateless_ di Layer 3/4, filtrando il traffico in base a regole sequenziali per garantire sicurezza e ottimizzazione delle risorse di rete.

## Logica di Processamento

Il router non legge l'intera lista; si ferma al primo "Sì".

- **Top-to-Bottom**: L'ordine delle righe (ACE - Access Control Entries) è fondamentale.
- **First Match Wins**: Trovata una corrispondenza, le righe successive vengono ignorate.
- **Implicit Deny Any**: Alla fine di ogni ACL esiste un `deny ip any any` invisibile. Se un pacchetto non fa match con nulla, viene scartato.

## 1. Tipologie e Range

|Tipo|Criteri di Match (Filtro)|Range Standard|Range Extended|
|---|---|---|---|
|Standard|**Solo IP Sorgente**|1–99, 1300–1999|—|
|Extended|Sorgente, Destinazione, Protocollo, Porte L4|—|100–199, 2000–2699|

## 2. Regole d'Oro per il Posizionamento

Il posizionamento corretto evita sprechi di banda e di cicli CPU.

> [!TIP] Strategia di Deployment
>
> - **Standard ACL**: **Più vicino possibile alla DESTINAZIONE.**
>     - _Logica:_ Non conoscendo la destinazione, se la metti all'origine rischi di bloccare l'accesso a tutta la rete (over-blocking).
> - **Extended ACL**: **Più vicino possibile alla SORGENTE.**
>     - _Logica:_ Scarta il traffico indesiderato prima che attraversi l'intera infrastruttura (bandwidth saving).
>

## 3. Wildcard Mask (L'inverso della Subnet)

Utilizzata per identificare un range di indirizzi o un singolo host.

> [!INFO] Calcolo Rapido
>
> Sottrai la Subnet Mask da `255.255.255.255`.
>
> - `/24 (255.255.255.0)` $\rightarrow$ Wildcard: **0.0.0.255**
> - `/32 (Host singolo)` $\rightarrow$ Wildcard: **0.0.0.0** (Keyword: `host`)
> - `Any (Tutto)` $\rightarrow$ Wildcard: **255.255.255.255** (Keyword: `any`)
>

## 4. CLI Core: Named ACL

La modalità "Named" è la best practice perché permette l'editing granulare tramite **Sequence Numbers**.

```
ip access-list extended PROTECT_SERVER
 remark -- Permette solo HTTPS al Server Web --
 10 permit tcp any host 10.1.1.100 eq 443
 20 permit icmp any host 10.1.1.100 echo-reply

 ! Logga i tentativi di attacco
 30 deny ip any host 10.1.1.100 log

 ! Permette il resto
 40 permit ip any any
```

### ACL numerata (sintassi classica)
```
! standard (solo sorgente)
access-list 10 permit 192.168.1.0 0.0.0.255

! extended
access-list 110 permit tcp 192.168.1.0 0.0.0.255 any eq 80

! solo risposte TCP (ACK/RST)
access-list 110 permit tcp any any established
access-list 110 deny ip any any log
```
- Standard **numerata**: non si modifica una riga singola (si cancella e si ricrea); usa i **named** con sequence number.
- Operatori porta: `eq`, `neq`, `lt`, `gt`, `range 20 21`.

### ACL sulle linee VTY (limita chi può fare SSH)
```
access-list 5 permit 10.0.0.0 0.0.0.255
line vty 0 15
 access-class 5 in            ! non "ip access-group"
```

### Verifica e Applicazione

```
interface g0/0
 ! Applica la lista in ingresso
 ip access-group PROTECT_SERVER in

! Verifica i "counters" (quanti match)
show access-lists

! Verifica la direzione (Inbound/Outbound)
show ip interface g0/0
```

## ⚠️ 5. Common Mistakes (Anatomy Check)

> [!CAUTION] Errori Fatali nei Lab
>
> - **Inbound vs Outbound:** Se applichi l'ACL nella direzione sbagliata, il traffico passerà indisturbato.
> - **L'ordine delle righe:** Se metti `permit ip any any` alla riga 10, tutte le righe successive (come i `deny`) saranno inutili. **Specifica sempre prima l'HOST, poi la NETWORK.**
> - **1 ACL per interfaccia / direzione / protocollo.** Il traffico *generato dal router* non è filtrato da un'ACL outbound.
> - **ACL Vuota:** Se applichi un'interfaccia a una ACL che non esiste o è vuota, il traffico passa tutto (nessun filtro).
>

## 🎯 Synthesis
La prima riga che combacia decide (poi implicit deny): standard vicino alla destinazione, extended vicino alla sorgente.

---

> [!EXAMPLE] Laboratori Pratici
> - [[Day 34 Lab - Standard ACLs.pkt]]
> - [[Day 35 Lab - Extended ACLs.pkt]]
