---
tags: [ccna, exam]
priorita: medio
stato: da-ripassare
---

> [!ABSTRACT] Cosa serve per l'esame
> Blueprint **5.7**: configurare e verificare le funzioni di sicurezza Layer 2 (DHCP snooping, DAI, port security).
> Devi sapere cosa limita port security, i valori di default, le tre modalità di violazione e le loro differenze, i tipi di MAC sicuri (statici, dinamici, sticky), l'aging e come si riattiva una porta err-disabled. Le altre due protezioni: [[DHCP Snooping]] e [[DAI (Dynamic ARP Inspection)]].

## 1. A cosa serve

Port security limita **quanti** e **quali** MAC sorgente possono usare una porta dello switch. Serve a:

- impedire che qualcuno colleghi un dispositivo non autorizzato a una presa;
- fermare il **MAC flooding**: l'attaccante manda frame con migliaia di MAC falsi per riempire la tabella MAC, e lo switch inonda i frame su tutte le porte (dove l'attaccante li legge);
- limitare la **DHCP starvation**, che usa MAC falsi.

Se arriva un frame con un MAC non permesso, o oltre il numero massimo, c'è una **violazione**.

## 2. I default

| Impostazione | Default |
| :--- | :--- |
| MAC permessi | **1** |
| Modalità di violazione | **shutdown** |
| MAC sicuri | **dinamici**: il primo MAC visto viene permesso |
| Aging | **disattivato** (tempo 0) |

Port security funziona solo su porte **access** o **trunk** configurate a mano: non su una porta in modalità dinamica (DTP, `dynamic auto` o `desirable`). Su una porta lasciata nella modalità di default, `switchport port-security` viene rifiutato.

## 3. Modalità di violazione

| | **Shutdown** (default) | **Restrict** | **Protect** |
| :--- | :--- | :--- | :--- |
| Porta | **err-disabled** (spenta) | resta su | resta su |
| Frame non permessi | tutto il traffico si ferma | scartati | scartati |
| Frame permessi | si ferma anche quello | passano | passano |
| Messaggio syslog/SNMP | uno | **uno per ogni violazione** | **nessuno** |
| Contatore delle violazioni | va a 1 | aumenta | **non aumenta** |

Il modo per ricordarle: shutdown spegne, restrict scarta e avvisa, protect scarta in silenzio.

Riattivare una porta err-disabled:

- a mano: togliere la causa, poi **`shutdown`** e **`no shutdown`** (solo `no shutdown` non basta);
- in automatico: `errdisable recovery cause psecure-violation` (dopo 300 s di default).

## 4. Tipi di MAC sicuri

| Tipo | Come si ottiene | Dopo un riavvio |
| :--- | :--- | :--- |
| **Statico** | scritto a mano: `switchport port-security mac-address <MAC>` | resta, se la config è salvata |
| **Dinamico** | imparato dal traffico | **perso** (anche quando la porta va giù) |
| **Sticky** | imparato dal traffico e **scritto nella running-config** | resta, **solo se** salvi la config (`copy running-config startup-config`) |

Sticky unisce i due vantaggi: non devi scrivere i MAC, ma restano dopo un riavvio. Attivando sticky, i MAC dinamici già imparati diventano sticky.

## 5. Aging

L'aging decide quando un MAC sicuro viene rimosso, per far posto a un altro dispositivo.

- Di default è **spento** (tempo 0): un MAC imparato resta finché la porta non va giù.
- `aging time <minuti>` lo attiva.
- Tipo **absolute** (default): il MAC scade allo scadere del tempo, anche se il dispositivo trasmette.
- Tipo **inactivity**: il tempo riparte a ogni frame; scade solo se il dispositivo resta in silenzio.
- L'aging vale solo per i MAC **dinamici**. Per gli statici serve `aging static`; gli sticky non scadono.

## 6. Configurazione

