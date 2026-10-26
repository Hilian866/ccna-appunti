---
tags: [ccna, exam, fondamenti, troubleshooting]
priorita: medio
dominio: Network Fundamentals
blueprint: 1.10
stato: da-ripassare
---

> [!ABSTRACT] Cosa serve per l'esame
> Blueprint **1.10**: verificare i parametri IP dei client (Windows, macOS, Linux).
> Devi conoscere i comandi di ogni sistema per vedere indirizzo, maschera, gateway e DNS, saper leggere l'output di `ipconfig /all`, riconoscere un indirizzo APIPA, e usare ping e traceroute per capire dove si interrompe la comunicazione. DHCP e DNS sono in [[DHCP - Dynamic Host Configuration Protocol]] e [[DNS - Domain Name System]].

## 1. Cosa controllare

Un host comunica correttamente solo se ha:

- **indirizzo IP** e **maschera** corretti per la sua subnet;
- **default gateway** nella **stessa subnet** (per uscire dalla rete);
- **server DNS** (per usare i nomi).

| Cosa | Windows | macOS | Linux |
| :--- | :--- | :--- | :--- |
| IP, maschera, gateway, DNS, MAC | **`ipconfig /all`** | `ifconfig`, `networksetup -getinfo Wi-Fi` | **`ip addr`** (o `ifconfig`) |
| Solo IP, maschera, gateway | `ipconfig` | `ifconfig` | `ip addr`, `ip route` |
| Tabella di routing | `route print`, `netstat -rn` | `netstat -rn` | **`ip route`** |
| Server DNS | `ipconfig /all` | `scutil --dns` | `resolvectl status`, `/etc/resolv.conf` |
| Rinnovo DHCP | `ipconfig /release`, poi `/renew` | dalle impostazioni di rete | `dhclient -r`, poi `dhclient` |
| Cache ARP | `arp -a` | `arp -a` | `ip neigh` |
| Test DNS | `nslookup` | `nslookup`, `dig` | `nslookup`, `dig` |
| Percorso | **`tracert`** | `traceroute` | `traceroute` |

## 2. Leggere ipconfig /all

```text
C:\> ipconfig /all
Ethernet adapter Ethernet:
   Physical Address. . . . . . . . . : 00-50-79-66-68-00
   DHCP Enabled. . . . . . . . . . . : Yes
   IPv4 Address. . . . . . . . . . . : 192.168.10.25(Preferred)
   Subnet Mask . . . . . . . . . . . : 255.255.255.0
   Lease Obtained. . . . . . . . . . : lunedì 26 ottobre 2026 08:10:12
   Lease Expires . . . . . . . . . . : martedì 27 ottobre 2026 08:10:12
   Default Gateway . . . . . . . . . : 192.168.10.1
   DHCP Server . . . . . . . . . . . : 192.168.10.1
   DNS Servers . . . . . . . . . . . : 8.8.8.8
```

- **Physical Address**: il MAC (Windows lo scrive con i trattini).
- **DHCP Enabled: Yes**, con **DHCP Server** e lease: l'indirizzo viene dal DHCP. Con un indirizzo statico, DHCP Enabled è No.
- Gateway nella stessa subnet dell'host: corretto. Un gateway fuori dalla subnet (es. 192.168.20.1 con maschera /24) non funziona.

Su macOS e Linux la maschera compare spesso in esadecimale (`netmask 0xffffff00` = 255.255.255.0) o in notazione CIDR (`inet 192.168.10.25/24`).

> [!WARNING] APIPA
> Un indirizzo **`169.254.x.x/16`** vuol dire che l'host **non ha ricevuto risposta dal DHCP** e se ne è assegnato uno da solo. Comunica solo con altri host APIPA della stessa LAN. Cause da controllare: server DHCP, VLAN della porta, `ip helper-address` sul gateway, [[DHCP Snooping]] (porta del server non trusted).

## 3. Ping

`ping` manda un **ICMP echo request** (tipo 8) e aspetta un **echo reply** (tipo 0). Dimostra che la destinazione è raggiungibile a livello 3, **in entrambe le direzioni** (serve anche la rotta di ritorno), e misura il tempo di andata e ritorno (RTT).

Su IOS il risultato è una riga di simboli:

