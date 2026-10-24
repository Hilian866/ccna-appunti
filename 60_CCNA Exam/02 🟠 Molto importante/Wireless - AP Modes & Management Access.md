---
tags: [ccna, exam, wireless, management]
priorita: molto-importante
dominio: Network Access
blueprint: 2.6, 2.7, 2.8
stato: da-ripassare
---

> [!ABSTRACT] Obiettivo
> Completa [[Wireless]] con tre punti del blueprint: **modalità degli AP** (2.6), **collegamenti fisici** di AP e WLC (2.7) e **accesso di gestione ai dispositivi** (2.8).

## 1. Modalità degli AP (Lightweight, gestiti da WLC)

| Modalità | Cosa fa | Note |
|---|---|---|
| Local | Serve i client, tunnel **CAPWAP** verso il WLC, tutto il traffico passa dal WLC | **Default**. Nei tempi morti scansiona gli altri canali (RRM/rogue detection) |
| FlexConnect | Serve i client e può **commutare il traffico localmente** (*local switching*) | Filiali remote; **resta operativo se il link WAN verso il WLC cade**. Richiede porta **trunk** |
| Monitor | **Non serve i client**: solo ascolto (rogue AP, IDS, localizzazione) | Solo ricezione |
| Sniffer | Cattura il traffico 802.11 e lo invia a un analizzatore (es. Wireshark) | Solo diagnostica |
| Rogue Detector | Ascolta ARP sulla rete cablata per scoprire AP non autorizzati | Non usa la radio per servire client |
| Bridge / Mesh | Collegamento wireless punto-punto o punto-multipunto tra edifici | Root AP + Mesh AP |
| SE-Connect | Analisi dello spettro (interferenze) | Diagnostica RF |

Architetture: **Autonomous** (AP standalone), **Lightweight** (AP + WLC, CAPWAP, *split-MAC*), **Cloud-based** (Meraki: gestione da dashboard cloud, dati in locale). Dettagli in [[Wireless]].

## 2. Collegamenti fisici (WLAN)

| Componente | Porta dello switch | Perché |
|---|---|---|
| AP Local | **Access** (VLAN di management dell'AP) | Il traffico utenti viaggia dentro il tunnel CAPWAP |
| AP FlexConnect | **Trunk** (con native VLAN = VLAN di management) | Deve inserire il traffico delle WLAN direttamente nelle VLAN locali |
| WLC | **Trunk** verso lo switch di distribuzione | Trasporta tutte le VLAN delle WLAN (interfacce dinamiche) |
| WLC con più porte | **LAG** (EtherChannel) | Aggrega le porte per banda e ridondanza |

> [!WARNING] LAG sul WLC
> Il WLC supporta solo **LAG statico** (`channel-group X mode on`): **non** negozia PAgP né LACP. Lo switch deve avere `mode on` sulle porte corrispondenti.

Alimentazione dell'AP: **PoE** dallo switch (vedi [[Interfacce, Cablaggio & Troubleshooting]]). L'AP ottiene l'IP via **DHCP** e scopre il WLC con **DHCP option 43**, DNS o broadcast.

## 3. Accesso di gestione ai dispositivi

| Metodo | Tipo | Porta | Sicuro? | Note |
|---|---|---|---|---|
| Console | Out-of-band | Seriale/USB | Sì (accesso fisico) | Prima configurazione, recovery |
| Telnet | In-band | TCP **23** | **No** (testo in chiaro) | Da disattivare |
| SSH | In-band | TCP **22** | **Sì** (cifrato) | Standard consigliato |
| HTTP | In-band | TCP **80** | No | GUI del WLC/switch |
| HTTPS | In-band | TCP **443** | Sì (TLS) | GUI sicura |
| Cloud managed | In-band | HTTPS verso il cloud | Sì | Meraki dashboard, Catalyst Center |

- **Out-of-band** = canale separato dalla rete dati (console, AUX): funziona anche se la rete è guasta. **In-band** = passa dalla rete stessa.
- L'**autenticazione centralizzata** avviene con **TACACS+** o **RADIUS** (AAA): vedi [[Security Fundamentals (AAA, VPN, Threats, WPA3)]].

```
line vty 0 15
 transport input ssh        ! blocca Telnet
 login local
ip http secure-server       ! attiva HTTPS
no ip http server           ! disattiva HTTP
```

## Common Mistakes
- AP **FlexConnect** collegato a una porta access: non può fare local switching.
- Configurare LACP/PAgP sul LAG del WLC: usa **`on`**.
- Dimenticare che l'AP **Monitor** e **Sniffer** non servono i client.
- Considerare la console "in-band": è out-of-band.

## 🎯 Synthesis
Local è il default (tutto via CAPWAP), FlexConnect commuta in locale e vuole un trunk; il WLC usa un LAG statico; si gestisce con SSH/HTTPS (mai Telnet/HTTP) e AAA centralizzato.
