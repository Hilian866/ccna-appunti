---
tags: [ccna, exam, routing]
priorita: critico
dominio: IP Connectivity
stato: da-ripassare
---

> [!ABSTRACT] Cosa serve per l'esame
> Blueprint **3.1** (componenti della routing table), **3.2** (come il router decide dove inoltrare) e **3.3** (rotte statiche IPv4 e IPv6: default, network, host, floating).
> Devi saper leggere un `show ip route` riga per riga, prevedere quale rotta usa il router per una destinazione e scrivere ogni tipo di rotta statica. La parte IPv6 è in [[IPv6]] (sezione 9).

## 1. Leggere la routing table (3.1)

```text
R1# show ip route
Codes: L - local, C - connected, S - static, O - OSPF, * - candidate default

Gateway of last resort is 192.168.12.2 to network 0.0.0.0

S*    0.0.0.0/0 [1/0] via 192.168.12.2
      10.0.0.0/8 is variably subnetted, 4 subnets, 2 masks
C        10.0.1.0/24 is directly connected, GigabitEthernet0/0
L        10.0.1.1/32 is directly connected, GigabitEthernet0/0
S        10.0.2.0/24 [1/0] via 192.168.12.2
O        10.0.3.0/24 [110/2] via 192.168.13.2, 00:12:44, GigabitEthernet0/2
      192.168.12.0/24 is variably subnetted, 2 subnets, 2 masks
C        192.168.12.0/30 is directly connected, GigabitEthernet0/1
L        192.168.12.1/32 is directly connected, GigabitEthernet0/1
      192.168.13.0/24 is variably subnetted, 2 subnets, 2 masks
C        192.168.13.0/30 is directly connected, GigabitEthernet0/2
L        192.168.13.1/32 is directly connected, GigabitEthernet0/2
```

Prendi la riga OSPF: `O 10.0.3.0/24 [110/2] via 192.168.13.2, 00:12:44, GigabitEthernet0/2`.

| Componente | Nell'esempio | Significato |
| :--- | :--- | :--- |
| Codice | `O` | da dove arriva la rotta: `C` connessa, `L` local, `S` statica, `O` OSPF; `*` = candidata default |
| Prefisso e maschera | `10.0.3.0/24` | la rete di destinazione |
| `[AD/metrica]` | `[110/2]` | Administrative Distance 110, metrica (costo OSPF) 2 |
| Next-hop | `via 192.168.13.2` | il router a cui consegnare il pacchetto |
| Età | `00:12:44` | da quanto è stata imparata (solo rotte dinamiche) |
| Interfaccia di uscita | `GigabitEthernet0/2` | dove esce il pacchetto |
| Gateway of last resort | `192.168.12.2` | dove va tutto ciò che non ha una rotta più specifica (la default route) |

Per ogni interfaccia up con un indirizzo il router aggiunge da solo due righe: `C` per la rete connessa e `L` per il proprio indirizzo (/32).

## 2. Come decide il router (3.2)

1. **Longest prefix match**: tra le rotte in tabella che contengono la destinazione vince la più specifica (/28 batte /24, che batte /8, che batte /0).
2. **Administrative Distance**: se due sorgenti offrono lo **stesso prefisso**, in tabella entra quella con AD più bassa (la più affidabile).
3. **Metrica**: a parità di prefisso e di protocollo vince la metrica più bassa. Se le metriche sono uguali, il router le tiene tutte e divide il traffico (ECMP).

AD e metrica decidono quale rotta **entra** in tabella; il longest prefix match decide quale si **usa** per un pacchetto. La metrica si confronta solo tra rotte dello stesso protocollo.

| Sorgente | AD |
| :--- | :--- |
| Connessa | 0 |
| Statica | 1 |
| eBGP | 20 |
| EIGRP | 90 |
| OSPF | 110 |
| IS-IS | 115 |
| RIP | 120 |
| EIGRP esterno | 170 |
| iBGP | 200 |
| Inutilizzabile | 255 (mai in tabella) |

### Esempio di longest prefix match

Rotte: `10.0.0.0/8` via A · `10.0.2.0/24` via B · `10.0.2.0/28` via C · `0.0.0.0/0` via D.

| Destinazione | Rotte che la contengono | Vince |
| :--- | :--- | :--- |
| `10.0.2.5` | /8, /24, /28 (0–15), /0 | C (/28) |
| `10.0.2.100` | /8, /24, /0 | B (/24) |
| `10.9.9.9` | /8, /0 | A (/8) |
| `8.8.8.8` | solo /0 | D (default) |

## 3. Rotte statiche (3.3)

Sintassi: `ip route <rete> <maschera> {next-hop | interfaccia [next-hop]} [AD]`

Come per IPv6, separa due domande.

**Cosa raggiungo** (il tipo, ed è ciò che chiede il blueprint):

| Tipo | Destinazione | Esempio |
| :--- | :--- | :--- |
| Network route | una rete | `ip route 10.0.2.0 255.255.255.0 192.168.12.2` |
| Host route | un solo host (/32) | `ip route 10.0.2.5 255.255.255.255 192.168.12.2` |
| Default route | tutto il resto (`0.0.0.0/0`) | `ip route 0.0.0.0 0.0.0.0 192.168.12.2` |
| Floating static | backup di un'altra rotta | come sopra, con AD più alta in fondo |