```ios
! La porta deve essere access (o trunk) configurata a mano
SW1(config)# interface g0/1
SW1(config-if)# switchport mode access
SW1(config-if)# switchport port-security

! Fino a 2 MAC (es. telefono IP e PC dietro di esso)
SW1(config-if)# switchport port-security maximum 2

! Impara i MAC e li scrive nella running-config
SW1(config-if)# switchport port-security mac-address sticky

! Oppure un MAC statico
SW1(config-if)# switchport port-security mac-address 0011.2233.4455

! Modalità di violazione
SW1(config-if)# switchport port-security violation restrict

! Aging: 60 minuti di inattività
SW1(config-if)# switchport port-security aging time 60
SW1(config-if)# switchport port-security aging type inactivity

! Riattivazione automatica delle porte spente da port security
SW1(config)# errdisable recovery cause psecure-violation
SW1(config)# errdisable recovery interval 300
```

## 7. Verifica

```ios
SW1# show port-security interface g0/1
Port Security              : Enabled
Port Status                : Secure-shutdown
Violation Mode             : Shutdown
Aging Time                 : 0 mins
Aging Type                 : Absolute
SecureStatic Address Aging : Disabled
Maximum MAC Addresses      : 1
Total MAC Addresses        : 1
Configured MAC Addresses   : 0
Sticky MAC Addresses       : 0
Last Source Address:Vlan   : 0050.7966.6801:1
Security Violation Count   : 1
```

- **Port Status: Secure-shutdown**: la porta è err-disabled per una violazione (con una porta funzionante si legge Secure-up).
- **Last Source Address**: il MAC che ha causato la violazione.
- **Security Violation Count: 1**: in modalità shutdown il contatore si ferma a 1.

```ios
! Riepilogo di tutte le porte: massimo, MAC attuali, violazioni, azione
SW1# show port-security

! Solo i MAC sicuri
SW1# show port-security address

! Porte spente e causa (psecure-violation)
SW1# show interfaces status err-disabled
```

## ⚠️ Trappole d'esame

> [!WARNING] Gli errori più frequenti
> 1. **Restrict e protect**: entrambi scartano; restrict manda log e aumenta il contatore, protect no.
> 2. **Riattivazione**: `shutdown` e poi `no shutdown`, non solo `no shutdown`.
> 3. **Porta in modalità dinamica**: port security non si attiva. Prima `switchport mode access`.
> 4. **Sticky senza salvataggio**: dopo un riavvio i MAC vanno reimparati.
> 5. **Default**: 1 MAC, shutdown, aging spento.
> 6. **Aging di default**: absolute, non inactivity.

## Esercizi

> [!QUESTION]- Una porta ha i default di port security. Un utente scollega il PC e collega il portatile. Cosa succede?
> Il MAC nuovo supera il massimo di 1 (il primo MAC è già stato imparato): la porta va in err-disabled.

> [!QUESTION]- Vuoi che i frame non autorizzati vengano scartati, la porta resti attiva e ogni violazione venga registrata. Che modalità?
> Restrict.

> [!QUESTION]- `show port-security interface` mostra Secure-shutdown e Violation Count 1. Come riattivi la porta?
> Togli il dispositivo non autorizzato, poi `shutdown` e `no shutdown` sull'interfaccia (o aspetti l'errdisable recovery, se configurato).

> [!QUESTION]- Hai usato sticky, lo switch si riavvia e i MAC sono spariti. Perché?
> La running-config non era stata salvata nella startup-config.

## Check da esame

- [ ] MAC permessi di default? **1**.
- [ ] Modalità di violazione di default? **Shutdown**.
- [ ] Modalità che non manda log e non conta le violazioni? **Protect**.
- [ ] Tipo di MAC imparato e scritto nella running-config? **Sticky**.
- [ ] Aging di default? **Spento (0); tipo absolute**.
- [ ] Causa da usare in errdisable recovery? **`psecure-violation`**.

## 🎯 Synthesis

Port security limita quanti e quali MAC usano una porta (di default 1, il primo visto). In violazione: shutdown (il default, err-disabled), restrict (scarta e registra) o protect (scarta in silenzio). I MAC sicuri possono essere statici, dinamici o sticky (imparati e scritti nella config, da salvare). La porta deve essere access o trunk configurata a mano; da err-disabled si esce con `shutdown` e `no shutdown` o con errdisable recovery.

> [!EXAMPLE] Laboratori pratici
> - [[Day 49 Lab - Port Security.pkt]]
