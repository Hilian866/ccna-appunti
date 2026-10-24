---
tags: [ccna, exam]
priorita: medio
stato: da-ripassare
---

## Obiettivo Strategico

Risolvere l'esaurimento degli indirizzi IPv4 (32-bit) introducendo uno spazio di indirizzamento a **128-bit** (esadecimale). IPv6 elimina il concetto di broadcast, semplifica l'header e introduce l'auto-configurazione nativa.

> [!INFO] Riferimenti Video
>
> **MODULO 1:** **[IPv6 Fundamentals & Addressing](https://youtu.be/ZNuXyOXae5U?list=PLxbwE86jKRgMpuZuLBivzlM8s2Dk5lXBQ)**
>
> **MODULO 2:** **[IPv6 Address Types & EUI-64](https://youtu.be/BrTMMOXFhDU?list=PLxbwE86jKRgMpuZuLBivzlM8s2Dk5lXBQ)**
>
> **MODULO 3:** **[NDP, SLAAC & Static Routing](https://youtu.be/rwkHfsWQwy8?list=PLxbwE86jKRgMpuZuLBivzlM8s2Dk5lXBQ)**

## Fondamentali e Formato

- **Struttura**: 8 quartetti di 4 cifre hex (es. `2001:0db8:0000:0000:0008:0800:200c:417a`).
- **Regole di Abbreviazione**:
    1. Rimuovere gli **0 iniziali** (Leading zeros).
    2. Sostituire gruppi consecutivi di zeri con **`::`** (una sola volta per indirizzo).
- **Network Prefix**: Solitamente un **/64** (50% Network, 50% Host/Interface ID).
- **Risultato:** `2001:db8::8:800:200c:417a`

## Tipi di Indirizzo (Blueprint 1.9)

| Tipo                                   | Range / Prefisso | Scopo                                                     |
| ------------------------------------------ | -------------------- | ------------------------------------------------------------- |
| **Global Unicast**                         | `2000::/3`           | Indirizzi pubblici, instradabili su Internet.                 |
| **Unique Local**                           | `fc00::/7`           | Indirizzi privati (RFC 4193). Instradabili solo internamente. |
| **Link-Local**                             | `fe80::/10`          | Obbligatori. Validi solo sul segmento fisico (link).          |
| **Multicast** [[Multicast address.png\|*]] | `ff00::/8`           | Sostituisce il broadcast.                                     |
| **Anycast**                                | Qualsiasi Unicast    | "One to one-of-many" (consegna al nodo più vicino).           |
| **Loopback**                               | `::1/128`            | Equivalente a 127.0.0.1.                                      |

## Meccanismi Chiave

### 1. EUI-64 (Modified) [▶ video](https://youtu.be/BrTMMOXFhDU?list=PLxbwE86jKRgMpuZuLBivzlM8s2Dk5lXBQ&t=113)

Metodo per generare automaticamente l'Interface ID a 64-bit partendo dal MAC Address (48-bit):

1. Dividi il MAC a metà.
2. Inserisci `fffe` al centro.
3. Inverti il **7° bit** del primo byte (U/L bit).

### 2. NDP (Neighbor Discovery Protocol) [▶ video](https://youtu.be/rwkHfsWQwy8?list=PLxbwE86jKRgMpuZuLBivzlM8s2Dk5lXBQ&t=688)

Sostituisce ARP. Utilizza messaggi ICMPv6 e il **Solicited-Node Multicast** [[Solicited-node Multicast.png|*]] (`ff02::1:ffxx:xxxx`).

- **NS (Neighbor Solicitation)**: "Qual è il tuo MAC?" (Tipo 135).
- **NA (Neighbor Advertisement)**: "Ecco il mio MAC" (Tipo 136).
- **RS/RA (Router Sol./Adv.)**: Scoperta del router e del prefisso per **SLAAC** [[Screenshot_14.png|*]]

## CLI & Routing

> [!CAUTION] Prerequisito Critico
>
> Un router Cisco non inoltra pacchetti IPv6 di default.
>
> Comando: `ipv6 unicast-routing`

### Configurazione Interfacce

```
interface g0/0
 ! Assegnazione statica
 ipv6 address 2001:db8:1::1/64

 ! Generazione automatica host ID
 ipv6 address 2001:db8:2::/64 eui-64

 ! Abilita solo il Link-Local
 ipv6 enable
```

### Static Routing IPv6 (Blueprint 3.3)

```
! Default Route
ipv6 route ::/0 2001:db8:1::2

! Network Route (Recursive)
ipv6 route 2001:db8:3::/64 2001:db8:1::2

! Link-Local Next-Hop (Fully Specified - OBBLIGATORIO su Ethernet)
ipv6 route 2001:db8:4::/64 g0/0 fe80::2
```

## ⚠️ Common Mistakes (Anatomy Check)

> [!DANGER] Trappole d'Esame
>
> 1. **Zero Esagerati**: Mai rimuovere gli zeri finali di un quartetto (es. `ab00` non diventa `ab`).
> 2. **Double Colon**: L'uso di `::` due volte rende l'indirizzo invalido (ambiguità).
> 3. **Next-Hop Link-Local**: Se usi un indirizzo `fe80` come next-hop in una rotta statica, devi **sempre** specificare l'interfaccia di uscita.
> 4. **Multicast Scopes**: `ff02` è Link-Local (stessa subnet), `ff0e` è Global. Confonderli rompe il routing.
> 5. **IPv6 Broadcast**: Se una domanda d'esame menziona "broadcast" in ambito IPv6, la risposta è quasi certamente falsa. Si usa **Multicast `ff02::1`** (All nodes).
>

## 🎯 Synthesis

IPv6 semplifica l'header eliminando campi come il Checksum (affidato ai livelli superiori). La gestione degli indirizzi è più flessibile grazie a SLAAC e **NDP**, ma richiede precisione nella gestione dei prefissi e nell'abilitazione del routing unicast globale sul router.
