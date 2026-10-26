---
tags: [ccna, exam]
priorita: critico
stato: da-ripassare
---

> [!ABSTRACT] Cosa serve per l'esame
> Blueprint **4.1**: configurare e verificare l'inside source NAT, statico e con pool (incluso il PAT).
> Devi saper distinguere i quattro indirizzi (inside/outside, local/global), scegliere tra static NAT, dynamic NAT e PAT, configurarli e leggere `show ip nat translations`.

## 1. Perché esiste il NAT

Gli indirizzi privati (RFC 1918: `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`, vedi [[Subnetting - Fondamentali e Calcolo Rapido|Subnetting]], sezione 6) si possono usare liberamente nelle reti interne, ma **gli ISP li scartano**: su Internet non possono viaggiare.

Il NAT, sul router di confine, sostituisce l'IP privato sorgente con uno pubblico all'uscita, e fa l'operazione inversa sulla risposta. Così molti host condividono pochi indirizzi pubblici: è il modo con cui IPv4 è sopravvissuto all'esaurimento.

Il CCNA chiede l'**inside source NAT**: cambia l'IP **sorgente** dei pacchetti che vanno dall'interno verso l'esterno.

## 2. I quattro indirizzi

- **Inside / outside** = **dove** sta l'host (nella tua rete o fuori).
- **Local / global** = **da quale lato** guardi l'indirizzo (da dentro o da fuori).

| Termine | Cos'è | Esempio |
| :--- | :--- | :--- |
| Inside local | l'IP vero dell'host interno (privato) | 192.168.1.10 |
| Inside global | l'IP con cui l'host interno appare su Internet | 203.0.113.1 |
| Outside local | l'IP dell'host esterno come lo vedi da dentro | 8.8.8.8 |
| Outside global | l'IP vero dell'host esterno | 8.8.8.8 |

Con il solo inside source NAT l'indirizzo esterno non cambia, quindi **outside local = outside global**.

### Il viaggio di un pacchetto (PAT)

1. Il PC 192.168.1.10 apre una connessione verso 8.8.8.8: sorgente `192.168.1.10:1024`.
2. Il pacchetto entra dall'interfaccia `ip nat inside`, combacia con l'ACL del NAT e, uscendo da quella `outside`, diventa `203.0.113.1:1024`.
3. Il router salva la corrispondenza nella tabella NAT.
4. La risposta arriva a `203.0.113.1:1024`: il router la cerca in tabella e la riconsegna a `192.168.1.10:1024`.

## 3. I tre tipi

| Tipo | Corrispondenza | Quando si usa | Limite |
| :--- | :--- | :--- | :--- |
| **Static NAT** | 1 privato ↔ 1 pubblico, fissa | server che devono essere raggiungibili da Internet | serve un IP pubblico per ogni host |
| **Dynamic NAT** | 1 privato ↔ 1 pubblico, presa da un **pool** e temporanea | pochi host e un gruppo di IP pubblici | se il pool finisce, i nuovi pacchetti vengono **scartati** |
| **PAT** (NAT overload) | molti privati → 1 pubblico, distinti dal **numero di porta** | la LAN che naviga (casa, ufficio) | — è il più usato |

- Il **static NAT** è bidirezionale: da Internet si può aprire una connessione verso l'inside global, e arriva al server interno.
- Nel **dynamic NAT** e nel PAT l'**ACL non filtra, seleziona**: `permit` vuol dire "da tradurre", `deny` vuol dire "non tradurre". Il pacchetto non tradotto non viene scartato: prosegue con l'IP originale.

## 4. Configurazione

### Passo 1: interfacce inside e outside (per tutti i tipi)

```ios
! Lato LAN
R1(config)# interface g0/1
R1(config-if)# ip nat inside

! Lato Internet
R1(config)# interface g0/0
R1(config-if)# ip nat outside
```

### Passo 2a: static NAT

```ios
! ip nat inside source static <inside local> <inside global>
R1(config)# ip nat inside source static 192.168.0.167 100.0.0.1
R1(config)# ip nat inside source static 192.168.0.168 100.0.0.2
```

### Passo 2b: dynamic NAT con pool

```ios
! Chi va tradotto (ACL standard, con la wildcard)
R1(config)# access-list 1 permit 192.168.1.0 0.0.0.255

! Gli IP pubblici disponibili (netmask o prefix-length)
R1(config)# ip nat pool POOL1 100.0.0.1 100.0.0.10 prefix-length 24

! Lega l'ACL al pool
R1(config)# ip nat inside source list 1 pool POOL1
```

### Passo 2c: PAT

