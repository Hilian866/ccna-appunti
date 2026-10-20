---
tags: [ccna, exam, automation]
priorita: molto-importante
stato: da-ripassare
---

> [!ABSTRACT] Core Logic
> **Terraform** è uno strumento di **Infrastructure as Code (IaC)** open-source, **agentless** e **declarative**, focalizzato principalmente sul **provisioning** di risorse (cloud e on-prem) piuttosto che sulla sola gestione della configurazione. A differenza di Ansible, promuove un'infrastruttura **immutabile**.

---

## 🌐 Infrastructure as Code (IaC)
L'IaC è la pratica di gestire e sottoporre a provisioning l'infrastruttura (server, rete, risorse cloud) tramite file di configurazione leggibili dalla macchina (**code**) invece di processi manuali via CLI o GUI [02:27](https://youtu.be/VAwUaffejWU&t=147s).

> [!INFO] Tool IaC per il CCNA
> Cisco include nel programma d'esame i seguenti tool: **Ansible**, **Terraform**, **Puppet** e **Chef** [00:32](https://youtu.be/VAwUaffejWU&t=32s).

---

## ⚡ Differenze Chiave: Provisioning vs Management
Sebbene esistano sovrapposizioni, i tool IaC si dividono in due categorie principali basate sul loro obiettivo primario:

| Caratteristica | **Configuration Management** (Ansible, Puppet, Chef) | **Infrastructure Provisioning** (Terraform) |
| :--- | :--- | :--- |
| **Focus** | Gestione di sistemi *esistenti* [04:03](https://youtu.be/VAwUaffejWU&t=243s). | Creazione di infrastruttura da *zero* [04:28](https://youtu.be/VAwUaffejWU&t=268s). |
| **Azioni** | Installazione software, configurazione parametri. | Creazione di VM, switch virtuali, VPC, storage [05:09](https://youtu.be/VAwUaffejWU&t=309s). |
| **Workflow** | Spesso usato *dopo* il provisioning. | Spesso usato come *primo step* dell'automazione. |

---

## 🏗️ Architettura e Approccio

### 🔄 Mutable vs Immutable Infrastructure
*   **Mutable (Ansible):** Le modifiche vengono applicate direttamente sulle risorse esistenti (**update in place**). Può portare al fenomeno del **Configuration Drift** [05:46](https://youtu.be/VAwUaffejWU&t=346s).
*   **Immutable (Terraform):** Le risorse non vengono modificate. Per ogni cambiamento, Terraform distrugge la vecchia risorsa e ne crea una nuova con la configurazione aggiornata, eliminando il rischio di drift [06:28](https://youtu.be/VAwUaffejWU&t=388s).

### 📑 Procedural vs Declarative
*   **Procedural (Imperative):** L'ingegnere deve definire *come* arrivare al risultato tramite step espliciti (es. "esegui questo comando, poi quest'altro") [07:30](https://youtu.be/VAwUaffejWU&t=450s).
*   **Declarative:** L'ingegnere definisce lo **stato finale desiderato** (es. "voglio 3 router con questa IP"). Il tool calcola autonomamente i passaggi necessari [08:05](https://youtu.be/VAwUaffejWU&t=485s).

> [!ABSTRACT] Classificazione dei Tool
> - **Procedural:** Ansible (prevalentemente), Chef.
> - **Declarative:** Terraform, Puppet [09:31](https://youtu.be/VAwUaffejWU&t=571s).

---

## 🛠️ Componenti e Workflow di Terraform

### Componenti Core [▶ 11:12](https://youtu.be/VAwUaffejWU&t=672s)
1.  **Terraform Core:** L'eseguibile principale (scritto in **Go**) che elabora le configurazioni.
2.  **Configuration Files:** File che definiscono l'infrastruttura, scritti in **HCL** (**HashiCorp Configuration Language**), un linguaggio **Domain-Specific (DSL)** [13:22](https://youtu.be/VAwUaffejWU&t=802s).
3.  **State File:** Un file critico che traccia lo stato attuale dell'infrastruttura distribuita [11:46](https://youtu.be/VAwUaffejWU&t=706s).
4.  **Providers:** Plugin che permettono a Terraform di interagire con piattaforme specifiche (AWS, Azure, **Cisco Catalyst Center**, **ACI**, **IOS XE**) [10:29](https://youtu.be/VAwUaffejWU&t=629s).

### Il Workflow Standard [▶ 12:39](https://youtu.be/VAwUaffejWU&t=759s)
> [!WARNING] Sequenza Operativa
> 1. **Write:** Definizione dello stato desiderato nei file `.tf`.
> 2. **Plan:** Terraform confronta lo stato attuale con i file e mostra un'anteprima delle modifiche.
> 3. **Apply:** Esecuzione effettiva delle modifiche per raggiungere lo stato desiderato.

---

## 📝 Sintesi per l'Esame
- **Linguaggio:** HCL (declarative).
- **Modello:** Push (agentless) [11:00](https://youtu.be/VAwUaffejWU&t=660s).
- **Infrastruttura:** Immutabile.
- **Utilizzo Cisco:** Integrazione con ACI, Catalyst Center e dispositivi IOS XE via API [10:41](https://youtu.be/VAwUaffejWU&t=641s).

---

#network-engineering #ccna #automation #terraform #iac
