---
tags: [ccna, exam, subnetting]
priorita: critico
dominio: IP Connectivity
stato: da-ripassare
---

> [!ABSTRACT] Cosa serve per l'esame
> Blueprint **1.6** (configurare e verificare indirizzi IPv4 e subnetting) e **1.7** (indirizzi IPv4 privati).
> Dato un indirizzo con prefisso devi trovare in pochi secondi: rete, broadcast, primo e ultimo host, numero di host. Al contrario, dato un numero di host devi scegliere la maschera. Serve anche per wildcard (ACL, OSPF), VLSM e summarization.

## 1. Le basi: bit, maschere e potenze di 2

Un indirizzo IPv4 ha 32 bit, divisi in 4 ottetti da 8. Il prefisso (`/27`) dice quanti bit, da sinistra, appartengono alla rete; gli altri sono la parte host.

Valori dei bit in un ottetto: `128 64 32 16 8 4 2 1`. Accendendoli da sinistra ottieni i soli valori possibili di un ottetto della maschera:

| Bit a 1 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| Valore | 128 | 192 | 224 | 240 | 248 | 252 | 254 | 255 |
| Block size (256 − valore) | 128 | 64 | 32 | 16 | 8 | 4 | 2 | 1 |

- **Host utilizzabili** = 2^h − 2, dove h sono i bit host (si tolgono rete e broadcast).
- **Numero di subnet** = 2^s, dove s sono i bit presi in prestito alla parte host.
- Potenze da sapere: 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048.

## 2. Tabella del 4° ottetto

| Prefisso | Maschera | Block size | Host utilizzabili |
| :--- | :--- | :--- | :--- |
| /24 | 255.255.255.0 | 256 | 254 |
| /25 | 255.255.255.128 | 128 | 126 |
| /26 | 255.255.255.192 | 64 | 62 |
| /27 | 255.255.255.224 | 32 | 30 |
| /28 | 255.255.255.240 | 16 | 14 |
| /29 | 255.255.255.248 | 8 | 6 |
| /30 | 255.255.255.252 | 4 | 2 |
| /31 | 255.255.255.254 | 2 | 2 (solo link punto-punto) |
| /32 | 255.255.255.255 | 1 | 1 host (loopback, host route, ACL) |

- **/30**: il classico link tra due router (2 host).
- **/31**: sui link punto-punto è valido (RFC 3021) e non spreca indirizzi, perché non ci sono rete e broadcast: entrambi gli indirizzi sono utilizzabili.
- **/32**: un solo host.

## 3. Il metodo del block size

Esempio: `192.168.1.50/27`.

1. **Trova l'ottetto del confine**: /27 cade nel 4° ottetto (24 < 27 ≤ 32).
2. **Block size** = 256 − 224 = **32**.
3. **Multipli del block size**: 0, 32, 64, 96… Il 50 sta tra 32 e 64.
4. **Rete** = il multiplo uguale o subito sotto: `192.168.1.32`.
5. **Broadcast** = rete successiva − 1: `192.168.1.63`.
6. **Host**: dal primo dopo la rete all'ultimo prima del broadcast, cioè `.33` – `.62` (30 host).

### Prefissi sotto /24

Stessa logica, applicata all'ottetto dove cade il confine; gli ottetti a destra vanno a 0 per la rete e a 255 per il broadcast.

| Esempio | Ottetto | Block size | Rete | Broadcast |
| :--- | :--- | :--- | :--- | :--- |
| `172.16.35.10/20` | 3° (maschera 240) | 16 | `172.16.32.0` | `172.16.47.255` |
| `10.1.6.9/22` | 3° (maschera 252) | 4 | `10.1.4.0` | `10.1.7.255` |
| `172.20.1.1/12` | 2° (maschera 240) | 16 | `172.16.0.0` | `172.31.255.255` |

## 4. Calcolo inverso: quale maschera serve?

- **Per N host**: trova il più piccolo h con 2^h − 2 ≥ N; il prefisso è /(32 − h).
  - 50 host → h = 6 (62) → **/26**
  - 100 host → h = 7 (126) → **/25**
  - 500 host → h = 9 (510) → **/23**
- **Per N subnet**: prendi s bit con 2^s ≥ N. Da un /24 per 6 subnet servono 3 bit (8 subnet) → **/27**.

## 5. VLSM

Subnet di dimensioni diverse dallo stesso blocco. Regola: **dalla più grande alla più piccola**, una dopo l'altra, senza sovrapposizioni.

Esempio: da `192.168.10.0/24` servono 100, 50 e 20 host e due link punto-punto.

1. 100 host → /25 → `192.168.10.0/25` (0–127)
2. 50 host → /26 → `192.168.10.128/26` (128–191)
3. 20 host → /27 → `192.168.10.192/27` (192–223)
4. Link → /30 → `192.168.10.224/30` (224–227) e `192.168.10.228/30` (228–231)

## 6. Classi e indirizzi privati (blueprint 1.7)

La classe si riconosce dal **primo ottetto**:

| Classe | Primo ottetto | Maschera di default | Uso |
| :--- | :--- | :--- | :--- |
| A | 1 – 126 | /8 | unicast |
| B | 128 – 191 | /16 | unicast |
| C | 192 – 223 | /24 | unicast |
| D | 224 – 239 | — | multicast |
| E | 240 – 255 | — | sperimentale |

