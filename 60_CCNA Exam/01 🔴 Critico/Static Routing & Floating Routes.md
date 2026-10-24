---
tags: [ccna, exam, routing]
priorita: critico
dominio: IP Connectivity
stato: da-ripassare
---

## Obiettivo
Inserire a mano le rotte nella routing table. Nessun protocollo, nessun overhead: ideale per stub network e per il backup.

## 1. Come sceglie il router (ordine)
1. **Longest prefix match** — vince la rotta più specifica (/28 batte /24 batte /0).
2. **Administrative Distance (AD)** — a parità di prefisso, vince l'AD più bassa.
3. **Metrica** — a parità di AD, si confrontano le metriche del protocollo (o si fa ECMP Equal-Cost Multi-Path).

| Sorgente | AD |
|---|---|
| Connected | **0** |
| **Static** | **1** |
| eBGP | 20 |
| EIGRP | 90 |
| **OSPF** | **110** |
| RIP | 120 |
| Unknown | 255 |

## 2. Tipi di rotta statica

| Tipo | Esempio | Nota |
|---|---|---|
| Network route | `ip route 10.0.2.0 255.255.255.0 192.168.12.2` | Verso una rete |
| Host route | `ip route 10.0.2.5 255.255.255.255 192.168.12.2` | /32 verso un host |
| **Default route** | `ip route 0.0.0.0 0.0.0.0 203.0.113.1` | Gateway of last resort (`S*`) |
| **Floating static** | `ip route 10.0.2.0 255.255.255.0 192.168.13.2 130` | AD > protocollo primario → backup |
| Next-hop | `... 192.168.12.2` | Serve un lookup ricorsivo |
| Exit interface | `... g0/1` | Ok solo su link point-to-point (su Ethernet genera ARP per ogni destinazione) |
| Fully specified | `... g0/1 192.168.12.2` | Consigliata su Ethernet |

> [!IMPORTANT] Floating static
> Si dà una AD **più alta** della rotta dinamica (es. 130 > OSPF 110). Resta nascosta finché la rotta primaria sparisce: allora entra in tabella.

## 3. CLI Core

```
ip route 10.0.2.0 255.255.255.0 192.168.12.2
ip route 0.0.0.0 0.0.0.0 203.0.113.1

! floating
ip route 10.0.2.0 255.255.255.0 192.168.13.2 130
ipv6 unicast-routing
ipv6 route 2001:db8:2::/64 2001:db8:12::2

show ip route
show ip route static

! quale rotta userebbe per questo IP
show ip route 10.0.2.5
```

Lettura del codice: `S` = static, `S*` = candidata default, `C` = connected, `L` = local, `O` = OSPF. Es. `[1/0]` = AD 1, metrica 0.

## 4. Common Mistakes
- **Manca la rotta di ritorno**: il ping va, ma la risposta si perde (ping asimmetrico).
- **Next-hop non raggiungibile** → la rotta non entra in tabella.
- **Maschera/wildcard confuse**: nelle rotte statiche va la subnet mask, non la wildcard.
- **Floating con AD ≤ protocollo primario** → non è più di backup, diventa la principale.
- **Exit interface su Ethernet** senza next-hop → funziona con proxy ARP, ma è fragile.

## 🎯 Synthesis
Il router sceglie prima il prefisso più lungo, poi l'AD più bassa; una floating static è una statica con AD alta che aspetta il guasto.

---

> [!EXAMPLE] Laboratori pratici
> - [[Day 11 Lab - Configuring Static Routes.pkt]]
> - [[Day 11 Lab - Troubleshooting Static Routes.pkt]]
> - [[Day 24 Lab - Floating Static Routes.pkt]]
> - [[Day 33 Lab - IPv6 Static Routes.pkt]]
