---
tags: [ccna, exam, ospf]
priorita: critico
dominio: IP Connectivity
stato: da-ripassare
---

## Obiettivo

Costruire una mappa topologica completa e identica (LSDB) tra tutti i router di un'area per calcolare il percorso più breve ed esente da loop verso ogni destinazione.

## 1. Identità e Scoperta

OSPF non usa indirizzi IP per "chiamare" i vicini, ma un'identità fissa.

> [!INFO] Selezione Router ID (RID)
>
> Il RID è un numero a 32 bit fondamentale per l'elezione del DR. L'ordine di priorità è:
>
> 1. **Comando manuale**: `router-id X.X.X.X` (Metodo consigliato).
> 2. **Loopback**: L'IP più alto su un'interfaccia virtuale.
> 3. **Interfaccia Fisica**: L'IP più alto su un'interfaccia attiva.
>

### Requisiti di Vicinato (Hello Packet)

I router inviano Hello al multicast **224.0.0.5**. L'adiacenza **NON** si forma se questi parametri non coincidono:

- **Area ID** e **Subnet Mask**.
- **Hello/Dead Timers** (Default: 10s/40s su Ethernet).
- **Password** di autenticazione.
- **Stub Area Flag** (Tipo di area).

## 2. Ruoli e Stati di Adiacenza

In reti broadcast (Ethernet), OSPF elegge dei leader per evitare che ogni router parli con tutti (evitando un numero eccessivo di adiacenze).

### Elezione DR / BDR

- **Vince la Priority** più alta (Default 1, Range 0-255). Una Priority **0** esclude il router dall'elezione.
- **Tie-breaker**: Router ID più alto.
- **Nota**: L'elezione è **Non-Preemptive**. Se aggiungi un router "più forte" a rete già formata, questo non diventerà DR fino al restart del processo.

### Tabella degli Stati

| Stato    | Descrizione Strategica                         | Output Operativo / Troubleshooting              |
| ------------ | -------------------------------------------------- | --------------------------------------------------- |
| Down     | Nessun Hello ricevuto. Il nodo è silente.          | Controlla cavo, interfaccia o ACL sul multicast.    |
| Init     | Hello ricevuto, ma manca il mio RID nel pacchetto. | Comunicazione unidirezionale (problema di ritorno). |
| 2-Way    | **I vicini si vedono (Bi-direzionale).**           | **Elezione DR/BDR.** Stato finale tra due DROTHER.  |
| ExStart  | Determinazione dei ruoli Master/Slave.             | Viene deciso chi inizia a inviare i dati.           |
| Exchange | Scambio dei descrittori (DBD).                     | Il router dichiara: "Ecco l'elenco di ciò che so".  |
| Loading  | Richiesta dettagli (LSR) e invio (LSU).            | Scaricamento delle rotte mancanti.                  |
| Full     | Database sincronizzati.                            | Adiacenza completa. Stato finale con DR e BDR.      |

## 3. I "Mattoni" della Mappa: LSA Types

Gli LSA (Link State Advertisements) sono i messaggi che compongono la topologia. *Per il CCNA (single-area) contano soprattutto Tipo 1 e 2; i tipi 3-5 servono solo come cultura multi-area.*

> [!TIP] LSA Quick Reference
>
> - **Tipo 1 (Router)**: "Io esisto e questi sono i miei link". (Inviato da tutti).
> - **Tipo 2 (Network)**: "Questi router sono collegati a questo segmento". (Inviato solo dal **DR**).
> - **Tipo 3 (Summary)**: "Ecco le rotte che vengono dalle altre aree". (Inviato dall'**ABR**).
> - **Tipo 4 (ASBR Summary):** "Ecco come raggiungere l'ASBR". (Inviato dall'ABR).
> - **Tipo 5 (External)**: "Ecco le rotte che vengono da fuori OSPF (Internet/Statiche)". (Inviato dall'**ASBR**).
>

## 4. Metrica: Il Costo

OSPF calcola il percorso basandosi sulla velocità dell'interfaccia.

$$Cost = \frac{Reference Bandwidth}{Interface Bandwidth}$$

> [!DANGER] CCNA Alert: Reference Bandwidth
>
> Il valore di default è **100 Mbps**.
>
> - Costo FastEthernet (100Mbps) = **1**
> - Costo Gigabit (1000Mbps) = **1** (Errore! OSPF li vede uguali).
> - **Soluzione**: Impostare `auto-cost reference-bandwidth 100000` su **tutti** i router.
>

## 5. CLI & Troubleshooting

```
router ospf 1
 router-id 1.1.1.1
 auto-cost reference-bandwidth 100000

 ! Impedisce adiacenze verso i PC (sicurezza)
 passive-interface g0/1
 network 192.168.1.0 0.0.0.255 area 0
 ip ospf 1 area 0
```

### Comandi di Verifica

- `show ip ospf neighbor`: Il comando più importante. Controlla se sei in **FULL**.
- `show ip ospf database`: Per vedere la topologia (LSA).
- `show ip route ospf`: Per vedere solo le rotte apprese via OSPF (codice `O`, **AD 110**).
- `show ip ospf interface brief`: Area, costo, stato (DR/BDR/P2P) e numero di vicini per interfaccia.
- `show ip protocols`: Router ID, network annunciate, passive interface.

### Altri comandi utili
```
interface g0/0
 ! non partecipa all'elezione DR/BDR
 ip ospf priority 0

 ! niente DR/BDR, adiacenza più rapida
 ip ospf network point-to-point

 ! forza il costo
 ip ospf cost 10

 ! timer da far combaciare con il vicino
 ip ospf hello-interval 5
router ospf 1
 ! propaga la default route
 default-information originate

! necessario per applicare il nuovo router-id
clear ip ospf process
```
> [!INFO] Multicast OSPF
> `224.0.0.5` = tutti i router OSPF · `224.0.0.6` = solo **DR/BDR**.
> DR/BDR solo su reti *broadcast* e NBMA; su point-to-point non c'è elezione (timer 10/40 s, P2P e broadcast); su NBMA 30/120 s.

## ⚠️ 6. Common Mistakes (Anatomy Check)

> [!CAUTION] Perché l'adiacenza è bloccata?
>
> - **Stato ExStart/Exchange**: Quasi sempre causato da un **MTU Mismatch** (le interfacce hanno dimensioni MTU diverse).
> - **Nessun vicino / Init**: timer, Area ID, subnet mask, autenticazione o ACL sul multicast. Se un lato vede il vicino e l'altro no → **Init** (traffico unidirezionale).
> - **FULL ma no rotte**: `network` statement sbagliato, `passive-interface` sull'interfaccia sbagliata, o rotte filtrate. Vicini bloccati in **2-Way** su Ethernet sono normali tra due DROTHER.
> - **Router ID duplicato**: adiacenze instabili o LSDB incoerente.
>

## 🎯 Synthesis
OSPF: vicini con Hello identici, sincronizzano il LSDB fino a FULL, poi SPF sceglie il costo minimo (100 Mbps di reference: ricordati di cambiarlo).

---

> [!EXAMPLE] Laboratori Pratici
> - [[Day 26 Lab - OSPF (Part 1).pkt]]
> - [[Day 27 Lab - OSPF (Part 2).pkt]]
> - [[Day 28 Lab - OSPF (Part 3).pkt]]
