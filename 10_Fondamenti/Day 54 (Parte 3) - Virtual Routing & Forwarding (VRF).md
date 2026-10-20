

---



> [!ABSTRACT]
> La tecnologia **VRF** permette di segmentare un singolo router fisico in molteplici istanze di routing virtuali indipendenti. Questo isolamento consente la coesistenza di tabelle di instradamento separate e l'utilizzo di **overlapping IP addresses** sullo stesso hardware.

### 🧩 Concetti Fondamentali e Analogie
Il **VRF** opera al **Layer 3** in modo analogo a come le **VLAN** operano al **Layer 2**. Senza VRF, un router possiede una singola **Global Routing Table**; con VRF, ogni istanza possiede la propria tabella dedicata.

| Caratteristica | VLAN (Layer 2) | VRF (Layer 3) |
| :--- | :--- | :--- |
| **Obiettivo** | Divisione del dominio di broadcast | Divisione della tabella di routing |
| **Isolamento** | Traffico segmentato tra switch virtuali | Traffico isolato tra router virtuali |
| **IP Overlapping** | Non applicabile direttamente | Permesso tra istanze diverse |

[01:38](https://youtu.be/Ge4644KUvh4t=98) - Spiegazione visiva della divisione del router fisico.

---

### 🏗️ Architettura e Multi-tenancy
Il VRF è essenziale negli ambienti **Service Provider** per garantire la **multi-tenancy**. Consente di trasportare il traffico di clienti diversi (es. Cliente A e Cliente B) mantenendo l'isolamento completo del **Control Plane** e del **Data Plane**.

*   **Overlapping IP Addresses**: Grazie ai VRF, diversi clienti possono utilizzare lo stesso spazio di indirizzamento (es. `192.168.1.0/24`) senza causare conflitti di routing sul router del provider. [04:51](https://youtu.be/Ge4644KUvh4t=291)
*   **VRF-Lite**: Si riferisce all'implementazione di VRF senza l'utilizzo di **MPLS** (Multi-Protocol Label Switching), tipicamente utilizzata in scenari enterprise o per scopi didattici CCNA. [03:56](https://youtu.be/Ge4644KUvh4t=236)

> [!INFO] Definizione: VRF Instance
> Ogni istanza VRF è un'entità logica che mantiene una propria **Routing Information Base (RIB)** e una **Forwarding Information Base (FIB)** separate dalla tabella globale.

---

### 🛠️ Configurazione Cisco IOS
La configurazione si divide in due fasi: creazione dell'istanza e assegnazione delle interfacce.

#### 1. Creazione dell'istanza VRF
[07:03](https://youtu.be/Ge4644KUvh4t=423)
```ios
R1(config)# ip vrf CUSTOMER_A
R1(config-vrf)# exit
```

#### 2. Associazione Interfaccia al VRF
[07:35](https://youtu.be/Ge4644KUvh4t=455)
```ios
R1(config)# interface gigabitEthernet 0/0
R1(config-if)# ip vrf forwarding CUSTOMER_A
R1(config-if)# ip address 192.168.1.1 255.255.255.252
```

> [!CAUTION] Rischio Tecnico: Rimozione Indirizzo IP
> Quando si assegna un'interfaccia a un VRF tramite il comando `ip vrf forwarding`, l'indirizzo **IPv4** precedentemente configurato viene **automaticamente rimosso**. È necessario riconfigurare l'IP dopo aver attivato il VRF sull'interfaccia. [07:47](https://youtu.be/Ge4644KUvh4t=467)

---

### 🔍 Verifica e Troubleshooting
I comandi standard di visualizzazione non mostrano i dati dei VRF se non specificati esplicitamente.

*   **Visualizzare la tabella di routing specifica**:
    [09:22](https://youtu.be/Ge4644KUvh4t=562)
    `show ip route vrf NOME_VRF`
*   **Test di connettività**:
    [11:01](https://youtu.be/Ge4644KUvh4t=661)
    `ping vrf NOME_VRF [IP_DESTINAZIONE]`

#### Comportamento del Ping
Se si tenta un ping verso un indirizzo che risiede in un VRF senza specificare l'istanza, il router cercherà l'indirizzo nella **Global Routing Table** e il test fallirà, anche se l'interfaccia è attiva. [10:40](https://youtu.be/Ge4644KUvh4t=640)

---
#NetworkEngineering #CCNA #Routing #VRF #Cisco #ObsidianNotes