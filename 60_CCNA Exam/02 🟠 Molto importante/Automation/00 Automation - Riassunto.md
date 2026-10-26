---
tags: [ccna, exam, automation]
priorita: molto-importante
stato: da-ripassare
---

> [!ABSTRACT] Cosa serve per l'esame
> Dominio **6** (circa il 10%): 6.1 impatto dell'automazione, 6.2 reti tradizionali contro reti con controller, 6.3 architettura SDN (overlay, underlay, fabric; control plane separato dal data plane; API northbound e southbound), 6.4 AI generativa e predittiva e machine learning, 6.5 REST API (autenticazione, CRUD, verbi HTTP, codifica dei dati), 6.6 Ansible e Terraform, 6.7 riconoscere i componenti di un JSON.
> Si chiede tutto a parole o leggendo un esempio: nessuna configurazione. Il punto più "pratico" è leggere un JSON.

## 1. Perché automatizzare (6.1)

Configurare i dispositivi uno per uno dalla CLI è lento, soggetto a errori e porta a configurazioni diverse tra dispositivi uguali. Con l'automazione:

- meno **errori umani** e configurazioni **coerenti**;
- modifiche su centinaia di dispositivi in poco tempo (**scalabilità**);
- meno costi operativi, più tempo per il lavoro che non si ripete;
- visione e monitoraggio centralizzati.

## 2. I tre piani (6.3.a)

| Piano | Cosa fa | Esempi |
| :--- | :--- | :--- |
| **Data plane** | inoltra i pacchetti | lookup nella tabella MAC o di routing, incapsulamento, ACL applicate. In hardware (**ASIC**, **TCAM**) |
| **Control plane** | decide **come** inoltrare | OSPF, STP, ARP: costruisce le tabelle che il data plane usa |
| **Management plane** | gestione del dispositivo | SSH, SNMP, syslog |

Nelle reti tradizionali ogni dispositivo ha il **suo** control plane (control plane distribuito).

## 3. Reti con controller (6.2, 6.3)

Nel **SDN** (software-defined networking) il control plane viene **centralizzato** in un software, il **controller**. I dispositivi si occupano soprattutto del data plane.

| | Tradizionale | Con controller |
| :--- | :--- | :--- |
| Control plane | su ogni dispositivo | centralizzato nel controller |
| Configurazione | dispositivo per dispositivo, da CLI | dal controller, che la applica a tutti |
| Visione della rete | frammentata | globale |
| Policy | ACL scritte a mano | definite per gruppi e applicate ovunque |

Il controller ha due interfacce:

- **Northbound (NBI)**: verso l'alto, tra le **applicazioni** (script, interfacce di gestione) e il controller. Di solito **REST API**.
- **Southbound (SBI)**: verso il basso, tra il controller e i **dispositivi**. Protocolli come OpenFlow, NETCONF, RESTCONF, OpFlex, ma anche SSH e SNMP.

L'architettura ha tre livelli: **application layer** (le applicazioni), **control layer** (il controller), **infrastructure layer** (i dispositivi).

## 4. SD-Access e Catalyst Center (6.3)

**SD-Access** è la soluzione SDN di Cisco per le LAN aziendali (campus). Il controller è **Catalyst Center** (prima DNA Center).

| Parte | Cos'è | Tecnologia |
| :--- | :--- | :--- |
| **Underlay** | la rete fisica, che dà connettività IP tra i dispositivi | routing IP (**IS-IS** consigliato) |
| **Overlay** | la rete virtuale costruita sopra, con tunnel | **VXLAN** per i dati, **LISP** per il control plane |
| **Fabric** | underlay e overlay insieme | |

