
---

> [!ABSTRACT] Core Logic
> Il video analizza l'evoluzione dai server fisici tradizionali alle infrastrutture **virtualizzate** e ai servizi **Cloud**. L'obiettivo è comprendere come gli **Hypervisor** permettano l'astrazione dell'hardware e come il framework **NIST SP 800-145** definisca l'architettura moderna del Cloud Computing.

---

### 🖥️ Fondamenti della Virtualizzazione
Prima della virtualizzazione, esisteva un rapporto 1:1 tra hardware fisico e **Operating System (OS)**, con un enorme spreco di risorse [02:09](https://youtu.be/_S3greGajJA&t=129s). La virtualizzazione rompe questo legame introducendo le **Virtual Machines (VM)**.

> [!INFO] Definizione di Hypervisor
> L'**Hypervisor** (o **VMM - Virtual Machine Monitor**) è il software incaricato di gestire e allocare le risorse hardware fisiche (CPU, RAM, Storage) alle diverse VM [03:55](https://youtu.be/_S3greGajJA&t=235s).

#### Comparazione Hypervisor: Type 1 vs Type 2
| Caratteristica | [[Screenshot_18.png\|Type 1]] (Bare Metal)                                     |  [[Screenshot_19.png\|Type 2]] (Hosted)                                          |
| -------------- | ------------------------------------------------------------------------------ | -------------------------------------------------------------------------------- |
| **Esecuzione** | Direttamente sull'hardware fisico [04:08](https://youtu.be/_S3greGajJA&t=248s) | Come applicazione su un **Host OS** [04:55](https://youtu.be/_S3greGajJA&t=295s) |
| **Efficienza** | Alta (basso overhead)                                                          | Minore (dipende dall'OS ospitante)                                               |
| **Use Case**   | Data Center / Enterprise                                                       | Personal use / Lab Testing                                                       |
| **Esempi**     | VMware **ESXi**, Microsoft **Hyper-V**                                         | Oracle **VirtualBox**, VMware Workstation                                        |
  
 


---

### 🌐 Networking Virtuale
Le VM comunicano tra loro e con l'esterno attraverso componenti di rete virtualizzati all'interno dell'Hypervisor [08:19](https://youtu.be/_S3greGajJA&t=499s):
- **vNIC (Virtual NIC)**: L'interfaccia di rete virtuale della VM.
- **vSwitch ([[Screenshot_21.png| Virtual Switch]])**: Permette il Layer 2 switching interno. Supporta **VLAN**, **Access Port** e **Trunk Port**.

---

### ☁️ Cloud Computing: Il framework NIST
Il Cloud non è solo "il computer di qualcun altro", ma un modello definito dallo standard **NIST SP 800-145** [11:19](https://youtu.be/_S3greGajJA&t=679s).

#### 5 Caratteristiche Essenziali [12:58](https://youtu.be/_S3greGajJA&t=778s)
1. **On-demand self-service**: Provisioning automatico senza comunicazioni dirette con il service provider [13:23](https://youtu.be/_S3greGajJA&t=803s).
2. **Broad network access**: Servizi disponibili su molteplici device (Smart phones, Tablets, Laptops, ecc ) [14:10](https://youtu.be/_S3greGajJA&t=850s).
3. **Resource pooling**: Risorse condivise in un modello **multi-tenant** [14:55](https://youtu.be/_S3greGajJA&t=895s).
4. **Rapid elasticity**: Scalabilità immediata in base alla domanda [16:04](https://youtu.be/_S3greGajJA&t=964s).
5. **Measured service**: Fatturazione basata sul consumo effettivo (Pay-as-you-go) [16:58](https://youtu.be/_S3greGajJA&t=1018s).

---

### 🛠️ Modelli di Servizio (Service Models)
I modelli definiscono la "linea di demarcazione" della responsabilità tra cliente e provider [18:31](https://youtu.be/_S3greGajJA&t=1111s).

| Modello  | Descrizione                                        | Responsabilità Cliente                                                                     |
| -------- | -------------------------------------------------- | ------------------------------------------------------------------------------------------ |
| **SaaS** | [[Screenshot_22.png\|Software as a Service]]       | Solo utilizzo dell'app (es. Office 365) [18:47](https://youtu.be/_S3greGajJA&t=1127s)      |
| **PaaS** | [[Screenshot_23.png\|Platform as a Service]]       | Sviluppo e gestione delle applicazioni [20:16](https://youtu.be/_S3greGajJA&t=1216s)       |
| **IaaS** | [[Screenshot_24.png\|Infrastructure as a Service]] | OS, App, Dati, Networking base (es. AWS EC2) [21:31](https://youtu.be/_S3greGajJA&t=1291s) |

---

### 🚀 Modelli di Deployment e Connettività
Esistono quattro modi principali per implementare il Cloud [13:18](https://youtu.be/_S3greGajJA&t=798s):
- **Public Cloud**: Risorse condivise globalmente (AWS, Azure, GCP).
- **Private Cloud**: Risorse dedicate a una singola organizzazione (On-prem o Off-prem).
- **Hybrid Cloud**: Combinazione di pubblico e privato con portabilità dei dati.
- **Community Cloud**: Condiviso tra organizzazioni con interessi comuni (es. sicurezza o compliance).

> [!CAUTION] Connettività Cloud
> L'accesso tramite Internet pubblico è economico ma rischioso. Per il traffico aziendale critico, è necessario utilizzare **IPsec VPN Tunnel** o connessioni **Private WAN** dedicate (come AWS Direct Connect) per garantire sicurezza e performance [19:54](https://youtu.be/_S3greGajJA&t=1194s).

---
*Documentazione generata per la preparazione all'esame Cisco 200-301 CCNA.*