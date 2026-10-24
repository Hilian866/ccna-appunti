


### What does / How it works

#### Ruoli Fisici (Cabling)

In ogni collegamento seriale, un'estremità deve agire da "orologio" per sincronizzare la trasmissione:

- **DCE (Data Communications Equipment)**:
    
    - Fornisce il segnale di temporizzazione (**clocking**)
        
    - Necessita del comando `clock rate`
        
- **DTE (Data Terminal Equipment)**:
    
    - Riceve il clocking dal lato DCE
        
    - Non richiede configurazione di clock
        

#### Default behavior (Cisco)

- Incapsulamento: **HDLC** (Cisco Proprietary)
    
- Stato iniziale: **Administratively down** (richiede `no shutdown`)
    
- Velocità: Determinata dal `clock rate` impostato sul DCE

### Why we use it (collegamento diretto all’esame)

Sebbene rimpiazzate da Metro Ethernet e Fibra, compaiono nel CCNA per:

- Comprendere i concetti di **Point-to-Point** (nessun bisogno di ARP)
    
- Studiare il comportamento di **OSPF** (nessuna elezione di DR/BDR)
    
- Verificare la distinzione tra **Layer 1** (DCE/DTE) e **Layer 2** (HDLC/PPP)

## Configurazione Necessaria (Punto critico)

Il protocollo sale (Line Protocol UP) solo se:

1. Gli indirizzi IP sono nella **stessa subnet**
    
2. L'incapsulamento è **identico** su entrambi i lati
    
3. Il lato DCE ha un **clock rate** configurato
    
4. Entrambe le interfacce sono in `no shutdown`

## CLI

### Verifica e Diagnosi

Bash

```
# Verifica chi è DCE e chi è DTE (fondamentale)
show controllers s0/0/0

# Verifica stato L1 e L2 e incapsulamento
show interfaces s0/0/0

# Verifica rapida indirizzi e stato
show ip interface brief
```

### Configurazione (Esempio R1-R2)

Bash

```
# Lato DCE (es. R1)
interface s0/0/0
 ip address 192.168.12.1 255.255.255.252
 clock rate 128000
 no shutdown

# Lato DTE (es. R2)
interface s0/0/0
 ip address 192.168.12.2 255.255.255.252
 no shutdown
```

## Common mistakes (da quiz)

- **Clock rate sul DTE**: Il comando viene accettato ma è inutile/ignorato.
    
- **Mismatch incapsulamento**: Un lato HDLC e l'altro PPP porterà il protocollo in `down`.
    
- **Cavo invertito**: Configurare il clock rate sul router che il comando `show controllers` indica come DTE.