```ios
R1(config)# access-list 1 permit 192.168.1.0 0.0.0.255

! Il modo più comune: tutti escono con l'IP dell'interfaccia WAN
R1(config)# ip nat inside source list 1 interface g0/0 overload

! In alternativa: PAT sugli indirizzi di un pool
R1(config)# ip nat inside source list 1 pool POOL1 overload
```

Senza `overload` è dynamic NAT 1:1, non PAT.

## 5. Verifica

```ios
! Tabella delle traduzioni attive
R1# show ip nat translations

! Contatori: hits (traduzioni riuscite), misses, uso del pool, interfacce inside/outside
R1# show ip nat statistics

! Svuota le traduzioni dinamiche (le statiche restano)
R1# clear ip nat translation *
```

```text
Pro  Inside global      Inside local        Outside local    Outside global
tcp  203.0.113.1:1024   192.168.1.10:1024   8.8.8.8:443      8.8.8.8:443
tcp  203.0.113.1:1025   192.168.1.11:1024   8.8.8.8:443      8.8.8.8:443
---  100.0.0.1          192.168.0.167       ---              ---
```

- Le prime due righe sono **PAT**: due host escono con lo stesso IP pubblico. Il secondo usava anch'esso la porta 1024, quindi il router gli ha dato la 1025 per distinguerli.
- La terza è una traduzione **statica**: resta in tabella anche senza traffico, e senza porte.
- Le traduzioni dinamiche compaiono solo quando passa traffico e scadono dopo un timeout.

## ⚠️ Trappole d'esame

> [!WARNING] Gli errori più frequenti
> 1. **Inside local e inside global confusi**: local = privato (vero), global = pubblico (come appare fuori).
> 2. **Inside/outside mancanti o invertiti**: senza `ip nat inside` e `ip nat outside` sulle interfacce giuste non viene tradotto nulla.
> 3. **Manca `overload`**: è dynamic NAT, non PAT, e il pool si esaurisce subito.
> 4. **Pool esaurito**: nel dynamic NAT i nuovi host vengono scartati (si vedono i misses in `show ip nat statistics`).
> 5. **`deny` nell'ACL del NAT**: non blocca il traffico, lo esclude solo dalla traduzione.
> 6. **Maschera nell'ACL**: va la wildcard (`0.0.0.255`).
> 7. **Static NAT per risparmiare indirizzi**: non ne risparmia; per quello c'è il PAT.

## Esercizi

> [!QUESTION]- Nella riga `tcp 203.0.113.1:1025 192.168.1.11:1024 8.8.8.8:443 8.8.8.8:443`, qual è l'inside local? E l'outside global?
> Inside local: `192.168.1.11:1024`, il PC interno. Outside global: `8.8.8.8:443`, il server esterno.

> [!QUESTION]- Un server interno 192.168.1.100 deve essere raggiungibile da Internet come 203.0.113.50. Che NAT usi, e con quale comando?
> Static NAT: `ip nat inside source static 192.168.1.100 203.0.113.50`

> [!QUESTION]- 50 PC, un pool di 10 IP pubblici, NAT dinamico senza `overload`. Cosa succede all'11° PC che prova a uscire?
> Il suo traffico viene scartato finché una traduzione non scade (o non viene cancellata con `clear`).

> [!QUESTION]- ACL del NAT: `access-list 1 deny host 192.168.1.5` · `access-list 1 permit 192.168.1.0 0.0.0.255`. Cosa succede al traffico di 192.168.1.5 verso Internet?
> Non viene tradotto ed esce con l'IP privato, quindi l'ISP lo scarta. L'ACL però non lo blocca: il router lo inoltra comunque.

## Check da esame

- [ ] Cosa significano inside/outside e local/global? **Dove sta l'host; da quale lato si guarda l'indirizzo**.
- [ ] NAT per un server raggiungibile da Internet? **Static NAT**.
- [ ] Parola chiave del PAT? **`overload`**.
- [ ] Cosa distingue gli host nel PAT? **Il numero di porta L4**.
- [ ] Cosa fa un `deny` nell'ACL del NAT? **Esclude dalla traduzione, non blocca**.
- [ ] Comando per vedere le traduzioni? **`show ip nat translations`**.
- [ ] Pool esaurito nel dynamic NAT? **I nuovi pacchetti vengono scartati**.

## 🎯 Synthesis

Il NAT del CCNA cambia l'IP sorgente dei pacchetti che escono: l'inside local (privato) diventa inside global (pubblico). Static = 1:1 fisso, per i server; dynamic = 1:1 da un pool, che si può esaurire; PAT (`overload`) = molti host su un IP, distinti dalla porta. Servono sempre `ip nat inside` e `ip nat outside`.

> [!EXAMPLE] Laboratori pratici
> - [[Day 44 Lab - Static NAT.pkt]]
> - [[Day 45 Lab - Dynamic NAT.pkt]]
