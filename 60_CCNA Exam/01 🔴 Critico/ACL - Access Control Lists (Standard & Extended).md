---
tags: [ccna, exam, acl]
priorita: critico
dominio: Security Fundamentals
stato: da-ripassare
---

> [!ABSTRACT] Cosa serve per l'esame
> Blueprint **5.6**: configurare e verificare le ACL.
> Dato un requisito ("il PC X non deve raggiungere il server Y via Telnet") devi scegliere tra standard ed extended, scrivere le righe nell'ordine giusto, applicarla sull'interfaccia e nella direzione corrette, e prevedere cosa succede a un pacchetto leggendo una ACL.

## 1. Come ragiona un'ACL

Un'ACL è una lista ordinata di regole (**ACE**, Access Control Entry), ognuna `permit` o `deny`. Di default un router inoltra tutto ciò per cui ha una rotta: l'ACL crea le eccezioni.

- **Dall'alto in basso**, e **vince la prima riga che combacia**: le righe sotto non vengono più lette.
- **Deny implicito**: in fondo c'è sempre un `deny any` invisibile. Se nessuna riga combacia, il pacchetto viene scartato.
- **Due passi**: la crei in global config (da sola non fa nulla), poi la applichi a un'interfaccia, `in` o `out`.
- **Una ACL per interfaccia, per direzione** (e per protocollo): al massimo una in ingresso e una in uscita. Una seconda nella stessa direzione sostituisce la prima.
- `in` filtra ciò che **entra** dall'interfaccia, `out` ciò che **esce**.

## 2. Standard ed extended

| | Standard | Extended |
| :--- | :--- | :--- |
| Cosa confronta | solo l'**IP sorgente** | protocollo, sorgente, destinazione, porte |
| Numeri | 1–99, 1300–1999 | 100–199, 2000–2699 |
| Dove si mette | vicino alla **destinazione** | vicino alla **sorgente** |

Il perché del posizionamento:

- una **standard** non sa dove va il pacchetto: messa vicino alla sorgente bloccherebbe quell'host verso **tutte** le destinazioni;
- una **extended** è precisa: conviene scartare il traffico appena entra, prima che attraversi la rete.

Entrambe possono essere **numerate** o **con nome**. Quelle con nome (o le numerate configurate in modalità named) hanno i **sequence number**, che permettono di inserire o cancellare una singola riga.

## 3. Wildcard

Nella wildcard un bit a **0** vuol dire "deve combaciare", un bit a **1** "non importa". Per una subnet: wildcard = 255.255.255.255 − maschera.

| Cosa vuoi indicare | Wildcard | Scorciatoia |
| :--- | :--- | :--- |
| una rete /24 | `0.0.0.255` | — |
| una rete /26 | `0.0.0.63` | — |
| una rete /20 | `0.0.15.255` | — |
| un solo host | `0.0.0.0` | `host 10.1.1.1` |
| qualsiasi indirizzo | `255.255.255.255` | `any` |

In una ACL standard un IP scritto senza wildcard vale come host singolo: `deny 1.1.1.1` = `deny host 1.1.1.1`.

## 4. Extended: come si scrive una riga

**permit/deny · protocollo · sorgente · [porta sorgente] · destinazione · [porta destinazione]**

- Protocollo: `ip` (tutto), `tcp`, `udp`, `icmp`…
- Le porte si possono indicare **solo** con `tcp` o `udp`. Operatori: `eq`, `neq`, `lt`, `gt`, `range 20 21`.
- La porta va dopo l'indirizzo a cui si riferisce. Per un server si filtra quasi sempre la porta di **destinazione**.
- Un pacchetto combacia solo se soddisfa **tutti** i criteri della riga.
- `established` fa passare solo i segmenti TCP di risposta (con ACK o RST).

