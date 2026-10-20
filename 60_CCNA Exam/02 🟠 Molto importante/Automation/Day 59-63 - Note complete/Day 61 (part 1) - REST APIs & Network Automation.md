---
tags: [ccna, exam, automation]
priorita: molto-importante
stato: da-ripassare
---

> [!ABSTRACT] Core Logic
> Le **REST APIs** rappresentano lo standard de facto per la programmabilità delle reti moderne. In un'architettura **SDN (Software-Defined Networking)**, esse costituiscono la **Northbound Interface (NBI)**, permettendo ad applicazioni esterne di comunicare con il **Controller** tramite il protocollo **HTTP** per automatizzare la gestione dei dispositivi.

---

## 🏗️ Architettura e SDN
Le API (**Application Programming Interface**) agiscono come un'interfaccia software che permette a due applicazioni di scambiare dati [02:01](https://youtu.be/Luei0p-2h10&t=121s).

* **Northbound Interface (NBI):** Tipicamente utilizza **REST APIs** per connettere il Controller SDN ad applicazioni di gestione o script [02:32](https://youtu.be/Luei0p-2h10&t=152s).
* **Southbound Interface (SBI):** Utilizza protocolli come **NETCONF**, **RESTCONF** o SNMP per configurare i dispositivi fisici [02:50](https://youtu.be/Luei0p-2h10&t=170s).

---

## ⚡ Operazioni CRUD e Verbi HTTP
La logica di gestione delle risorse in REST si basa sul modello **CRUD**, che mappa direttamente sui verbi del protocollo **HTTP** [03:08](https://youtu.be/Luei0p-2h10&t=188s).

| Operazione CRUD | Descrizione | Verbo HTTP |
| :--- | :--- | :--- |
| **Create** | Crea una nuova risorsa/variabile | `POST` |
| **Read** | Recupera informazioni su una risorsa | `GET` |
| **Update** | Modifica una risorsa esistente | `PUT` / `PATCH` |
| **Delete** | Rimuove una risorsa | `DELETE` |

> [!INFO] Differenza tra PUT e PATCH
> Sebbene entrambi effettuino un **Update**, `PUT` solitamente sostituisce l'intera risorsa, mentre `PATCH` modifica solo i campi specificati [05:08](https://youtu.be/Luei0p-2h10&t=308s).

---

## 🛠️ Anatomia di una Richiesta REST
Ogni chiamata API tramite HTTP deve contenere elementi specifici per essere interpretata correttamente dal server [05:35](https://youtu.be/Luei0p-2h10&t=335s):

1. **URI (Uniform Resource Identifier):** Indica la risorsa specifica.
   * *Esempio:* `https://sandboxdnac.cisco.com/dna/intent/api/v1/network-device` [06:11](https://youtu.be/Luei0p-2h10&t=371s).
1. **Intestazioni (Headers):** Metadati come `Accept: application/json` per specificare il formato dati desiderato [07:16](https://youtu.be/Luei0p-2h10&t=436s).
2. **Payload (Data):** I dati effettivi, solitamente in formato **JSON** o **XML**.

---

## 🚥 Codici di Risposta HTTP
Il server risponde con codici di stato che indicano l'esito dell'operazione [08:34](https://youtu.be/Luei0p-2h10&t=514s):

* **2xx (Success):** Operazione completata correttamente (es. `200 OK`, `201 Created`).
* **3xx (Redirection):** Risorsa spostata [09:22](https://youtu.be/Luei0p-2h10&t=562s).
* **4xx (Client Error):** Errore nella richiesta (es. `403 Forbidden`, `404 Not Found`) [09:41](https://youtu.be/Luei0p-2h10&t=581s).
* **5xx (Server Error):** Il server ha fallito l'elaborazione (es. `500 Internal Server Error`) [10:41](https://youtu.be/Luei0p-2h10&t=641s).

---

## 📑 Vincoli dell'Architettura RESTful
Per essere definita **RESTful**, un'API deve rispettare sei vincoli fondamentali [13:28](https://youtu.be/Luei0p-2h10&t=808s):

1. **Client-Server:** Separazione netta tra l'interfaccia utente e la gestione dei dati.
2. **Stateless (Senza Stato):** Ogni richiesta deve contenere tutte le informazioni necessarie; il server non memorizza il contesto delle sessioni passate [14:45](https://youtu.be/Luei0p-2h10&t=885s).
3. **Cacheable:** Le risposte devono dichiarare se possono essere memorizzate per migliorare le performance [16:15](https://youtu.be/Luei0p-2h10&t=975s).
4. **Layered System:** Il client non deve sapere se è connesso direttamente al server finale o a un intermediario.
5. **Uniform Interface:** Utilizzo di identificatori di risorse e messaggi auto-descrittivi.
6. **Code on Demand (Opzionale):** Invio di codice eseguibile dal server al client.

> [!WARNING] Stateless != TCP
> Anche se REST usa spesso **HTTP** su **TCP** (che è stateful), l'applicazione REST stessa è **stateless**. Il server non tiene traccia di "dove sei rimasto" tra una chiamata e l'altra [15:45](https://youtu.be/Luei0p-2h10&t=945s).

---

## 💻 Demo Pratica: Cisco DevNet & Postman
Nel video viene mostrato come utilizzare **Postman** per interrogare un controller **Cisco DNA Center** tramite sandbox gratuite [17:51](https://youtu.be/Luei0p-2h10&t=1071s).

* **Passaggio 1:** Generazione dell'**Auth Token** tramite `POST` e credenziali di base [20:33](https://youtu.be/Luei0p-2h10&t=1233s).
* **Passaggio 2:** Utilizzo del token nell'header `X-Auth-Token` per ottenere l'inventario dei dispositivi con una `GET` [22:15](https://youtu.be/Luei0p-2h10&t=1335s).
* **Analisi JSON:** Analisi dei dati ritornati (Hostname, Platform ID, Uptime) [23:17](https://youtu.be/Luei0p-2h10&t=1397s).

---

#network-automation #ccna #rest-api #sdn #obsidian-notes
