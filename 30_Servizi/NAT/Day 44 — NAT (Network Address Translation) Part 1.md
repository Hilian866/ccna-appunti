
### What is it

**NAT (Network Address Translation)** modifica il **source e/o destination IP address** dei pacchetti.

Scopo principale:

- permettere a **host con IP privati** di comunicare su Internet
    
- aggirare la **scarsità di IPv4**
    

Exam topic **4.1**.

---

### Core CCNA — concetti fondamentali

#### Private IPv4 addresses (RFC 1918)

Intervalli **non instradabili su Internet**:

- `10.0.0.0/8 → (10.0.0.0 – 10.255.255.255)`
    
- `172.16.0.0/12 → (172.16.0.0 – 172.31.255.255)`
    
- `192.168.0.0/16 → (192.168.0.0 – 192.168.255.255)`
    

Caratteristiche:

- riutilizzabili liberamente nelle reti interne
    
- **ISP (Internet Service Provider) scarta traffico** con IP privati
    
- usati comunemente nelle LAN
    

---

### Why NAT exists

Senza NAT:

- IP privati **non possono uscire su Internet**
    
- indirizzi duplicati causano ambiguità
    

Con NAT:

- host interni “**prendono in prestito**” un IP pubblico
    
- comunicazione Internet possibile
    
- traduzione fatta dal **router di confine**
    

---

### Source NAT (overview)

- NAT **modifica il source IP**
    
- caso CCNA: **inside source NAT**
    
- la traduzione viene **invertita** al ritorno del traffico
    

Flusso base:

`Inside host (private IP) → router (NAT) → Internet Internet → router (reverse NAT) → inside host`

---

## Static Source NAT (focus del video)

### What it is

**Static NAT** = mapping **1:1** tra:

- **inside local** ↔ **inside global**
    

Ogni host interno:

- ha **un IP pubblico dedicato**
    
- mapping **permanente**


![[Screenshot_1 12.png]]

---

### NAT terminology (OBBLIGATORIO CCNA)

|Termine|Significato|
|---|---|
|Inside local|IP reale dell’host interno|
|Inside global|IP dell’host interno visto da Internet|
|Outside local|IP host esterno visto dalla rete interna|
|Outside global|IP reale host esterno|

Note:

- senza destination NAT → outside local = outside global
    
- “inside / outside” = **posizione**
    
- “local / global” = **prospettiva**
    

---

### Static NAT — esempio concettuale

- PC1: `192.168.0.167` → `100.0.0.1`
    
- PC2: `192.168.0.168` → `100.0.0.2`
    

Limite:

- **non conserva IP pubblici**
    
- ogni host richiede **1 IP pubblico**
    

---

### Configurazione Static NAT

#### Definizione interfacce

```
interface g0/1
 ip nat inside

interface g0/0
 ip nat outside
```


#### Mapping statico

```
ip nat inside source static 192.168.0.167 100.0.0.1
ip nat inside source static 192.168.0.168 100.0.0.2
```


---

### Verifica e troubleshooting

#### Tabella NAT

`show ip nat translations`

Osservazioni:

- entry statiche → **permanenti**
    
- entry dinamiche → create quando il traffico passa
    

#### Statistiche

`show ip nat statistics`

#### Pulizia entry dinamiche

`clear ip nat translation *`

---

### Key rules / exam points

- Static NAT = **1:1**
    
- Un IP pubblico **non può essere riutilizzato**
    
- Static NAT **non scala**
    
- Inside / Outside ≠ Local / Global
    
- ISP blocca IP privati
    
- Static NAT ≠ uso IP interfaccia router
    

---

### Common mistakes / notes

- confondere inside local / inside global
    
- dimenticare `ip nat inside / outside`
    
- tentare mapping multipli verso stesso IP pubblico
    
- pensare che Static NAT risolva il problema IP exhaustion