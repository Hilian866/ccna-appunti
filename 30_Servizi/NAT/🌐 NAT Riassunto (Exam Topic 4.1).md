
---

### 1. Il Perimetro: Indirizzi Privati (RFC 1918)

Gli IP privati sono **variabili interne** non instradabili. Gli ISP scartano questi pacchetti per prevenire la collisione di nodi globali.

|**Classe**|**Intervallo**|**CIDR**|
|---|---|---|
|**A**|`10.0.0.0` – `10.255.255.255`|`/8`|
|**B**|`172.16.0.0` – `172.31.255.255`|`/12`|
|**C**|`192.168.0.0` – `192.168.255.255`|`/16`|

---

### 2. La Matrice Terminologica (Critico)

Per non confondersi, usa questa bussola:

- **Inside / Outside:** Dove si trova fisicamente l'host rispetto al router.
    
- **Local / Global:** Com'è visto l'indirizzo (Local = dall'interno, Global = da Internet).
    

|**Termine**|**Definizione Tecnica**|**Prospettiva**|
|---|---|---|
|**Inside Local**|IP privato reale dell'host interno.|Interna|
|**Inside Global**|IP pubblico che rappresenta l'host su Internet.|Esterna|
|**Outside Local**|IP dell'host esterno come appare alla LAN.|Interna|
|**Outside Global**|IP pubblico reale dell'host esterno.|Esterna|

> **Nota:** Se non c'è Destination NAT, `Outside Local` e `Outside Global` sono identici.

---

### 3. Tassonomia delle Traduzioni

#### **A. Static NAT (Mapping 1:1)**

- **Meccanismo:** Un IP privato è legato permanentemente a un IP pubblico.
    
- **Uso:** Server interni (Web, Mail) che devono essere raggiungibili dall'esterno.
    
- **Limite:** Non risparmia indirizzi; 100 host = 100 IP pubblici.
    

#### **B. Dynamic NAT (Pool 1:1)**

- **Meccanismo:** Gli IP pubblici sono in un "pool". L'host ne prende uno solo quando comunica.
    
- **Peculiarità:** Se il pool è vuoto, il router **scarta (drop)** i nuovi pacchetti.
    
- **ACL:** Qui l'ACL **identifica** chi può essere tradotto, non filtra il traffico.
    

#### **C. PAT / NAT Overload (Many-to-One)**

- **Meccanismo:** Usa le **porte Layer 4** per distinguere i flussi.
    
- **Vantaggio:** Migliaia di host usano **un solo IP pubblico** (quello dell'interfaccia o di un pool).
    

---

### 4. Protocollo di Configurazione (CLI)

#### **Fase 1: Definizione Confini**

```
interface g0/0
 ip nat inside    # Lato LAN
interface g0/1
 ip nat outside   # Lato WAN
```


#### **Fase 2: Selezione e Mapping**

- **Per PAT su Interfaccia (Il più comune):**
    

```
access-list 1 permit 192.168.1.0 0.0.0.255
ip nat inside source list 1 interface g0/1 overload 
```



- **Per Dynamic NAT con Pool:**
    

```
ip nat pool MIO_POOL 100.0.0.1 100.0.0.10 netmask 255.255.255.0 
ip nat inside source list 1 pool MIO_POOL 
```

---

### 5. Troubleshooting & Audit

- **`show ip nat translations`**: Mostra la tabella attiva. Le entry statiche sono sempre presenti, quelle dinamiche scompaiono dopo un timeout.
    
- **`show ip nat statistics`**: Indica hit, miss e se il pool è esaurito.
    
- **`debug ip nat`**: (Usa con cautela) Mostra le traduzioni in tempo reale nel formato `s=192.168.1.1->1.1.1.1`.
    

---

### ⚠️ Errori da "Red Flag" all'Esame

1. **Dimenticare `overload`:** Trasformi un PAT in un Dynamic NAT. Solo il primo utente navigherà, gli altri saranno bloccati finché il primo non chiude la sessione.
    
2. **Invertire Inside/Outside:** Il router non tradurrà nulla perché cercherà di applicare le regole sulle porte sbagliate.
    
3. **ACL Deny:** Se l'ACL collegata al NAT ha un `deny`, il traffico **passa ma non viene tradotto**. Risultato: il pacchetto arriva all'ISP con IP privato e viene scartato lì. Non è un "drop" del router, ma un fallimento della connettività end-to-end.
    

