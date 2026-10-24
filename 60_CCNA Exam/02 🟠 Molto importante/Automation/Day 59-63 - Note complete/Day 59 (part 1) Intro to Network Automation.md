---
tags: [ccna, exam, automation]
priorita: molto-importante
stato: da-ripassare
---

> [!ABSTRACT] Core Logic
>
> [01:21](http://www.youtube.com/watch?v=4tsBgMCPVuc&t=81) L'automazione di rete segna il passaggio dalla gestione manuale "hop-by-hop" (CLI) a un modello programmabile centralizzato. L'obiettivo è eliminare l'errore umano, garantire la conformità delle configurazioni (evitando il _config drift_) e ridurre le spese operative (OPEX).

## Anatomia dei Piani Logici

Per comprendere il Software-Defined Networking (SDN), è fondamentale scomporre le funzioni di rete in tre piani distinti:

|Piano|Funzione Primaria|Driver Operativo|
|---|---|---|
|Data Plane|Inoltro dei pacchetti (Forwarding).|Basato su ASIC e TCAM per velocità hardware.|
|Control Plane|Decision making (Routing, STP).|Tradizionalmente distribuito su ogni nodo.|
|Management Plane|Accesso e monitoraggio (SSH, SNMP).|Overhead di gestione e configurazione.|

## Data Plane: Efficienza del Monitoraggio [▶ 13:13](http://www.youtube.com/watch?v=4tsBgMCPVuc&t=793)

L'inoltro dei dati non deve gravare sulla CPU del dispositivo per evitare colli di bottiglia.

- **ASIC:** Chip specializzati che gestiscono la logica di switching a velocità di linea.
- **TCAM:** Memoria che permette lookup istantanei della tabella MAC e delle ACL.
- **CPU:** Interviene solo per il traffico destinato al dispositivo stesso (Management/Control) o per pacchetti che richiedono elaborazione complessa.

## Software-Defined Networking (SDN) [▶ 15:17](http://www.youtube.com/watch?v=4tsBgMCPVuc&t=917)

L'SDN centralizza il **Control Plane** in un software chiamato **Controller**. Gli apparati fisici diventano meri esecutori del Data Plane.

### Interfacce di Sistema

1. **Southbound Interface (SBI) [17:49](http://www.youtube.com/watch?v=4tsBgMCPVuc&t=1069):** Il protocollo con cui il controller istruisce gli switch (es. OpenFlow, NETCONF, OpFlex).
2. **Northbound Interface (NBI) [20:24](http://www.youtube.com/watch?v=4tsBgMCPVuc&t=1224):** API (solitamente **REST**) che permettono alle applicazioni di dialogare con il controller per programmare la rete.

## Estrazione di Valore e Benefici

L'automazione non è solo SDN, ma include script (Python) e strumenti di gestione (Ansible):

- **Riduzione Errore:** Eliminazione dei typo manuali.
- **Scalabilità:** Modifiche su centinaia di dispositivi in una singola operazione.
- **Analisi Analitica:** Il controller offre una visione globale della topologia, facilitando il troubleshooting rispetto al modello tradizionale distribuito.

## Formati Dati (Verso la Programmabilità)

A differenza della CLI (pensata per gli umani), l'automazione utilizza dati strutturati per la comunicazione tra macchine:

- **JSON / XML:** Formati standard che rendono i dati facilmente leggibili dai programmi senza necessità di complessi parsing dell'output "show".
