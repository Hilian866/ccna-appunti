---
tags: [ccna, exam]
priorita: molto-importante
stato: da-ripassare
---

> [!ABSTRACT] Cosa serve per l'esame
> Blueprint **5.7**: configurare e verificare le funzioni di sicurezza Layer 2 (DHCP snooping, DAI, port security).
> Devi sapere quale attacco ferma DAI, con cosa confronta gli ARP, come si comportano porte trusted e untrusted, il rate limit di default e come si gestiscono gli host con IP statico. DAI si appoggia alla binding table di [[DHCP Snooping]]; ARP è spiegato in [[Switching Concepts (MAC Table, ARP)]].

## 1. L'attacco: ARP poisoning

ARP traduce un IP nel MAC corrispondente, dentro la LAN. Non ha autenticazione: un host accetta anche le risposte che non ha chiesto (**gratuitous ARP**, inviate in broadcast).

1. L'attaccante manda un gratuitous ARP che dice "l'IP del gateway (192.168.1.1) è al **mio** MAC".
2. I PC aggiornano la loro tabella ARP e mandano all'attaccante il traffico destinato al gateway.
3. L'attaccante legge o modifica il traffico e poi lo inoltra al gateway vero: nessuno se ne accorge (**man-in-the-middle**).

Un messaggio ARP contiene quattro campi utili: **sender IP, sender MAC, target IP, target MAC**.

## 2. Come funziona DAI

DAI ispeziona **solo i messaggi ARP**, e solo sulle porte **untrusted**.

| Porta | Dove | Cosa fa lo switch |
| :--- | :--- | :--- |
| **Trusted** | uplink verso altri switch e router | inoltra gli ARP senza controlli |
| **Untrusted** | porte verso gli host | confronta ogni ARP con la fonte attendibile |

Quando attivi DAI su una VLAN, **tutte le porte sono untrusted**.

Su una porta untrusted, lo switch prende **sender IP + sender MAC** del messaggio ARP e cerca una corrispondenza:

1. nella **binding table di DHCP snooping** (il caso normale: per questo DAI di solito richiede DHCP snooping);
2. in una **ARP ACL**, per gli host con IP statico.

Se la coppia c'è, l'ARP passa; altrimenti viene **scartato**. Nell'esempio sopra la binding table dice che 192.168.1.1 non sta sul MAC dell'attaccante: l'ARP falso non arriva a nessuno.

## 3. Controlli aggiuntivi

Si possono attivare tre controlli in più:

| Opzione | Controllo |
| :--- | :--- |
| `src-mac` | MAC sorgente del frame Ethernet = **sender MAC** dell'ARP |
| `dst-mac` | MAC destinazione del frame Ethernet = **target MAC** dell'ARP (nelle risposte) |
| `ip` | niente IP non validi, come `0.0.0.0`, broadcast o multicast |

Vanno scritti in **un solo comando**: ogni `ip arp inspection validate` sostituisce il precedente, quindi con due comandi separati resta attivo solo l'ultimo. Un ARP deve superare tutti i controlli attivi.

## 4. Rate limit

Limita gli ARP ricevuti su una porta; oltre il limite la porta va in **err-disabled**.

| | DAI | DHCP snooping |
| :--- | :--- | :--- |
| Rate limit di default | **attivo**, 15 pacchetti/s, sulle porte untrusted | nessuno |
| Sulle porte trusted | disattivato | — |
| Intervallo | si può dare un **burst interval** (X pacchetti in Y secondi) | solo pacchetti al secondo |

Riattivazione: `shutdown` e `no shutdown`, oppure `errdisable recovery cause arp-inspection`.

## 5. Configurazione e verifica

