---
tags: [ccna, exam]
priorita: molto-importante
stato: da-ripassare
---

> [!ABSTRACT] Cosa serve per l'esame
> Blueprint **5.7**: configurare e verificare le funzioni di sicurezza Layer 2 (DHCP snooping, DAI, port security).
> Devi sapere quali attacchi ferma, la differenza tra porte trusted e untrusted, quali messaggi DHCP vengono scartati e perché, cosa c'è nella binding table, e come si configura. DAI usa la binding table: vedi [[DAI (Dynamic ARP Inspection)]]. Il DHCP in sé è in [[DHCP - Dynamic Host Configuration Protocol]].

## 1. Gli attacchi

| Attacco | Come funziona | Danno |
| :--- | :--- | :--- |
| **DHCP starvation** | l'attaccante manda migliaia di Discover, ognuno con un MAC falso diverso | il pool si esaurisce e i client veri restano senza indirizzo (DoS) |
| **DHCP poisoning** (rogue server) | un server DHCP abusivo risponde prima di quello vero e indica sé stesso come **default gateway** | tutto il traffico verso l'esterno passa dall'attaccante (man-in-the-middle) |

Spesso i due attacchi vanno insieme: prima si esaurisce il server vero, poi risponde solo quello falso. Un client accetta la **prima** Offer che riceve.

## 2. Porte trusted e untrusted

DHCP snooping guarda **solo i messaggi DHCP**: il resto del traffico non lo tocca.

| Porta | Dove | Cosa fa lo switch |
| :--- | :--- | :--- |
| **Trusted** | uplink verso il server DHCP, il relay o altri switch | inoltra tutto, senza controlli |
| **Untrusted** | porte verso gli host | ispeziona ogni messaggio DHCP e scarta quelli sospetti |

Quando lo attivi, **tutte le porte sono untrusted**: l'uplink verso il server va dichiarato trusted, altrimenti le risposte del server vengono scartate e nessuno riceve più un indirizzo.

## 3. Cosa viene scartato su una porta untrusted

| Messaggio | Da chi | Controllo |
| :--- | :--- | :--- |
| **Offer, Ack, Nak** | server | **scartati sempre**: un host non deve fare da server (ferma il rogue server) |
| Discover, Request | client | il **MAC sorgente** del frame deve essere uguale al campo **CHADDR** del messaggio DHCP (il MAC del client). Altrimenti scartato |
| Release, Decline | client | IP sorgente e porta devono corrispondere alla **binding table**. Così nessuno può liberare l'indirizzo di un altro |

Il controllo MAC = CHADDR si aggira se l'attaccante falsifica entrambi. Contro la starvation serve allora anche il **rate limit** (sezione 5).

## 4. La binding table

Lo switch costruisce una tabella con i client che hanno ottenuto un indirizzo dal DHCP. Ogni riga contiene **MAC, IP, lease, VLAN, interfaccia**. Il default gateway **non** c'è (domanda frequente).

```ios
SW1# show ip dhcp snooping binding
MacAddress          IpAddress        Lease(sec)  Type           VLAN  Interface
------------------  ---------------  ----------  -------------  ----  --------------------
00:E0:4C:39:BA:01   192.168.10.15    86340       dhcp-snooping  10    FastEthernet0/1
```

Come si riempie:

1. Subito dopo l'attivazione la tabella è **vuota**.
2. Lo switch scrive una riga quando vede passare l'**Ack** del server verso un client (Discover e Request da soli non bastano).
3. I client che avevano già un indirizzo compaiono solo quando rinnovano il lease (o con `ipconfig /release` e `/renew`).
4. Gli host con **IP statico** non passano dal DHCP e non compaiono mai.

