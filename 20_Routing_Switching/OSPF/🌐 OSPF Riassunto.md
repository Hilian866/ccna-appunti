

## 1. Il Cuore di OSPF (Definizione)

**OSPF (Open Shortest Path First)** è un protocollo **Link-State**. Ogni router non si fida ciecamente dei vicini, ma costruisce una **mappa completa** (LSDB) della rete e calcola i percorsi migliori usando l'algoritmo **SPF / Dijkstra**.

---

## 2. La Nascita della Rete (Timeline di Configurazione)

Quando abiliti OSPF su un'interfaccia, il router non conosce nessuno. Ecco cosa succede cronologicamente:

### A. Selezione dell'Identità (Router ID)

Prima di parlare, il router sceglie un nome (RID) seguendo questo ordine:

1. **Manuale:** `router-id 1.1.1.1` (Scelta consigliata).
    
2. **Loopback:** L'IP più alto su un'interfaccia virtuale Loopback.
    
3. **Fisica:** L'IP più alto su un'interfaccia fisica attiva.
    

### B. Il Primo Contatto (Neighbor Discovery)

Il router invia pacchetti **Hello** al multicast **224.0.0.5** ogni 10 secondi (su Ethernet).

> "Requisiti per diventare Neighbor (Se questi mancano, l'adiacenza non parte): Stessa Subnet e stessa Area. Timers (Hello/Dead) identici. * Password di autenticazione identica. * MTU coerente."


> **Parametri (Subnet, Area, Timer, Auth):** `show ip ospf interface <int>`
  >  
> **MTU:** `show interfaces <int> | include MTU`
>    
> **debug network type ed hello timer:** `show ip ospf interface`
  >  
> **Stato Vicini:** `show ip ospf neighbor`



### C. L'Elezione dei Ruoli (DR / BDR)

In una rete Ethernet (Broadcast), i router decidono chi comanda per ridurre il traffico (LSA Flooding).

- **DR (Designated Router):** Il "capo" che distribuisce le info.
    
- **BDR (Backup DR):** Il vice pronto a subentrare.
    
- **DROTHER:** Tutti gli altri router.
    

**Regole di Elezione:**

1. **Priority più alta** (Default = 1. Se 0, non può mai essere eletto).
    
2. **Router ID più alto** (In caso di parità di priorità).
    
3. **NON-PREEMPTIVE:** Una volta eletti, DR e BDR non cambiano se arriva un router "più forte", a meno di un reset o di un guasto.
    

**CLI di riferimento:**

```
! --- Imposta il Router ID (Globale) ---
router ospf 1
 router-id 1.1.1.1

! --- Imposta la Priorità (Sull'interfaccia) ---
interface g0/0
 ip ospf priority 255  ! Forza questo router a diventare DR (se resettato)
```
---

## 3. Adiacenza vs Vicinato: Chi arriva a "FULL"?

Non tutti i router si scambiano tutte le informazioni.

- **Neighbor (Stato 2-Way):** Relazione tra due **DROTHER**. Si vedono ma **non** si scambiano la mappa della rete.
    
- **Adjacency (Stato FULL):** Sincronizzazione completa del database (LSDB).
    
    - Ogni **DROTHER** arriva a **FULL** solo con il **DR** e il **BDR**.
        
    - **DR** e **BDR** sono in **FULL** tra di loro.
        

---

### 4. La Costruzione della Mappa (LSA & LSDB)

Una volta in stato **FULL**, i router si scambiano gli **LSA** (Link State Advertisements) per costruire la topologia della rete.

- **LSA Type 1 (Router LSA):** Generato da **ogni router**. Dice: "Io esisto e questi sono i miei link diretti".
    
- **LSA Type 2 (Network LSA):** Generato solo dal **DR**. Elenca tutti i router connessi a un segmento Broadcast (Ethernet).
    
