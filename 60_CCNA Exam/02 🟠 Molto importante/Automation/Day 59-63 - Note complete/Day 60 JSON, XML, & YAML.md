---
tags: [ccna, exam, automation]
priorita: molto-importante
stato: da-ripassare
---

> [!ABSTRACT] Core Logic
> La **Data Serialization** è il processo di conversione dei dati in un formato standardizzato per consentirne l'archiviazione o la trasmissione tra applicazioni diverse (es. Python e Java) e tra controller SDN e dispositivi di rete. È il linguaggio universale delle **API** e dell'automazione.

---

## 🏗️ Fondamenti della Serializzazione
La serializzazione permette di rappresentare variabili e strutture dati complesse sotto forma di testo leggibile [01:34](https://youtu.be/nohde2-QNJ4&t=94s). Senza uno standard, due applicazioni scritte in linguaggi diversi non potrebbero interpretare correttamente i dati scambiati [02:53](https://youtu.be/nohde2-QNJ4&t=173s).

> [!INFO] Variabili come Container
> In questo contesto, le variabili sono container che memorizzano valori (es. `interface_name`: `GigabitEthernet1/1`) [02:37](https://youtu.be/nohde2-QNJ4&t=157s).

---

## 🌐 JSON (JavaScript Object Notation)
È il formato più rilevante per l'esame CCNA (Topic 6.7) ed è ampiamente utilizzato nelle **REST API** [04:10](https://youtu.be/nohde2-QNJ4&t=250s).

### Caratteristiche Chiave:
- **Standard:** Definito in **RFC 8259** [04:41](https://youtu.be/nohde2-QNJ4&t=281s).
- **Indipendenza:** Nonostante il nome, è indipendente dal linguaggio di programmazione.
- **Whitespace:** Spazi e a capo sono insignificanti per il computer (ma utili per l'uomo) [05:19](https://youtu.be/nohde2-QNJ4&t=319s).

### 📑 Data Types in JSON
JSON supporta 6 tipi di dati fondamentali, divisi in primitivi e strutturati [05:33](https://youtu.be/nohde2-QNJ4&t=333s):

| Tipo | Descrizione | Esempio | Timestamp |
| :--- | :--- | :--- | :--- |
| **String** | Testo racchiuso in doppi apici `""` | `"Up"`, `"10.1.1.1"` | [05:55](https://youtu.be/nohde2-QNJ4&t=355s) |
| **Number** | Valore numerico (senza apici) | `1000`, `1.5` | [06:18](https://youtu.be/nohde2-QNJ4&t=378s) |
| **Boolean** | Valore logico (case sensitive: minuscolo) | `true`, `false` | [06:39](https://youtu.be/nohde2-QNJ4&t=399s) |
| **Null** | Assenza intenzionale di un valore | `null` | [07:28](https://youtu.be/nohde2-QNJ4&t=448s) |
| **Object** | Lista non ordinata di coppie **key-value** `{}` | `{"key": "value"}` | [08:06](https://youtu.be/nohde2-QNJ4&t=486s) |
| **Array** | Lista ordinata di valori racchiusa in `[]` | `["G0/1", "G0/2"]` | [12:47](https://youtu.be/nohde2-QNJ4&t=767s) |

> [!WARNING] Errore Comune
> Una stringa che contiene un numero (es. `"5"`) è diversa da un tipo **Number** (es. `5`). In JSON, i doppi apici definiscono sempre una **String** [06:27](https://youtu.be/nohde2-QNJ4&t=387s).

---

## 🏗️ Strutture Dati Complesse
- **Key-Value Pairs:** La chiave deve essere sempre una stringa, separata dal valore da due punti `:` [08:19](https://youtu.be/nohde2-QNJ4&t=499s).
- **Nested Objects:** Un oggetto può contenere un altro oggetto come valore, permettendo gerarchie complesse [11:55](https://youtu.be/nohde2-QNJ4&t=715s).
- **Array di Oggetti:** Spesso usato per elencare configurazioni simili, come le interfacce di un router [14:04](https://youtu.be/nohde2-QNJ4&t=844s).

---

## 📊 Confronto tra Formati (XML vs YAML)

### 🏷️ XML (Extensible Markup Language)
Nato come linguaggio di markup (simile a HTML), oggi usato per la serializzazione [15:10](https://youtu.be/nohde2-QNJ4&t=910s).
- Utilizza i **tag** per definire chiavi e valori: `<key>value</key>` [15:51](https://youtu.be/nohde2-QNJ4&t=951s).
- È considerato meno leggibile dall'uomo rispetto a JSON [15:31](https://youtu.be/nohde2-QNJ4&t=931s).

### 📝 YAML (YAML Ain't Markup Language)
Il formato più "human-friendly", molto usato in tool di automazione come **Ansible** [17:26](https://youtu.be/nohde2-QNJ4&t=1046s).
- **Significatività del Whitespace:** A differenza di JSON/XML, l'indentazione **è fondamentale** per definire la struttura [18:05](https://youtu.be/nohde2-QNJ4&t=1085s).
- Inizia tipicamente con tre trattini `---` [18:15](https://youtu.be/nohde2-QNJ4&t=1095s).
- Liste indicate con un trattino `-` [18:18](https://youtu.be/nohde2-QNJ4&t=1098s).

---

## ⚖️ Tabella Comparativa Finale

| Feature | JSON | XML | YAML |
| :--- | :--- | :--- | :--- |
| **Leggibilità** | Alta | Media | Eccellente |
| **Sintassi** | `{ }`, `[ ]`, `:` | `<tag> </tag>` | Indentazione, `-` |
| **Utilizzo Principale** | REST APIs | REST / Legacy | Ansible / Config |
| **Whitespace** | Irrilevante | Irrilevante | **Significativo** |

---

> [!ABSTRACT] Quiz Review
> - **In JSON**, l'ultima coppia key-value di un oggetto **non** deve avere la virgola finale [13:31](https://youtu.be/nohde2-QNJ4&t=811s).
> - **In YAML**, la corretta indentazione definisce l'appartenenza di un dato a un oggetto superiore [18:09](https://youtu.be/nohde2-QNJ4&t=1089s).

---

#Networks #CCNA #Automation #JSON #XML #YAML
