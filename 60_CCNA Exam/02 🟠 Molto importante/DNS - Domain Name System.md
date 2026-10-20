---
tags: [ccna, exam]
priorita: molto-importante
stato: da-ripassare
---

## Obiettivo

Tradurre identificatori testuali leggibili dall'uomo (FQDN - Fully Qualified Domain Names) in indirizzi IP numerici, permettendo l'instradamento dei pacchetti senza che l'utente debba memorizzare variabili binarie complesse.

---

## 🏛️ Fondamentali e Protocolli

Il DNS è uno dei pochi servizi che utilizza entrambi i protocolli di trasporto sulla **porta 53**.

- **UDP Porta 53**: Utilizzata per le query standard. Priorità alla velocità e al basso overhead.
- **TCP Porta 53**: Utilizzata per risposte superiori a **512 byte** o per i _Zone Transfer_ (sincronizzazione tra database di diversi server).

### 🏷️ Tipi di Record (Exam Essentials)

|**Record**|**Funzione**|**Mapping**|
|---|---|---|
|**A**|Host Address|Nome $\rightarrow$ **IPv4**|
|**AAAA**|IPv6 Address|Nome $\rightarrow$ **IPv6**|
|**CNAME**|Canonical Name|Alias (Nome $\rightarrow$ Altro Nome)|
|**MX**|Mail Exchanger|Identifica i server di posta|
|**NS**|Name Server|Indica il server autoritativo per la zona|

---

## Gerarchia di Risoluzione Locale

Prima di uscire verso Internet, un host segue un ordine rigoroso. Conoscerlo è la chiave per il troubleshooting dei reindirizzamenti errati.

1. **DNS Cache Locale**: Memoria temporanea (RAM) delle query recenti.
2. **Hosts File**: Database testuale statico sul sistema operativo.
    - > [!WARNING] **Nota Strategica**: Il file _Hosts_ ha sempre la precedenza sul server DNS. Se un malware lo modifica, può dirottare il traffico.
3. **DNS Server**: Interrogazione esterna al server configurato via DHCP o manualmente.

---

## 🛠️ Il Router Cisco: I 3 Ruoli Operativi

### 1. DNS Client

Il router deve risolvere nomi per le proprie operazioni (es. `ping google.com` o download di firmware via FQDN).

```
! Abilita la risoluzione (Default)
ip domain-lookup

! Server di riferimento
ip name-server 8.8.8.8

! Appende il suffisso ai nomi brevi
ip domain-name lab.com
```

### 2. DNS Server (Autoritativo locale)

Il router risponde direttamente alle query della LAN per nomi definiti localmente.

```
! Attiva il demone server
ip dns server

! Record A statico nel database del router
ip host PC-ADMIN 192.168.1.50
```

### 3. DNS Forwarder

Il router riceve la query e la inoltra a un server esterno. È il ruolo più comune nelle piccole infrastrutture.

> [!TIP] **Anti-Lockout (Comando Salvavita)**
>
> `no ip domain-lookup`: Impedisce al router di bloccarsi per 30 secondi cercando di risolvere un comando digitato male (che interpreta come un nome host). **Essenziale in ogni Lab.**

---

## 🔍 Audit & Troubleshooting

### **Lato Host (Windows)**

- `nslookup [nome]`: Testa la risoluzione ignorando la cache.
- `ipconfig /displaydns`: Analizza cosa c'è nella memoria temporanea.
- `ipconfig /flushdns`: Svuota la cache (da fare sempre dopo aver cambiato un record A).

### **Lato Cisco IOS**

- `show hosts`: Mostra i mapping statici e la cache del router.
- `ping [nome]`: Il test più rapido per verificare il ruolo di "Client".

---

## ⚠️ Common Mistakes (Anatomy Check)

> [!CAUTION] **Attenzione ai trabocchetti**
>
> - **TCP vs UDP**: Se un quiz menziona la sicurezza o lo scambio di interi database tra server, la risposta è sempre **TCP 53**.
> - **IPv6 AAAA**: Non confonderlo con il record "A". Ricorda: 4 "A" per un indirizzo 4 volte più lungo (128 bit).
> - **Gateway**: Se il DNS è esterno (es. Google 8.8.8.8), la risoluzione fallirà se il routing verso l'esterno non è configurato, anche se il server DNS è "attivo".
>

---

## 🎯 Synthesis
DNS traduce nomi in IP (UDP 53, TCP per i trasferimenti); l'host interroga il resolver, che risolve ricorsivamente.

---

> [!EXAMPLE] Laboratorio Consigliato
> - [[Day 38 Lab - DNS.pkt]]
