---
tags: [ccna, exam, fondamenti, switching]
priorita: medio
dominio: Network Fundamentals
blueprint: 1.13
stato: da-ripassare
---

> [!ABSTRACT] Obiettivo
> Capire come uno switch costruisce la **MAC address table** e decide se inoltrare, filtrare o fare **flooding** di un frame, e come ARP collega IP e MAC.

## 1. Il frame Ethernet

| Campo | Dimensione | Note |
|---|---|---|
| Preamble + SFD | 8 B | Sincronizzazione |
| **Destination MAC** | 6 B | |
| **Source MAC** | 6 B | |
| Type (o tag 802.1Q + Type) | 2 B (+4 B) | 0x0800 = IPv4, 0x86DD = IPv6, 0x0806 = ARP |
| Data (payload) | 46–1500 B | MTU = 1500 |
| **FCS** | 4 B | CRC di controllo errori |

Il **MAC address** è di 48 bit (12 cifre hex): i primi 24 bit sono l'**OUI** del produttore. Destinazioni speciali: broadcast `FFFF.FFFF.FFFF`, multicast (il bit meno significativo del primo byte = 1).

## 2. Le 4 azioni dello switch

1. **Learning** — legge il Source MAC del frame in arrivo e lo associa alla porta d'ingresso (e alla VLAN).
2. **Forwarding** — cerca il Destination MAC nella tabella: se lo conosce, lo invia **solo** sulla porta associata (*known unicast*).
3. **Flooding** — se il destination è sconosciuto (*unknown unicast*), broadcast o multicast, lo invia su **tutte le porte della stessa VLAN** tranne quella d'ingresso.
4. **Filtering** — se il destination è sulla **stessa porta** da cui è arrivato il frame, lo scarta.

> [!INFO] Aging
> Le voci dinamiche scadono dopo **300 secondi** senza traffico dal MAC (`mac address-table aging-time`). La tabella è **per VLAN** ed è in memoria CAM.

```
show mac address-table
show mac address-table dynamic
show mac address-table address 0011.2233.4455
clear mac address-table dynamic
mac address-table static 0011.2233.4455 vlan 10 interface g0/2
```

## 3. Metodi di switching (frame switching)
| Metodo | Decide dopo… | Controlla errori (FCS)? |
|---|---|---|
| **Store-and-forward** | Aver ricevuto tutto il frame | **Sì** (scarta i frame errati) |
| Cut-through | Aver letto il Destination MAC | No (latenza minima) |
| Fragment-free | Primi 64 byte | Parziale (evita i runt) |

Gli switch Catalyst moderni usano di default store-and-forward.

## 4. Domini di collisione e di broadcast

| Dispositivo | Domini di collisione | Domini di broadcast |
|---|---|---|
| Hub | 1 in totale | 1 |
| Switch | **1 per porta** | 1 **per VLAN** |
| Router | 1 per interfaccia | **1 per interfaccia** |

## 5. ARP (Address Resolution Protocol)
Risolve **IP → MAC** sulla stessa subnet (L3 → L2).

1. L'host A vuole parlare con `192.168.1.20`: controlla la **ARP cache**.
2. Se manca, invia una **ARP Request** in broadcast (`FFFF.FFFF.FFFF`): "Chi ha 192.168.1.20?".
3. L'host B risponde con una **ARP Reply** in **unicast** con il proprio MAC.
4. Se la destinazione è **fuori subnet**, l'host fa ARP per il **MAC del default gateway**, non per quello remoto.

```
! Cisco IOS
show ip arp
clear ip arp

! Windows / macOS / Linux
arp -a
```
Reti sicure: [[DAI (Dynamic ARP Inspection)]] contro l'ARP poisoning; **Gratuitous ARP** = annuncio non richiesto ([[FHRP (First Hop Redundancy Protocol)]]).

## Common Mistakes
- Pensare che lo switch impari il MAC dal **destination**: impara sempre dal **source**.
- Confondere **domini di broadcast** (VLAN/router) e **di collisione** (porte dello switch).
- Dimenticare che il flooding avviene **solo nella VLAN** del frame.
- In un attacco di **MAC flooding** la tabella si riempie e lo switch inizia a fare flooding di tutto: si contrasta con [[Port Security (Layer 2)]].

## 🎯 Synthesis
Lo switch impara dal source MAC, inoltra sul destination noto e fa flooding se è ignoto o broadcast; ARP traduce IP in MAC con una request broadcast e una reply unicast.

Vedi anche: [[VLAN - Trunking & Inter-VLAN Routing]]
