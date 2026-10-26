---
tags: [ccna, exam, wireless, management]
priorita: molto-importante
dominio: Network Access
blueprint: 2.6, 2.7, 2.8
stato: da-ripassare
---

> [!ABSTRACT] Cosa serve per l'esame
> Blueprint **2.6** (architetture wireless e modalità degli AP), **2.7** (collegamenti fisici di AP, WLC e switch: porte access, trunk, LAG) e **2.8** (accesso di gestione: Telnet, SSH, HTTP, HTTPS, console, TACACS+/RADIUS, cloud).
> Devi saper dire cosa fa ogni modalità di un AP, a che tipo di porta si collegano AP e WLC, e quali metodi di gestione sono sicuri. Le basi del wireless sono in [[Wireless]].

## 1. Modalità degli AP lightweight

| Modalità | Cosa fa | Serve i client? |
| :--- | :--- | :--- |
| **Local** | il default: tutto il traffico va al WLC nel tunnel CAPWAP. Nei tempi morti controlla gli altri canali (gestione RF, AP non autorizzati) | sì |
| **FlexConnect** | può commutare il traffico **in locale** (local switching) e continua a funzionare se il link verso il WLC cade. Per le filiali | sì |
| Monitor | solo ascolto: AP non autorizzati, rilevamento intrusioni, localizzazione | no |
| Sniffer | cattura il traffico 802.11 e lo manda a un analizzatore (es. Wireshark) | no |
| Rogue detector | ascolta gli ARP sulla rete **cablata** per scoprire AP non autorizzati | no |
| SE-Connect | analisi dello spettro, per trovare interferenze | no |
| Bridge / Mesh | collega edifici via radio (root AP più mesh AP) | dipende |

Architetture: **autonomous** (AP indipendenti), **lightweight** (AP più WLC con CAPWAP, split-MAC), **cloud-based** (Meraki: gestione dal cloud, dati in locale). Dettagli in [[Wireless]], sezione 6.

## 2. Collegamenti fisici

| Dispositivo | Porta dello switch | Perché |
| :--- | :--- | :--- |
| AP in **Local** | **access** (VLAN di management degli AP) | il traffico dei client viaggia dentro il tunnel CAPWAP |
| AP in **FlexConnect** | **trunk** (native = VLAN di management) | deve mettere il traffico di ogni WLAN direttamente nella sua VLAN |
| AP autonomo | **trunk** | ogni SSID ha la sua VLAN, più quella di management |
| **WLC** | **trunk** verso lo switch | trasporta le VLAN di tutte le WLAN |
| WLC con più porte | **LAG** (EtherChannel) | banda e ridondanza |

> [!WARNING] Il LAG del WLC è solo statico
> Il WLC **non** negozia né PAgP né LACP. Sullo switch le porte vanno in `channel-group X mode on`.

- **Alimentazione**: l'AP riceve corrente dallo switch con **PoE** (vedi [[Interfacce, Cablaggio & Troubleshooting]]).
- **Indirizzo e WLC**: l'AP prende l'IP via **DHCP** e trova il WLC con la **option 43** del DHCP, con il DNS o con un broadcast nella subnet.

```ios
! Switch: due porte verso il WLC in LAG statico, poi trunk
SW1(config)# interface range g1/0/1 - 2
SW1(config-if-range)# channel-group 1 mode on

SW1(config)# interface port-channel 1
SW1(config-if)# switchport mode trunk
SW1(config-if)# switchport trunk allowed vlan 10,100,200
```

## 3. Accesso di gestione

| Metodo | Tipo | Porta | Sicuro? | Uso |
| :--- | :--- | :--- | :--- | :--- |
| Console | out-of-band | seriale/USB | sì (serve accesso fisico) | prima configurazione, ripristino |
| Telnet | in-band | TCP 23 | **no**, testo in chiaro | da disattivare |
| **SSH** | in-band | TCP 22 | **sì**, cifrato | lo standard |
| HTTP | in-band | TCP 80 | no | GUI di WLC e switch |
| **HTTPS** | in-band | TCP 443 | **sì**, TLS | GUI sicura |
| Cloud | in-band | HTTPS verso il cloud | sì | dashboard Meraki, Catalyst Center |

- **Out-of-band**: un canale separato dalla rete dati (console, AUX), che funziona anche se la rete è guasta.
- **In-band**: passa dalla rete stessa.
- L'autenticazione centralizzata degli amministratori si fa con **TACACS+** o **RADIUS** (AAA): vedi [[Security Fundamentals (AAA, VPN, Threats, WPA3)]].

```ios
! Solo SSH sulle linee virtuali, con utenti locali
R1(config)# line vty 0 15
R1(config-line)# transport input ssh
R1(config-line)# login local

! GUI solo in HTTPS
R1(config)# ip http secure-server
R1(config)# no ip http server
```

La configurazione completa di SSH è in [[IP Services (NTP, SNMP, Syslog, SSH, CDP-LLDP, FTP-TFTP)]].

## ⚠️ Trappole d'esame

> [!WARNING] Gli errori più frequenti
> 1. **AP FlexConnect su una porta access**: non può fare local switching. Serve un trunk.
> 2. **AP Local su un trunk**: non serve, basta una porta access.
> 3. **LACP o PAgP verso il WLC**: il WLC accetta solo LAG statico (`mode on`).
> 4. **Monitor e Sniffer** non servono client.
> 5. **Console "in-band"**: è out-of-band.
> 6. **Telnet e HTTP** non sono sicuri: viaggiano in chiaro.

## Esercizi

> [!QUESTION]- Una filiale deve continuare a far navigare i client anche se il link WAN verso il WLC centrale cade. Che modalità AP usi, e su che porta lo colleghi?
> FlexConnect, su una porta trunk.

> [!QUESTION]- Vuoi un AP che cerchi soltanto AP non autorizzati via radio, senza servire client. Che modalità?
> Monitor.

> [!QUESTION]- Lo switch ha `channel-group 1 mode active` verso il WLC e il LAG non sale. Perché?
> `active` è LACP, che il WLC non negozia. Serve `mode on`.

## Check da esame

- [ ] Modalità AP di default? **Local**.
- [ ] Modalità che commuta in locale e sopravvive alla perdita del WLC? **FlexConnect**.
- [ ] Porta per un AP Local? E per il WLC? **Access; trunk**.
- [ ] Che LAG supporta il WLC? **Solo statico (`mode on`)**.
- [ ] Come trova il WLC un AP in un'altra subnet? **DHCP option 43 (o DNS)**.
- [ ] Porte di SSH e Telnet? **22 e 23**.
- [ ] Cos'è la gestione out-of-band? **Un canale separato dalla rete dati, come la console**.

## 🎯 Synthesis

Local è il default (tutto via CAPWAP, porta access); FlexConnect commuta in locale e vuole un trunk. Il WLC va su un trunk, con LAG solo statico. I dispositivi si gestiscono con SSH e HTTPS (mai Telnet e HTTP), con autenticazione centralizzata TACACS+ o RADIUS.

> [!EXAMPLE] Laboratori pratici
> - [[Day 58 Lab - Wireless LANs.pkt]]
