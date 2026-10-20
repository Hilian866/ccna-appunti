

---
### 🧠 Core Logic
Analisi del protocollo **Syslog**, standard di settore per la messaggistica di log nei dispositivi di rete. La nota approfondisce la struttura dei messaggi, la classificazione per **Severity Levels** e la configurazione su sistemi **Cisco IOS** per il monitoraggio e il troubleshooting.

---

### 📝 Panoramica di Syslog
> [!ABSTRACT]
> **Syslog** è un protocollo utilizzato per generare messaggi relativi ad eventi specifici (cambi di stato interfacce, adiacenze **OSPF**, riavvii di sistema). I messaggi possono essere visualizzati in tempo reale, salvati localmente o inviati a un server esterno. [00:19](https://youtu.be/RaQPSKQ4J5A&t=19s)

### 📊 Formato del Messaggio Syslog
Il formato standard di un messaggio di log segue una struttura gerarchica precisa: [03:20](https://youtu.be/RaQPSKQ4J5A&t=200s)

```text
seq:time stamp: %facility-severity-MNEMONIC:description
```

| Campo | Descrizione |
| :--- | :--- |
| **Sequence Number** | Indica l'ordine dei messaggi (opzionale). |
| **Timestamp** | Data e ora esatta dell'evento (fondamentale con **NTP**). |
| **Facility** | Indica quale processo ha generato il messaggio (es. LINK, OSPF, SYS). |
| **Severity** | Numero da 0 a 7 che indica la gravità dell'evento. |
| **Mnemonic** | Codice breve identificativo dell'evento (es. UP DOWN). |
| **Description** | Testo dettagliato che spiega cosa è accaduto. |

---

### 🚦 Livelli di Gravità (Severity Levels)
È essenziale memorizzare i livelli per l'esame **CCNA**. Più basso è il numero, più critica è la situazione. [05:15](https://youtu.be/RaQPSKQ4J5A&t=315s)

| Livello | Keyword | Descrizione |
| :---: | :--- | :--- |
| **0** | **Emergency** | Sistema inutilizzabile. |
| **1** | **Alert** | Azione immediata necessaria. |
| **2** | **Critical** | Condizioni critiche. |
| **3** | **Error** | Condizioni di errore. |
| **4** | **Warning** | Messaggi di avviso. |
| **5** | **Notice** | Condizioni normali ma significative (**Notification**). |
| **6** | **Informational** | Messaggi informativi. |
| **7** | **Debugging** | Messaggi di debug (estremamente dettagliati). |

> [!INFO] **Mnemonic per la memoria**
> Per ricordare l'ordine (0-7): **E**mergencies **A**re **C**ritical **E**ven **W**hen **N**obody **I**s  **D**ead. 

---

### 📍 Destinazioni dei Log e Porte
I messaggi possono essere inviati a diverse locazioni: [10:20](https://youtu.be/RaQPSKQ4J5A&t=620s)

1.  **Console Line**: Visualizzazione diretta via cavo console (Abilitata di default).
2.  **VTY Lines**: Sessioni **Telnet** o **SSH** (Disabilitata di default).
3.  **Buffer (RAM)**: Salvataggio temporaneo nella memoria del dispositivo.
4.  **External Server**: Invio a un server Syslog remoto tramite la porta **UDP 514**. [12:16](https://youtu.be/RaQPSKQ4J5A&t=736s)

---

### 🛠️ Configurazione su Cisco IOS
Comandi principali per la gestione della messaggistica: [12:31](https://youtu.be/RaQPSKQ4J5A&t=751s)

```ios
! Abilita log verso un server esterno
R1(config)# logging 192.168.1.100

! Imposta il livello di gravità per il server (trap)
R1(config)# logging trap debugging

! Configura il logging nel buffer locale con dimensione specifica
R1(config)# logging buffered 8192 6

! Sincronizza l'output dei log con l'input dell'utente
R1(config-line)# logging synchronous
```

> [!CAUTION] **Terminal Monitor & Buffer**
> - Se sei connesso via SSH/Telnet, i log NON appaiono finché non digiti il comando `terminal monitor` in **Privileged EXEC mode**. Questo comando non è persistente dopo la disconnessione. [15:08](https://youtu.be/RaQPSKQ4J5A&t=908s)
> - Un buffer troppo grande può consumare eccessiva RAM, impattando sulle performance del device. [13:51](https://youtu.be/RaQPSKQ4J5A&t=831s)

---

### 🔄 Syslog vs SNMP
| Caratteristica | **Syslog** | **SNMP** |
| :--- | :--- | :--- |
| **Modello** | Principalmente **Push** (il device invia). | **Pull** (Get) e **Push** (Traps). |
| **Scopo** | Messaggi testuali di eventi. | Monitoraggio variabili (CPU, Temp, Traffico). |
| **Configurazione** | Semplice. | Complessa (richiede MIB e OID). |
| **Modifica Dati** | Sola lettura (log degli eventi). | Permette modifiche (SNMP Set). |

[18:30](https://youtu.be/RaQPSKQ4J5A&t=1110s)