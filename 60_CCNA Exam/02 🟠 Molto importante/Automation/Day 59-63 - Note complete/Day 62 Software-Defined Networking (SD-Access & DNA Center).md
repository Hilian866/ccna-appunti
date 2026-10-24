---
tags: [ccna, exam, automation]
priorita: molto-importante
stato: da-ripassare
---

> [!ABSTRACT] Core Logic
> Il Software-Defined Networking (SDN) evolve la gestione di rete separando il **Control Plane** dal **Data Plane**. Cisco implementa questa visione nel Campus LAN tramite **SD-Access**, utilizzando il controller DNA Center per trasformare i requisiti di business (Intent) in configurazioni di rete automatizzate attraverso un'architettura a Fabric.

## Architettura e Layer SDN
L'approccio SDN centralizza l'intelligenza della rete in un software chiamato **Controller** [01:31](https://www.youtube.com/watch?v=7HhWCeXDTpA&t=91s).

L'architettura si divide in tre layer fondamentali [03:08](https://www.youtube.com/watch?v=7HhWCeXDTpA&t=188s):
1.  **Application Layer**: Script e applicazioni che definiscono i comportamenti desiderati.
2.  **Control Layer**: Il **Controller SDN** (es. DNA Center) che elabora le istruzioni.
3.  **Infrastructure Layer**: I dispositivi fisici che inoltrano il traffico (Data Plane) [[Screenshot_10 5.png|*]]

### Interfacce API
- **Northbound API (NBI)**: Permette la comunicazione tra applicazioni e controller [02:39](https://www.youtube.com/watch?v=7HhWCeXDTpA&t=159s).
- **Southbound API (SBI)**: Permette al controller di programmare i dispositivi fisici (es. NETCONF, RESTCONF) [02:34](https://www.youtube.com/watch?v=7HhWCeXDTpA&t=154s).

## Cisco SD-Access (SDA)
SD-Access è la soluzione Cisco per automatizzare le LAN aziendali [04:19](https://www.youtube.com/watch?v=7HhWCeXDTpA&t=259s). Si basa sul concetto di Fabric [05:21](https://www.youtube.com/watch?v=7HhWCeXDTpA&t=321s).

### Underlay vs Overlay
| Concetto | Descrizione | Protocolli/Note |
| :--- | :--- | :--- |
| Underlay | Rete fisica di switch e router che garantisce connettività IP [06:02](https://www.youtube.com/watch?v=7HhWCeXDTpA&t=362s). | Spesso usa **IS-IS**. Design **L3 Routed Access** (no STP) [09:12](https://www.youtube.com/watch?v=7HhWCeXDTpA&t=552s). |
| Overlay | Rete virtuale creata sopra l'Underlay tramite tunnel [06:30](https://www.youtube.com/watch?v=7HhWCeXDTpA&t=390s). | Utilizza tunnel **VXLAN** per il Data Plane [06:34](https://www.youtube.com/watch?v=7HhWCeXDTpA&t=394s). |
| Fabric | La combinazione logica di Underlay e Overlay [06:42](https://www.youtube.com/watch?v=7HhWCeXDTpA&t=402s). | Rappresenta l'intera entità di rete SDA. |

### Ruoli degli Switch nella Fabric [▶ 07:53](https://www.youtube.com/watch?v=7HhWCeXDTpA&t=473s)
- **Edge Node**: Collega gli host finali (simile all'Access Layer tradizionale).
- **Border Node**: Collega la Fabric a reti esterne (es. Internet o WAN).
- **Control Node**: Gestisce il database di mapping tra endpoint e la loro posizione.

## Protocolli Chiave in SD-Access
> [!INFO] Il Control Plane e il Data Plane di SDA
> In SD-Access, i protocolli tradizionali sono sostituiti o potenziati per supportare la mobilità e l'automazione.
> - **LISP (Locator/ID Separation Protocol)**: Gestisce il Control Plane. Mappa gli **EID** (Endpoint Identifiers) ai **RLOC** (Routing Locators) [08:12](https://www.youtube.com/watch?v=7HhWCeXDTpA&t=492s).
> - **VXLAN (Virtual Extensible LAN)**: Gestisce il Data Plane. Incapsula i frame Layer 2 in pacchetti Layer 3 per creare i tunnel dell'Overlay [11:26](https://www.youtube.com/watch?v=7HhWCeXDTpA&t=686s).
> - **Cisco TrustSec (CTS)**: Applica le policy di sicurezza basate su gruppi (**SGT**) invece che su indirizzi IP [11:13](https://www.youtube.com/watch?v=7HhWCeXDTpA&t=673s).

## Cisco DNA Center (DNAC)
Il DNA Center è il "cervello" dell'architettura SD-Access [10:57](https://www.youtube.com/watch?v=7HhWCeXDTpA&t=657s).

### Intent-Based Networking (IBN)
DNAC permette l'**Intent-Based Networking**: l'amministratore definisce *cosa* la rete deve fare (Intent) e il controller gestisce il *come* (configurazione tecnica) [13:38](https://www.youtube.com/watch?v=7HhWCeXDTpA&t=818s).

> [!WARNING] Deployment Tipi
> - **Greenfield**: Nuovo network costruito da zero ottimizzato per SDA [15:00](https://www.youtube.com/watch?v=7HhWCeXDTpA&t=900s).
> - **Brownfield**: Aggiunta di SDA su un'infrastruttura esistente [14:26](https://www.youtube.com/watch?v=7HhWCeXDTpA&t=866s).

### Gestione Tradizionale vs DNA Center [▶ 11:15](https://www.youtube.com/watch?v=7HhWCeXDTpA&t=675s)
| Caratteristica | Gestione Tradizionale | Cisco DNA Center |
| :--- | :--- | :--- |
| Configurazione | Dispositivo per dispositivo (CLI/SSH) | Centralizzata tramite GUI o API |
| Policy | Basate su IP/ACL manuali (complesse) | Basate sull'Intent e Gruppi Utente |
| Deployment | Tempi lunghi, rischio errore umano | Automatizzato (Zero Touch Provisioning) |
| Visibilità | Frammentata (SNMP/Syslog) | **Assurance** (analisi predittiva della salute) |

## Troubleshooting & Monitoring
Cisco DNAC include una sezione di Assurance [18:03](https://www.youtube.com/watch?v=7HhWCeXDTpA&t=1083s) che fornisce un punteggio di "salute" per ogni dispositivo e client, permettendo di identificare rapidamente colli di bottiglia o problemi di compliance software [17:30](https://www.youtube.com/watch?v=7HhWCeXDTpA&t=1050s).

---

*Nota generata per il ripasso CCNA - Basata su Jeremy's IT Lab Day 62.*
