---
tags: [ccna, exam]
priorita: molto-importante
stato: da-ripassare
---

> [!ABSTRACT] Core Logic
>
> Il DAI è una funzionalità di sicurezza che protegge la rete prevenendo gli attacchi di **[[arp poisoning-man in the middle.png|ARP Poisoning]]** (Man-in-the-Middle). Funziona ispezionando i messaggi ARP su porte **Untrusted** e validandoli rispetto al **DHCP Snooping Binding Table**.

---

## Funzionamento e Porte [▶ 05:33](http://www.youtube.com/watch?v=HwbTKaIvL6s&t=333)

Il DAI classifica le interfacce in modo simile al DHCP Snooping per determinare dove applicare l'ispezione:

|**Tipo Porta**|**Destinazione**|**Comportamento**|
|---|---|---|
|**Trusted**|Switch, Router|I messaggi ARP passano senza controlli.|
|**Untrusted**|Host finali (PC, Stampanti)|Ogni pacchetto ARP viene ispezionato e validato.|

> [!WARNING] Di default, tutte le porte sono **Untrusted** quando il DAI viene abilitato su una VLAN.

---

## Processo di Validazione [▶ 09:05](http://www.youtube.com/watch?v=HwbTKaIvL6s&t=545)

Per ogni pacchetto ARP su porta Untrusted, lo switch esegue un match critico:

- **Check Primario:** Confronta l'indirizzo `Sender MAC` e `Sender IP` del pacchetto ARP con le voci nel **DHCP Snooping Binding Table**.
- **Esito:** Se non esiste una corrispondenza esatta, il pacchetto viene scartato (Drop).

---

## Check di Validazione Addizionali [▶ 15:45](http://www.youtube.com/watch?v=HwbTKaIvL6s&t=945)

Oltre al binding table, è possibile attivare controlli granulari per proteggere ulteriormente l'integrità del sistema:

- **Source MAC:** Verifica che il MAC nell'header Ethernet coincida con il Sender MAC nel corpo del messaggio ARP.
- **Destination MAC:** Verifica che il MAC nell'header Ethernet coincida con il Target MAC nel corpo del messaggio ARP (per i reply).
- **IP Address:** Scarta pacchetti con IP sorgente/destinazione non validi (es. 0.0.0.0 o multicast).

---

## 🛠️ Implementazione Operativa (CLI)

> [!NOTE] [11:31](http://www.youtube.com/watch?v=HwbTKaIvL6s&t=691) Configurazione Globale e VLAN
>
>
> ```
> ! Abilitazione del DAI sulla VLAN specifica
> ip arp inspection vlan 1
> 
> ! Configurazione controlli addizionali (tutti in un unico comando)
> ip arp inspection validate src-mac dst-mac ip 
> 
> ! Automazione ripristino per violazioni di rate-limiting
> errdisable recovery cause arp-inspection
> ```

> [!NOTE] [12:05](http://www.youtube.com/watch?v=HwbTKaIvL6s&t=725) Configurazione Interfacce
>
>
> ```
> interface g0/0
>  ! Imposta la porta come Trusted (Uplink)
>  ip arp inspection trust
> 
> interface range f0/1 - 24
>  ! [00:14:10] Rate Limiting: Default 15 pps su untrusted
>  ip arp inspection limit rate 20 burst interval 2 
> ```

---

## 📋 Gestione Host Statici (ARP ACL) [▶ 19:08](http://www.youtube.com/watch?v=HwbTKaIvL6s&t=1148)

Se un host ha un IP statico, non sarà nel binding table e il DAI lo bloccherà. La soluzione è creare una "whitelist":

1. **Definizione ACL:** `arp access-list [NOME]`
2. **Permit:** `permit ip host [IP] mac host [MAC]`
3. **Applicazione:** `ip arp inspection filter [NOME] vlan [ID]`

---

## 🔍 Comandi di Verifica Strategica [▶ 20:56](http://www.youtube.com/watch?v=HwbTKaIvL6s&t=1256)

- `show ip arp inspection`: Riepilogo globale, stato VLAN e statistiche di drop.
- `show ip arp inspection interfaces`: Visualizza stato di trust e rate-limit per ogni porta.
- `show ip dhcp snooping binding`: Per verificare la "Source of Truth" usata dal DAI.

---

## 🎯 Synthesis
DAI confronta i pacchetti ARP con la binding table di DHCP Snooping e scarta quelli falsi (anti ARP spoofing).

---

> [!EXAMPLE] Laboratori Pratici
> - [[Day 51 Lab - Dynamic ARP Inspection.pkt]]
