---
tags: [ccna, exam]
priorita: molto-importante
stato: da-ripassare
---

## Obiettivo

Automatizzare la distribuzione dei parametri IP (Indirizzo, Maschera, Gateway, DNS) per eliminare l'errore umano e prevenire conflitti di indirizzamento in reti con alta densità di nodi dinamici.

## I 4 Pilastri: Il Processo DORA

Il client e il server interagiscono attraverso una sequenza specifica di quattro messaggi.

|Fase|Messaggio|Tipo|Scopo Strategico|
|---|---|---|---|
|1|**D**iscover|Broadcast|Il client cerca un server DHCP attivo.|
|2|**O**ffer|Unicast/Broadcast|Il server propone un IP e i parametri di rete.|
|3|**R**equest|**Broadcast**|Il client accetta l'offerta e avvisa gli altri server.|
|4|**A**cknowledgment|Unicast/Broadcast|Il server conferma la locazione (Lease).|

> [!IMPORTANT] Focus Esame: Perché la Request è Broadcast?
>
> Serve a notificare formalmente a tutti gli altri server DHCP presenti sul link che il client ha scelto un'offerta specifica, permettendo loro di rimettere nel pool gli indirizzi che avevano temporaneamente riservato.

## DHCP Relay: Superare i Confini L3

I router non inoltrano i broadcast. Senza un Relay Agent, il DHCP funzionerebbe solo all'interno della singola subnet/VLAN.

### Il comando `ip helper-address`

- **Funzionamento**: Converte il pacchetto _Discover_ (Broadcast) in un pacchetto **Unicast** indirizzato all'IP del server.
- **Posizionamento**: Va configurato sull'interfaccia del router **più vicina al client** (Gateway).
- **Meccanica Giaddr**: Il router inserisce il proprio IP nel campo _Giaddr_ del pacchetto; il server legge questo campo per capire da quale **pool** specifico deve pescare l'indirizzo IP.

## Protocollo di Configurazione Cisco IOS

> [!DANGER] Regola d'Oro: Escludi prima di creare
>
> Configura sempre gli IP statici (Gateway, Server) come esclusioni **prima** di attivare il pool, per prevenire conflitti immediati.

```
! 1. Esclusioni (IP per infrastruttura)
ip dhcp excluded-address 192.168.1.1 192.168.1.10

! 2. Creazione Pool
ip dhcp pool VLAN10_POOL
 network 192.168.1.0 255.255.255.0
 default-router 192.168.1.1      ! Indirizzo del Gateway
 dns-server 8.8.8.8
 domain-name lab.com
 lease 0 8 0                     ! Giorni Ore Minuti
```
[21:35](https://youtu.be/hzkleGAC2_Y?t=1295)

## ⚠️ Common Mistakes (Anatomy Check)

> [!CAUTION] Errori Fatali
>
> - **Lease Timeout:** In reti ad alta rotazione (es. Guest Wi-Fi), lease troppo lunghe portano all'**esaurimento del pool**.
> - **Helper-address mancante:** Se il server è centralizzato (es. in una VLAN "Management"), dimenticare l'helper sulle SVI delle VLAN utenti blocca l'accesso a tutta la rete.
> - **Porte UDP:** Server = **67**, Client = **68**. Essenziale per le regole ACL o Firewall.
>

## Audit & Troubleshooting

- `show ip dhcp binding`: Mostra le associazioni **IP <-> MAC**. È la tabella principale per verificare chi è online.
- `show ip dhcp pool`: Indica quanti IP sono rimasti liberi.
- `show ip dhcp conflict`: Se vedi entry qui, qualcuno ha configurato un IP statico che appartiene al pool DHCP.

## 🎯 Synthesis

Il DHCP trasforma la gestione della rete da un'attività manuale a un servizio sistemico. La comprensione del processo **DORA** e l'uso corretto dell'**Helper-Address** sono i due nodi centrali per garantire la connettività nelle architetture Enterprise.

---

> [!EXAMPLE] Laboratori Pratici
> - [[Day 39 Lab - DHCP.pkt]]