- **LISP** associa l'identità di un host (**EID**) alla sua posizione nella rete (**RLOC**, il nodo a cui è collegato).
- La sicurezza usa i **SGT** (Security Group Tag, Cisco TrustSec): le policy si basano sui gruppi di utenti, non sugli IP.
- Ruoli dei nodi: **edge** (collega gli host, come l'access layer), **border** (collega la fabric alle reti esterne), **control plane node** (tiene il database LISP).

Catalyst Center fa anche **intent-based networking** (l'amministratore dice *cosa* vuole, il controller decide *come* configurarlo) e **assurance** (monitora lo stato della rete e segnala i problemi).

## 5. AI e machine learning (6.4)

- **AI**: sistemi che svolgono compiti che richiederebbero intelligenza umana.
- **Machine learning**: la parte dell'AI che **impara dai dati** invece di seguire regole scritte a mano.
  - **Supervised**: impara da dati etichettati (es. traffico già classificato come normale o attacco).
  - **Unsupervised**: trova da solo schemi in dati non etichettati (es. raggruppa comportamenti simili).

| | AI predittiva | AI generativa |
| :--- | :--- | :--- |
| Cosa fa | analizza i dati per **prevedere** eventi | **crea** contenuti nuovi (testo, codice, configurazioni) |
| Nel networking | previsione di guasti e congestione, rilevamento di anomalie rispetto a una **baseline**, manutenzione predittiva | genera configurazioni e script, risponde a domande sulla rete in linguaggio naturale, riassume log |

In Catalyst Center: **AI Network Analytics** costruisce le baseline e trova le anomalie; il **Machine Reasoning Engine** automatizza la ricerca della causa dei problemi (root cause analysis).

## 6. REST API (6.5)

Una REST API permette a un programma di leggere e cambiare dati su un altro sistema via HTTP (di solito HTTPS).

Caratteristiche di REST:

- **client-server**: il client fa richieste, il server risponde;
- **stateless**: ogni richiesta contiene tutto ciò che serve; il server non ricorda le richieste precedenti (anche se sotto c'è TCP, che ha stato);
- **cacheable**: le risposte dicono se possono essere memorizzate;
- **uniform interface**, **layered system**, **code on demand** (facoltativo).

Una richiesta ha: un **URI** (la risorsa, es. `https://catalyst.lab/dna/intent/api/v1/network-device`), un **verbo**, degli header (es. `Authorization`, `Content-Type: application/json`) e, se serve, un corpo con i dati.

| Operazione (CRUD) | Verbo HTTP |
| :--- | :--- |
| **Create** | **POST** |
| **Read** | **GET** |
| **Update** | **PUT** (sostituisce tutta la risorsa) o **PATCH** (cambia solo alcuni campi) |
| **Delete** | **DELETE** |

| Codice | Significato | Esempi |
| :--- | :--- | :--- |
| 1xx | informativo | 102 Processing |
| **2xx** | successo | **200** OK, **201** Created |
| 3xx | reindirizzamento | 301 Moved Permanently |
| **4xx** | errore del **client** | 400 Bad Request, **401** Unauthorized (non autenticato), **403** Forbidden (autenticato ma senza permesso), **404** Not Found |
| **5xx** | errore del **server** | **500** Internal Server Error |

Autenticazione:

| Tipo | Come funziona |
| :--- | :--- |
| **Basic** | utente e password codificati in **Base64** a ogni richiesta. Base64 non è cifratura: serve HTTPS |
| **Bearer token** | il client si autentica una volta e riceve un token temporaneo da allegare alle richieste |
| **API key** | una stringa fissa e univoca assegnata al client |
| **OAuth 2.0** | delega dell'accesso: un servizio accede ai tuoi dati su un altro senza ricevere la tua password (es. "accedi con Google") |

I dati di una REST API sono codificati di solito in **JSON**, a volte in XML.

## 7. JSON, XML e YAML (6.7)

```json
{
  "hostname": "R1",
  "uptime_days": 42,
  "ospf_enabled": true,
  "backup_router": null,
  "interfaces": [
    {"name": "GigabitEthernet0/0", "ip": "10.0.0.1", "up": true},
    {"name": "GigabitEthernet0/1", "ip": "10.0.1.1", "up": false}
  ]
}
```

| Tipo JSON | Come si scrive | Nell'esempio |
| :--- | :--- | :--- |
| **Object** | coppie **chiave: valore** tra `{ }`, separate da virgole, senza ordine | tutto il documento; ogni interfaccia |
| **Array** | lista **ordinata** di valori tra `[ ]` | `"interfaces"` |
| **String** | tra **doppi apici** | `"R1"`, `"10.0.0.1"` |
| **Number** | senza apici | `42` |
| **Boolean** | `true` o `false`, in minuscolo | `true` |
| **Null** | `null`: nessun valore | `"backup_router"` |

- Le **chiavi** sono sempre stringhe, tra doppi apici.
- `"5"` è una stringa, `5` un numero.
- Un oggetto può contenere altri oggetti e array (qui: un array di oggetti).
- Gli spazi e gli a capo non contano.

| | JSON | XML | YAML |
| :--- | :--- | :--- | :--- |
| Struttura | `{ }`, `[ ]`, `:` | tag `<nome>valore</nome>` | indentazione, `-` per le liste |
| Spazi | irrilevanti | irrilevanti | **significativi**: l'indentazione definisce la gerarchia |
| Uso tipico | REST API | REST API, NETCONF | **Ansible** (playbook) |

## 8. Ansible e Terraform (6.6)

Gli strumenti di **configuration management** applicano configurazioni a molti dispositivi partendo da template (configurazione con segnaposti) e variabili (i valori di ogni dispositivo). Il codice si tiene in un sistema di versioni (Git): è l'**infrastructure as code**.

| | Ansible | Puppet | Chef |
| :--- | :--- | :--- | :--- |
| Agent sui dispositivi | **no** (agentless, usa **SSH**) | sì | sì |
| Modello | **push**: il control node invia le modifiche | **pull**: l'agent chiede la configurazione | pull |
| File | **playbook** in **YAML**, inventory, template Jinja2 | manifest | recipe, cookbook |
| Scritto in | Python | Ruby | Ruby |
| Comunicazione | SSH | HTTPS, TCP 8140 | HTTPS, TCP 10002 |

Per i dispositivi di rete conta l'**agentless**: su router e switch di solito non si può installare un agent.

| | Ansible | Terraform |
| :--- | :--- | :--- |
| Scopo | **configurare** sistemi che esistono già | **creare** l'infrastruttura (provisioning: server, reti, risorse cloud) |
| Approccio | procedurale: elenca i passi da eseguire | **dichiarativo**: descrivi lo stato finale, Terraform calcola cosa fare |
| Linguaggio | YAML | **HCL** |
| Modifiche | sul posto (mutable) | spesso distrugge e ricrea (immutable) |
| Stato | non ne tiene uno | un **state file** con lo stato attuale |

Il ciclo di Terraform: write (file HCL), **plan** (confronta lo stato attuale con quello voluto e mostra le modifiche), **apply** (le esegue). I **provider** sono i plugin per le varie piattaforme (AWS, Azure, Catalyst Center, IOS XE).

## ⚠️ Trappole d'esame

> [!WARNING] Gli errori più frequenti
> 1. **Northbound e southbound**: northbound tra applicazioni e controller (REST); southbound tra controller e dispositivi (OpenFlow, NETCONF, RESTCONF).
> 2. **Cosa centralizza il SDN**: il control plane, non il data plane.
> 3. **PUT e PATCH**: PUT sostituisce tutta la risorsa, PATCH ne cambia una parte. POST crea.
> 4. **401 e 403**: 401 non autenticato, 403 autenticato ma senza permesso.
> 5. **Base64** è una codifica, non una cifratura.
> 6. **Ansible** è agentless e push; Puppet e Chef usano un agent e pull.
> 7. **JSON**: `true`, `false` e `null` in minuscolo e senza apici; le chiavi tra doppi apici.
> 8. **Underlay e overlay**: l'underlay è la rete fisica, l'overlay i tunnel VXLAN sopra.

## Esercizi

> [!QUESTION]- Nel JSON qui sopra, che tipo è il valore di `"interfaces"`? E il suo primo elemento?
> Un array; il primo elemento è un object.

> [!QUESTION]- Uno script deve modificare solo la descrizione di un'interfaccia tramite REST, lasciando il resto com'è. Che verbo usa?
> PATCH.

> [!QUESTION]- Una richiesta REST restituisce 201. Cosa significa?
> La risorsa è stata creata (tipicamente dopo un POST).

> [!QUESTION]- Serve uno strumento che configuri 200 switch via SSH senza installare niente su di loro. Quale?
> Ansible.

> [!QUESTION]- Un sistema analizza mesi di dati e avvisa che un link si saturerà la settimana prossima. È AI predittiva o generativa?
> Predittiva.

> [!QUESTION]- Che protocollo crea i tunnel dell'overlay in SD-Access, e quale fa da control plane?
> VXLAN per i tunnel (data plane), LISP per il control plane.

## Check da esame

- [ ] Cosa centralizza il SDN? **Il control plane**.
- [ ] API tra applicazioni e controller? **Northbound, di solito REST**.
- [ ] Verbo HTTP per creare una risorsa? **POST**. Per leggerla? **GET**.
- [ ] REST tiene lo stato tra le richieste? **No, è stateless**.
- [ ] Ansible usa un agent? **No: agentless, via SSH, modello push**.
- [ ] Linguaggio dei playbook Ansible? **YAML**. Di Terraform? **HCL**.
- [ ] Sei tipi di dati JSON? **Object, array, string, number, boolean, null**.

## 🎯 Synthesis

L'automazione riduce errori e tempi. Il SDN separa il control plane, centralizzato nel controller, dal data plane dei dispositivi; il controller parla con le applicazioni via northbound (REST) e con i dispositivi via southbound (NETCONF, RESTCONF, OpenFlow). SD-Access usa underlay IP, overlay VXLAN e LISP. Le REST API sono stateless, usano i verbi HTTP per il CRUD e dati in JSON. Ansible (agentless, push, YAML) configura; Terraform (dichiarativo, HCL) crea l'infrastruttura.

## Note complete (cartella `Day 59-63 - Note complete`)

- SDN e piani → [[Day 59 (part 1) Intro to Network Automation]] · [[Day 62 Software-Defined Networking (SD-Access & DNA Center)]]
- AI e ML → [[Day 59 (part 2) AI e ML]]
- JSON, XML, YAML → [[Day 60 JSON, XML, & YAML]]
- REST e autenticazione → [[Day 61 (part 1) - REST APIs & Network Automation]] · [[Day 61 (part 2) REST API Authentication]]
- Configuration management e IaC → [[Day 63 (part 1) Ansible, Puppet, & Chef]] · [[Day 63 (part 2) Terraform Basics & Infrastructure as Code (IaC)]]
- Tutto in una pagina: [[01 Automation - Tutte le note (lettura continua)]]
