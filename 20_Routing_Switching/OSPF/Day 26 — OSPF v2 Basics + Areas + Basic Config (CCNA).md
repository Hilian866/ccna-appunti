
### 1) Cos’è OSPF (in 1 riga)

**OSPF (Open Shortest Path First)** è un **routing protocol link-state**: ogni router costruisce una mappa completa della rete e calcola i best path con **SPF / Dijkstra**.

## 2) Link-state: il “flow” mentale (3 step CCNA)

### Step 1 — Neighbor adjacency 🤝

- I router sullo stesso segmento diventano **neighbor** (scambio _Hello_).
    

### Step 2 — LSA flooding 🌊

- I router generano e **floodano LSAs** (Link-State Advertisements).
    
- Tutti i router della stessa area finiscono con una **LSDB identica** (Link-State Database).
    

### Step 3 — SPF calculation 🧠

- Ogni router esegue **SPF (Dijkstra)** sulla LSDB e installa i best route in tabella.
    

**Termini core**

- **LSA** = “pezzo” di info sullo stato dei link.
    
- **LSDB** = collezione di LSAs = “mappa della rete”.
    
- **Flooding** = inoltro delle LSAs a tutti i neighbor dell’area.

## 3) Versioni OSPF (da non confondere)

- **OSPFv2** → IPv4 (**quello del CCNA**)
    
- **OSPFv3** → IPv6 (può anche IPv4 ma non è il focus CCNA)

## 4) OSPF Areas (concetto + regole minime CCNA)

### Cos’è un’area

Un’**area** è un set di router e link che condividono la **stessa LSDB**.

### Backbone area = Area 0

- È l’area “spina dorsale”.
    
- **Tutte le altre aree devono connettersi ad Area 0** (regola base).
    

### Router roles (termini che ti chiedono)

- **Internal router**: tutte le interfacce in **una sola area**
    
- **ABR (Area Border Router)**: interfacce in **più aree** (tipico: area 0 + altra area)
    
    - Mantiene **una LSDB per area**
        
- **Backbone router**: qualsiasi router con almeno un’interfaccia in **Area 0** (include ABR)
    
- **ASBR (Autonomous System Boundary Router)**: router che collega OSPF a **reti esterne** e introduce routes esterne (es. default verso Internet)
    

### Route types (termini)

- **Intra-area**: destinazione nella _stessa area_
    
- **Inter-area**: destinazione in _area diversa_
    

### Regole “a memoria” (minimo)

1. **Area 0** deve essere il punto di connessione di tutte le altre aree
    
2. Aree **contigue** (non spezzate in due)
    
3. Interfacce nello **stesso subnet** devono stare nella **stessa area** (altrimenti niente neighbor)

## 5) Config base OSPF (single-area) 🔧

### Entrare nel processo

`router ospf 1`

- **Process ID**: _localmente significativo_ (non deve matchare altri router).
    

### Attivare OSPF sulle interfacce (network + wildcard + area)

```
network 10.0.12.0 0.0.0.15 area 0
network 10.0.13.0 0.0.0.63 area 0
```

**Nota chiave:** il `network` **non “annuncia una rete”**, ma **seleziona le interfacce** i cui IP matchano quel range e abilita OSPF lì, nell’area indicata.

## 6) Passive-interface (stesso concetto di RIP/EIGRP) 🤫

```
router ospf 1
passive-interface g2/0
```

- Non manda **Hello** su quella porta → non cerca neighbor
    
- **Continua a pubblicare** la subnet dell’interfaccia tramite LSAs verso gli altri neighbor
    

**Best practice CCNA:** passive su interfacce verso **LAN con host**, non verso router.

## 7) Default route in OSPF (e ASBR) 🌐

1. Crea la default statica:
    

`ip route 0.0.0.0 0.0.0.0 203.0.113.2`

2. Inietta la default in OSPF:
    

```
router ospf 1
default-information originate
```

Effetto:

- gli altri router installano **O*E2 0.0.0.0/0** (tipicamente)
    
- il router che origina diventa **ASBR** (perché introduce info verso esterno)

## 8) Router ID (RID) ✅

### Order of selection (da sapere)

1. `router-id X.X.X.X` (manuale) 🥇
    
2. IP più alto su **loopback**
    
3. IP più alto su **interfaccia fisica**
    

Config:

```
router ospf 1
router-id 1.1.1.1
```

Per farlo prendere:

- reload **oppure**
    

`clear ip ospf process`

⚠️ In produzione è disruptive (reset OSPF).

## 9) Comandi show utili (Day 26 level)

```
show ip protocols
show ip route
show ip ospf neighbor
```

`show ip protocols` ti fa vedere:

- process ID
    
- router-id
    
- network statements
    
- passive interfaces
    
- neighbor list
    
- AD (default **110**)

## 10) Mini “error traps” da evitare 🧨

- **Process ID ≠ area** (non confonderli)
    
- Single-area OSPF **non deve per forza** essere area 0 (ma è best practice)
    
- Interfacce nello stesso subnet ma **aree diverse** → **niente neighbor**
    
- `router-id` non cambia “live” senza reload/clear