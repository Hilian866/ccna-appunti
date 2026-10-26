---
tags: [ccna, exam]
priorita: molto-importante
stato: da-ripassare
---

> [!ABSTRACT] Cosa serve per l'esame
> Blueprint **4.3** (il ruolo di DHCP e DNS) e **4.6** (configurare e verificare un router come client DHCP e come relay).
> Devi conoscere i quattro messaggi DORA e chi li manda a chi, sapere perché serve il relay e dove si configura, e saper configurare un router come server, relay e client DHCP. Il DNS è in [[DNS - Domain Name System]].

## 1. A cosa serve

Il DHCP assegna in automatico a un host **indirizzo IP, maschera, default gateway, server DNS** e altri parametri. Si usa per i dispositivi finali (PC, telefoni); router e server di solito hanno indirizzi statici.

- Usa **UDP**: porta **67** sul server, **68** sul client.
- L'indirizzo è dato in **lease** (in prestito, a tempo): alla scadenza il client lo rinnova o lo libera. Così gli indirizzi si riutilizzano.

## 2. DORA

| Passo | Messaggio | Da → a | IP sorgente → destinazione |
| :--- | :--- | :--- | :--- |
| 1 | **Discover** | client → tutti | `0.0.0.0` → `255.255.255.255` (broadcast) |
| 2 | **Offer** | server → client | unicast o broadcast (lo decide un flag del client) |
| 3 | **Request** | client → tutti | broadcast |
| 4 | **Ack** | server → client | unicast o broadcast |

- La **Request** è broadcast anche se il client ha già scelto un server: così anche gli altri server che avevano fatto un'offerta sanno di essere stati scartati, e rimettono l'indirizzo nel loro pool.
- Con **Release** (unicast, dal client al server) il client restituisce l'indirizzo prima della scadenza.

## 3. Il relay

I router **non inoltrano i broadcast**, quindi un Discover non esce dalla sua subnet. Se il server DHCP sta in un'altra rete serve un **relay agent**:

- si configura con `ip helper-address <IP del server>` sull'interfaccia del router **verso i client** (il loro gateway);
- il router riceve il broadcast e lo inoltra in **unicast** al server;
- nel pacchetto mette il proprio IP di quell'interfaccia (campo **giaddr**). Il server lo usa per scegliere il **pool** della subnet giusta.

## 4. I tre ruoli di un router

### Server

```ios
! Indirizzi da non assegnare (gateway, server): prima di creare il pool
R1(config)# ip dhcp excluded-address 192.168.1.1 192.168.1.10

R1(config)# ip dhcp pool LAN1
R1(dhcp-config)# network 192.168.1.0 255.255.255.0
R1(dhcp-config)# default-router 192.168.1.1
R1(dhcp-config)# dns-server 8.8.8.8
R1(dhcp-config)# domain-name lab.local

! Durata del lease: giorni ore minuti
R1(dhcp-config)# lease 0 8 0
```

### Relay

```ios
! Sull'interfaccia (o SVI) dove stanno i client
R1(config)# interface g0/1
R1(config-if)# ip helper-address 192.168.10.10
```

### Client

```ios
! L'interfaccia prende l'indirizzo dal DHCP (es. dall'ISP)
R1(config)# interface g0/0
R1(config-if)# ip address dhcp
```

## 5. Verifica

```ios
! Indirizzi assegnati: IP, MAC del client, scadenza del lease
R1# show ip dhcp binding

! Pool: indirizzi totali, usati, liberi
R1# show ip dhcp pool

! Indirizzi del pool già usati da qualcuno con IP statico
R1# show ip dhcp conflict

! Su relay e client: helper address configurato, indirizzo ricevuto
R1# show ip interface g0/1
```

Su un PC Windows:

```text
ipconfig /all        indirizzo, gateway, DNS, server DHCP e lease
ipconfig /release    restituisce l'indirizzo
ipconfig /renew      ne chiede uno nuovo (rifà DORA)
```

Un client che non riceve risposta si assegna da solo un indirizzo **APIPA** `169.254.x.x`: è il segno che il DHCP non ha risposto (vedi [[Verifica IP Client & Troubleshooting (ping, traceroute)]]).

Gli AP lightweight possono ricevere dal DHCP anche l'indirizzo del WLC, con la **option 43** (vedi [[Wireless - AP Modes & Management Access]]).

## ⚠️ Trappole d'esame

> [!WARNING] Gli errori più frequenti
> 1. **Helper-address sull'interfaccia sbagliata**: va su quella **verso i client**, non verso il server.
> 2. **Server in un'altra subnet senza relay**: i Discover non arrivano.
> 3. **Esclusioni dimenticate**: il DHCP assegna l'indirizzo del gateway a un PC, e nasce un conflitto.
> 4. **Request "unicast"**: è broadcast.
> 5. **Porte invertite**: il server ascolta sulla 67, il client sulla 68.
> 6. **Lease troppo lunghi** dove i client cambiano spesso (Wi-Fi ospiti): il pool si esaurisce.

## Esercizi

> [!QUESTION]- Che IP sorgente e destinazione ha un DHCP Discover?
> `0.0.0.0` → `255.255.255.255`.

> [!QUESTION]- I PC della VLAN 20 (gateway: SVI `interface vlan 20` su SW1) devono ricevere l'indirizzo dal server 10.0.0.5, in un'altra rete. Cosa configuri, e dove?
> `ip helper-address 10.0.0.5` sotto `interface vlan 20` su SW1.

> [!QUESTION]- Un PC mostra 169.254.20.7. Cosa è successo?
> Non ha ricevuto risposta dal DHCP e si è dato un indirizzo APIPA. Controlla il server, il relay e la connessione.

> [!QUESTION]- Perché un client manda la Request in broadcast, se conosce già il server scelto?
> Per avvisare anche gli altri server DHCP che la loro offerta è stata rifiutata.

## Check da esame

- [ ] I quattro messaggi in ordine? **Discover, Offer, Request, Ack**.
- [ ] Porte UDP di server e client? **67 e 68**.
- [ ] Comando del relay? **`ip helper-address <server>`**.
- [ ] Router come client DHCP? **`ip address dhcp`**.
- [ ] Comando per vedere gli indirizzi assegnati? **`show ip dhcp binding`**.
- [ ] A cosa serve `excluded-address`? **A riservare indirizzi statici fuori dal pool**.

## 🎯 Synthesis

Il client trova il server con DORA (Discover e Request in broadcast) e riceve indirizzo, gateway e DNS in lease. I broadcast non attraversano i router: con il server in un'altra rete serve `ip helper-address` sull'interfaccia verso i client. Un router può fare da server (pool), relay e client (`ip address dhcp`).

> [!EXAMPLE] Laboratori pratici
> - [[Day 39 Lab - DHCP.pkt]]
