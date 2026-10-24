---
tags: [ccna, exam]
priorita: critico
stato: da-ripassare
---

## Obiettivo

Segmentare la rete in **domini di broadcast logici** isolati per migliorare sicurezza e performance, garantendo la comunicazione tra di essi tramite routing Layer 3.

## 1. VLAN (Virtual LAN)

Una VLAN isola il traffico a livello 2. Senza un router o uno switch L3, il traffico non può mai passare da una VLAN all'altra.

> [!INFO] Relazione Chiave
>
> **1 VLAN = 1 Dominio di Broadcast = 1 Subnet IP**

- **VLAN Default (1):** Usata per il traffico di controllo (CDP, VTP, STP). **Best Practice:** Non usarla per il traffico utenti.
- **VLAN Riservate (1002-1005):** Legacy (Token Ring/FDDI). Ineliminabili.

## 2. Trasporto: Trunking & 802.1Q

Il Trunk permette a un singolo cavo fisico di trasportare traffico appartenente a centinaia di VLAN diverse.

### Il Tag 802.1Q (4 Byte)

Viene inserito nell'Ethernet Frame tra _Source MAC_ e _Type_.

- **VLAN ID (VID):** 12 bit (Range: 1 - 4094).
- **PCP (Priority):** 3 bit per la Qualità del Servizio (QoS).

> [!WARNING] Native VLAN Mismatch
>
> I frame della **Native VLAN** transitano senza tag. Se gli switch ai due capi del trunk hanno Native VLAN diverse:
>
> 1. Vengono generati log di errore costanti.
> 2. Il traffico può "saltare" da una VLAN all'altra (**VLAN Leaking**).
>

## 3. Inter-VLAN Routing

Come far comunicare le VLAN tra loro.

### Metodo A: Router-on-a-Stick (ROAS)

Usa un router fisico con **sub-interfaces**.

- L'interfaccia fisica deve essere in `no shutdown`.
- Ogni sub-interface deve avere l'incapsulamento corretto: `encapsulation dot1q <VLAN_ID>`.

### Metodo B: Multilayer Switch (SVI)

Il metodo moderno e più veloce (routing via hardware/ASIC).

> [!DANGER] Condizioni SVI "UP/UP" (Checklist Esame)
>
> Un'interfaccia SVI (`interface vlan X`) non salirà mai se:
>
> 1. La **VLAN X** non esiste nel database (`show vlan`).
> 2. Non esiste **almeno una porta attiva** (fisica o trunk) associata alla VLAN X.
> 3. L'interfaccia è in `shutdown`.
>

## 4. CLI Core: Comandi di Verifica

|Comando|Scopo Strategico|
|---|---|
|`show vlan brief`|Verifica VLAN esistenti e porte **Access**.|
|`show interfaces trunk`|Verifica quali porte sono **Trunk** e le VLAN permesse.|
|`show ip route`|Verifica se il routing L3 è attivo (cerca il gateway).|
|`show interfaces status`|Controllo rapido dello stato fisico delle porte.|

## ⚠️ 5. Common Quiz Traps (Anatomy Check)

> [!CAUTION] Attenzione ai trabocchetti
>
> - **Scomparsa delle porte:** Se una porta è configurata come Trunk, sparirà dall'output di `show vlan brief`. Questo è il trucco più comune nei quiz Cisco.
> - **Creazione Automatica:** Creare una SVI **NON** crea la VLAN nel database. Assegnare una porta access a una VLAN inesistente invece **SÌ**.
> - **Intervallo VLAN:** > * **Normal (1-1005):** Salvate nel file `vlan.dat` nella Flash.
>     - **Extended (1006-4094):** Salvate solo nella `running-config`.
>

## 🎯 Synthesis
Lo switch Layer 2 isola, il Trunk trasporta, il Router (o lo Switch L3) connette. Ricorda sempre di verificare che la VLAN esista nel database prima di cercare di capire perché il routing non funziona.

---

> [!EXAMPLE] Laboratori Pratici
> - [[Day 16 Lab - VLANs (Part 1).pkt]]
> - [[Day 17 Lab - VLANs (Part 2).pkt]]
> - [[Day 18 Lab - Multilayer Switching.pkt]]
