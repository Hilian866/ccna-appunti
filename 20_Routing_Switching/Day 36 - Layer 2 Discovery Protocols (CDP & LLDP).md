

> [!ABSTRACT] Core Logic
> Analisi dei protocolli di **Layer 2 Discovery** (**CDP** e **LLDP**), strumenti fondamentali per l'amministratore di rete per scoprire e mappare i vicini direttamente connessi, identificando hostname, capacità e interfacce senza necessità di configurazione IP sui protocolli stessi.

### Introduzione ai Protocolli di Discovery
I protocolli di Layer 2 operano scambiando frame tra interfacce fisiche. Non sono instradabili (vengono scartati dai router) e servono a costruire una mappa della topologia fisica [01:46](https://youtu.be/_hnMZBzXRRk&t=106s).

> [!INFO] Definizione
> Questi protocolli condividono informazioni quali hostname, indirizzo IP di gestione, tipo di dispositivo (Router, Switch, etc.) e ID della porta locale e remota.

### Cisco Discovery Protocol (CDP)
Protocollo proprietario **Cisco**, abilitato di default su quasi tutti i dispositivi (Router, Switch, IP Phones).

- **MAC Destinazione:** Multicast `0100.0CCC.CCCC` [04:17](https://youtu.be/_hnMZBzXRRk&t=257s).
- **Versioni:** La **v2** è lo standard attuale e permette di rilevare mismatch di Native VLAN e Duplex [06:08](https://youtu.be/_hnMZBzXRRk&t=368s).
- **Configurazione Globale:** `cdp run` [14:54](https://youtu.be/_hnMZBzXRRk&t=894s).
- **Configurazione Interfaccia:** `cdp enable` [15:08](https://youtu.be/_hnMZBzXRRk&t=908s).

### Link Layer Discovery Protocol (LLDP)
Standard aperto **IEEE 802.1AB**, essenziale in ambienti multi-vendor (es. switch Cisco collegati a firewall Palo Alto).

- **MAC Destinazione:** Multicast `0180.C200.000E` [16:36](https://youtu.be/_hnMZBzXRRk&t=996s).
- **Stato Default:** Solitamente **disabilitato** su hardware Cisco [16:22](https://youtu.be/_hnMZBzXRRk&t=982s).
- **Configurazione Granulare:** A differenza di CDP, LLDP richiede l'abilitazione separata di trasmissione e ricezione sull'interfaccia [18:54](https://youtu.be/_hnMZBzXRRk&t=1134s):
	- `lldp transmit`
	- `lldp receive`

### Tabella di Confronto: CDP vs LLDP

| Caratteristica | CDP (Cisco) | LLDP (IEEE) |
| :--- | :--- | :--- |
| Standard | Proprietario | **IEEE 802.1AB** |
| Default Cisco | Abilitato | Disabilitato |
| Hello Timer | 60 Secondi [05:23](https://youtu.be/_hnMZBzXRRk&t=323s) | 30 Secondi [17:05](https://youtu.be/_hnMZBzXRRk&t=1025s) |
| Hold Timer | 180 Secondi | 120 Secondi |
| Config. Interfaccia | `cdp enable` | `lldp transmit` / `lldp receive` |
| Specificità | Rileva VTP, Native VLAN | Reinit Delay (2s) |

### Comandi Operativi (CLI)

```ios
! --- COMANDI CDP ---
R1# show cdp neighbors          ! Visione sintetica dei vicini [08:57]
R1# show cdp neighbors detail   ! Include IP e versione IOS [12:30]
R1# show cdp interface          ! Verifica timers e stato interfacce

! --- COMANDI LLDP ---
R1(config)# lldp run            ! Abilitazione globale
R1# show lldp neighbors         ! Visione sintetica standard
R1# show lldp traffic           ! Statistiche frame inviati/ricevuti
```

> [!CAUTION] Rischi per la Sicurezza
> Entrambi i protocolli condividono informazioni sensibili in chiaro. È **best practice** disabilitarli sulle interfacce rivolte verso reti esterne o dispositivi non fidati (es. porte utente) per evitare il **Network Reconnaissance** da parte di malintenzionati [03:01](https://youtu.be/_hnMZBzXRRk&t=181s).

### Interpretazione della Tabella Neighbors
Quando si esegue `show cdp neighbors`, le colonne chiave sono [09:16](https://youtu.be/_hnMZBzXRRk&t=556s):
1. **Local Intrfce**: La porta del dispositivo su cui sei loggato.
2. **Capability**: Codici (R=Router, S=Switch, S=Bridge).
3. **Port ID**: La porta fisica del dispositivo remoto a cui sei collegato.

> [!ABSTRACT] Recap Rapido
> Usa CDP se hai solo Cisco; usa LLDP se hai vendor misti. Disabilita sempre tutto ciò che non è necessario per la visibilità operativa.