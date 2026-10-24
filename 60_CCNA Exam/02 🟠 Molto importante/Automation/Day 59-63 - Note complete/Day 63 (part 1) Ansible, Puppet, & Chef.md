---
tags: [ccna, exam, automation]
priorita: molto-importante
stato: da-ripassare
---

> [!ABSTRACT] Core Logic
> I tool di **Configuration Management** automatizzano il provisioning, il monitoraggio e la conformità delle configurazioni di rete su larga scala, eliminando i rischi legati alla gestione manuale "hop-by-hop" e prevenendo il fenomeno del configuration drift.

## Il Problema: Configuration Drift
Il **Configuration Drift** [01:46](https://youtu.be/Kog9gHTjALI&t=106s) si verifica quando le modifiche manuali eseguite nel tempo (per troubleshooting o test) causano una deviazione del dispositivo dallo standard aziendale.
- Senza automazione, tenere traccia di queste variazioni è quasi impossibile in reti con centinaia di nodi [02:57](https://youtu.be/Kog9gHTjALI&t=177s).

## Configuration Provisioning: Modello a Template
Per scalare la gestione, i tool di automazione utilizzano due componenti essenziali [05:08](https://youtu.be/Kog9gHTjALI&t=308s):
1. **Templates**: File di configurazione standard con placeholder.
2. **Variables**: File separati contenenti i dati specifici (es. IP, hostname) che vengono iniettati nel template per generare la configurazione finale [05:23](https://youtu.be/Kog9gHTjALI&t=323s).

## Tool di Automazione a Confronto

### Ansible
È attualmente il tool più popolare per i Network Engineers grazie alla sua semplicità [08:04](https://youtu.be/Kog9gHTjALI&t=484s).
- **Architettura**: **Agentless** [08:18](https://youtu.be/Kog9gHTjALI&t=498s) (non richiede software installato sui nodi gestiti).
- **Protocollo**: Utilizza **SSH** per connettersi ai dispositivi [08:27](https://youtu.be/Kog9gHTjALI&t=507s).
- **Modello**: **Push** [08:44](https://youtu.be/Kog9gHTjALI&t=524s) (il Control Node spinge le modifiche verso i client).
- **Componenti chiave** [09:10](https://youtu.be/Kog9gHTjALI&t=550s):
    - **Playbooks**: "Blueprint" delle task scritti in **YAML**.
    - **Inventory**: Elenco dei dispositivi gestiti.
    - **Templates**: Basati su formato **Jinja2**.

### Puppet
Tool maturo, spesso preferito in ambienti server misti [10:55](https://youtu.be/Kog9gHTjALI&t=655s).
- **Architettura**: Tipicamente **Agent-based** [11:00](https://youtu.be/Kog9gHTjALI&t=660s) (esiste un'opzione agentless tramite proxy).
- **Modello**: **Pull** [11:30](https://youtu.be/Kog9gHTjALI&t=690s) (i nodi chiedono la configurazione al Puppet Master).
- **Comunicazione**: **HTTPS** su porta **TCP 8140** [11:39](https://youtu.be/Kog9gHTjALI&t=699s).
- **Terminologia**: Utilizza file chiamati **Manifests** [11:56](https://youtu.be/Kog9gHTjALI&t=716s) scritti in un linguaggio proprietario.

### Chef
Meno comune in ambito puramente networking, molto potente per l'infrastruttura IT globale [13:03](https://youtu.be/Kog9gHTjALI&t=783s).
- **Architettura**: Agent-based [13:07](https://youtu.be/Kog9gHTjALI&t=787s).
- **Modello**: Pull [13:22](https://youtu.be/Kog9gHTjALI&t=802s).
- **Comunicazione**: HTTPS su porta **TCP 10002** [13:25](https://youtu.be/Kog9gHTjALI&t=805s).
- **Terminologia "Culinarie"** [13:44](https://youtu.be/Kog9gHTjALI&t=824s):
    - **Resources**: Gli "ingredienti" della configurazione.
    - **Recipes**: Logica delle azioni da compiere.
    - **Cookbooks**: Gruppi di recipe correlate.
    - **Run-list**: L'ordine sequenziale in cui eseguire le recipe.

## Tabella Comparativa Finale
> [!INFO] Memorizzare questa tabella per l'esame CCNA [15:08](https://youtu.be/Kog9gHTjALI&t=908s).

| Caratteristica | Ansible | Puppet | Chef |
| :--- | :--- | :--- | :--- |
| Linguaggio | Python | Ruby | Ruby |
| Modello | Push | Pull | Pull |
| Setup | Agentless | Agent-based | Agent-based |
| Protocollo | SSH | HTTPS (8140) | HTTPS (10002) |
| File Principali| Playbook (YAML) | Manifest | Recipe / Cookbook |

## ⚠️ Avvertenze per l'Esame
> [!WARNING] Supporto Cisco
> Non tutti i dispositivi Cisco supportano gli agent di **Puppet** o **Chef**. Questo è uno dei motivi principali per cui **Ansible** (essendo agentless via SSH) è lo standard de facto nel networking [11:08](https://youtu.be/Kog9gHTjALI&t=668s).
