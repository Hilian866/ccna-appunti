---
tags: [ccna, exam, fondamenti, troubleshooting]
priorita: medio
dominio: Network Fundamentals
blueprint: 1.10
stato: da-ripassare
---

> [!ABSTRACT] Obiettivo
> Verificare i **parametri IP di un client** (Windows, macOS, Linux) e usare `ping` / `traceroute` per isolare i guasti.

## 1. Parametri da controllare
**IP address · subnet mask · default gateway · DNS server · MAC address · DHCP attivo/lease**.

| Azione | **Windows** | **macOS** | **Linux** |
|---|---|---|---|
| Mostra IP, mask, gateway, DNS, MAC | `ipconfig /all` | `ifconfig` · `networksetup -getinfo Wi-Fi` | `ip a` (o `ip addr`) |
| Tabella di routing | `route print` · `netstat -rn` | `netstat -rn` | `ip route` |
| DNS configurati | `ipconfig /all` | `scutil --dns` | `resolvectl status` · `cat /etc/resolv.conf` |
| Rinnova DHCP | `ipconfig /release` + `/renew` | Impostazioni → Rinnova lease DHCP | `sudo dhclient -r` + `sudo dhclient` |
| Cache ARP | `arp -a` | `arp -a` | `ip neigh` |
| Cache DNS | `ipconfig /displaydns` · `/flushdns` | `sudo dscacheutil -flushcache` | `resolvectl flush-caches` |
| Test DNS | `nslookup nome` | `nslookup` / `dig` | `nslookup` / `dig` |
| Traccia il percorso | `tracert` | `traceroute` | `traceroute` |

> [!WARNING] APIPA
> Un IP **`169.254.x.x/16`** significa che il client **non ha ricevuto risposta dal DHCP**: controlla server, VLAN, `ip helper-address`, [[DHCP Snooping]].

## 2. Ping (ICMP)
`ping` usa **ICMP Echo Request** (tipo 8) e attende **Echo Reply** (tipo 0). Dimostra la raggiungibilità a livello 3 e mostra RTT e **TTL**.

Su **Cisco IOS** l'output è simbolico:

| Simbolo | Significato |
|---|---|
| `!` | Risposta ricevuta |
| `.` | **Timeout** (nessuna risposta: ACL, rotta mancante, host spento) |
| `U` | **Destination unreachable** (ricevuto dal router: nessuna rotta) |
| `M` | Non si può frammentare |

```
ping 10.0.0.1

! ping esteso: cambia l'IP sorgente (verifica routing/ACL/NAT)
ping 10.0.0.1 source g0/0
```

### Sequenza di troubleshooting (dal basso verso l'alto)
1. `ping 127.0.0.1` → lo stack TCP/IP locale funziona.
2. `ping` del **proprio IP** → la scheda di rete è attiva.
3. `ping` del **default gateway** → la LAN funziona (cavo, VLAN, mask).
4. `ping` di un **IP remoto** (es. `8.8.8.8`) → il routing verso l'esterno funziona.
5. `ping` di un **nome** (`google.com`) → il **DNS** funziona.
Se il passo 4 funziona e il 5 no, il problema è il DNS.

## 3. Traceroute
Mostra **ogni router** lungo il percorso incrementando il **TTL** di 1 a ogni pacchetto:
- Il router che azzera il TTL risponde con **ICMP Time Exceeded** (tipo 11), rivelando il proprio IP.
- **Windows** `tracert` usa pacchetti **ICMP Echo**; **Linux/macOS/Cisco** usano di default **UDP** su porte alte.
- Alla destinazione la risposta è un **Echo Reply** (ICMP) o **Port Unreachable** (UDP).
- `* * *` = nessuna risposta da quell'hop (ACL, ICMP filtrato o guasto).
Serve a capire **dove** si interrompe il percorso (rotta mancante, ACL, NAT).

```
traceroute 8.8.8.8         (Cisco / Linux / macOS)
tracert 8.8.8.8            (Windows)
```

## Common Mistakes
- Considerare un ping fallito come "host spento": può essere un **ACL** o il firewall che filtra ICMP.
- Dimenticare che il ping può riuscire ma il **DNS** no.
- Non usare il **ping esteso** con `source`: il ping da un router usa l'IP dell'interfaccia di uscita, che può nascondere problemi di rotta di ritorno.
- Confondere `.` (timeout) con `U` (unreachable: c'è un router che risponde che manca la rotta).

## 🎯 Synthesis
`ipconfig /all` (o `ip a`) mostra i parametri IP; ping da 127.0.0.1 al nome DNS isola il guasto per livelli, e traceroute (TTL + ICMP Time Exceeded) mostra dove si ferma il percorso.

Approfondimenti: [[Windows CLI]] · [[DNS - Domain Name System]] · [[DHCP - Dynamic Host Configuration Protocol]]
