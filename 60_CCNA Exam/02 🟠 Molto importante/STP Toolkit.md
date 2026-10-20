---
tags: [ccna, exam]
priorita: molto-importante
stato: da-ripassare
---

## 1. PortFast (Edge Connectivity) [▶ video](https://youtu.be/zqzppl4LOwk?list=PLxbwE86jKRgMpuZuLBivzlM8s2Dk5lXBQ&t=195)

Bypassa gli stati Listening e Learning per portare la porta in **Forwarding in <1 secondo**.

- **Target:** Solo porte collegate a dispositivi finali (PC, Server, Stampanti).
- **Meccanica:** Elimina il ritardo di 30s che causerebbe il timeout di richieste DHCP o l'errore di login ai domini Windows.
- **Comandi Chiave:**
    - `spanning-tree portfast` (Interface level).
    - `spanning-tree portfast default` (Global level - si applica a tutte le porte `access`).
- **Eccezione Trunk:** Usa `spanning-tree portfast trunk` solo per router (ROAS) o server ESXi/Hyper-V.

---

## 2. BPDU Guard (The "Hard" Defense) [▶ video](https://youtu.be/jfC_AeJnuhY?t=360)

Protegge le porte PortFast dall'inserimento di switch non autorizzati.

- **Trigger:** Se riceve **qualsiasi** BPDU.
- **Effetto:** Porta in **err-disabled** (spenta logicamente).
- **Configurazione Best-Practice:** * `spanning-tree portfast bpduguard default` (Abilita la protezione su tutte le porte dove PortFast è attivo).
- **Recovery:** * Manuale: `shutdown` seguito da `no shutdown`.
    - Automatica: `errdisable recovery cause bpduguard`.

---

## 3. BPDU Filter (The "Silence" Tool) [▶ video](https://youtu.be/jfC_AeJnuhY?t=899)

Smette di inviare BPDU verso i dispositivi finali per ridurre il rumore sulla rete.

- **Comportamento Globale (Consigliato):** Se riceve un BPDU, lo switch **rimuove** il filtro e PortFast, trattando la porta come un link STP standard (Protezione attiva).
- **Comportamento Interfaccia (Pericoloso):** Ignora i BPDU ricevuti e non ne invia. **Disabilita STP di fatto.**
- **Esame Tip:** Se abiliti BPDU Filter a livello interfaccia, il **BPDU Guard non scatta mai**, perché il filtro "nasconde" il BPDU prima che la protezione lo veda.

---

## 4. Root Guard (Topology Enforcement) [▶ video](https://youtu.be/2XE_PgkvSic?list=PLxbwE86jKRgMpuZuLBivzlM8s2Dk5lXBQ&t=501)

Garantisce che il Core Switch rimanga il Root Bridge, a prescindere da chi viene collegato esternamente.

- **Trigger:** Ricezione di un **Superior BPDU** (BID migliore).
- **Stato:** **ROOT_Inc (Root Inconsistent)**. La porta smette di inoltrare traffico ma resta UP.
- **Recovery:** Automatica non appena cessano i BPDU "aggressivi".
- **Placement:** Si configura sulle porte **Designated** rivolte verso switch esterni o secondari.

---

## 5. Loop Guard (Unidirectional link protection) [▶ video](https://youtu.be/uJ5_Klha0ig?list=PLxbwE86jKRgMpuZuLBivzlM8s2Dk5lXBQ&t=431)

Previene i loop causati da guasti ai cavi (es. fibra che riceve ma non trasmette).

- **Trigger:** Quando una **Root Port** o **Alternate Port** smette improvvisamente di ricevere BPDU.
- **Stato:** **LOOP_Inc (Loop Inconsistent)**. Impedisce alla porta di diventare Designated e creare un loop.
- **Differenza con Root Guard:** Sono mutuamente esclusivi. Root Guard protegge le DP (Designated), Loop Guard protegge le RP (Root) e le AP (Alternate).

---

## Pro-Tip per l'Esame: Tabella di Contrasto Rapido

|**Feature**|**Applicazione**|**Violazione = ?**|**Logica CCNA**|
|---|---|---|---|
|**BPDU Guard**|Access/Edge|**err-disabled**|"Non voglio switch qui"|
|**Root Guard**|Uplink/Distribution|**ROOT_Inc**|"Non voglio un nuovo Root"|
|**Loop Guard**|Uplink/RP/AP|**LOOP_Inc**|"Il link è rotto, non aprire"|
|**BPDU Filter**|Access/Edge|**Filtro OFF** (Global)|"Silenzio, ma vigilo"|

---

## Final Check: Errori Comuni da evitare

1. **BPDU Guard vs Root Guard:** BPDU Guard spegne la porta (`err-disable`), Root Guard la mette in pausa (`inconsistent`).
2. **Handshake RSTP:** Ricorda che in RSTP (802.1w), PortFast è rinominato **Edge Port**, ma i comandi IOS rimangono spesso identici per retrocompatibilità.
3. **Show Commands:** Usa `show spanning-tree inconsistentports` per identificare rapidamente perché una porta è bloccata da Root o Loop Guard.

---

## 🎯 Synthesis
PortFast/BPDU Guard proteggono le porte access, Root Guard difende il root, Loop Guard evita loop da BPDU mancanti.
