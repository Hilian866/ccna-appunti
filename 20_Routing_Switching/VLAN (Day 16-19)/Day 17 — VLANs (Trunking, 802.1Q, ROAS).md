
### Scope CCNA

- **CORE CCNA**: trunk, 802.1Q tag, native VLAN, allowed VLANs, router-on-a-stick

## Trunk port

- **Trunk port**: porta switch che trasporta **più VLAN** su **un singolo link**
    
- **Access port**: porta switch in **una sola VLAN** (untagged)
    

📌 Confini concettuali

- **Trunk = tagged port**
    
- **Access = untagged port**
    
- Trunk serve a evitare “1 cavo per VLAN” (non scalabile)

## Perché servono i trunk

- VLAN distribuite su più switch → serve trasportare traffico di più VLAN tra switch e verso router
    
- Alternativa “link per VLAN” = spreco porte / router senza abbastanza interfacce

## VLAN tagging (802.1Q)

- **802.1Q**: standard per **taggare** frame Ethernet su trunk
    
- **ISL**: vecchio Cisco proprietary, praticamente morto → **NON core** (solo riconoscimento)
    

### Dove sta il tag

- Tag 802.1Q inserito **tra Source MAC** e **Type/Length**
    

### Dimensione e campi

- **Tag 802.1Q = 4 byte (32 bit)**
    
- Due macro-campi:
    
    - **TPID** (16 bit): valore fisso **0x8100** → indica frame tagged
        
    - **TCI** (16 bit): contiene **PCP / DEI / VID**
        

#### TCI sub-campi (atomiche)

- **PCP (3 bit)**: Class of Service (priorità) _(QoS-lite)_
    
- **DEI (1 bit)**: “drop eligible” se congestione
    
- **VID (12 bit)**: **VLAN ID** (campo che identifica la VLAN) ✅
    

📌 Quiz trap

- Campo VLAN ID nella tag: **VID**, non PCP/TPID

## Range VLAN

- **VLAN ID teorici (12 bit)**: 0–4095
    
- **VLAN utilizzabili (1–4094)**
    
    - **0** e **4095** riservate
        

_(Nel tuo testo compaiono numeri errati tipo 494/495 → qui va corretto per CCNA: 4094.)_

### Normal vs Extended

- **Normal VLAN**: **1–1005**
    
- **Extended VLAN**: **1006–4094**

## Native VLAN (802.1Q)

- **Native VLAN**: VLAN i cui frame su trunk vengono inviati **untagged**
    
- Default: **VLAN 1**
    
- Se ricevi un frame untagged su trunk → lo switch lo tratta come native VLAN
    

📌 Confini concettuali

- **Native VLAN ≠ Allowed VLAN list**
    
- **Native VLAN mismatch** tra due switch → traffico untagged interpretato in VLAN sbagliata → problemi reali
    

Best practice (menzionata)

- Cambiare native VLAN a **VLAN non usata** (es. 1001) per sicurezza

## Config trunk (switch)

### Rendere una porta trunk

```
interface g0/1
 switchport mode trunk
```

### Se lo switch supporta più encapsulation (ISL + 802.1Q)

- Potrebbe servire prima:
    

```
switchport trunk encapsulation dot1q
switchport mode trunk
```

📌 Nota

- Su switch “solo dot1q” il comando encapsulation può non esistere/servire
    

### Verifica trunk

`show interfaces trunk`

## Allowed VLANs su trunk

- Default: **tutte** le VLAN **1–4094** allowed
    

Comandi:

```
switchport trunk allowed vlan 10,30
switchport trunk allowed vlan add 20
switchport trunk allowed vlan remove 20
switchport trunk allowed vlan all
switchport trunk allowed vlan none
switchport trunk allowed vlan except 1-5,10
```

📌 Quiz trap (output show interfaces trunk)

- Se VLAN è “allowed” ma **non esiste sullo switch**, può non apparire in “allowed and active…”
    
    - Soluzione: **creare la VLAN** (o assegnare una porta access a quella VLAN)

## Native VLAN config (switch)

`switchport trunk native vlan 1001`

📌 Quiz trap

- `show vlan brief` mostra **porte access** per VLAN, **non** trunk
    
- Per trunk: **`show interfaces trunk`**

## Router-on-a-Stick (ROAS)

- **ROAS**: inter-VLAN routing usando **1 sola interfaccia fisica** router↔switch (trunk) + **subinterfaces** sul router
    
- Switch: porta verso router = **trunk** con VLAN necessarie allowed
    
- Router: subinterface per VLAN
    

### Config router (pattern)

```
interface g0/0
 no shutdown

interface g0/0.10
 encapsulation dot1q 10
 ip address <GW_VLAN10> <mask>

interface g0/0.20
 encapsulation dot1q 20
 ip address <GW_VLAN20> <mask>

interface g0/0.30
 encapsulation dot1q 30
 ip address <GW_VLAN30> <mask>
```


📌 Confini concettuali

- Numero subinterface **non deve** matchare VLAN, ma **best practice: sì**
    
- La **fisica g0/0** spesso **senza IP**, IP sulle subinterface
    

Verifica:

```
show ip interface brief
show ip route
```

## Flusso logico (ROAS)

- Frame arriva al router tagged VLAN 10 → trattato come arrivato su **g0/0.10**
    
- Router route → esce da subinterface corretta (es. .30) **taggando VLAN 30**

## Quiz pattern (dalla lezione)

- “VLAN untagged su trunk” → native VLAN
    
- Reset allowed VLANs → `switchport trunk allowed vlan all`
    
- Errore `switchport mode trunk` → serve `switchport trunk encapsulation dot1q` (su modelli che supportano ISL+dot1q)
    
- Campo VLAN ID nella tag → VID
    
- VLAN allowed ma non “active” → VLAN non creata sullo switch