| Simbolo | Significato |
| :--- | :--- |
| `!` | risposta ricevuta |
| `.` | **timeout**: nessuna risposta (rotta mancante all'andata o al ritorno, ACL, host spento) |
| `U` | **destination unreachable**: un router ha risposto che non sa come arrivarci |
| `M` | il pacchetto andrebbe frammentato ma non si può |

```ios
R1# ping 192.168.20.10
Type escape sequence to abort.
Sending 5, 100-byte ICMP Echos to 192.168.20.10, timeout is 2 seconds:
.!!!!
Success rate is 80 percent (4/5), round-trip min/avg/max = 1/2/4 ms
```

Il primo `.` è normale la prima volta: il router doveva ancora fare l'ARP, e il primo pacchetto è andato perso.

Da un router il ping parte con l'IP dell'interfaccia di uscita. Con il ping **esteso** si sceglie la sorgente: serve a verificare che anche la rete della LAN sia raggiungibile dal lato opposto (rotta di ritorno, ACL, NAT).

```ios
! Ping con sorgente l'interfaccia LAN
R1# ping 192.168.20.10 source g0/1
```

Scrivendo solo `ping` e Invio, IOS chiede i parametri uno a uno (ripetizioni, dimensione, sorgente, timeout).

### Isolare il guasto per gradi

1. `ping 127.0.0.1`: lo stack TCP/IP del PC funziona.
2. Ping del **proprio IP**: la scheda di rete è configurata.
3. Ping del **default gateway**: la LAN funziona (cavo, VLAN, maschera).
4. Ping di un **IP remoto** (es. 8.8.8.8): il routing verso l'esterno funziona.
5. Ping di un **nome** (es. `cisco.com`): il **DNS** funziona.

Se il punto 4 riesce e il 5 no, il problema è il DNS.

## 4. Traceroute

Mostra i **router** attraversati fino alla destinazione.

1. Il primo pacchetto parte con **TTL 1**: il primo router lo scarta e risponde con un **ICMP time exceeded** (tipo 11), rivelando il proprio IP.
2. Il secondo parte con TTL 2, e risponde il secondo router. E così via.
3. La destinazione risponde con un echo reply (se il traceroute usa ICMP) o con un **port unreachable** (se usa UDP).

- **Windows `tracert`** usa ICMP echo; **Linux, macOS e IOS** usano di default UDP verso porte alte.
- `* * *` su un salto: nessuna risposta da quel router (ICMP filtrato, ACL, guasto). Se dopo un certo salto ci sono solo asterischi, il percorso si ferma lì.

```ios
R1# traceroute 8.8.8.8
Type escape sequence to abort.
Tracing the route to 8.8.8.8
  1 10.0.12.2 4 msec 2 msec 2 msec
  2 203.0.113.1 10 msec 9 msec 10 msec
  3  *  *  *
```

Qui il pacchetto arriva al secondo router; dopo, o manca una rotta o il terzo salto filtra le risposte.

## ⚠️ Trappole d'esame

> [!WARNING] Gli errori più frequenti
> 1. **Ping fallito = host spento**: può essere un'ACL o un firewall che blocca ICMP, o manca la rotta di ritorno.
> 2. **`.` e `U`**: `.` nessuna risposta; `U` un router ha risposto che non ha la rotta.
> 3. **APIPA** (169.254.x.x): il DHCP non ha risposto.
> 4. **Gateway fuori subnet**: l'host non riesce a raggiungerlo.
> 5. **tracert e traceroute**: Windows usa ICMP, gli altri UDP.
> 6. **Comandi per sistema**: `ipconfig` Windows, `ifconfig` macOS, `ip addr` Linux.

## Esercizi

> [!QUESTION]- Un PC ha 169.254.33.7. Cosa è successo?
> Non ha ricevuto risposta dal DHCP e si è assegnato un indirizzo APIPA.

> [!QUESTION]- Un PC fa ping verso 8.8.8.8 ma non riesce ad aprire siti per nome. Dove guardi?
> Al DNS: server configurato (`ipconfig /all`) e risoluzione con `nslookup`.

> [!QUESTION]- PC: 192.168.1.50/24, gateway 192.168.2.1. Cosa non funziona?
> Il gateway è fuori dalla subnet dell'host: il PC raggiunge solo la sua LAN.

> [!QUESTION]- Un ping da R1 mostra `U.U.U`. Cosa significa?
> Un router lungo il percorso risponde che non ha una rotta verso la destinazione (le U); i `.` compaiono perché quel router limita i messaggi unreachable che invia (di default uno ogni 500 ms).

> [!QUESTION]- Comando Linux per vedere la tabella di routing?
> `ip route`.

## Check da esame

- [ ] Comando Windows con IP, gateway, DNS e MAC? **`ipconfig /all`**.
- [ ] Equivalente Linux? **`ip addr`** (e `ip route` per il gateway).
- [ ] Tipo ICMP di echo request e reply? **8 e 0**.
- [ ] Messaggio ICMP che usa traceroute? **Time exceeded (tipo 11)**.
- [ ] Simbolo IOS di un ping riuscito? **`!`**. Di un timeout? **`.`**.
- [ ] Indirizzo APIPA? **169.254.0.0/16**.

## 🎯 Synthesis

Un host ha bisogno di IP e maschera giusti, gateway nella stessa subnet e DNS: si controllano con `ipconfig /all` (Windows), `ifconfig` (macOS) e `ip addr` / `ip route` (Linux). 169.254.x.x vuol dire DHCP senza risposta. Il ping (echo request e reply) va fatto per gradi, dal proprio stack fino a un nome DNS; su IOS `!` è successo, `.` timeout, `U` rotta mancante. Il traceroute aumenta il TTL di 1 e raccoglie i time exceeded per mostrare dove si ferma il percorso.

Approfondimenti: [[Windows CLI]]
