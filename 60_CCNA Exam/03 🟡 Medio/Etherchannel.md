---
tags: [ccna, exam]
priorita: medio
stato: da-ripassare
---

> [!ABSTRACT] Core Logic
> L'**EtherChannel** permette di raggruppare più interfacce fisiche in un'unica interfaccia logica (**Port-Channel**). L'obiettivo primario è aumentare la bandwidth totale e fornire ridondanza, evitando che lo Spanning Tree Protocol (STP) blocchi i link ridondanti. [00:23](https://youtu.be/xuo69Joy_Nc&t=23s)

## ⚠️ Il Problema: Spanning Tree e Oversubscription
In un design di rete standard, collegare due switch con link multipli fisici causa **Layer 2 Loops**. Lo **Spanning Tree (STP)** interviene disattivando tutti i link tranne uno per prevenire **Broadcast Storms** [04:48](https://youtu.be/xuo69Joy_Nc&t=288s).
- **Risultato:** Spreco di larghezza di banda e congestione (Oversubscription).
- **Soluzione EtherChannel:** STP vede il gruppo di link come un'unica connessione logica, mantenendo tutte le interfacce fisiche in stato di **forwarding** [05:46](https://youtu.be/xuo69Joy_Nc&t=346s).

## Algoritmi di Load-Balancing
L'EtherChannel non invia pacchetti in modo casuale, ma utilizza dei **Flows** (flussi) per decidere quale interfaccia fisica usare. [09:01](https://youtu.be/xuo69Joy_Nc&t=541s)

> [!INFO] Definizione di Flow
> Un flusso è una comunicazione tra due nodi della rete. I frame dello stesso flusso vengono inviati sulla stessa interfaccia fisica per evitare il riordinamento dei frame (**out-of-order delivery**). [09:09](https://youtu.be/xuo69Joy_Nc&t=549s)

**Metodi di calcolo supportati:**
- **Source MAC** o **Destination MAC**.
- **Source IP** o **Destination IP**.
- Combinazioni (Source AND Destination IP/MAC). [11:32](https://youtu.be/xuo69Joy_Nc&t=692s)

```ios
! Comando per cambiare il metodo di load-balancing
SW(config)# port-channel load-balance src-dst-mac
! Verifica delle impostazioni correnti
SW# show etherchannel load-balance
```
[13:13](https://youtu.be/xuo69Joy_Nc&t=793s)

## Protocolli di Negoziazione
Esistono tre metodi per formare un EtherChannel: **PAgP**, **LACP** e **Statico**. [15:31](https://youtu.be/xuo69Joy_Nc&t=931s)

| Protocollo  | Proprietario    | Modalità Attiva | Modalità Passiva |
| :---------- | :-------------- | :-------------- | :--------------- |
| PAgP    | Cisco           | Desirable   | Auto         |
| LACP    | IEEE (Standard) | Active      | Passive      |
| Statico | N/A             | On          | On           |

> [!CAUTION] Limitazioni Tecniche
> Affinché un EtherChannel si formi, i parametri su entrambi i lati devono corrispondere: Speed, Duplex, VLAN (Access o Trunk) e Allowed VLAN List. Se i parametri non matchano, l'interfaccia viene esclusa dal bundle. [14:18](https://youtu.be/xuo69Joy_Nc&t=858s)

## Configurazione Layer 2 (LACP)
Il metodo standard per configurare un bundle su interfacce di switch. [17:57](https://youtu.be/xuo69Joy_Nc&t=1077s)

```ios
SW(config)# interface range g0/0 - 3

! Abilita LACP Unconditionally
SW(config-if-range)# channel-group 1 mode active
SW(config)# interface port-channel 1

! Configura l'interfaccia logica
SW(config-if)# switchport mode trunk
```

## Layer 3 EtherChannel
Utilizzato nel **Core** della rete per collegare switch **Multilayer** senza usare lo Spanning Tree. [17:30](https://youtu.be/xuo69Joy_Nc&t=1050s)

1. Disabilitare le funzioni di switchport fisica con `no switchport`.
2. Creare il Port-Channel.
3. Assegnare l'indirizzo IP direttamente all'interfaccia logica. [19:05](https://youtu.be/xuo69Joy_Nc&t=1145s)

```ios
SW(config)# interface range g0/0 - 3

! Trasforma in Routed Ports
SW(config-if-range)# no switchport
SW(config-if-range)# channel-group 1 mode active
SW(config)# interface port-channel 1
SW(config-if)# ip address 10.0.0.1 255.255.255.252
```

## Comandi di Verifica Cruciali
- `show etherchannel summary`: Mostra lo stato del Port-Channel e le interfacce membri. [14:53](https://youtu.be/xuo69Joy_Nc&t=893s)
- `show etherchannel port-channel`: Dettagli approfonditi sull'interfaccia logica. [16:26](https://youtu.be/xuo69Joy_Nc&t=986s)
- `show spanning-tree`: Conferma che STP tratti il Port-Channel come un singolo link. [17:01](https://youtu.be/xuo69Joy_Nc&t=1021s)

> [!INFO] Flag del summary
> - **(SU)**: Layer 2, In Use (Operativo).
> - **(RU)**: Layer 3, In Use (Operativo).
> - **(P)**: Bundled in Port-Channel (Interfaccia fisica ok).
> - **(D)**: Down (Problema fisico o configurazione errata).

## 🎯 Synthesis
EtherChannel unisce più link in uno logico: LACP (active/passive), PAgP (desirable/auto), static (on); i parametri devono combaciare.
