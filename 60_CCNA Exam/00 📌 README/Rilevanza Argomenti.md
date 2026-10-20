---
tags: [ccna, exam, readme]
tipo: mappa
---

> Nota **unica** (sostituisce le vecchie "Rilevanza 1/2/3", che si contraddicevano). Le cartelle di `60_CCNA Exam` seguono questa priorità.

## Peso ufficiale dei domini (blueprint 200-301 v1.1)

| Dominio | Peso |
|---|---|
| 1. Network Fundamentals | 20% |
| 2. Network Access (VLAN, STP, EtherChannel, WLAN) | 20% |
| 3. IP Connectivity (routing statico, OSPF, FHRP) | 25% |
| 4. IP Services (NAT, DHCP, DNS, NTP, SNMP, Syslog, QoS) | 10% |
| 5. Security Fundamentals | 15% |
| 6. Automation & Programmability | 10% |

> ⚠️ Automation **non è "pochissimo"**: vale come tutto IP Services. Non serve saper programmare, ma JSON, REST, SDN e Ansible/Puppet/Chef si devono saper leggere e distinguere. Verifica i pesi sul blueprint Cisco aggiornato.

Mappa obiettivi ufficiali → note: [[Copertura Blueprint]].

## Priorità di studio

### 🔴 Critico — zero errori tollerati
- [[Subnetting - Fondamentali e Calcolo Rapido]] (+ VLSM, sotto tempo)
- [[VLAN - Trunking & Inter-VLAN Routing]]
- [[Static Routing & Floating Routes]]
- [[OSPF - Open Shortest Path First]]
- [[ACL - Access Control Lists (Standard & Extended)]]
- [[NAT - Network Address Translation]]

### 🟠 Molto importante
- [[STP (802.1D) & Rapid-PVST+ (802.1w)]] · [[STP Toolkit]]
- [[Wireless]]
- [[DHCP - Dynamic Host Configuration Protocol]] · [[DNS - Domain Name System]]
- [[DHCP Snooping]] · [[DAI (Dynamic ARP Inspection)]]
- [[Security Fundamentals (AAA, VPN, Threats, WPA3)]]
- [[Wireless - AP Modes & Management Access]]
- [[IP Services (NTP, SNMP, Syslog, SSH, CDP-LLDP, FTP-TFTP)]]
- **Automation & Programmability (≈10%)**: [[00 Automation - Riassunto]] (riepilogo) → note complete in `Day 59-63 - Note complete`

### 🟡 Medio
- [[Etherchannel]] · [[Port Security (Layer 2)]] · [[FHRP (First Hop Redundancy Protocol)]] · [[IPv6]]
- [[QoS]]
- [[TCP vs UDP & Modello OSI]]
- [[Cloud, Virtualizzazione & WAN]]
- [[Componenti di Rete (Ruoli e Funzioni)]] · [[Switching Concepts (MAC Table, ARP)]]
- [[Interfacce, Cablaggio & Troubleshooting]] · [[Verifica IP Client & Troubleshooting (ping, traceroute)]]

## Ordine consigliato di ripasso
1. Subnetting (ogni giorno, cronometrato) → 2. VLAN/Trunk → 3. Routing statico + OSPF → 4. ACL + NAT → 5. STP/EtherChannel → 6. Security L2 + Security Fundamentals → 7. Wireless → 8. IP Services + Automation → 9. Rimanenti.

## Verità cruda
Se padroneggi 🔴 e sei decente su 🟠 sei a buon punto, ma **🟡 non è opzionale**: pesa meno per argomento, non vale zero (ma Automation, che vale ≈10%, è stata promossa a 🟠). Il subnetting lento, però, ti fa finire il tempo.
