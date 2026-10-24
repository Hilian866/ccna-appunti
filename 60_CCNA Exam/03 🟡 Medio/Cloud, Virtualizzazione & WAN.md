---
tags: [ccna, exam, fondamenti, wan]
priorita: medio
dominio: Network Fundamentals
stato: da-ripassare
---

## Obiettivo
Architetture LAN/WAN, cloud e virtualizzazione: domande di sola teoria.

## 1. Architetture LAN
| | 2-tier (Collapsed Core) | 3-tier | Spine-Leaf |
|---|---|---|---|
| Livelli | Access + Distribution/Core | Access, Distribution, Core | Leaf (access) + Spine |
| Uso | Campus medio | Campus grande | **Data center** |
| Traffico | Nord-Sud | Nord-Sud | **Est-Ovest**, latenza prevedibile |
| Link | — | — | Ogni leaf ↔ ogni spine; leaf-leaf e spine-spine **mai** collegati |

**SOHO**: un solo dispositivo (router + switch + AP). **Access** = utenti/AP, **Distribution** = policy/inter-VLAN/routing, **Core** = backbone veloce.

## 2. WAN
| Tecnologia | Note |
|---|---|
| Leased line | Punto-punto dedicato, costoso, sicuro |
| MPLS VPN | Rete del provider, QoS, L3 VPN |
| Metro Ethernet | Ethernet su rete del provider |
| Internet + VPN | Economico: **IPsec** site-to-site o remote access |
| DMVPN / GRE | GRE incapsula multicast/routing ma **non cifra**; IPsec cifra |

Topologie: point-to-point, hub-and-spoke, full mesh, partial mesh. Vedi [[Day 53 — WAN Architectures & VPNs]] · Lab: [[Day 53 Lab - GRE Tunnels.pkt]].

## 3. Cloud
| Modello | Gestisci tu | Esempio |
|---|---|---|
| IaaS | OS, app, dati | AWS EC2, Azure VM |
| PaaS | App e dati | Azure App Service, Heroku |
| SaaS | Solo l'uso | Microsoft 365, Gmail |

Deployment: public, private, hybrid, community. Caratteristiche: on-demand, elastic, pay-as-you-go, resource pooling.

## 4. Virtualizzazione
| | VM | Container |
|---|---|---|
| Isolamento | Ogni VM ha il **proprio OS** (hypervisor) | Condividono il **kernel** dell'host |
| Peso | GB, avvio lento | MB, avvio rapido |
| Esempi | VMware ESXi, KVM, Hyper-V | Docker, Kubernetes |

- **Hypervisor Tipo 1** = *bare metal* (ESXi, KVM); **Tipo 2** = su OS host (VirtualBox).
- **VRF**: più routing table indipendenti su un solo router (segmentazione L3), con IP sovrapponibili.

## Common Mistakes
- **GRE non cifra**; per la cifratura serve IPsec.
- Spine-Leaf: **i leaf non si collegano tra loro**.
- Container ≠ VM: niente OS guest.
- Tier: **inter-VLAN routing/policy = distribution**, non access.

## 🎯 Synthesis
Campus = 2/3 tier, data center = spine-leaf; cloud = IaaS/PaaS/SaaS in base a quanto gestisci tu; VM hanno un OS, i container condividono il kernel.

Approfondimenti: [[Day 52 — LAN Architectures (2-tier, 3-tier, Spine-Leaf, SOHO)]] · [[Day 54 (Parte 1) - Virtualization & Cloud Fundamentals]] · [[Day 54 (Parte 2) - Virtualization - Virtual Machines vs Containers]] · [[Day 54 (Parte 3) - Virtual Routing & Forwarding (VRF)]]
