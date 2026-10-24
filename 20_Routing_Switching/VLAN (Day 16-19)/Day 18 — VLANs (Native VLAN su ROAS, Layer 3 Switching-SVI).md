


## Native VLAN su router (ROAS)

- **Native VLAN**: traffico **untagged** su trunk (dot1q)
    
- Best practice: native VLAN = **VLAN non usata** (security)
    

### 2 metodi validi (quiz)

**Metodo 1 — Subinterface “native”**

```
interface g0/0.10
 encapsulation dot1q 10 native
 ip address <GW_VLAN10> <mask>
```

**Metodo 2 — IP sulla fisica (niente subinterface per native)**

```
interface g0/0
 ip address <GW_VLAN10> <mask>
```

- In questo caso **niente** `encapsulation dot1q` per la native VLAN
    

📌 Confine concettuale

- Frame untagged ricevuti su trunk → trattati come native VLAN
    
- Frame della native VLAN inviati → untagged

## Layer 3 switch / Multilayer switch

- **Multilayer switch**: fa **switching (L2)** + **routing (L3)**
    
- Può avere:
    
    - **SVI** (interfacce virtuali per VLAN)
        
    - **Routed ports** (porte fisiche L3 con IP)
        

📌 Confini concettuali

- L2 switch: no routing, solo MAC
    
- L3 switch: routing interno, **routing table propria**

## Inter-VLAN routing: confronto secco

- **Router con 1 porta per VLAN**: funziona, non scalabile (porte finite)
    
- **ROAS**: 1 trunk router↔switch, ma traffico “hairpin” → possibile congestione
    
- **L3 switch + SVI**: inter-VLAN routing **nel switch** (preferito in reti grandi)

## Architettura con L3 switch (pattern)

- VLAN restano tra switch (trunk)
    
- Verso router/Internet: link **L3 point-to-point** (no VLAN su quel link)
    

Esempio:

- SW2 (L3) ↔ R1: `192.168.1.192/30`
    
    - SW2 G0/1 = `.193`
        
    - R1 G0/0 = `.194`
        
- SW2 default route → R1

## Config: passaggio da ROAS a L3 switching

![[Screenshot_10 2.png]]

### 1) Router: rimuovere subinterface ROAS e mettere IP sulla fisica

```
no interface g0/0.10
no interface g0/0.20
no interface g0/0.30
default interface g0/0
interface g0/0
 ip address 192.168.1.194 255.255.255.252
 no shutdown
```

📌 Nota

- `show ip interface brief` può mostrare subinterfaces come **deleted** finché non reload → ok
    

### 2) Switch L3: abilitare routing + convertire porta a routed port

```
default interface g0/1
ip routing
interface g0/1
 no switchport
 ip address 192.168.1.193 255.255.255.252
 no shutdown
```

### 3) Default route sullo switch

`ip route 0.0.0.0 0.0.0.0 192.168.1.194`

Verifiche utili:

```
show ip route
show ip interface brief
show interfaces status
```

- In `show interfaces status` una routed port appare come **ROUTED** nella colonna VLAN

## SVI (Switch Virtual Interface)

- **SVI**: interfaccia virtuale `interface vlan X` con IP = gateway della VLAN
    
- Gateway dei PC = SVI, non router
    

Config (pattern):

```
interface vlan 10
 ip address <GW_VLAN10> <mask>
 no shutdown
```

_(ripeti per vlan 20, 30)_

📌 Quiz trap: SVI sono **shutdown di default** → serve `no shutdown`

## Condizioni per SVI UP/UP (CORE)

Un SVI va **UP/UP** solo se:

1. **La VLAN esiste** sullo switch ✅
    
2. Esiste almeno **una** di queste condizioni ✅
    
    - un **access port** in quella VLAN è up/up, **oppure**
        
    - un **trunk port** che **permette** quella VLAN è up/up
        
3. La VLAN non è **shutdown** (la VLAN stessa, non l’SVI)
    
4. L’SVI non è shutdown (`no shutdown`)
    

📌 Confine concettuale importante

- **SVI per VLAN inesistente NON crea la VLAN automaticamente**
    
    - (diverso da access port → può creare VLAN automaticamente)

## Quiz pattern (dalla lezione)

- Native VLAN su router: **2 metodi corretti** (subif `native` oppure IP sulla fisica)
    
- SVI down/down: tipico perché
    
    - VLAN non esiste
        
    - nessuna porta/trunk per quella VLAN è up
        
- Routed port: comando chiave = **`no switchport`**
    
- Routing L3 switch: comando chiave = **`ip routing`**