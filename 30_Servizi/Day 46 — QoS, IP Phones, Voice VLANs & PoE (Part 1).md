 >[!ABSTRACT]  Core Logic
Il video introduce i concetti fondamentali di **Quality of Service (QoS)**, **Power over Ethernet (PoE)** e **Voice VLAN**. L'obiettivo è comprendere come gestire reti convergenti dove traffico voce, video e dati devono coesistere sullo stesso medium fisico senza degradazione delle performance.

---

### 📞 IP Phones & Voice VLAN
I telefoni IP moderni non richiedono una porta dedicata sullo switch grazie a un design a **switch interno a 3 porte** [03:09](https://youtu.be/H6FKJMiiL6E&t=189s).

*   **Porta 1:** Uplink verso lo switch fisico.
*   **Porta 2:** Downlink verso il PC dell'utente.
*   **Porta 3:** Connessione interna al telefono stesso.

> [!INFO] Definizione: Voice VLAN
> È una VLAN dedicata esclusivamente al traffico voce. Permette di separare logicamente il traffico audio dai dati del PC per applicare politiche di **QoS** specifiche [04:18](https://youtu.be/H6FKJMiiL6E&t=258s).

![[Screenshot_1 14.png]]
**Configurazione Rapida:**
```ios
interface gigabitethernet0/0
 switchport mode access
 switchport access vlan 10      ! VLAN per i Dati (Untagged)
 switchport voice vlan 11      ! VLAN per la Voce (Tagged via CDP)
```

---

### ⚡ Power over Ethernet (PoE)
Il protocollo **PoE** permette allo switch di alimentare i dispositivi finali (PD) tramite il cavo Ethernet, eliminando la necessità di alimentatori esterni [08:07](https://youtu.be/H6FKJMiiL6E&t=487s).

| Ruolo | Acronimo | Descrizione |
| :--- | :--- | :--- |
| **Power Sourcing Equipment** | **PSE** | Il dispositivo che fornisce energia (solitamente lo Switch). |
| **Powered Device** | **PD** | Il dispositivo che riceve energia (IP Phone, AP, Camera). |

#### Tabella Standard PoE [12:27](https://youtu.be/H6FKJMiiL6E&t=747s)
| Nome | Standard | Potenza Max (Watt) | Coppie di fili usate |
| :--- | :--- | :--- | :--- |
| PoE (Type 1) | 802.3af | 15.4W | 2 |
| PoE+ (Type 2) | 802.3at | 30W | 2 |
| UPoE (Type 3) | 802.3bt | 60W | 4 |
| UPoE+ (Type 4) | 802.3bt | 100W | 4 |

> [!CAUTION] Power Policing
> Se un dispositivo (PD) assorbe più energia di quella negoziata, lo switch può mettere la porta in stato **err-disabled** per proteggere i circuiti interni [10:04](https://youtu.be/H6FKJMiiL6E&t=604s).

---

### 📊 Fondamenti di Quality of Service (QoS)
Nelle **Converged Networks**, diverse tipologie di traffico competono per la stessa **Bandwidth** [15:34](https://youtu.be/H6FKJMiiL6E&t=934s). La QoS gestisce quattro caratteristiche chiave [16:40](https://youtu.be/H6FKJMiiL6E&t=1000s):

1.  **Bandwidth:** Capacità totale del link (bps).
2.  **Delay (Latenza):** Tempo impiegato da un pacchetto per andare dalla sorgente alla destinazione.
3.  **Jitter:** Variazione nel ritardo di ricezione dei pacchetti.
4.  **Loss (Packet Loss):** Percentuale di pacchetti che non raggiungono la destinazione.

#### Standard per Audio Interattivo (VoIP) [18:55](https://youtu.be/H6FKJMiiL6E&t=1135s)
Per garantire una chiamata fluida, la rete deve rispettare questi parametri:
*   **One-way Delay:** ≤ 150 ms
*   **Jitter:** ≤ 30 ms
*   **Packet Loss:** ≤ 1%

---

### 🧪 Gestione delle Code (Queuing)
Quando uno switch riceve pacchetti più velocemente di quanto possa trasmetterli, li inserisce in una **Queue**.

*   **FIFO (First-In, First-Out):** I pacchetti sono inviati nell'ordine di arrivo. Nessuna priorità [20:01](https://youtu.be/H6FKJMiiL6E&t=1201s).
*   **Tail Drop:** Quando la coda è piena, tutti i nuovi pacchetti in arrivo vengono scartati. Causa la **TCP Global Synchronization**, che degrada l'efficienza della rete [20:40](https://youtu.be/H6FKJMiiL6E&t=1240s).
![[Screenshot_2 12.png]]
#### Soluzioni al Tail Drop [22:41](https://youtu.be/H6FKJMiiL6E&t=1361s)
> [!ABSTRACT] Meccanismi di Congestion Avoidance
> 1. **RED (Random Early Detection):** Scarta pacchetti casuali prima che la coda sia piena per forzare le sessioni TCP a rallentare.
> 2. **WRED (Weighted RED):** Evoluzione di RED che scarta pacchetti in base alla loro priorità (es. scarta dati HTTP prima dei pacchetti Voce).

---
#Cisco #CCNA #QoS #Networking #PoE