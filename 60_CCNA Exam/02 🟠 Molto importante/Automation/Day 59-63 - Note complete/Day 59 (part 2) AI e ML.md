---
tags: [ccna, exam, automation]
priorita: molto-importante
stato: da-ripassare
---

> [!ABSTRACT] Core Logic
> Analisi dei fondamentali di **Artificial Intelligence (AI)** e **Machine Learning (ML)** applicati al networking, con focus sui modelli di apprendimento e sulle funzionalità intelligenti del **Cisco Catalyst Center**.

---

## 🌐 Definizioni Fondamentali

> [!INFO] **Artificial Intelligence (AI)**
> L'uso di sistemi computazionali per simulare l'intelligenza umana, inclusi il riconoscimento di pattern, l'apprendimento autonomo e il problem solving. [01:52](https://www.youtube.com/watch?v=Fn_kAv35W5A&t=112s)

> [!INFO] **Machine Learning (ML)**
> Un sottogruppo dell'AI che permette ai computer di apprendere dai dati e migliorare le performance nel tempo senza essere esplicitamente programmati per ogni specifica attività. [04:08](https://www.youtube.com/watch?v=Fn_kAv35W5A&t=248s)

---

## 🛠️ Tipologie di Machine Learning

| Tipo              | Funzionamento                                               | Applicazione Tipica                      | Timestamp                                                   |
| :---------------- | :---------------------------------------------------------- | :--------------------------------------- | :---------------------------------------------------------- |
| **Supervised**    | Allestito su **Labeled Data** (dati etichettati).           | Classificazione immagini, filtri spam.   | [06:27](https://www.youtube.com/watch?v=Fn_kAv35W5A&t=387s) |
| **Unsupervised**  | Analizza dati non etichettati per trovare cluster.          | Segmentazione clienti, pattern nascosti. | [10:28](https://www.youtube.com/watch?v=Fn_kAv35W5A&t=628s) |
| **Reinforcement** | Basato su un sistema di **premi/penalità** (trial & error). | Auto a guida autonoma, Game AI.          | [13:15](https://www.youtube.com/watch?v=Fn_kAv35W5A&t=795s) |
| **Deep Learning** | Utilizza **Artificial Neural Networks** multistrato.        | Riconoscimento vocale, LLM complessi.    | [16:17](https://www.youtube.com/watch?v=Fn_kAv35W5A&t=977s) |

---

## 📊 Predictive AI vs Generative AI nel Networking

## 🔮 Predictive AI
Analizza i dati storici per prevedere eventi futuri. [20:48](https://www.youtube.com/watch?v=Fn_kAv35W5A&t=1248)
- **Traffic Forecasting:** Ottimizzazione della banda e prevenzione della congestione.
- **Security Threat Detection:** Identificazione proattiva di anomalie e attacchi.
- **Predictive Maintenance:** Sostituzione hardware prima del guasto critico.

## 🎨 Generative AI
Crea nuovi contenuti (testo, immagini, codice) basandosi su pattern appresi. [21:45](https://www.youtube.com/watch?v=Fn_kAv35W5A&t=1305s)
- **Generazione Configurazioni:** Creazione automatica di script per dispositivi di rete.
- **Troubleshooting:** Analisi dei log e suggerimenti di risoluzione.
- **Scripting:** Automazione tramite script **Python** generati dall'AI. [28:32](https://www.youtube.com/watch?v=Fn_kAv35W5A&t=1712s)

> [!CAUTION] **Rischio Allucinazioni**
> I modelli **LLM** (come ChatGPT) possono generare configurazioni sintatticamente corrette ma tecnicamente errate. È imperativo verificare sempre l'output prima dell'implementazione in produzione. [25:18](https://www.youtube.com/watch?v=Fn_kAv35W5A&t=1518s)

---

## 🏛️ AI nel Cisco Catalyst Center (ex DNA Center)

L'infrastruttura Cisco utilizza l'AI per passare da una gestione reattiva a una **proattiva**. [29:01](https://www.youtube.com/watch?v=Fn_kAv35W5A&t=1741s)

## 🚀 Funzionalità Chiave:
1. **AI Network Analytics:** Stabilisce una **baseline** del comportamento normale della rete per rilevare anomalie specifiche. [29:51](https://www.youtube.com/watch?v=Fn_kAv35W5A&t=1791s)
- **Machine Reasoning Engine (MRE):** Esegue la **Root-cause analysis** automatizzata per risolvere problemi complessi più velocemente. [30:52](https://www.youtube.com/watch?v=Fn_kAv35W5A&t=1852s)
1. **AI Endpoint Analytics:** Identifica e classifica i dispositivi connessi (IoT, PC, Mobile) per applicare policy di sicurezza e **segmentazione**. [32:02](https://www.youtube.com/watch?v=Fn_kAv35W5A&t=1922s)
2. **AI-Enhanced RRM:** Ottimizza le frequenze Wi-Fi e la potenza di trasmissione degli Access Point per ridurre le interferenze. [32:51](https://www.youtube.com/watch?v=Fn_kAv35W5A&t=1971s)

---

## 📝 Esempio di Automazione AI (Python)
L'AI può generare script per automatizzare il **Control Plane**:

```python
from netmiko import ConnectHandler

def enable_interface(device_ip, interface):
    # Esempio di script generato per abilitare una G0/0
    device = {
        'device_type': 'cisco_ios',
        'host': device_ip,
        'username': 'admin',
        'password': 'password123',
    }
    with ConnectHandler(**device) as net_connect:
        config_commands = [f'interface {interface}', 'no shutdown']
        output = net_connect.send_config_set(config_commands)
        print(output)
```

---

> [!ABSTRACT] **Summary per l'esame CCNA**
> - Comprendere la differenza tra **Supervised** (etichettato) e **Unsupervised** (non etichettato).
> - Sapere che le **Neural Networks** sono alla base del Deep Learning.
> - Riconoscere **MRE** e **AI Network Analytics** come pilastri del Cisco Catalyst Center.
> - Ricordare che l'AI nelle reti serve a creare **Baselines**, ottimizzare il **Wi-Fi (RRM)** e accelerare la **Root-cause analysis**. [35:54](https://www.youtube.com/watch?v=Fn_kAv35W5A&t=2154s)

---

#Networks #CCNA #Cisco #AI #MachineLearning #Automation