```ios
! Attiva DAI sulla VLAN (tutte le porte diventano untrusted)
SW1(config)# ip arp inspection vlan 10

! Controlli aggiuntivi: tutti nello stesso comando
SW1(config)# ip arp inspection validate src-mac dst-mac ip

! Uplink verso router e altri switch
SW1(config)# interface g0/1
SW1(config-if)# ip arp inspection trust

! Porte verso gli host: 25 ARP ogni 2 secondi (il default è 15 al secondo)
SW1(config)# interface range f0/1 - 24
SW1(config-if-range)# ip arp inspection limit rate 25 burst interval 2

! Riattivazione automatica delle porte err-disabled
SW1(config)# errdisable recovery cause arp-inspection
```

Per un host con IP statico (es. un server) si crea un'ARP ACL e la si applica alla VLAN:

```ios
SW1(config)# arp access-list SERVER-STATICI
SW1(config-arp-nacl)# permit ip host 192.168.10.100 mac host 0011.2233.4455
SW1(config-arp-nacl)# exit
SW1(config)# ip arp inspection filter SERVER-STATICI vlan 10
```

```ios
! VLAN con DAI, controlli attivi, ARP inoltrati e scartati
SW1# show ip arp inspection

! Per ogni porta: trusted/untrusted e rate limit
SW1# show ip arp inspection interfaces

! La fonte usata per i controlli
SW1# show ip dhcp snooping binding
```

## ⚠️ Trappole d'esame

> [!WARNING] Gli errori più frequenti
> 1. **DAI senza DHCP snooping**: la binding table è vuota e tutti gli ARP sulle porte untrusted vengono scartati (salvo ARP ACL).
> 2. **Host con IP statico**: non sono nella binding table, serve un'ARP ACL.
> 3. **Più comandi `validate`**: resta solo l'ultimo.
> 4. **Rate limit**: DAI lo ha di default (15 pacchetti/s), DHCP snooping no.
> 5. **Uplink untrusted**: gli ARP del router vengono controllati e, se non sono nella tabella, scartati.

## Esercizi

> [!QUESTION]- Un PC su una porta untrusted manda un ARP che dice "192.168.10.1 è a aaaa.bbbb.cccc". Nella binding table 192.168.10.1 non c'è. Cosa succede?
> L'ARP viene scartato: nessuna corrispondenza tra sender IP e sender MAC.

> [!QUESTION]- Hai scritto `ip arp inspection validate src-mac` e poi `ip arp inspection validate ip`. Quali controlli sono attivi?
> Solo `ip`: il secondo comando ha sostituito il primo. Serve `ip arp inspection validate src-mac ip`.

> [!QUESTION]- Una porta untrusted riceve 30 ARP in un secondo, senza configurazioni di rate limit. Cosa succede?
> Supera il default di 15 pacchetti/s e va in err-disabled.

> [!QUESTION]- La stampante 192.168.10.50 ha IP statico e dopo l'attivazione di DAI non comunica più. Come la sblocchi?
> Con un'ARP ACL che permetta la sua coppia IP-MAC, applicata con `ip arp inspection filter <nome> vlan 10`.

## Check da esame

- [ ] Attacco fermato da DAI? **ARP poisoning (man-in-the-middle)**.
- [ ] Campi confrontati? **Sender IP e sender MAC**.
- [ ] Con cosa? **Binding table di DHCP snooping, o ARP ACL**.
- [ ] Stato di default delle porte? **Untrusted**.
- [ ] Rate limit di default? **15 pacchetti/s sulle porte untrusted**.
- [ ] Come si attivano più controlli aggiuntivi? **In un solo comando `validate`**.

## 🎯 Synthesis

DAI blocca l'ARP poisoning: sulle porte untrusted (il default) confronta sender IP e sender MAC di ogni ARP con la binding table di DHCP snooping o con un'ARP ACL, e scarta quelli che non corrispondono. Le porte trusted (uplink) non vengono controllate. Ha un rate limit di default di 15 pacchetti/s, e i controlli aggiuntivi vanno in un solo comando.

> [!EXAMPLE] Laboratori pratici
> - [[Day 51 Lab - Dynamic ARP Inspection.pkt]]
