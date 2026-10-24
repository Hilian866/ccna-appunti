
### Scope CCNA

- **CORE CCNA**
    
- Base concettuale **critica** per VLAN, Trunk, Inter-VLAN

## LAN & Broadcast Domain

- **LAN**: **un singolo broadcast domain**
    
- **Broadcast domain**: dispositivi che ricevono frame con MAC `FFFF.FFFF.FFFF`
    
- **Router**: **non inoltra broadcast**
    
- **Switch**: flood di broadcast e unknown unicast
    

📌 **Confine concettuale**

- **Subnet ≠ Broadcast domain**
    
- Separare a L3 **non** separa automaticamente a L2

## Problema (senza VLAN)

- Tutti gli host sullo switch → **stesso broadcast domain**
    
- Effetti:
    
    - ❌ Broadcast inutili → performance ↓
        
    - ❌ Nessun controllo di sicurezza intra-LAN
        
- ACL/firewall sul router **inefficaci** se traffico resta a L2

## VLAN — definizione

- **VLAN (Virtual LAN)**: separazione **logica** di un dominio di broadcast a **Layer 2**
    
- Ogni VLAN = **broadcast domain distinto**
    
- VLAN configurate **sulle porte dello switch**
    

📌 **VLAN ≠ Subnet**

- VLAN → L2
    
- Subnet → L3
    
- Spesso mappate 1:1, ma **concetti diversi**

## Effetti delle VLAN

- Broadcast/unknown unicast **restano nella VLAN**
    
- Switch **non inoltra traffico tra VLAN**
    
- Comunicazione tra VLAN → **router necessario**
    

📌 **Confine concettuale da quiz**

- **Switch L2 ≠ inter-VLAN routing**
    
- Anche **stessa subnet**, VLAN diverse → **niente forwarding diretto**

## Inter-VLAN routing (anticipazione)

- Metodo visto: router
    
- Altri metodi esistono → **Day successivi**
    
- **NON CORE qui**, solo concetto

## Porte switch

- **Access port**
    
    - Appartiene a **una sola VLAN**
        
    - Tipicamente verso end host
        
- **Trunk port**
    
    - Trasporta **più VLAN**
        
    - **NON approfondito in Day 16**
        

📌 Best practice:

- Impostare **explicitly** `switchport mode access`
    
- Non affidarsi all’autonegotiation

## VLAN di default

- **VLAN 1**: default per tutte le porte
    
- **VLAN 1002–1005**: legacy (FDDI/Token Ring)
    
- **Non eliminabili**

## Comandi VLAN essenziali (CORE)

`show vlan brief`

```
interface range g1/0 - 3
 switchport mode access
 switchport access vlan 10
```

```
vlan 10
 name ENGINEERING
```

📌 **Quiz trap**

- Assegnare una porta a VLAN inesistente → **VLAN creata automaticamente**

## Comportamento broadcast (chiave d’esame)

- Broadcast inviato:
    
    - ricevuto **solo** da dispositivi nella **stessa VLAN**
        
- Senza VLAN:
    
    - ricevuto da **tutti** sullo switch

## Riassunto secco

- VLAN = separazione L2
    
- Ogni VLAN = broadcast domain
    
- Switch non collega VLAN tra loro
    
- Router necessario per comunicazione inter-VLAN
    
- VLAN configurate **per porta**

## Quiz pattern ricorrenti

- Conteggio broadcast domain
    
- VLAN create automaticamente
    
- VLAN default sempre presenti
    
- Differenza VLAN vs subnet