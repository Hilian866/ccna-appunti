---
tags: [ccna, exam, fondamenti]
priorita: medio
dominio: Network Fundamentals
blueprint: 1.1
stato: da-ripassare
---

> [!ABSTRACT] Cosa serve per l'esame
> Blueprint **1.1**: ruolo e funzione dei componenti di rete: router, switch Layer 3, NGFW e IPS, access point, controller (Catalyst Center e WLC), endpoint, server, PoE.
> Devi sapere cosa fa ciascuno, a che livello lavora e come si distingue da quello che gli somiglia (switch L2 e L3, firewall e NGFW, IDS e IPS, AP autonomo e lightweight, WLC e Catalyst Center). Dove si collocano nella rete: [[Cloud, Virtualizzazione & WAN]].

## 1. I componenti

| Componente | Livello | Cosa fa |
| :--- | :--- | :--- |
| **Router** | 3 | inoltra pacchetti **tra reti diverse** in base all'IP di destinazione. Ogni interfaccia è un dominio di broadcast diverso. Fa anche NAT, ACL, VPN, DHCP |
| **Switch Layer 2** | 2 | inoltra frame **dentro una LAN** in base al MAC. VLAN, trunk, STP. Ogni porta è un dominio di collisione separato |
| **Switch Layer 3** (multilayer) | 2 e 3 | fa switching **e** routing, in hardware (ASIC): **SVI** per l'inter-VLAN routing, porte routed |
| **Firewall** | 3-4 | filtra il traffico tra zone (interna, esterna, DMZ), tenendo traccia delle connessioni (**stateful**) |
| **NGFW** (next-generation firewall) | 3-7 | firewall stateful più riconoscimento delle **applicazioni**, IPS integrato, filtro URL, protezione da malware |
| **IPS** | 3-7 | analizza il traffico **in linea** e **blocca** quello che corrisponde a firme di attacchi |
| **Access point** | 1-2 | collega i client wireless alla rete cablata (fa da ponte tra 802.11 ed Ethernet) |
| **WLC** (wireless LAN controller) | — | gestisce in modo centralizzato gli AP lightweight (configurazione, canali, potenza, roaming), con **CAPWAP** |
| **Catalyst Center** (ex DNA Center) | — | controller di **tutta** la rete campus: automazione, policy, monitoraggio (assurance), intent-based networking |
| **Endpoint** | — | i dispositivi finali: PC, telefoni IP, stampanti, telecamere, sensori IoT |
| **Server** | — | offre servizi agli endpoint: DHCP, DNS, web, file, posta, autenticazione |
| **PoE** | 1 | lo switch (**PSE**) alimenta il dispositivo (**PD**: AP, telefono, telecamera) sullo stesso cavo Ethernet |

Il firewall tradizionale guarda indirizzi, porte e stato delle connessioni. L'NGFW riconosce anche **quale applicazione** sta passando (es. blocca un'app di file sharing anche sulla porta 443).

Un **IDS** fa lo stesso lavoro dell'IPS ma riceve una **copia** del traffico: può solo **avvisare**, non bloccare.

## 2. Dove si collocano

- **Access**: switch L2 verso endpoint e AP, con PoE.
- **Distribution**: switch L3, inter-VLAN routing, policy, ridondanza.
- **Core**: switch L3 veloci tra i distribution.
- **Perimetro (edge)**: router verso Internet e NGFW/IPS.
- **Controller**: WLC e Catalyst Center gestiscono AP e switch, ma il traffico degli utenti non passa necessariamente da loro.

## 3. PoE

| Nome | Standard | Potenza massima per porta | Coppie usate |
| :--- | :--- | :--- | :--- |
| PoE | 802.3af | 15,4 W | 2 |
| PoE+ | 802.3at | 30 W | 2 |
| UPoE | 802.3bt (tipo 3) | 60 W | 4 |
| UPoE+ | 802.3bt (tipo 4) | 100 W | 4 |

Lo switch prima verifica che il dispositivo sia compatibile, poi gli dà la potenza richiesta. Con il **power policing**, se un dispositivo assorbe più del previsto la porta viene spenta (err-disabled) o viene registrato un messaggio. Dettagli in [[Interfacce, Cablaggio & Troubleshooting]].

## 4. Confronti tipici

| Coppia | Differenza |
| :--- | :--- |
| Switch L2 e L3 | L2 inoltra solo per MAC; L3 instrada anche tra VLAN (SVI), senza router esterno |
| Firewall e NGFW | il firewall filtra su IP, porte e stato; l'NGFW riconosce anche le applicazioni e le minacce |
| IDS e IPS | IDS passivo (avvisa); IPS in linea (blocca) |
| AP autonomo e lightweight | l'autonomo si configura da solo; il lightweight dipende da un WLC (CAPWAP, split-MAC) |
| WLC e Catalyst Center | il WLC gestisce il wireless; Catalyst Center tutta la rete campus |

## ⚠️ Trappole d'esame

> [!WARNING] Gli errori più frequenti
> 1. **Switch L2 che instrada**: senza funzioni Layer 3 (SVI, `ip routing`) non può.
> 2. **IDS e IPS**: l'IDS non blocca.
> 3. **Controller nel percorso dei dati**: il controller gestisce (control e management plane); i dati li inoltrano i dispositivi. Vedi [[00 Automation - Riassunto]].
> 4. **NGFW e firewall stateful**: entrambi sono stateful; solo l'NGFW riconosce le applicazioni.
> 5. **PSE e PD**: il PSE (switch) fornisce l'energia, il PD la riceve.

## Esercizi

> [!QUESTION]- Serve un dispositivo che blocchi automaticamente un attacco riconosciuto da una firma, mentre il traffico passa. IDS o IPS?
> IPS: è in linea e può bloccare.

> [!QUESTION]- Tre VLAN devono comunicare tra loro senza un router esterno. Che dispositivo serve?
> Uno switch Layer 3, con una SVI per VLAN.

> [!QUESTION]- Un AP richiede 25 W. Che standard PoE minimo deve supportare lo switch?
> PoE+ (802.3at, 30 W).

> [!QUESTION]- Vuoi bloccare un'applicazione di streaming che usa la porta 443, senza bloccare il resto del traffico HTTPS. Che dispositivo serve?
> Un NGFW, che riconosce le applicazioni.

## Check da esame

- [ ] Livello del router? **3**. Dello switch L2? **2**.
- [ ] Cosa aggiunge un NGFW a un firewall? **Riconoscimento delle applicazioni, IPS, filtro URL, antimalware**.
- [ ] Protocollo tra AP lightweight e WLC? **CAPWAP**.
- [ ] Standard PoE+? **802.3at, 30 W**.
- [ ] Controller di tutta la rete campus Cisco? **Catalyst Center**.

## 🎯 Synthesis

Il router instrada tra reti (livello 3), lo switch L2 inoltra per MAC dentro la LAN, lo switch L3 fa entrambe le cose. Firewall e NGFW filtrano (l'NGFW riconosce anche le applicazioni), l'IPS blocca in linea mentre l'IDS avvisa soltanto. Gli AP collegano il wireless, il WLC li gestisce, Catalyst Center gestisce tutta la rete. Il PoE alimenta AP e telefoni dallo switch.

Vedi anche: [[Wireless]] · [[Security Fundamentals (AAA, VPN, Threats, WPA3)]]