| Servizio | Porta |
| :--- | :--- |
| FTP | TCP 20, 21 |
| SSH / Telnet | TCP 22 / TCP 23 |
| SMTP | TCP 25 |
| DNS | UDP 53 (TCP 53 per i trasferimenti di zona) |
| DHCP | UDP 67 (server), 68 (client) |
| TFTP | UDP 69 |
| HTTP / HTTPS | TCP 80 / TCP 443 |
| NTP | UDP 123 |
| SNMP | UDP 161 (agent), 162 (trap) |
| Syslog | UDP 514 |

## 5. Dal requisito alla configurazione

### Esempio 1: standard

*Requisito*: l'host 192.168.1.50 non deve raggiungere la LAN 10.0.2.0/24 (collegata a G0/1 di R2); tutto il resto passa.

1. Conta solo la sorgente, quindi basta una **standard**.
2. Va vicino alla **destinazione**: su R2, G0/1, in uscita.
3. Senza `permit any` finale, il deny implicito bloccherebbe tutti.

```ios
R2(config)# ip access-list standard BLOCK_PC50
R2(config-std-nacl)# deny host 192.168.1.50
R2(config-std-nacl)# permit any

! Uscita verso la LAN da proteggere
R2(config)# interface g0/1
R2(config-if)# ip access-group BLOCK_PC50 out
```

### Esempio 2: extended

*Requisito*: la rete 192.168.1.0/24 (collegata a G0/0 di R1) non deve aprire Telnet verso il server 10.0.0.10; tutto il resto passa.

1. Contano protocollo, destinazione e porta, quindi serve una **extended**.
2. Va vicino alla **sorgente**: su R1, G0/0, in ingresso.

```ios
R1(config)# ip access-list extended NO_TELNET_SRV
R1(config-ext-nacl)# deny tcp 192.168.1.0 0.0.0.255 host 10.0.0.10 eq 23
R1(config-ext-nacl)# permit ip any any

! Ingresso dalla LAN dei PC
R1(config)# interface g0/0
R1(config-if)# ip access-group NO_TELNET_SRV in
```

### La stessa cosa con le ACL numerate

```ios
! Standard numerata
R1(config)# access-list 10 deny host 192.168.1.50
R1(config)# access-list 10 permit any

! Extended numerata
R1(config)# access-list 110 deny tcp 192.168.1.0 0.0.0.255 host 10.0.0.10 eq 23
R1(config)# access-list 110 permit ip any any

! Applicazione: con il numero al posto del nome
R1(config-if)# ip access-group 110 in
```

## 6. Modificare e verificare

```ios
R1(config)# ip access-list extended NO_TELNET_SRV

! Inserisce una riga tra la 10 e la 20
R1(config-ext-nacl)# 15 deny icmp 192.168.1.0 0.0.0.255 host 10.0.0.10

! Cancella solo la riga 15
R1(config-ext-nacl)# no 15

! Rinumera 10, 20, 30... quando i numeri sono troppo vicini per inserire righe
R1(config)# ip access-list resequence NO_TELNET_SRV 10 10
```

Una ACL numerata modificata col comando classico non permette di togliere una riga: `no access-list 110` cancella **tutta** la lista.

```ios
! Righe e contatori (quanti pacchetti hanno combaciato)
R1# show access-lists

! Quali ACL sono applicate all'interfaccia, e in che direzione
R1# show ip interface g0/0
```

```text
Extended IP access list NO_TELNET_SRV
    10 deny tcp 192.168.1.0 0.0.0.255 host 10.0.0.10 eq telnet (12 matches)
    20 permit ip any any (845 matches)
```

IOS mostra le porte note con il nome (`eq telnet` al posto di `eq 23`). Il deny implicito non compare e non ha contatore.

### ACL sulle linee VTY

Per limitare chi può collegarsi al router in SSH/Telnet si applica una ACL standard alle linee VTY con **`access-class`**, non con `ip access-group`.

```ios
R1(config)# access-list 5 permit 10.0.0.0 0.0.0.255

R1(config)# line vty 0 15
R1(config-line)# access-class 5 in
```

