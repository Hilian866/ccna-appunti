---
tags: [ccna, exam, readme, blueprint]
tipo: mappa
---

> [!ABSTRACT] A cosa serve
> Mappa gli obiettivi ufficiali del **CCNA 200-301 v1.1** (PDF in `00_Inbox`) sulle note di ripasso. ✅ = coperto · ⚠️ = coperto in parte.

## 1.0 Network Fundamentals (20%)
| Obiettivo | Nota |
|---|---|
| 1.1 Ruolo dei componenti di rete (incl. PoE) | ✅ [[Componenti di Rete (Ruoli e Funzioni)]] |
| 1.2 Architetture (2/3-tier, spine-leaf, WAN, SOHO, cloud) | ✅ [[Cloud, Virtualizzazione & WAN]] |
| 1.3 Cablaggio e connessioni · 1.4 Problemi di interfaccia | ✅ [[Interfacce, Cablaggio & Troubleshooting]] |
| 1.5 TCP vs UDP | ✅ [[TCP vs UDP & Modello OSI]] |
| 1.6 IPv4 e subnetting | ✅ [[Subnetting - Fondamentali e Calcolo Rapido]] |
| 1.7 IPv4 privato | ⚠️ [[NAT - Network Address Translation]] (RFC 1918), APIPA in [[Verifica IP Client & Troubleshooting (ping, traceroute)]] |
| 1.8 · 1.9 IPv6 (indirizzi, tipi, EUI-64) | ✅ [[IPv6]] |
| 1.10 Verifica IP sul client | ✅ [[Verifica IP Client & Troubleshooting (ping, traceroute)]] |
| 1.11 Principi wireless | ✅ [[Wireless]] |
| 1.12 Virtualizzazione (VM, container, VRF) | ✅ [[Cloud, Virtualizzazione & WAN]] |
| 1.13 Switching (MAC learning, flooding, tabella MAC) | ✅ [[Switching Concepts (MAC Table, ARP)]] |

## 2.0 Network Access (20%)
| Obiettivo | Nota |
|---|---|
| 2.1 VLAN · 2.2 Trunk / 802.1Q / native VLAN | ✅ [[VLAN - Trunking & Inter-VLAN Routing]] |
| 2.3 CDP e LLDP | ✅ [[IP Services (NTP, SNMP, Syslog, SSH, CDP-LLDP, FTP-TFTP)]] |
| 2.4 EtherChannel (LACP) | ✅ [[Etherchannel]] |
| 2.5 Rapid PVST+ e STP Toolkit | ✅ [[STP (802.1D) & Rapid-PVST+ (802.1w)]] · [[STP Toolkit]] |
| 2.6 Architetture wireless e modalità AP · 2.7 Collegamenti WLAN · 2.8 Accesso di gestione | ✅ [[Wireless - AP Modes & Management Access]] |
| 2.9 Interpretare la GUI del WLC | ✅ [[Wireless]] |

## 3.0 IP Connectivity (25%)
| Obiettivo | Nota |
|---|---|
| 3.1 Componenti della routing table | ⚠️ [[Static Routing & Floating Routes]] (codici, AD, metrica, gateway of last resort) |
| 3.2 Decisione di forwarding | ✅ [[Static Routing & Floating Routes]] |
| 3.3 Routing statico IPv4/IPv6 (default, network, host, floating) | ✅ [[Static Routing & Floating Routes]] · [[IPv6]] |
| 3.4 OSPFv2 single area | ✅ [[OSPF - Open Shortest Path First]] |
| 3.5 FHRP | ✅ [[FHRP (First Hop Redundancy Protocol)]] |

## 4.0 IP Services (10%)
| Obiettivo | Nota |
|---|---|
| 4.1 NAT (static, pool, PAT) | ✅ [[NAT - Network Address Translation]] |
| 4.2 NTP · 4.4 SNMP · 4.5 Syslog (facility e severity) · 4.8 SSH · 4.9 TFTP/FTP | ✅ [[IP Services (NTP, SNMP, Syslog, SSH, CDP-LLDP, FTP-TFTP)]] |
| 4.3 DHCP e DNS · 4.6 DHCP client e relay | ✅ [[DHCP - Dynamic Host Configuration Protocol]] · [[DNS - Domain Name System]] |
| 4.7 QoS (PHB) | ✅ [[QoS]] |

## 5.0 Security Fundamentals (15%)
| Obiettivo | Nota |
|---|---|
| 5.1 Concetti chiave · 5.2 Security program · 5.3 Password locali · 5.4 Password policy · 5.5 VPN IPsec · 5.8 AAA · 5.9 Protocolli wireless | ✅ [[Security Fundamentals (AAA, VPN, Threats, WPA3)]] |
| 5.6 ACL | ✅ [[ACL - Access Control Lists (Standard & Extended)]] |
| 5.7 Sicurezza L2 (DHCP snooping, DAI, port security) | ✅ [[DHCP Snooping]] · [[DAI (Dynamic ARP Inspection)]] · [[Port Security (Layer 2)]] · confronto in [[Security Fundamentals (AAA, VPN, Threats, WPA3)]] (sez. 10) |
| 5.10 WLAN con WPA2-PSK (GUI) | ✅ [[Wireless]] |

## 6.0 Automation & Programmability (10%)
| Obiettivo | Nota |
|---|---|
| 6.1–6.7 Automazione, controller-based/SDN, AI/ML, REST, Ansible/Terraform, JSON | ✅ [[00 Automation - Riassunto]] (dettagli in `Day 59-63 - Note complete`) |

> [!INFO] Verifica
> Punti ⚠️ da rafforzare: componenti della routing table (3.1) e indirizzamento IPv4 privato (1.7). Le note nuove sono scritte dalla conoscenza generale e dal blueprint: confrontale con i tuoi appunti dei video.
