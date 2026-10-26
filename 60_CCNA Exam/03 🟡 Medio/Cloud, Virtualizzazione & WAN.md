---
tags: [ccna, exam, fondamenti, wan]
priorita: medio
dominio: Network Fundamentals
stato: da-ripassare
---

> [!ABSTRACT] Cosa serve per l'esame
> Blueprint **1.2** (architetture: two-tier, three-tier, spine-leaf, WAN, SOHO, on-premise e cloud) e **1.12** (virtualizzazione: server virtuali, container, VRF).
> Tutto a parole: devi riconoscere un'architettura da una descrizione, sapere le regole di cablaggio dello spine-leaf, le tecnologie WAN e i termini di ridondanza, i modelli di servizio e di deployment del cloud, e la differenza tra VM e container. Le VPN sono in [[Security Fundamentals (AAA, VPN, Threats, WPA3)]], i dispositivi in [[Componenti di Rete (Ruoli e Funzioni)]].

## 1. Topologie fisiche

- **Stella**: tutti collegati a un dispositivo centrale (gli host su uno switch).
- **Full mesh**: ogni dispositivo collegato a tutti gli altri. Massima ridondanza, ma i link crescono in fretta: con n dispositivi sono n(n-1)/2.
- **Partial mesh**: alcuni dispositivi collegati tra loro, non tutti.

## 2. Architetture LAN

### Three-tier

| Livello | Cosa fa |
| :--- | :--- |
| **Access** | collega gli host e gli AP. Port security, PoE, QoS marking, VLAN |
| **Distribution** | aggrega gli switch di access, fa da **confine tra Layer 2 e Layer 3**: inter-VLAN routing, policy, ACL, ridondanza del gateway |
| **Core** | il backbone veloce tra i distribution. Solo **Layer 3**, niente STP, nessuna funzione che rallenti (niente ACL pesanti, niente host collegati) |

Il core serve quando i blocchi di distribution sono tanti: collegarli tutti tra loro in full mesh non scalerebbe.

### Two-tier (collapsed core)

**Access più distribution**, con le funzioni del core **dentro** il distribution. Va bene per campus piccoli e medi, dove un livello core separato non serve.

### Spine-leaf (data center)

