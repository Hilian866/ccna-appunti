---
tags: [ccna, exam, automation]
priorita: molto-importante
stato: da-ripassare
---

> [!ABSTRACT] Core Logic
> Transizione dal networking tradizionale (distribuito e manuale) al **Software-Defined Networking (SDN)**. L'obiettivo è la centralizzazione del controllo, l'astrazione dell'hardware e l'automazione tramite API e strumenti di Configuration Management.

## 1. Architettura SDN & Logic Planes

Il networking moderno separa le funzioni logiche per abilitare la centralizzazione tramite un **Controller**.

| Piano | Funzione Primaria | Driver Tradizionale |
| :--- | :--- | :--- |
| Data Plane | Inoltro pacchetti (Forwarding). | Basato su **ASIC** e **TCAM** per wire speed. |
| Control Plane | Decision making (Routing, STP). | Tradizionalmente distribuito su ogni nodo. |
| Management Plane | Accesso e monitoraggio (SSH, SNMP). | Configurazione individuale del dispositivo. |

> [!INFO] Northbound vs Southbound
> - **Northbound Interface (NBI):** API (solitamente **REST**) che permettono ad applicazioni/script di comunicare con il controller.
> - **Southbound Interface (SBI):** Protocolli usati dal controller per gestire i dispositivi fisici (es. OpenFlow, NETCONF, RESTCONF).

## 2. AI & Machine Learning nel Networking

Definizioni chiave per il nuovo curriculum Cisco:

*   **AI:** Simulazione dell'intelligenza umana (pattern recognition).
*   **Machine Learning (ML):** Sottoinsieme dell'AI che apprende dai dati.
    *   **Supervised:** Usa dati etichettati.
    *   **Unsupervised:** Trova pattern nascosti in dati non etichettati.
*   **Cisco Catalyst Center (DNA Center):**
    *   **AI Network Analytics:** Stabilisce **Baselines** per trovare anomalie.
    *   **MRE (Machine Reasoning Engine):** Automazione della **Root-cause analysis**.

## 3. Data Serialization (JSON, XML, YAML)

Formati standard per la comunicazione tra macchine (Machine-to-Machine).

| Feature | JSON | XML | YAML |
| :--- | :--- | :--- | :--- |
| Readability | Alta | Media | **Eccellente** |
| Sintassi | `{ } , [ ] :` | `<tag> </tag>` | `Indentation, -` |
| Whitespace | Irrilevante | Irrilevante | **Significativo** |
| Uso Principale| API REST | Legacy/REST | Ansible/Config |

> [!WARNING] YAML Alert
> In **YAML**, l'indentazione non è estetica: definisce la gerarchia dei dati. Un errore di spaziatura rompe il file.

## 4. REST APIs & HTTP

Il protocollo REST è lo standard de facto per la programmabilità.

### CRUD & Verbi HTTP
*   **Create:** `POST`
*   **Read:** `GET`
*   **Update:** `PUT` (Sostituisce) / `PATCH` (Modifica parziale)
*   **Delete:** `DELETE`

### Codici di Stato HTTP
- **2xx (Success):** `200 OK`, `201 Created`.
- **3xx (Redirection):** Risorsa spostata.
- **4xx (Client Error):** `401 Unauthorized`, `403 Forbidden`, `404 Not Found`.
- **5xx (Server Error):** `500 Internal Server Error`.

## 5. API Authentication

1.  **[[Basic Auth.png|Basic Auth]]:** `username:password` codificati in **Base64** (Non sicuro senza HTTPS).
2.  **[[Bearer.png|Bearer Token]]:** Token generato per la sessione.
3.  **[[API Key.png|API Key]]:** Stringa statica univoca.
4.  **[[OAuth 2.0.png|OAuth 2.0]]:** Framework avanzato per "Access Delegation" (es. Login con Google).

## 6. Cisco SD-Access (SDA) & Fabric

SDA automatizza le LAN campus utilizzando un'architettura **Fabric**.

*   **Underlay:** Rete fisica (Switch/Router) che fornisce connettività IP. Usa **IS-IS**.
*   **Overlay:** Rete virtuale (Tunnel) sopra l'underlay. Usa **VXLAN** per il data plane.
*   **Control Plane:** Usa **LISP** per mappare Endpoint IDs (EID) a Routing Locators (RLOC).
*   **Security:** Usa **Cisco TrustSec (SGT)** invece delle ACL basate su IP.

## 7. Strumenti di Configuration Management

| Feature | Ansible | Puppet | Chef |
| :--- | :--- | :--- | :--- |
| Linguaggio | Python | Ruby | Ruby |
| Modello | **Push** | Pull | Pull |
| Setup | **Agentless (SSH)** | Agent-based | Agent-based |
| Formato | YAML (Playbooks) | Manifests | Recipes |

### Terraform vs Ansible
*   **Ansible:** Focalizzato sulla **Configurazione** di sistemi esistenti. È **Mutable** (aggiorna in loco) e **Procedurale** (descrive *come* fare).
*   **Terraform:** Focalizzato sul **Provisioning** dell'infrastruttura. È **Immutable** (distrugge e ricrea), usa HCL ed è **Declarative** (descrive lo *stato finale* desiderato).

## Note complete (cartella `Day 59-63 - Note complete`)
Sono il materiale di studio principale: questo riassunto ne è la sintesi.

- SDN e piani logici → [[Day 59 (part 1) Intro to Network Automation]] · [[Day 62 Software-Defined Networking (SD-Access & DNA Center)]]
- AI/ML → [[Day 59 (part 2) AI e ML]]
- JSON/XML/YAML → [[Day 60 JSON, XML, & YAML]]
- REST e autenticazione → [[Day 61 (part 1) - REST APIs & Network Automation]] · [[Day 61 (part 2) REST API Authentication]]
- Config management e IaC → [[Day 63 (part 1) Ansible, Puppet, & Chef]] · [[Day 63 (part 2) Terraform Basics & Infrastructure as Code (IaC)]]
- Lettura continua di tutto: [[01 Automation - Tutte le note (lettura continua)]]

## 🎯 Synthesis
Automation = controller (SDN) + API REST/JSON + config management (Ansible/Puppet/Chef/Terraform) al posto della CLI a mano.

*Fonte: Jeremy's IT Lab e obiettivi d'esame Cisco CCNA 200-301.*
