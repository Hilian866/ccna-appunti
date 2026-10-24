
### Scope CCNA

- **NON core (rimossi dalla blueprint 200-301)**, ma **possibili domande** (concetti + comportamento default)
    
- Focus: cosa fanno, mode principali, revision number (VTP), best practice (disabilitare)

# DTP (Dynamic Trunking Protocol)

- **DTP**: protocollo Cisco per negoziare automaticamente se una porta è **access** o **trunk** tra switch Cisco.
    
- **Default**: DTP **enabled** sulle porte switch (dipende dal modello: vecchi “desirable”, nuovi “auto”).
    
- **Best practice**: **disabilitare** DTP e configurare **manuale** (security).
    

## Termini atomici (quiz)

- **dynamic desirable**: “spinge” attivamente per formare un trunk.
    
- **dynamic auto**: “passivo”, accetta trunk solo se l’altro lo propone.
    
- **nonegotiate**: smette di inviare frame DTP.
    
- **administrative mode**: ciò che configuri.
    
- **operational mode**: ciò che la porta diventa davvero (trunk/access) dopo negoziazione.
    

## Regole di formazione trunk (sintesi)

### Se una porta è dynamic desirable

- Forma TRUNK con: `trunk` / `dynamic desirable` / `dynamic auto`
    
- Diventa ACCESS con: `access`
    

### Se una porta è dynamic auto

- Forma TRUNK con: `trunk` / `dynamic desirable`
    
- Diventa ACCESS con: `access` / `dynamic auto`
    

### Misconfig da riconoscere

- `access` ↔ `trunk` = **misconfig** (problemi / traffico non corretto)
    

## Output/Verifica

`show interfaces g0/0 switchport`

Campi chiave:

- Administrative Mode
    
- Operational Mode
    
- Negotiation of Trunking (on/off)
    

## Disabilitare DTP (pattern)

- Access mode **disabilita di fatto** DTP (non invia DTP)
    
- Trunk mode **non** lo disabilita automaticamente → serve `nonegotiate`
    

```
interface g0/0
 switchport mode trunk
 switchport nonegotiate
```

## Confini concettuali

- **DTP non negozia trunk con router/PC** → per **ROAS** devi configurare trunk manuale (sullo switch).

# Trunk encapsulation negotiation (ISL vs 802.1Q)

- Switch che supportano **ISL + dot1q** possono negoziare anche l’**encapsulation** via DTP.
    
- Default spesso: `switchport trunk encapsulation negotiate`
    
- **ISL preferito** se entrambi lo supportano (ma oggi è legacy).
    
- Frame DTP viaggiano:
    
    - con **ISL**: su **VLAN 1**
        
    - con **dot1q**: su **native VLAN** (default native = VLAN 1)
        

📌 Confine concettuale

- **Encapsulation negotiation ≠ VLAN allowed/native**: sono cose diverse.

# VTP (VLAN Trunking Protocol)

- **VTP**: protocollo Cisco per **sincronizzare il database VLAN** tra switch (non le porte).
    
- Serve a evitare di creare VLAN manualmente su ogni switch.
    
- **Raramente usato** oggi (rischio operativo alto).
    

## Termini atomici (quiz)

- **VTP domain**: “gruppo” logico; VTP sync solo dentro lo stesso domain.
    
- **revision number**: contatore che indica “database VLAN più nuovo”.
    
- **VTP advertisement**: annunci VTP inviati **solo su trunk**.
    
- **VLAN database**: elenco VLAN (id + name ecc.), non assegnazioni porte.
    

## VTP modes (CORE concettuale)

### Server (default Cisco)

- Può **add/modify/delete VLAN**
    
- VLAN database salvato in **NVRAM**
    
- Incrementa revision number a ogni cambio VLAN
    
- **Server si comporta anche da client**: se vede un server con revision più alta, **si aggiorna**
    

### Client

- **Non** può creare/modificare/cancellare VLAN (CLI rejected)
    
- In VTPv1/v2 non salva VLAN DB in NVRAM (in **v3 sì**)
    
- Si sincronizza al DB con **revision più alta**
    
- Forwarda advertisements su trunk
    

### Transparent

- **Non** sincronizza il DB con il domain
    
- Mantiene DB **indipendente** (NVRAM)
    
- Può creare VLAN **locali**, ma **non le pubblicizza**
    
- **Forwarda** advertisements **solo se** il domain nel messaggio “matcha” il suo domain
    

📌 Confine concettuale

- **VTP propaga VLANs, non le assegnazioni porte** → devi comunque fare `switchport access vlan X` ecc.

## Pericolo principale (motivo per cui si evita)

- Se colleghi uno switch “vecchio” con **revision number più alta** e **domain uguale**:
    
    - tutta la rete può **sincronizzarsi** al suo DB → VLAN “spariscono” → outage immediato.

## Reset VTP revision number a 0 (quiz)

Metodi mostrati:

- Cambiare domain a un **unused domain**
    
- Mettere in **vtp mode transparent**  
    _(entrambi resettano revision a 0)_

## Comandi visti

```
show vtp status
show vlan brief
vtp domain CISCO
vtp mode client
vtp mode transparent
vtp version 2
```
