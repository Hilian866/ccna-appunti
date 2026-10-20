Questa nota tecnica è ottimizzata per **Obsidian**, utilizzando una struttura modulare, callout tematici e link diretti ai momenti chiave del video per la preparazione all'esame **Cisco CCNA 200-301**.

---
## 🧠 Core Logic
Il **Simple Network Management Protocol (SNMP)** è un framework industry-standard utilizzato per monitorare la salute dei dispositivi di rete, raccogliere statistiche e modificare configurazioni da una postazione centralizzata (**NMS**), minimizzando l'intervento manuale su ogni singolo nodo.

---
## 🏗️ Architettura e Componenti [06:26](https://youtu.be/HXu0Ifj0oWU&t=386s)

L'ecosistema SNMP si divide in due entità principali:

1.  **NMS (Network Management Station)**: Il "Server" che esegue l'applicazione di monitoraggio. Ospita l'**SNMP Manager**.
2.  **Managed Device**: Il dispositivo di rete (Router, Switch, Firewall) che ospita l'**SNMP Agent**.

### 🗄️ Struttura Dati: MIB e OID
Per organizzare le informazioni, SNMP utilizza un database gerarchico:
*   **MIB (Management Information Base)**: La struttura che contiene tutte le variabili gestibili del dispositivo [08:13](https://youtu.be/HXu0Ifj0oWU&t=493s).
*   **OID (Object Identifier)**: Un indirizzo numerico univoco che punta a una specifica variabile (es. `.1.3.6.1.2.1.1.5` per il *SysName*) [09:05](https://youtu.be/HXu0Ifj0oWU&t=545s).

> [!INFO] Definizione Agent
> L'**SNMP Agent** è il software che gira sul dispositivo gestito. Il suo compito è rispondere alle query del Manager e inviare notifiche proattive in caso di eventi critici.

---
## 📊 Confronto Versioni SNMP [09:59](https://www.youtube.com/watch?t=599s&v=R9Icl0l5mRE)

Esistono tre iterazioni principali del protocollo. La scelta della versione impatta drasticamente sulla sicurezza e l'efficienza.

| Caratteristica | SNMPv1 | SNMPv2c | SNMPv3 |
| :--- | :--- | :--- | :--- |
| **Sicurezza** | Community String (Cleartext) | Community String (Cleartext) | **User-based (USM)** |
| **Crittografia** | No | No | **Sì (AES/DES)** |
| **Autenticazione** | No | No | **Sì (SHA/MD5)** |
| **Efficienza** | Bassa | Alta (GetBulk) | Alta |

> [!CAUTION] Rischio Cleartext
> In **v1** e **v2c**, la password (**Community String**) viaggia in chiaro nel pacchetto. Chiunque catturi il traffico con Wireshark può leggere la stringa e potenzialmente modificare la configurazione del dispositivo [19:55](https://youtu.be/HXu0Ifj0oWU&t=1195s).

---
## 📨 Messaggi e Operazioni [11:31](https://youtu.be/HXu0Ifj0oWU&t=691s)

SNMP opera attraverso classi di messaggi specifiche per leggere, scrivere o notificare.

### 1. Operazioni di Lettura (Read)
*   **Get**: Richiede il valore di un OID specifico.
*   **GetNext**: Percorre l'albero MIB per trovare la variabile successiva.
*   **GetBulk** (v2c/v3): Recupera grandi set di dati in un'unica transazione.

### 2. Operazioni di Scrittura (Write)
*   **Set**: Utilizzato dall'NMS per cambiare impostazioni (es. cambiare l'indirizzo IP di un'interfaccia) [13:16](https://youtu.be/HXu0Ifj0oWU&t=796s).

### 3. Notifiche (Managed Device -> NMS)
*   **Trap**: Messaggio non confermato. Il dispositivo lo invia e non sa se l'NMS lo riceve (**Unreliable**) [14:30](https://youtu.be/HXu0Ifj0oWU&t=870s).
*   **Inform**: Messaggio confermato. L'NMS deve rispondere con un *Acknowledgement* (**Reliable**) [15:25](https://youtu.be/HXu0Ifj0oWU&t=925s).

---
## 🔌 Porte e Protocolli di Trasporto

SNMP utilizza il protocollo **UDP** per massimizzare la velocità e ridurre l'overhead.

> [!ABSTRACT] Quick Reference Porte
> *   **UDP 161**: Utilizzato dall'**Agent** per ricevere richieste dal Manager.
> *   **UDP 162**: Utilizzato dall'**NMS** per ricevere Trap e Inform dai dispositivi [16:33](https://youtu.be/HXu0Ifj0oWU&t=993s).

---
## 🛠️ Configurazione Base (v2c) [16:51](https://youtu.be/HXu0Ifj0oWU&t=1011s)

Esempio di configurazione su un Router Cisco per abilitare l'accesso in lettura/scrittura e l'invio di trap.

```ios
! Configurazione delle Community Strings (Password)
Router(config)# snmp-server community PUBLIC ro  ! Read-Only
Router(config)# snmp-server community PRIVATE rw ! Read-Write

! Informazioni opzionali sul dispositivo
Router(config)# snmp-server contact admin@network.it
Router(config)# snmp-server location DataCenter_Rack1

! Configurazione dell'NMS di destinazione per le Trap
Router(config)# snmp-server host 192.168.1.10 version 2c PUBLIC

! Abilitazione globale delle Trap (es. Link Up/Down)
Router(config)# snmp-server enable traps
```

---
## 📝 Riepilogo per l'Esame
*   **SNMPv3** è l'unica versione sicura per reti di produzione.
*   **Trap** = UDP 162, **Get/Set** = UDP 161.
*   **MIB** è il database, **OID** è la chiave dell'informazione.
*   **Inform** è più affidabile di **Trap** perché richiede conferma.