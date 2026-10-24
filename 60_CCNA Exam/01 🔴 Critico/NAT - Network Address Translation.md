---
tags: [ccna, exam]
priorita: critico
stato: da-ripassare
---

> [!ABSTRACT]
> Il **NAT** ottimizza l'uso degli indirizzi **IPv4** traducendo IP privati non instradabili in IP pubblici globalmente univoci. Questo processo permette di conservare lo spazio di indirizzamento e fornisce un primo livello di sicurezza nascondendo la topologia interna della rete.

## Il Perimetro: Indirizzi Privati (RFC 1918)
> [!INFO]
> Gli **Indirizzi Privati** sono definiti dalla **RFC 1918** come spazio non instradabile su Internet. Gli **ISP** scartano automaticamente questi pacchetti per prevenire collisioni globali.

| Classe | Intervallo | CIDR | Uso Tipico |
| :--- | :--- | :--- | :--- |
| A | 10.0.0.0 – 10.255.255.255 | /8 | Enterprise / Grandi reti |
| B | 172.16.0.0 – 172.31.255.255 | /12 | Medie imprese |
| C | 192.168.0.0 – 192.168.255.255 | /16 | Home / Small Office |

## La Matrice Terminologica
Per la certificazione CCNA, è essenziale distinguere tra la posizione fisica (**Inside/Outside**) e la prospettiva dell'indirizzo (**Local/Global**).

| Termine | Definizione Tecnica | Visibilità |
| :--- | :--- | :--- |
| Inside Local | L'IP privato reale assegnato all'host interno. | LAN |
| Inside Global | L'IP pubblico che rappresenta l'host interno verso l'esterno. | Internet |
| Outside Local | L'IP della destinazione esterna come appare alla LAN. | LAN |
| Outside Global | L'IP pubblico reale del server o host esterno. | Internet |

## Tassonomia delle Traduzioni

*   **Static NAT (1:1):** Crea un mapping permanente tra un IP privato e uno pubblico. Essenziale per Web Server o Mail Server che devono essere raggiungibili dall'esterno (**Inbound**).
*   **Dynamic NAT (Pool 1:1):** Assegna dinamicamente un IP pubblico da un pool predefinito.
    > [!CAUTION]
    > Se il pool di indirizzi pubblici si esaurisce, i nuovi tentativi di connessione verranno scartati dal router (**NAT Misses**).
*   **PAT / NAT Overload (Many-to-One):** Il metodo più comune. Utilizza i numeri di porta del **Layer 4** per permettere a migliaia di host interni di condividere un unico indirizzo **Inside Global**.

## Configurazione (CLI)

### Fase 1: Marcatura Interfacce

Senza questo passaggio, il router ignora completamente ogni regola di traduzione.

```
interface g0/0
 ip nat inside     ! Lato LAN (Privato)
interface g0/1
 ip nat outside    ! Lato WAN (Pubblico)
```

### Fase 2: Selezione e Mapping

Identifica lo scenario necessario e applica la configurazione corrispondente:

> [!ABSTRACT] A. Static NAT (Pubblicazione Server)
>
> Si utilizza per rendere un host interno (Web Server, Mail, VPN) sempre raggiungibile dall'esterno. Crea un mapping fisso 1:1 che non scade mai.
>
> - **Vantaggio:** Permette connessioni _Inbound_.
> - **Configurazione:**
>
>
>
> ```
> ! ip nat inside source static [IP_Privato] [IP_Pubblico]
> ip nat inside source static 192.168.0.1 100.0.0.1
> ```

> [!NOTE] B. Dynamic NAT (Pool di Indirizzi)
>
> Utilizzato quando si ha a disposizione un gruppo di IP pubblici da assegnare temporaneamente agli host. La traduzione è 1:1 ma non permanente.
>
> - **Configurazione:**
>
>
>
> ```
> ! 1. Identifica chi può essere tradotto
> access-list 1 permit 192.168.1.0 0.0.0.255
> 
> ! 2. Definisci il range di IP pubblici disponibili
> ip nat pool MIO_POOL 100.0.0.1 100.0.0.10 netmask 255.255.255.0 
> 
> ! 3. Lega l'ACL al Pool
> ip nat inside source list 1 pool MIO_POOL
> ```

> [!TIP] C. PAT / Overload (Navigazione Massiva)
> [12:34](https://youtu.be/kILDNs4KjYE?list=PLxbwE86jKRgMpuZuLBivzlM8s2Dk5lXBQ&t=754)
>
> È la configurazione standard per le reti LAN. Permette a migliaia di host di navigare usando un solo IP pubblico (quello dell'interfaccia WAN) grazie alla manipolazione delle porte L4.
>
> - **Configurazione:**
>
>
>
> ```
> ! 1. Identifica la subnet della LAN
> access-list 1 permit 192.168.1.0 0.0.0.255
> 
> ! 2. Applica la traduzione con la keyword magica 'overload'
> ip nat inside source list 1 interface g0/1 overload
> ```

## Audit e Manutenzione Operativa

Utilizza questa sequenza per testare la configurazione o per risolvere problemi di connettività:

1. **`show ip nat translations`** — Visualizza la tabella attiva. Controlla se i mapping statici (Server) sono presenti e se gli host della LAN stanno generando entry dinamiche.
2. **`clear ip nat translation *`** — Svuota istantaneamente tutte le traduzioni dinamiche.

    > [!IMPORTANT] Si usa per forzare il router a riapplicare le regole (ad esempio dopo aver modificato un'ACL) o per verificare se un host sta effettivamente rigenerando una sessione NAT corretta.

3. **`show ip nat statistics`** — Fornisce una vista d'insieme. È fondamentale per capire se il NAT sta funzionando (contatore _Hits_) o se il Pool di indirizzi pubblici è esaurito (contatore _Misses_).

## 🎯 Synthesis
NAT traduce inside local → inside global; static = 1:1, dynamic = pool, PAT = molti IP su uno tramite porte.

---

> [!EXAMPLE] Laboratori Pratici
> - [[Day 44 Lab - Static NAT.pkt]]
> - [[Day 45 Lab - Dynamic NAT.pkt]]
