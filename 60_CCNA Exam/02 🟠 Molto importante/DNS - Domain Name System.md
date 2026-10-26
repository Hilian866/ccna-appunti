---
tags: [ccna, exam]
priorita: molto-importante
stato: da-ripassare
---

> [!ABSTRACT] Cosa serve per l'esame
> Blueprint **4.3**: il ruolo di DNS (e DHCP) nella rete.
> Devi sapere cosa fa il DNS, che porte usa, i tipi di record principali, in che ordine un host cerca un nome, e come configurare un router come client o server DNS. Il DHCP è in [[DHCP - Dynamic Host Configuration Protocol]].

## 1. A cosa serve

Il DNS traduce un **nome** (`www.esempio.com`) in un **indirizzo IP**. Le persone usano i nomi, i dispositivi comunicano con gli IP.

1. Il client vuole aprire `youtube.com` e manda una **query** al suo server DNS (configurato a mano o ricevuto dal DHCP).
2. Il server risponde con l'IP.
3. Il client usa quell'IP per la connessione vera (es. HTTPS).

I router lungo il percorso si limitano a inoltrare i pacchetti DNS: non serve configurare il DNS su di loro.

- **UDP 53** per le query normali.
- **TCP 53** per le risposte più grandi di **512 byte** e per i **trasferimenti di zona** (la copia del database tra server DNS).

## 2. Record

| Record | Cosa associa |
| :--- | :--- |
| **A** | nome → indirizzo **IPv4** |
| **AAAA** | nome → indirizzo **IPv6** (4 "A" per un indirizzo 4 volte più lungo) |
| **CNAME** | nome → **altro nome** (alias) |
| MX | dominio → server di posta |
| NS | zona → server DNS autoritativo |

## 3. Dove cerca un host

1. **Cache DNS**: le risposte recenti, tenute in memoria.
2. **File hosts**: associazioni scritte a mano sul computer; ha la precedenza sul server DNS (non scala, e un malware può modificarlo per dirottare il traffico).
3. **Server DNS**.

Su Windows:

```text
ipconfig /all          mostra anche i server DNS in uso
nslookup youtube.com   chiede il nome direttamente al server DNS
ipconfig /displaydns   mostra la cache
ipconfig /flushdns     svuota la cache (dopo aver cambiato un record)
```

## 4. Il router e il DNS

- **Client DNS**: il router risolve nomi **per sé** (per esempio in `ping server1`).
- **Server DNS**: risponde alle query **degli altri** con i record che ha in configurazione. Se non conosce un nome, lo chiede al server esterno indicato con `ip name-server`.

```ios
! Client: a quale server chiedere
R1(config)# ip name-server 8.8.8.8

! Risoluzione dei nomi attiva (è già il default)
R1(config)# ip domain lookup

! Dominio aggiunto ai nomi brevi: "ping PC1" diventa "ping PC1.lab.local"
R1(config)# ip domain name lab.local
```

```ios
! Server: attiva il servizio
R1(config)# ip dns server

! Record statici
R1(config)# ip host PC1 192.168.0.101
R1(config)# ip host PC2 192.168.0.102

! Server esterno per i nomi che non conosce
R1(config)# ip name-server 8.8.8.8
```

```ios
! Record statici e cache del router
R1# show hosts
```

Nei lab si usa spesso `no ip domain lookup`: senza, un comando scritto male viene preso per un nome da risolvere e il router resta bloccato a cercarlo per decine di secondi. Il dominio (`ip domain name`) serve anche per generare le chiavi di SSH.

## ⚠️ Trappole d'esame

> [!WARNING] Gli errori più frequenti
> 1. **"Il DNS usa solo UDP"**: usa anche TCP 53, per le risposte grandi e i trasferimenti di zona.
> 2. **A e AAAA**: A per IPv4, AAAA per IPv6.
> 3. **Cache e file hosts**: la cache è temporanea e automatica; il file hosts è manuale e ha la precedenza sul server.
> 4. **Router "che deve fare DNS" per inoltrare le query**: no, le inoltra come qualsiasi pacchetto.
> 5. **DNS esterno irraggiungibile**: se manca la rotta verso il server (es. 8.8.8.8), la risoluzione fallisce anche se il server funziona.

## Esercizi

> [!QUESTION]- Che record serve per far risolvere `www.esempio.com` in `2001:db8::10`?
> Un record AAAA.

> [!QUESTION]- Hai cambiato il record A di un server, ma un PC continua a usare il vecchio IP. Cosa fai?
> Svuoti la cache con `ipconfig /flushdns` (e controlli che il file hosts non contenga quel nome).

> [!QUESTION]- R1 deve rispondere alle query dei PC per il nome PRINTER (192.168.1.50) e girare a 8.8.8.8 le altre. Quali comandi?
> `ip dns server`, `ip host PRINTER 192.168.1.50`, `ip name-server 8.8.8.8`.

## Check da esame

- [ ] Porta del DNS? **53, UDP e TCP**.
- [ ] Quando si usa TCP? **Risposte oltre 512 byte e trasferimenti di zona**.
- [ ] Record per un alias? **CNAME**.
- [ ] Comando per far risolvere i nomi al router? **`ip name-server <IP>`**.
- [ ] Comando per attivare il router come server DNS? **`ip dns server`**.
- [ ] Comando Windows per interrogare un server DNS? **`nslookup`**.

## 🎯 Synthesis

Il DNS traduce nomi in IP: UDP 53 per le query, TCP 53 per risposte grandi e trasferimenti di zona. Un host cerca prima nella cache, poi nel file hosts, poi nel server. Un router Cisco può essere client (`ip name-server`) o server (`ip dns server` più `ip host`).

> [!EXAMPLE] Laboratori pratici
> - [[Day 38 Lab - DNS.pkt]]
