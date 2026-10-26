---
tags: [ccna, exam]
priorita: medio
stato: da-ripassare
---

> [!ABSTRACT] Cosa serve per l'esame
> Blueprint **1.8** (configurare e verificare indirizzi e prefisso), **1.9** (tipi di indirizzo: unicast global / unique local / link-local, anycast, multicast, modified EUI-64) e **3.3** (rotte statiche IPv6: default, network, host, floating).
> In pratica devi saper: abbreviare ed espandere un indirizzo, ricavare il prefisso di rete, riconoscere il tipo di indirizzo dalle prime cifre, calcolare un EUI-64, sapere cosa sostituisce ARP e broadcast, e scrivere le rotte statiche.
> Video: [modulo 1](https://youtu.be/ZNuXyOXae5U?list=PLxbwE86jKRgMpuZuLBivzlM8s2Dk5lXBQ) · [modulo 2](https://youtu.be/BrTMMOXFhDU?list=PLxbwE86jKRgMpuZuLBivzlM8s2Dk5lXBQ) · [modulo 3](https://youtu.be/rwkHfsWQwy8?list=PLxbwE86jKRgMpuZuLBivzlM8s2Dk5lXBQ)

## 1. Formato dell'indirizzo

IPv4 ha 32 bit (circa 4,3 miliardi di indirizzi, esauriti); IPv6 ne ha **128**. Si scrivono in esadecimale, dove **1 cifra hex = 4 bit**:

- 128 bit = 32 cifre hex = **8 gruppi da 4 cifre** (16 bit ciascuno), separati da `:`.
- Niente subnet mask: si usa solo la notazione `/prefisso`, anche su IOS.
- Cifre valide: `0-9` e `a-f`. Una `g` rende l'indirizzo invalido.
- `2001:db8::/32` è riservato alla documentazione: lo trovi in tutti gli esempi e nei lab.

### Abbreviare

Due regole, combinabili:

1. In ogni gruppo togli gli **zeri iniziali** (mai quelli finali): `0db8` → `db8`, `0800` → `800`, ma `ab00` resta `ab00`.
2. Una sequenza di gruppi tutti a zero diventa `::`, **una sola volta** per indirizzo.

```text
2001:0db8:0000:0000:0008:0800:200c:417a
2001:db8:0:0:8:800:200c:417a
2001:db8::8:800:200c:417a
```

Se ci sono due sequenze di zeri, `::` va su una sola delle due: `2001:0:0:1:0:0:0:1` diventa `2001:0:0:1::1` oppure `2001::1:0:0:0:1`. Sono valide entrambe; la forma canonica lo mette sulla sequenza più lunga.

### Espandere

Riporta ogni gruppo a 4 cifre, poi sostituisci `::` con tanti `0000` quanti mancano per arrivare a **8 gruppi**.

```text
2001:db8:a::12
gruppi presenti: 2001, db8, a, 12 = 4  →  :: vale 4 gruppi
2001:0db8:000a:0000:0000:0000:0000:0012
```

## 2. Prefisso e subnetting

### Struttura tipica di un indirizzo global unicast

| Parte | Bit | Chi la decide |
| :--- | :--- | :--- |
| Global routing prefix | /48 | assegnato dall'ISP all'azienda |
| Subnet ID | 16 (da /48 a /64) | l'azienda, per creare le sue subnet |
| Interface ID | 64 | l'host (manuale, EUI-64 o casuale) |

Le subnet sono quasi sempre **/64**. Da un /48 ottieni 2^16 = **65.536 subnet /64**; in generale le /64 disponibili sono 2^(64 − prefisso).

### Ricavare il prefisso di rete da un indirizzo

Come in IPv4: i bit host vanno a zero.

- **Prefisso multiplo di 4** (/48, /56, /64): ogni cifra hex è 4 bit, quindi tieni le prime prefisso/4 cifre e azzera il resto.
  `2001:db8:abcd:12:3456:789a:bcde:f012/64` → 16 cifre su 32 → `2001:db8:abcd:12::/64`
- **Prefisso non multiplo di 4**: converti in binario solo la cifra hex "a cavallo", azzera i suoi bit host, riconvertila.
  `2001:db8:0:1b::1/62` → 62 = 48 + 14, quindi nel 4° gruppo (`001b`) tieni 14 bit: le prime tre cifre intere e 2 bit della cifra `b`. `b` = `1011` → tieni `10`, azzera il resto → `1000` = `8`. Risultato: `2001:db8:0:18::/62`.

## 3. Tipi di indirizzo

Il tipo si riconosce dalle **prime cifre**:

| Tipo | Prefisso | Come lo riconosci | A cosa serve |
| :--- | :--- | :--- | :--- |
| Global unicast | `2000::/3` | inizia con `2` o `3` | pubblico, instradabile su Internet |
| Unique local | `fc00::/7` | in pratica inizia con `fd` | privato: instradabile solo dentro l'azienda |
| Link-local | `fe80::/10` | inizia con `fe80` | valido solo sul link, mai instradato |
| Multicast | `ff00::/8` | inizia con `ff` | uno a molti: sostituisce il broadcast |
| Anycast | nessuno proprio | è un unicast marcato `anycast` | uno al più vicino tra molti |
| Unspecified | `::` | tutti zeri | "non ho ancora un indirizzo" |
| Loopback | `::1` | — | come `127.0.0.1` |

IPv6 **non ha broadcast**. Se una risposta d'esame parla di broadcast in IPv6, è sbagliata: si usa il multicast `ff02::1`.

### Unicast

- **Global unicast**: struttura /48 + subnet ID + interface ID (vedi sopra). Va assegnato o registrato.
- **Unique local** (l'equivalente dei privati IPv4): il range è `fc00::/7`, ma l'8° bit dev'essere 1, quindi in pratica gli indirizzi iniziano con `fd`. Dopo `fd` c'è un **Global ID** di 40 bit, da generare **a caso**, così due aziende che si fondono non hanno indirizzi sovrapposti. Gli ISP lo scartano, ma tra le tue subnet si instrada normalmente.
- **Link-local**: si genera **da solo** su ogni interfaccia con IPv6 attivo (su Cisco con EUI-64). Ogni interfaccia ha quindi almeno due indirizzi: link-local e global. Si usa per:
  - il next-hop delle rotte (anche quelle di OSPFv3);
  - le adiacenze OSPFv3;
  - NDP.

### Multicast

Indirizzi da sapere: l'ultima cifra coincide con quella del multicast IPv4.

| Gruppo | IPv6 | IPv4 |
| :--- | :--- | :--- |
| Tutti i nodi (all nodes) | `ff02::1` | `224.0.0.1` |
| Tutti i router (all routers) | `ff02::2` | `224.0.0.2` |
| Router OSPF | `ff02::5` | `224.0.0.5` |
| DR/BDR OSPF | `ff02::6` | `224.0.0.6` |
| Router RIP | `ff02::9` | `224.0.0.9` |
| Router EIGRP | `ff02::a` | `224.0.0.10` |

La **quarta cifra** indica fin dove arriva il pacchetto (scope):

| Scope | Prefisso | Fin dove arriva |
| :--- | :--- | :--- |
| Interface-local | `ff01` | non esce dal dispositivo |
| Link-local | `ff02` | resta nella subnet, non viene instradato |
| Site-local | `ff05` | il sito |
| Organization-local | `ff08` | l'organizzazione |
| Global | `ff0e` | tutta Internet |

Non confondere l'indirizzo link-local `fe80::/10` (unicast) con lo scope multicast link-local `ff02`.

### Anycast

Più router configurano lo **stesso** indirizzo unicast con la parola chiave `anycast`; il routing consegna il pacchetto al più vicino (metrica più bassa). Non ha un range dedicato.

## 4. Modified EUI-64

Genera l'interface ID a 64 bit partendo dal MAC a 48 bit. Non è un tipo di indirizzo: è un **metodo** per creare la parte host.

1. Dividi il MAC a metà.
2. Inserisci `fffe` al centro.
3. Inverti il **7° bit** (bit U/L) del primo byte.

```text
MAC              0012.3456.789a
1-2. fffe        0012:34ff:fe56:789a
3. 7° bit        00 = 0000 0000  →  0000 0010 = 02
Interface ID     0212:34ff:fe56:789a
Con 2001:db8:1::/64  →  2001:db8:1:0:212:34ff:fe56:789a
Link-local       →  fe80::212:34ff:fe56:789a
```

> [!TIP] Il 7° bit senza passare dal binario
> Il 7° bit vale 2 nella **seconda cifra hex** del MAC: quella cifra cambia di 2.
> `0↔2` · `1↔3` · `4↔6` · `5↔7` · `8↔a` · `9↔b` · `c↔e` · `d↔f`

## 5. NDP: cosa sostituisce ARP

**NDP** (Neighbor Discovery Protocol) usa messaggi ICMPv6 e fa tre cose: risolve IPv6 → MAC (come ARP), scopre i router sul link e controlla che un indirizzo non sia già in uso (**DAD**, Duplicate Address Detection).

| Messaggio | Tipo ICMPv6 | A cosa serve | Destinazione |
| :--- | :--- | :--- | :--- |
| NS (Neighbor Solicitation) | 135 | "qual è il tuo MAC?" | solicited-node multicast del destinatario |
| NA (Neighbor Advertisement) | 136 | "ecco il mio MAC" | unicast a chi ha chiesto |
| RS (Router Solicitation) | 133 | "ci sono router?" | `ff02::2` (all routers) |
| RA (Router Advertisement) | 134 | "sono un router, ecco il prefisso" | `ff02::1` (all nodes) |

Il punto chiave: **NDP usa il solicited-node multicast per fare ciò che ARP faceva con il broadcast**. Ascolta solo il nodo interessato, non tutto il link.

- **Solicited-node multicast** = `ff02::1:ff` + le **ultime 6 cifre hex** dell'indirizzo unicast.
  `2001:db8::1234:5678` → `ff02::1:ff34:5678`
- **DAD**: prima di usare un indirizzo, l'host manda un NS al proprio solicited-node. Se nessuno risponde con un NA, l'indirizzo è libero.
- La tabella ARP diventa la neighbor table: `show ipv6 neighbor`.

## 6. SLAAC: indirizzo automatico senza DHCP

**SLAAC** (Stateless Address Auto-Configuration):

1. L'host manda un **RS** a `ff02::2`.
2. Il router risponde con un **RA** che contiene il prefisso (es. `2001:db8:1::/64`).
3. L'host crea da solo l'interface ID (con EUI-64 o casuale, dipende dal sistema operativo) e verifica che sia unico con il DAD.

Come default gateway l'host usa l'indirizzo **link-local** del router che ha mandato l'RA. Su un router Cisco, un'interfaccia diventa client SLAAC con `ipv6 address autoconfig`.

## 7. Header IPv6 (approfondimento)

Header di lunghezza **fissa, 40 byte**: più semplice di quello IPv4, e senza checksum (se ne occupano gli altri livelli). Corrispondenze utili:

| Campo IPv6 | Equivalente IPv4 |
| :--- | :--- |
| Traffic Class | ToS / DSCP |
| Payload Length | Total Length (ma conta solo il payload) |
| Next Header | Protocol |
| Hop Limit | TTL |
| Flow Label | nessuno (nuovo: identifica un flusso di traffico) |

## 8. Configurazione e verifica

```ios
! Senza questo il router parla IPv6 ma NON inoltra tra subnet
R1(config)# ipv6 unicast-routing

R1(config)# interface g0/0

! Indirizzo statico completo
R1(config-if)# ipv6 address 2001:db8:1::1/64

! Solo il prefisso: l'interface ID lo genera EUI-64
R1(config-if)# ipv6 address 2001:db8:2::/64 eui-64

! Solo il link-local, nessun indirizzo global
R1(config-if)# ipv6 enable

! Indirizzo preso via SLAAC (router come client)
R1(config-if)# ipv6 address autoconfig

! Stesso indirizzo condiviso con altri router
R1(config-if)# ipv6 address 2001:db8:1::99/128 anycast
```

```ios
! Per ogni interfaccia: stato, link-local (FE80::...) e global
R1# show ipv6 interface brief

! Dettaglio: indirizzi e gruppi multicast a cui l'interfaccia è iscritta
! (ff02::1, ff02::2 sui router, solicited-node ff02::1:ff...)
R1# show ipv6 interface g0/0

! La "tabella ARP" di IPv6
R1# show ipv6 neighbor
```

La verifica degli indirizzi sui client (Windows, macOS, Linux) è in [[Verifica IP Client & Troubleshooting (ping, traceroute)]].

## 9. Rotte statiche IPv6 (blueprint 3.3)

Stessa logica di IPv4 (vedi [[Static Routing & Floating Routes]]), ma con una tabella separata. Tieni distinte due domande:

**Cosa raggiungo** (il tipo di rotta, ed è ciò che chiede il blueprint):

| Tipo | Destinazione | Esempio |
| :--- | :--- | :--- |
| Network route | una subnet | `2001:db8:0:3::/64` |
| Host route | un solo host | `2001:db8:0:1::10/128` |
| Default route | tutto il resto | `::/0` |
| Floating static | una rotta di backup | come sopra, con AD più alta |

**Come la scrivo** (la forma):

| Forma | Cosa specifichi | Nota |
| :--- | :--- | :--- |
| Directly attached | solo l'interfaccia | ⚠️ non funziona su Ethernet in IPv6 |
| Recursive | solo il next-hop | la più comune |
| Fully specified | interfaccia + next-hop | **obbligatoria** se il next-hop è link-local |

```ios
! Network route (recursive)
R1(config)# ipv6 route 2001:db8:0:3::/64 2001:db8:0:12::2

! Host route
R1(config)# ipv6 route 2001:db8:0:1::10/128 2001:db8:0:12::1

! Default route
R1(config)# ipv6 route ::/0 2001:db8:0:23::2

! Floating static: AD 200, entra solo se la rotta principale sparisce
R1(config)# ipv6 route 2001:db8:0:3::/64 2001:db8:0:13::3 200

! Next-hop link-local: il router non sa su quale interfaccia sta, va indicata
R1(config)# ipv6 route 2001:db8:0:3::/64 g0/0 fe80::2
```

```ios
! Codici: S statica, C connessa, L indirizzo locale dell'interfaccia (/128)
R1# show ipv6 route
```

La statica ha AD 1. Una floating deve avere un'AD **più alta** della rotta che protegge: per fare da backup a OSPF (AD 110) serve per esempio 200.

## ⚠️ Trappole d'esame

> [!WARNING] Gli errori più frequenti
> 1. **Zeri finali**: si tolgono solo gli zeri iniziali di un gruppo. `ab00` non diventa `ab`.
> 2. **`::` due volte**: l'indirizzo è invalido, perché non si sa quanti zeri vale ciascun `::`.
> 3. **9 gruppi o cifre non hex**: un indirizzo valido ha esattamente 8 gruppi di cifre `0-9a-f`.
> 4. **Broadcast**: in IPv6 non esiste; "tutti gli host" è `ff02::1`.
> 5. **`ipv6 unicast-routing` dimenticato**: le interfacce funzionano, ma il router non inoltra.
> 6. **Next-hop link-local senza interfaccia**: la rotta non funziona; serve la forma fully specified.
> 7. **Rotta solo con l'interfaccia su Ethernet**: in IPv6 non funziona.
> 8. **Unique local "non instradabile"**: lo è, ma solo dentro l'azienda; è Internet che lo scarta.
> 9. **EUI-64 come tipo di indirizzo**: è un metodo per generare l'interface ID.
> 10. **Scope multicast**: `ff01` resta nel dispositivo; per la subnet serve `ff02`.

## Esercizi

> [!QUESTION]- Espandi `2001:db8:0:a::1`
> Gruppi presenti: 2001, db8, 0, a, 1 = 5, quindi `::` vale 3 gruppi.
> `2001:0db8:0000:000a:0000:0000:0000:0001`

> [!QUESTION]- Abbrevia `2001:0db8:0000:0000:ab00:0000:0000:0001`
> `2001:db8::ab00:0:0:1` oppure `2001:db8:0:0:ab00::1`. `ab00` resta così: i suoi zeri sono finali.

> [!QUESTION]- Prefisso di rete di `2001:db8:5:6a7c::9/58`
> 58 = 48 + 10: nel 4° gruppo (`6a7c`) tieni le cifre `6` e `a` (8 bit) e 2 bit della cifra `7`.
> `7` = `0111` → tieni `01`, azzera il resto → `0100` = `4`. Le cifre dopo vanno a zero.
> `2001:db8:5:6a40::/58`

> [!QUESTION]- Interface ID EUI-64 del MAC `6a00.1234.abcd`
> Inserisci `fffe`: `6a00:12ff:fe34:abcd`. La seconda cifra `a` diventa `8` (7° bit invertito).
> `6800:12ff:fe34:abcd`

> [!QUESTION]- Solicited-node multicast di `fe80::212:34ff:fe56:789a`
> Ultime 6 cifre hex: `56:789a` → `ff02::1:ff56:789a`

> [!QUESTION]- Quante subnet /64 si ottengono da un /56?
> 2^(64 − 56) = 2^8 = **256**.

## Check da esame

- [ ] Quanti bit ha un indirizzo IPv6, e quanti gruppi? **128 bit, 8 gruppi da 16 bit**.
- [ ] Quante volte si può usare `::`? **Una sola**.
- [ ] Come riconosci un global unicast? **Inizia con 2 o 3 (`2000::/3`)**.
- [ ] Range unique local, e come inizia in pratica? **`fc00::/7`, inizia con `fd`**.
- [ ] Range link-local? **`fe80::/10`**.
- [ ] Indirizzo di tutti i nodi e di tutti i router? **`ff02::1` e `ff02::2`**.
- [ ] Cosa sostituisce ARP? **NDP: NS/NA verso il solicited-node multicast**.
- [ ] Dove va un RS e dove un RA? **RS a `ff02::2`, RA a `ff02::1`**.
- [ ] I 3 passi dell'EUI-64? **Dividi il MAC, inserisci `fffe`, inverti il 7° bit**.
- [ ] Default route IPv6? **`ipv6 route ::/0 <next-hop>`**.
- [ ] Next-hop link-local: cosa serve in più? **L'interfaccia di uscita**.
- [ ] Comando per far inoltrare IPv6 al router? **`ipv6 unicast-routing`**.

Approfondimenti: [[IPv6 (part 1) - Hex, Address Format, Abbreviation, Prefixes, Basic Config|Parte 1: formato e abbreviazione]] · [[IPv6 (part 2) - Address Types + EUI-64 (Modified) – Global-Unique-Link-Local-Multicast-Anycast|Parte 2: tipi di indirizzo ed EUI-64]] · [[IPv6 (part 3) - NDP, SLAAC, Header, Static Routing|Parte 3: NDP, SLAAC e rotte statiche]]

## 🎯 Synthesis

IPv6 = 128 bit in hex, quasi sempre subnet /64; il tipo si legge dalle prime cifre (`2`/`3` global, `fd` privato, `fe80` link-local, `ff` multicast). Niente ARP né broadcast: NDP usa il multicast, SLAAC ricava l'indirizzo dagli RA. Il router inoltra solo con `ipv6 unicast-routing`, e una rotta con next-hop link-local vuole anche l'interfaccia.

> [!EXAMPLE] Laboratori pratici
> - [[Day 31 Lab - IPv6 Configuration (Part 1).pkt]]
> - [[Day 32 Lab - IPv6 Configuration (Part 2).pkt]]
> - [[Day 33 Lab - IPv6 Static Routes.pkt]]