> [!CAUTION] Prima la tabella, poi DAI
> DAI scarta gli ARP degli host che non sono nella binding table. Se lo attivi prima che la tabella sia piena, tagli fuori i client già connessi e quelli con IP statico (per questi serve un'ARP ACL).

## 5. Rate limit

Limita i messaggi DHCP al secondo su una porta. Se il limite viene superato la porta va in **err-disabled**.

- Di default **non c'è** limite (al contrario di DAI, che ha 15 pacchetti/s di default).
- Riattivazione: `shutdown` e `no shutdown`, oppure automatica con `errdisable recovery cause dhcp-rate-limit`.

## 6. Option 82

L'Option 82 (relay agent information) aggiunge al messaggio informazioni sulla porta e sulla VLAN del client. Con DHCP snooping attivo, uno switch Cisco la **inserisce di default** anche se non fa da relay. Questo causa due problemi:

- un altro switch con snooping riceve il messaggio con l'Option 82 su una porta untrusted e lo **scarta**;
- il server può rifiutarlo per "informazioni di relay incoerenti".

Nei lab, se i client smettono di ricevere l'indirizzo dopo aver attivato lo snooping, la soluzione è `no ip dhcp snooping information option`.

## 7. Configurazione e verifica

```ios
! Attivazione globale, poi sulle VLAN (servono entrambe)
SW1(config)# ip dhcp snooping
SW1(config)# ip dhcp snooping vlan 10,20

! Niente Option 82 (se crea problemi)
SW1(config)# no ip dhcp snooping information option

! Uplink verso il server o il relay
SW1(config)# interface g0/1
SW1(config-if)# ip dhcp snooping trust

! Porte verso gli host: massimo 15 messaggi DHCP al secondo
SW1(config)# interface range f0/1 - 24
SW1(config-if-range)# ip dhcp snooping limit rate 15

! Riattivazione automatica delle porte err-disabled (dopo 300 s)
SW1(config)# errdisable recovery cause dhcp-rate-limit
SW1(config)# errdisable recovery interval 300
```

```ios
! VLAN attive, porte trusted e rate limit
SW1# show ip dhcp snooping

! Client registrati
SW1# show ip dhcp snooping binding

! Cause di errdisable recovery attive e timer
SW1# show errdisable recovery
```

## ⚠️ Trappole d'esame

> [!WARNING] Gli errori più frequenti
> 1. **Solo `ip dhcp snooping`**: senza `ip dhcp snooping vlan X` non filtra niente.
> 2. **Uplink lasciato untrusted**: le Offer vere del server vengono scartate.
> 3. **Cosa si scarta su una porta untrusted**: i messaggi del server **sempre**; quelli del client solo se falliscono i controlli.
> 4. **Default gateway nella binding table**: non c'è.
> 5. **Rate limit di default**: nessuno per DHCP snooping, 15 pacchetti/s per DAI.

## Esercizi

> [!QUESTION]- Un PC su una porta untrusted manda una DHCP Offer. Cosa fa lo switch?
> La scarta: Offer, Ack e Nak su una porta untrusted vengono scartati sempre.

> [!QUESTION]- Hai attivato snooping e VLAN, e nessun PC riceve più l'indirizzo. Il server è dietro g0/1. Due possibili cause?
> g0/1 non è trusted, quindi le risposte del server vengono scartate; oppure l'Option 82 inserita dallo switch fa scartare i messaggi (soluzione: `no ip dhcp snooping information option`).

> [!QUESTION]- Un attaccante falsifica sia il MAC sorgente sia il CHADDR per esaurire il pool. Cosa lo ferma?
> Il rate limit (`ip dhcp snooping limit rate`), che manda la porta in err-disabled.

> [!QUESTION]- Un server con IP statico è collegato a una porta untrusted. Compare nella binding table?
> No: le righe nascono solo dagli Ack DHCP.

## Check da esame

- [ ] Due attacchi fermati da DHCP snooping? **Starvation e rogue server (poisoning)**.
- [ ] Stato di default delle porte? **Untrusted**.
- [ ] Messaggi scartati sempre su untrusted? **Offer, Ack, Nak**.
- [ ] Controllo su Discover e Request? **MAC sorgente = CHADDR**.
- [ ] Campi della binding table? **MAC, IP, lease, VLAN, interfaccia**.
- [ ] Stato della porta oltre il rate limit? **Err-disabled**.

## 🎯 Synthesis

DHCP snooping divide le porte in trusted (verso il server) e untrusted (verso gli host, il default). Su quelle untrusted scarta sempre i messaggi da server e controlla quelli dei client, ferma starvation e rogue server, e costruisce la binding table (MAC, IP, lease, VLAN, porta) che usa anche DAI. Si attiva in globale e per VLAN.

> [!EXAMPLE] Laboratori pratici
> - [[Day 50 Lab - DHCP Snooping.pkt]]
