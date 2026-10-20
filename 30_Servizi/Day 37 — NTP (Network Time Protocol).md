> [!ABSTRACT] Core Logic
> L'obiettivo di questa sessione è comprendere, configurare e verificare il protocollo **NTP** per garantire la sincronizzazione temporale accurata tra i dispositivi di rete. Questo è fondamentale per la coerenza dei log di **Syslog**, il troubleshooting e il corretto funzionamento dei certificati digitali.

---

### 🕒 L'Importanza del Tempo nella Rete
Tutti i dispositivi hanno un clock interno, ma l'accuratezza del tempo è cruciale per correlare gli eventi tra diversi apparati.

*   **Comando di base**: Per visualizzare l'ora corrente, usa `show clock` [01:59](https://youtu.be/qGJaJx7OfUo&t=119s).
*   **Problematica**: Se i clock non sono sincronizzati, i messaggi di **Syslog** [03:36](https://youtu.be/qGJaJx7OfUo&t=216s) risulteranno inutili per il troubleshooting poiché mostreranno timestamp incoerenti tra loro.

> [!INFO] UTC (Coordinated Universal Time)
> Di default, i dispositivi Cisco utilizzano il fuso orario **UTC** [02:18](https://youtu.be/qGJaJx7OfUo&t=138s). È responsabilità dell'amministratore configurare il corretto offset del fuso orario locale.

---

### 🛠️ Configurazione Manuale (Non Scalabile)
Sebbene sia possibile impostare l'ora manualmente, i clock interni tendono a "driftare" (perdere accuratezza) nel tempo.

*   **Software Clock**: Configurato con `clock set` [05:41](https://youtu.be/qGJaJx7OfUo&t=341s).
*   **Hardware Clock (Calendar)**: Gestito con `calendar set` [07:08](https://youtu.be/qGJaJx7OfUo&t=428s).
*   **Sincronizzazione**: Per allineare il calendario hardware al clock di sistema, usa `clock update-calendar` [07:33](https://youtu.be/qGJaJx7OfUo&t=453s).

---

### 🕸️ Fondamenti di NTP
**NTP** utilizza il protocollo **UDP** sulla porta **123** [16:03](https://youtu.be/qGJaJx7OfUo&t=963s) per sincronizzare il tempo tra client e server.

#### Gerarchia Stratum
Il concetto di **Stratum** definisce la "distanza" dalla sorgente temporale originale.

| Livello Stratum | Descrizione | Accuratezza |
| :--- | :--- | :--- |
| **Stratum 0** | Orologi atomici, ricevitori GPS (Reference Clocks). | Massima |
| **Stratum 1** | Server direttamente connessi a Stratum 0. | Altissima |
| **Stratum 2** | Client che ricevono il tempo da server Stratum 1. | Alta |
| **Stratum 15** | Limite massimo di sincronizzazione utilizzabile. | Bassa |

> [!CAUTION] Stratum 16
> Uno **Stratum 16** [17:25](https://youtu.be/qGJaJx7OfUo&t=1045s) indica che il tempo è considerato non sincronizzato e inaffidabile; i dispositivi non si sincronizzeranno con questa sorgente.

---

### ⚙️ Configurazione e Modalità Operative
I router Cisco possono operare in diverse modalità contemporaneamente.

1.  **Client Mode**: Il dispositivo richiede il tempo a un server.
    ```ios
    R1(config)# ntp server 216.239.35.0 [19:56]
    ```
2.  **Server Mode**: Il dispositivo serve il tempo ad altri client. Se non ha un server esterno, può agire come master.
    ```ios
    R1(config)# ntp master 8 [29:00]
    ```
3.  **Symmetric Active Mode (Peer)**: Due dispositivi si scambiano il tempo a vicenda per backup.
    ```ios
    R1(config)# ntp peer 10.0.0.2 [30:42]
    ```

#### Verifica dello stato
*   `show ntp associations`: Mostra i server con cui il router sta comunicando [20:49](https://youtu.be/qGJaJx7OfUo&t=1249s). L'asterisco (`*`) indica il server attualmente scelto come sorgente.
*   `show ntp status`: Conferma se il clock è sincronizzato e indica il proprio livello stratum [22:29](https://youtu.be/qGJaJx7OfUo&t=1349s).

---

### 🔐 Autenticazione NTP
Per prevenire attacchi di tipo *time-spoofing*, è possibile configurare l'autenticazione tramite hash **MD5**.

```ios
R1(config)# ntp authenticate
R1(config)# ntp authentication-key 1 md5 jeremysitlab
R1(config)# ntp trusted-key 1
R1(config)# ntp server 10.0.12.1 key 1 [31:34]
```

> [!INFO] Best Practice: Loopback Interface
> È consigliato usare un'interfaccia **Loopback** come sorgente per i pacchetti NTP per garantire che la sincronizzazione non dipenda dallo stato di una singola interfaccia fisica.
> `ntp source loopback 0` [24:48](https://youtu.be/qGJaJx7OfUo&t=1488s).