Il 127 non è di classe A utilizzabile: `127.0.0.0/8` è loopback.

**Indirizzi privati (RFC 1918)**: non instradabili su Internet; per uscire serve il [[NAT - Network Address Translation|NAT]].

| Blocco | Range |
| :--- | :--- |
| `10.0.0.0/8` | 10.0.0.0 – 10.255.255.255 |
| `172.16.0.0/12` | 172.16.0.0 – 172.31.255.255 |
| `192.168.0.0/16` | 192.168.0.0 – 192.168.255.255 |

Altri da riconoscere: `169.254.0.0/16` è **APIPA** (il client non ha ricevuto un indirizzo dal DHCP), `127.0.0.0/8` è loopback.

## 7. Wildcard e summarization

- **Wildcard** = 255.255.255.255 − maschera. Si usa in ACL e OSPF. /26 → `0.0.0.63`; /21 → `0.0.7.255`.
- **Summarization**: la rotta riassuntiva copre più reti contigue con il prefisso comune più lungo. `10.1.0.0/24` … `10.1.3.0/24` (4 reti, 2 bit) → `10.1.0.0/22`.

## 8. Configurazione e verifica

```ios
R1(config)# interface g0/0

! Indirizzo e maschera (IOS vuole la maschera, non il prefisso)
R1(config-if)# ip address 192.168.1.1 255.255.255.0

! Le interfacce dei router sono spente di default
R1(config-if)# no shutdown
```

```ios
! IP e stato (Status/Protocol) di tutte le interfacce
R1# show ip interface brief

! Dettaglio: indirizzo con prefisso, broadcast, ACL applicate
R1# show ip interface g0/0
```

Quando l'interfaccia è up, nella routing table compaiono la rete connessa (`C`) e l'indirizzo dell'interfaccia (`L`, /32).

## ⚠️ Trappole d'esame

> [!WARNING] Gli errori più frequenti
> 1. **Il −2**: "quanti host utilizzabili?" non è mai una potenza di 2. Per un /27 sono 30, non 32.
> 2. **Indirizzo di rete o broadcast come host**: `192.168.1.63/26` è un broadcast, non un host valido.
> 3. **"Stessa subnet?"**: calcola la rete di entrambi gli indirizzi con la stessa maschera.
> 4. **Confine sotto /24**: con /20 o /22 il calcolo si fa sul 3° ottetto, e il broadcast finisce con `.255`.
> 5. **Wildcard al posto della maschera**: nei comandi `ip address` e `ip route` va la maschera, la wildcard solo in ACL e OSPF.
> 6. **172.32.x.x privato?** No: il blocco privato è 172.16 – 172.31.

## Esercizi

> [!QUESTION]- `10.20.30.77/26`: rete, broadcast e host?
> Block size 64 nel 4° ottetto: 77 sta tra 64 e 128.
> Rete `10.20.30.64` · broadcast `10.20.30.127` · host `.65` – `.126` (62).

> [!QUESTION]- `172.16.45.200/21`: rete, broadcast e host?
> /21 cade nel 3° ottetto, maschera 248, block size 8: 45 sta tra 40 e 48.
> Rete `172.16.40.0` · broadcast `172.16.47.255` · host `172.16.40.1` – `172.16.47.254` (2046).

> [!QUESTION]- `192.168.5.130/25` e `192.168.5.120/25` sono nella stessa subnet?
> No: il primo è nella rete `192.168.5.128`, il secondo nella `192.168.5.0`.

> [!QUESTION]- `10.1.1.255/23` può essere assegnato a un host?
> No. /23: block size 2 nel 3° ottetto → rete `10.1.0.0`, broadcast `10.1.1.255`. È il broadcast.

> [!QUESTION]- Che prefisso serve per 300 host?
> 2^9 − 2 = 510 ≥ 300 (2^8 − 2 = 254 non basta) → **/23**.

> [!QUESTION]- Rotta riassuntiva per `172.16.8.0/24` … `172.16.15.0/24`?
> 8 reti contigue, a partire da un multiplo di 8 → 3 bit → `172.16.8.0/21`.

## Check da esame

- [ ] Block size di un /28? **16**.
- [ ] Host utilizzabili in un /29? **6**.
- [ ] Maschera di un /26? **255.255.255.192**.
- [ ] Prefisso per 60 host? **/26** (62).
- [ ] Wildcard di un /27? **0.0.0.31**.
- [ ] I tre blocchi privati? **10/8, 172.16/12, 192.168/16**.
- [ ] Un client ha 169.254.x.x: cosa significa? **APIPA: il DHCP non ha risposto**.
- [ ] Classe di 191.1.1.1? **B**.

Esercizi in più (solo in Obsidian): [[Subnetting Practice]].

## 🎯 Synthesis

Trova l'ottetto del confine, calcola il block size (256 − maschera) e prendi il multiplo sotto l'indirizzo: quella è la rete; il broadcast è la rete successiva meno 1. Gli host sono 2^h − 2, e i privati sono 10/8, 172.16/12 e 192.168/16.