**Come la scrivo** (la forma):

| Forma | Cosa specifichi | Quando entra in tabella | Nota |
| :--- | :--- | :--- | :--- |
| Recursive | solo next-hop | se il next-hop è raggiungibile | la più comune; serve un secondo lookup per trovare l'uscita |
| Directly connected | solo interfaccia | se l'interfaccia è up | ok su link punto-punto; su Ethernet si appoggia al proxy ARP del vicino (fragile) |
| Fully specified | interfaccia + next-hop | interfaccia up | la più robusta su Ethernet |

### Floating static

È una statica con AD **più alta** della rotta che protegge: finché la principale esiste resta fuori dalla tabella; se la principale sparisce, entra.

- Backup di OSPF (AD 110): serve un'AD maggiore di 110, per esempio 130.
- Backup di un'altra statica (AD 1): basta un'AD maggiore di 1, per esempio 5.

## 4. Configurazione e verifica

```ios
! Network route verso la LAN di R2
R1(config)# ip route 10.0.2.0 255.255.255.0 192.168.12.2

! Host route verso un server
R1(config)# ip route 10.0.2.5 255.255.255.255 192.168.12.2

! Default route: diventa il gateway of last resort
R1(config)# ip route 0.0.0.0 0.0.0.0 192.168.12.2

! Floating: la rotta OSPF passa da R3; se sparisce, si passa da R2 (AD 130 > 110)
R1(config)# ip route 10.0.3.0 255.255.255.0 192.168.12.2 130

! Fully specified: interfaccia di uscita + next-hop
R1(config)# ip route 10.0.4.0 255.255.255.0 g0/1 192.168.12.2
```

```ios
! Tutta la tabella, poi solo le statiche
R1# show ip route
R1# show ip route static

! Quale rotta userebbe per questa destinazione
R1# show ip route 10.0.2.5
```

## ⚠️ Trappole d'esame

> [!WARNING] Gli errori più frequenti
> 1. **Manca la rotta di ritorno**: l'andata funziona, la risposta si perde. Le statiche vanno configurate in entrambe le direzioni.
> 2. **Next-hop non raggiungibile**: la rotta recursive non entra in tabella.
> 3. **Wildcard al posto della maschera**: `ip route` vuole la subnet mask.
> 4. **Floating con AD troppo bassa**: se l'AD è minore o uguale a quella della principale, la floating diventa la rotta usata.
> 5. **AD prima del prefisso**: una /24 statica (AD 1) **non** batte una /28 OSPF (AD 110) per una destinazione nella /28. Vince sempre il prefisso più lungo.
> 6. **Metriche di protocolli diversi**: non si confrontano; si confronta l'AD.

## Esercizi

> [!QUESTION]- Nella tabella della sezione 1, dove va un pacchetto per `10.0.3.9`? E per `10.0.5.1`?
> `10.0.3.9` → rotta OSPF `10.0.3.0/24`, via 192.168.13.2 su G0/2.
> `10.0.5.1` → nessuna rotta specifica: default route, via 192.168.12.2.

> [!QUESTION]- R1 impara `10.1.1.0/24` da OSPF e ha anche `ip route 10.1.1.0 255.255.255.0 10.9.9.2`. Quale entra in tabella?
> La statica: stesso prefisso, AD 1 contro 110.

> [!QUESTION]- Vuoi che la statica dell'esercizio precedente faccia solo da backup. Cosa cambi?
> Aggiungi un'AD maggiore di 110: `ip route 10.1.1.0 255.255.255.0 10.9.9.2 130`.

> [!QUESTION]- Cosa significa `[1/0]` accanto a una rotta `S`?
> AD 1 (statica) e metrica 0.

## Check da esame

- [ ] Primo criterio per scegliere la rotta? **Longest prefix match**.
- [ ] AD di statica e OSPF? **1 e 110**.
- [ ] Default route IPv4? **`ip route 0.0.0.0 0.0.0.0 <next-hop>`**.
- [ ] Host route? **Maschera 255.255.255.255 (/32)**.
- [ ] Come si crea una floating static? **AD più alta della rotta principale**.
- [ ] Cosa sono le righe `L`? **L'indirizzo dell'interfaccia stessa, /32**.
- [ ] Dove si legge la default in uso? **"Gateway of last resort"**.

## 🎯 Synthesis

Il router usa la rotta col prefisso più lungo; AD e metrica servono solo a scegliere quale rotta, a parità di prefisso, entra in tabella. Le statiche hanno AD 1: con un'AD più alta diventano floating, cioè di backup.

> [!EXAMPLE] Laboratori pratici
> - [[Day 11 Lab - Configuring Static Routes.pkt]]
> - [[Day 11 Lab - Troubleshooting Static Routes.pkt]]
> - [[Day 24 Lab - Floating Static Routes.pkt]]
> - [[Day 33 Lab - IPv6 Static Routes.pkt]]
