## What is it

OSPF usa come metrica il **cost**, calcolato in base alla banda delle interfacce e usato per scegliere il percorso migliore.

## How it works

### Cost

- Formula:  
    **Cost = Reference Bandwidth / Interface Bandwidth**
    
- Default reference bandwidth = **100 Mbps**
    
- Qualsiasi valore < 1 viene convertito in **1**

![[Screenshot_2 5.png]]
- Il **costo di una rotta** = somma dei costi delle **interfacce di uscita**
    
![[Screenshot_3 3.png]]
### Implicazione chiave (ESAME)

- FastEthernet, Gigabit, 10G → **stesso cost = 1** (default)
    
- **Va cambiata la reference bandwidth**
    

## CLI Core – Cost

```
router ospf 1  
auto-cost reference-bandwidth 100000 ! 
interface g0/0  
ip ospf cost 100
```

## CLI Core – OSPF (attivazione / passive)

### Attivazione OSPF direttamente su interfaccia

Alternativa al comando `network`.

```
interface g0/0
 ip ospf 1 area 0
```

- Attiva OSPF **solo sull’interfaccia**
    
- Il **process ID è localmente significativo**
    
- Non richiede `router ospf`
    

---

## Passive interface – metodo alternativo

Configura tutte le interfacce come passive, poi abilita solo quelle necessarie.

```
router ospf 1
 passive-interface default
 no passive-interface g0/0
```

- Tutte le interfacce **non inviano Hello**
    
- Solo le interfacce con `no passive-interface` formano neighbor
    
- Funzionalmente equivalente al metodo classico



## Modi per modificare il cost

1. `auto-cost reference-bandwidth` (**consigliato**)
    
2. `ip ospf cost` (per singola interfaccia)
    
3. `bandwidth` (sconsigliato: impatta altri protocolli)
    
![[Screenshot_4 2.png]]

---

## OSPF Neighbors – Stati

### Sequenza da ricordare (ESAME)

**Down → Init → 2-Way → ExStart → Exchange → Loading → Full**

### Sintesi funzionale

- **Down / Init / 2-Way** → scoperta neighbor
    
- **ExStart / Exchange / Loading** → sincronizzazione LSDB
    
- **Full** → adiacenza completa

![[Screenshot_6 3.png]]

![[Screenshot_5 4.png]]
### Dettagli chiave

- Hello multicast: **224.0.0.5**
    
- Protocol number IP: **89**
    
- Hello / Dead (Ethernet): **10 / 40 sec**
    
- Master/Slave deciso in **ExStart** (RID più alto = Master)
    

## CLI Core – Neighbor

```
show ip ospf neighbor
show ip ospf interface brief
```

## Common Mistakes

- Non distinguere **neighbor** da **adjacent neighbor**
    
- Dimenticare l’ordine degli stati
    
- Confondere **DR/BDR** con **Master/Slave**
    

## Synthesis

OSPF sceglie il percorso con il cost e crea adiacenze complete solo dopo la sincronizzazione delle LSDB.