Nei data center il traffico è soprattutto **est-ovest** (server ↔ server, dentro il data center), non nord-sud (verso l'esterno). Con il three-tier quel traffico fa percorsi di lunghezza diversa. Lo spine-leaf ha regole fisse:

- ogni **leaf** è collegato a **ogni spine**;
- i leaf **non** si collegano tra loro, gli spine nemmeno;
- i server (e i router verso l'esterno) si collegano **solo ai leaf**.

Così tra due server qualsiasi su leaf diversi il percorso è sempre leaf → spine → leaf: latenza prevedibile, e il traffico si bilancia sui vari spine. Per crescere si aggiunge un leaf e lo si collega a tutti gli spine.

### SOHO

Small office / home office: un solo dispositivo (il "router di casa") fa da router, switch, AP, firewall e server DHCP.

## 3. WAN

Una WAN collega LAN lontane tra loro (sedi in città o paesi diversi).

| Tecnologia | Come funziona |
| :--- | :--- |
| **Leased line** | collegamento fisico **dedicato** punto-punto, affittato dal provider. Costoso e lento da attivare. Storicamente seriale (T1 1,544 Mbit/s, E1 2,048 Mbit/s) con PPP o HDLC |
| **MPLS** | rete condivisa del provider che inoltra in base a **label** invece che agli IP. Crea VPN tra le sedi del cliente |
| **Internet + VPN** | si usa Internet (economico) e si protegge il traffico con una VPN IPsec |
| Accesso a Internet | DSL (linea telefonica), cavo (rete della TV, con modem), **fibra**, rete cellulare 4G/5G, Metro Ethernet |

**MPLS**:

- **CE** (customer edge): il router del cliente, non usa MPLS.
- **PE** (provider edge): il router del provider collegato al CE; aggiunge e toglie le label.
- **P** (provider): router interni del provider.
- **MPLS VPN Layer 3**: il CE fa routing con il PE (OSPF, BGP, statiche).
- **MPLS VPN Layer 2**: il provider è trasparente, i CE si vedono come collegati direttamente.

Topologia WAN tipica: **hub-and-spoke** (una sede centrale, le filiali collegate a lei). Si usano anche full e partial mesh.

Ridondanza della connessione a Internet:

| Termine | Link | ISP |
| :--- | :--- | :--- |
| **Single-homed** | 1 | 1 |
| **Dual-homed** | 2 | 1 (lo stesso) |
| **Multihomed** | 1 per ISP | 2 o più |
| **Dual multihomed** | 2 per ISP | 2 o più |

**GRE** crea tunnel che trasportano anche multicast (quindi protocolli di routing), ma **non cifra**; per questo si usa GRE over IPsec. Dettagli in [[Security Fundamentals (AAA, VPN, Threats, WPA3)]], sezione 7.

## 4. On-premise e cloud

- **On-premise**: l'infrastruttura sta nei locali dell'azienda, che la compra e la gestisce.
- **Cloud**: risorse prese da un provider, quando servono.

Le cinque caratteristiche del cloud (definizione NIST):

1. **On-demand self-service**: il cliente attiva le risorse da solo, senza contattare il provider.
2. **Broad network access**: accesso dalla rete, da qualsiasi dispositivo.
3. **Resource pooling**: le risorse del provider sono condivise tra molti clienti (multi-tenant).
4. **Rapid elasticity**: le risorse crescono e calano rapidamente con la domanda.
5. **Measured service**: si paga quanto si usa.

| Modello di servizio | Il provider dà | Il cliente gestisce | Esempi |
| :--- | :--- | :--- | :--- |
| **IaaS** | hardware, rete, virtualizzazione | sistema operativo, applicazioni, dati | VM su AWS EC2, Azure |
| **PaaS** | anche OS e ambiente di sviluppo | applicazioni e dati | Google App Engine, Azure App Service |
| **SaaS** | tutto, applicazione compresa | solo l'uso | Microsoft 365, Gmail |

| Deployment | Chi lo usa |
| :--- | :--- |
| **Public** | chiunque, su infrastruttura del provider |
| **Private** | una sola organizzazione (anche se gestito da un provider) |
| **Community** | più organizzazioni con esigenze comuni (es. requisiti di legge) |
| **Hybrid** | combinazione di due o più dei precedenti |

Collegarsi al cloud: via **Internet** (economico, conviene con una VPN IPsec) o con una **WAN privata** (MPLS, collegamento diretto con il provider).

## 5. Virtualizzazione

Su un server fisico girano più **macchine virtuali** (VM), ognuna con il **proprio sistema operativo**. Le gestisce l'**hypervisor**.

| Hypervisor | Dove gira | Esempi | Uso |
| :--- | :--- | :--- | :--- |
| **Tipo 1** (bare metal, nativo) | direttamente sull'hardware | VMware ESXi, Microsoft Hyper-V, KVM | data center |
| **Tipo 2** (hosted) | sopra un sistema operativo | VirtualBox, VMware Workstation | PC personali, test |

Ogni VM ha una o più **vNIC**, collegate a un **virtual switch** dentro l'hypervisor. Il vSwitch supporta VLAN, porte access e trunk, e si collega alla rete fisica tramite le schede del server (spesso un trunk verso lo switch).

| | VM | Container |
| :--- | :--- | :--- |
| Contiene | un **sistema operativo completo** | solo l'applicazione e le sue librerie |
| Condivide | l'hardware (tramite l'hypervisor) | il **kernel** del sistema operativo host |
| Dimensione | GB | MB |
| Avvio | minuti | secondi o meno |
| Isolamento | più forte | minore |
| Strumenti | ESXi, Hyper-V, KVM | **Docker** (motore), **Kubernetes** (orchestrazione) |

### VRF

Un **VRF** (virtual routing and forwarding) divide un router in più **tabelle di routing** separate: le interfacce di un VRF non vedono le rotte degli altri. È la virtualizzazione del livello 3, come le VLAN lo sono del livello 2.

- I VRF diversi possono usare **indirizzi sovrapposti** (lo stesso 192.168.1.0/24 per due clienti).
- **VRF-lite**: VRF senza MPLS, in ambito aziendale.

```ios
! Crea il VRF e ci mette un'interfaccia
R1(config)# ip vrf CLIENTE_A
R1(config)# interface g0/0
R1(config-if)# ip vrf forwarding CLIENTE_A

! L'IP va rimesso: ip vrf forwarding cancella quello configurato prima
R1(config-if)# ip address 192.168.1.1 255.255.255.0

! Tabella di routing e ping dentro il VRF
R1# show ip route vrf CLIENTE_A
R1# ping vrf CLIENTE_A 192.168.1.10
```

## ⚠️ Trappole d'esame

> [!WARNING] Gli errori più frequenti
> 1. **Spine-leaf**: i leaf non si collegano tra loro, gli spine nemmeno; i server solo ai leaf.
> 2. **Two-tier**: è access + distribution (core collassato nel distribution), non access + core.
> 3. **Core**: niente STP e niente funzioni lente; l'inter-VLAN routing sta nel distribution.
> 4. **GRE** non cifra.
> 5. **Dual-homed e multihomed**: dual-homed = due link allo stesso ISP; multihomed = ISP diversi.
> 6. **IaaS e PaaS**: in IaaS il sistema operativo lo gestisci tu, in PaaS no.
> 7. **Container**: niente sistema operativo proprio, condividono il kernel.
> 8. **Hypervisor tipo 1** gira sull'hardware, il tipo 2 sopra un sistema operativo.

## Esercizi

> [!QUESTION]- Un data center ha 4 spine e 10 leaf. Quanti link servono tra i due livelli?
> 40: ogni leaf è collegato a ogni spine (10 × 4).

> [!QUESTION]- Una sede ha due collegamenti a Internet, entrambi con lo stesso ISP. Come si chiama?
> Dual-homed.

> [!QUESTION]- L'azienda vuole solo caricare il proprio codice, senza gestire server e sistemi operativi. Che modello di cloud?
> PaaS.

> [!QUESTION]- Due clienti usano entrambi 10.0.0.0/24 e devono passare dallo stesso router senza vedersi. Che tecnologia?
> VRF (VRF-lite): una tabella di routing separata per cliente.

> [!QUESTION]- Un'azienda piccola ha switch di accesso collegati a due switch multilayer che fanno routing e collegano Internet. Che architettura è?
> Two-tier (collapsed core).

## Check da esame

- [ ] Architettura del data center? **Spine-leaf**.
- [ ] Traffico tipico del data center? **Est-ovest (server ↔ server)**.
- [ ] Livello che fa da confine L2/L3 nel three-tier? **Distribution**.
- [ ] Le cinque caratteristiche NIST? **Self-service, broad network access, resource pooling, rapid elasticity, measured service**.
- [ ] Cosa condividono i container? **Il kernel dell'host**.
- [ ] Ruoli MPLS? **CE (cliente), PE (bordo del provider), P (interni)**.

## 🎯 Synthesis

Campus: three-tier (access, distribution, core) o two-tier (core collassato nel distribution); data center: spine-leaf (ogni leaf su ogni spine, traffico est-ovest). WAN: leased line, MPLS (CE, PE, P) o Internet con VPN; ridondanza da single-homed a dual multihomed. Cloud: cinque caratteristiche NIST, IaaS/PaaS/SaaS, public/private/community/hybrid. Virtualizzazione: VM con un sistema operativo proprio sull'hypervisor (tipo 1 o 2), container che condividono il kernel, VRF per tabelle di routing separate.

Approfondimenti: [[Day 52 — LAN Architectures (2-tier, 3-tier, Spine-Leaf, SOHO)]] · [[Day 53 — WAN Architectures & VPNs]] · [[Day 54 (Parte 1) - Virtualization & Cloud Fundamentals]] · [[Day 54 (Parte 2) - Virtualization - Virtual Machines vs Containers]] · [[Day 54 (Parte 3) - Virtual Routing & Forwarding (VRF)]]

> [!EXAMPLE] Laboratori pratici
> - [[Day 53 Lab - GRE Tunnels.pkt]]
