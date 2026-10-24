---
tags: [ccna, exam]
priorita: molto-importante
stato: da-ripassare
---

> [!ABSTRACT] Core Logic
>
> [01:21](http://www.youtube.com/watch?v=qYYeg2kz1yE&t=81) Funzionalità di sicurezza Layer 2 che filtra i messaggi DHCP. Crea il **DHCP Snooping Binding Table**, un database fondamentale per prevenire attacchi di spoofing e alimentare protocolli successivi come DAI e IPSG.

## Segmentazione Interfacce

Il sistema divide le porte in due categorie logiche per mitigare i rischi di inserimento di nodi non autorizzati:

|Porta|Target Tipico|Comportamento DHCP|
|---|---|---|
|Trusted|Uplink (Router/Server)|Inoltra tutto; nessuna ispezione.|
|Untrusted|Porte Access (PC/Host)|Ispezione rigorosa; scarto pacchetti "Server-side".|

## Ispezione e Validazione (Esame Focus)

Lo switch applica controlli specifici sui messaggi ricevuti su porte **Untrusted** per prevenire l'estrazione illecita di indirizzi e il posizionamento di server rogue:

1. **Filtering dei Messaggi Server [06:21](http://www.youtube.com/watch?v=qYYeg2kz1yE&t=381):**
    - Scarto immediato di: `OFFER`, `ACK`, `NAK`. Impedisce a un attaccante di agire come autorità di assegnazione IP.
2. **Validazione Messaggi Client:**
    - **Discover / Request:** Verifica che `Source MAC` (Header L2) == `CHADDR` (Payload DHCP). Previene il **DHCP Starvation**.
    - **Release / Decline:** Verifica che `Source IP` + `Porta` corrispondano ai dati nel **Binding Table**. Previene DoS e spoofing di rilascio.

## Rate Limiting & Efficienza del Monitoraggio

Protegge le risorse computazionali dello switch (CPU) da flood di pacchetti DHCP che potrebbero causare instabilità sistemica.

- **Meccanismo:** Limita i pacchetti DHCP al secondo (pps) su una porta.
- **Violazione:** L'interfaccia viene posta in stato `err-disabled`.
- **Ripristino [16:16](http://www.youtube.com/watch?v=qYYeg2kz1yE&t=976):** Può essere automatizzato tramite `errdisable recovery` per ridurre l'attrito operativo.

## Binding Table (Source of Truth)

Database dinamico popolato durante il processo DORA. Campi essenziali:

- MAC Address, IP Address, Lease Time, VLAN, Interface.

> **Comando Verifica:** `show ip dhcp snooping binding`
> **Comando Verifica Interfacce:** `show ip dhcp snooping `

### Come si popola la Binding Table
1. **Stato iniziale:** appena configurato lo snooping, `show ip dhcp snooping binding` è **vuoto**: lo switch è "in ascolto" ma non ha ancora dati.
2. **Trigger (ciclo DORA):** la tabella si riempie solo quando i client sulle porte Untrusted fanno una richiesta DHCP.
   - *Discover/Request*: lo switch li analizza ma non scrive nulla.
   - *Offer*: verifica che arrivi da una porta **Trusted**.
   - **ACK** (momento chiave): lo switch legge IP assegnato e MAC del client e **scrive la riga**.
3. **Client già connessi:** chi aveva già un IP prima dell'attivazione **non appare** finché il lease non scade o non rinnova.

> [!CAUTION] Rischio operativo (lock-in)
> Se attivi il **DAI** prima che la tabella sia popolata, scolleghi di fatto tutti i client già connessi: lo switch non trova i loro MAC/IP e scarta i loro ARP come "non validi".

**Forzare il popolamento**
- *Lato client:* `ipconfig /release` + `ipconfig /renew` (Windows).
- *Lato switch:* `shutdown` / `no shutdown` sulle porte utente.
- *Host con IP statico:* non passano dal DORA → serve un binding statico (`ip dhcp snooping binding …`) o una ARP ACL per il DAI.

```
SW1# show ip dhcp snooping binding
MacAddress          IpAddress        Lease(sec)  Type           VLAN  Interface
------------------  ---------------  ----------  -------------  ----  --------------------
00:E0:4C:39:BA:01   192.168.10.15    86340       dhcp-snooping  10    FastEthernet0/1
```

## Implementazione Operativa (CLI)

> [!NOTE] Configurazione Globale e VLAN [12:44](http://www.youtube.com/watch?v=qYYeg2kz1yE&t=764)
>
> ```
> ! Inizializzazione globale
> ip dhcp snooping
>
> ! Attivazione sui segmenti target
> ip dhcp snooping vlan 1,10,20
> 
> ! Automazione del Ripristino
> errdisable recovery cause dhcp-rate-limit
>
> ! Riavvio automatico dopo 300s
> errdisable recovery interval 300
> ```

> [!NOTE] Configurazione Interfacce
>
> ```
> interface g0/1
>  ! Nodo di fiducia (Uplink)
>  ip dhcp snooping trust
> 
> interface range f0/1 - 24
>  ! Protezione CPU (Soglia pps)
>  ip dhcp snooping limit rate 15
> ```

## ⚠️ Troubleshooting: Option 82 [▶ 17:36](http://www.youtube.com/watch?v=qYYeg2kz1yE&t=1056)

- **Criticità:** Lo switch inserisce l'Option 82 di default. Se riceve pacchetti con questa opzione su porte untrusted o se il server non la supporta, il traffico viene scartato, generando un'interruzione del servizio (denial of service involontario).
- **Fix Strategico:** `no ip dhcp snooping information option` per disabilitare l'inserimento dell'opzione e garantire l'interoperabilità.

## 🎯 Synthesis
DHCP Snooping distingue porte trusted (server) e untrusted (client) e costruisce la binding table, che si popola solo con gli ACK DHCP (host statici e client già connessi vanno gestiti a parte).

---

> [!EXAMPLE] Laboratori Pratici
> - [[Day 50 Lab - DHCP Snooping.pkt]]