## ⚠️ Trappole d'esame

> [!WARNING] Gli errori più frequenti
> 1. **Ordine delle righe**: un `permit any` in alto rende inutili i `deny` sotto. Le righe più specifiche vanno prima.
> 2. **Manca il permit finale**: per il deny implicito tutto il resto viene bloccato.
> 3. **Direzione sbagliata**: in/out invertiti, quindi l'ACL non filtra il traffico voluto.
> 4. **Standard vicino alla sorgente**: blocca l'host verso ogni destinazione.
> 5. **Maschera al posto della wildcard**: `0.0.0.255`, non `255.255.255.0`.
> 6. **Porta sul lato sbagliato**: `deny tcp any host 1.1.1.1 eq 80` controlla la porta di **destinazione**.
> 7. **Traffico generato dal router**: non viene filtrato da un'ACL in uscita sul router stesso.
> 8. **ACL applicata ma inesistente o vuota**: non filtra nulla, passa tutto.
> 9. **VTY**: si usa `access-class`, non `ip access-group`.

## Esercizi

> [!QUESTION]- `access-list 150 permit ...` è standard o extended?
> Extended: 150 è nel range 100–199.

> [!QUESTION]- ACL: `10 permit any` · `20 deny host 1.1.1.1`. Il traffico da 1.1.1.1 passa?
> Sì: combacia già con la riga 10, quindi la 20 non viene mai letta.

> [!QUESTION]- Scrivi una extended che permette solo HTTPS da 10.0.0.0/16 verso il server 2.2.2.2 e blocca tutto il resto.
> `permit tcp 10.0.0.0 0.0.255.255 host 2.2.2.2 eq 443`
> Per bloccare tutto il resto basta il deny implicito.

> [!QUESTION]- Wildcard per 172.16.0.0/20?
> 255.255.255.255 − 255.255.240.0 = `0.0.15.255`.

> [!QUESTION]- Vuoi impedire a 192.168.1.0/24 di fare ping verso 10.0.0.0/24, lasciando passare il resto. Che tipo di ACL, e dove la metti?
> Extended (serve il protocollo ICMP), vicino alla sorgente, in ingresso:
> `deny icmp 192.168.1.0 0.0.0.255 10.0.0.0 0.0.0.255` poi `permit ip any any`.

> [!QUESTION]- Un'ACL standard con nome ha le righe 10 e 20. Come aggiungi una riga che deve essere letta prima della 20?
> In modalità ACL scrivi la riga con un numero tra 10 e 20, per esempio `15 deny host 192.168.1.9`.

## Check da esame

- [ ] Cosa c'è in fondo a ogni ACL? **Un deny implicito**.
- [ ] Range standard ed extended? **1–99 e 1300–1999; 100–199 e 2000–2699**.
- [ ] Dove va una standard? E una extended? **Vicino alla destinazione; vicino alla sorgente**.
- [ ] Quante ACL per interfaccia? **Una per direzione**.
- [ ] Comando per applicarla a un'interfaccia? **`ip access-group <ACL> in|out`**.
- [ ] E alle linee VTY? **`access-class <ACL> in`**.
- [ ] Wildcard di un host singolo? **0.0.0.0, cioè `host`**.
- [ ] Comando per vedere i contatori? **`show access-lists`**.

## 🎯 Synthesis

Una ACL si legge dall'alto e la prima riga che combacia decide; in fondo c'è sempre un deny implicito. Le standard guardano solo la sorgente e vanno vicino alla destinazione; le extended guardano protocollo, indirizzi e porte e vanno vicino alla sorgente. Si applicano con `ip access-group` (`access-class` sulle VTY).

> [!EXAMPLE] Laboratori pratici
> - [[Day 34 Lab - Standard ACLs.pkt]]
> - [[Day 35 Lab - Extended ACLs.pkt]]
