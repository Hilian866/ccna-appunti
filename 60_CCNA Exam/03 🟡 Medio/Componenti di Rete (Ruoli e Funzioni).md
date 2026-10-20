---
tags: [ccna, exam, fondamenti]
priorita: medio
dominio: Network Fundamentals
blueprint: 1.1
stato: da-ripassare
---

> [!ABSTRACT] Obiettivo
> Sapere **che cosa fa** ciascun componente e a quale livello opera. L'esame chiede di distinguere i ruoli, non di configurarli.

## 1. Tabella dei componenti

| Componente | Livello | Funzione | Punti chiave |
|---|---|---|---|
| **Router** | L3 | Instrada tra reti diverse in base all'IP | Un dominio di broadcast per interfaccia; NAT, ACL, routing dinamico |
| **Switch L2** | L2 | Inoltra frame in base al MAC | VLAN, trunk, STP, Port Security |
| **Switch L3 (multilayer)** | L2 + L3 | Switching **e** routing via hardware (ASIC) | **SVI** per l'inter-VLAN routing; porte routed |
| **NGFW** (Next-Gen Firewall) | L3–L7 | Firewall stateful + application awareness | IPS integrato, URL filtering, protezione malware, ispezione SSL |
| **IPS** | L3–L7 | Rileva **e blocca** minacce in linea (inline) | L'IDS invece osserva e basta (passivo, solo alert) |
| **Access Point (AP)** | L1–L2 | Collega i client wireless alla rete cablata | *Autonomous* o *Lightweight* (gestito da WLC) |
| **Controller** | — | Gestione centralizzata | **WLC** per il wireless; **Cisco Catalyst Center** (ex DNA Center) per campus/SDN |
| **Endpoint** | — | Dispositivi finali degli utenti | PC, laptop, telefoni IP, stampanti, IoT |
| **Server** | — | Offre servizi ai client | DHCP, DNS, web, file, posta |
| **PoE** | L1 | Alimenta AP/telefoni via cavo Ethernet | 802.3af/at/bt (vedi [[Interfacce, Cablaggio & Troubleshooting]]) |

## 2. Dove si collocano
- **Access layer**: switch L2 verso gli endpoint e gli AP (PoE).
- **Distribution**: switch L3, policy, inter-VLAN routing, ridondanza.
- **Core**: backbone veloce tra distribution.
- **Edge / perimetro**: router di bordo + **NGFW/IPS** verso Internet.
- **Controller**: WLC e Catalyst Center gestiscono AP e switch dall'alto.
Dettagli sulle architetture: [[Cloud, Virtualizzazione & WAN]].

## 3. Confronti tipici da esame
| Coppia | Differenza |
|---|---|
| **Switch L2 vs L3** | L2 = solo MAC/VLAN; L3 = instrada tra VLAN con SVI (senza router esterno). |
| **Firewall tradizionale vs NGFW** | Il tradizionale filtra su IP/porta/stato; l'NGFW ispeziona anche **applicazioni** e minacce. |
| **IDS vs IPS** | IDS = passivo (alert); IPS = **inline** (blocca). |
| **AP autonomo vs lightweight** | Autonomo = configurato da solo; lightweight = richiede un WLC (**CAPWAP**, split-MAC). |
| **WLC vs Catalyst Center** | WLC = gestisce solo il wireless; Catalyst Center = gestione e automazione di **tutta** la rete campus (intent-based). |

## Common Mistakes
- Dire che uno switch **L2** può instradare: senza SVI/L3 no.
- Confondere l'**IPS** (blocca) con l'**IDS** (segnala).
- Pensare che il **controller** faccia passare il traffico dati: gestisce (control/management plane); il data plane resta sui dispositivi ([[00 Automation - Riassunto]]).

## 🎯 Synthesis
Il router instrada tra reti, lo switch L2 inoltra per MAC, lo switch L3 fa entrambi; NGFW e IPS proteggono il perimetro; AP e WLC gestiscono il wireless; Catalyst Center governa tutta la rete campus.

Vedi anche: [[Wireless]] · [[Security Fundamentals (AAA, VPN, Threats, WPA3)]]