- **LSA Type 3 (Summary LSA):** Generato dall'**ABR**. Annuncia le reti di un'area alle altre aree (Inter-Area).
    
- **LSA Type 4 (ASBR Summary LSA):** Generato dall'**ABR**. Spiega agli altri router come raggiungere l'ASBR.
    
- **LSA Type 5 (AS-External LSA):** Generato dall'**ASBR**. Contiene le rotte esterne al dominio OSPF, come rotte statiche o Internet.
    

**Risultato:** Grazie a questi messaggi, tutti i router della stessa area hanno una **LSDB (Link State Database) identica** , che usano come "mappa" per calcolare il cammino più breve con l'algoritmo di **Dijkstra**.

---

## 5. La Scelta del Percorso (Metric: Cost)

OSPF sceglie la strada basandosi sul **Costo** (più è basso, meglio è).

$$Cost = \frac{Reference Bandwidth (Default 100 Mbps)}{Interface Bandwidth}$$

> **Problema CCNA:** Di default, OSPF non distingue tra FastEthernet (100M) e Gigabit (1000M) perché entrambi danno costo 1. **Soluzione:** Cambiare la Reference Bandwidth su TUTTI i router: `auto-cost reference-bandwidth 100000` (per 100Gbps).



| **Tipo Interfaccia** | **Velocità Reale (BW)** | **Formula (Default 100M)** | **Costo Default**    | **Formula (Ref 10000M)** | **Nuovo Costo** |
| -------------------- | ----------------------- | -------------------------- | -------------------- | ------------------------ | --------------- |
| **Ethernet**         | 10 Mbps                 | 100 / 10                   | **10**               | 10000 / 10               | **1000**        |
| **FastEthernet**     | 100 Mbps                | 100 / 100                  | **1**                | 10000 / 100              | **100**         |
| **Gigabit**          | 1.000 Mbps              | 100 / 1000                 | **1** (arrotondato*) | 10000 / 1000             | **10**          |
| **10 Gigabit**       | 10.000 Mbps             | 100 / 10000                | **1** (arrotondato*) | 10000 / 10000            | **1**           |


In alternativa, puoi forzare il costo manualmente su una specifica interfaccia (sovrascrive il calcolo automatico):

```
interface g0/0
 ip ospf cost 50
```

---

## 6. Comandi Operativi (Cheat Sheet)

### Configurazione

Snippet di codice

```
! --- CONFIGURAZIONE GLOBALE ---
router ospf 1
 router-id 1.1.1.1
 auto-cost reference-bandwidth 10000 
 network 10.0.0.0 0.0.0.255 area 0  
 passive-interface g0/1             

! --- CONFIGURAZIONE INTERFACCIA ---
interface g0/0
 ip ospf 1 area 0                 
 ip ospf cost 50
 ! Cambia il tipo di rete (es. per evitare elezione DR/BDR su Ethernet)
 ip ospf network point-to-point
```

### Verifica e Troubleshooting

- `show ip ospf neighbor`: La colonna **State** deve essere **FULL** (o **2-WAY** tra DROthers).
    
- `show ip ospf interface brief`: Per vedere ruolo (**DR/BDR/POINT**), numero di adiacenze e stato.
    
- `show ip ospf interface <int>`: Per vedere il **Network Type** esplicito e i timer.
    
- `show ip route ospf`: Per vedere le rotte imparate.
    
- `clear ip ospf process`: Forza il riavvio del processo OSPF. **Indispensabile** per rendere effettivi i cambi di Router ID o forzare una nuova elezione DR/BDR (visto che non è preemptive).
    
- **MTU Mismatch**: Stato **EXSTART/EXCHANGE** = i router non riescono a scambiarsi i pacchetti DBD per via della dimensione diversa.
    
- **Network Type Mismatch**: Stato **FULL** ma **niente rotte** in tabella = il database è sincronizzato ma l'algoritmo SPF fallisce perché i tipi di rete non coincidono.