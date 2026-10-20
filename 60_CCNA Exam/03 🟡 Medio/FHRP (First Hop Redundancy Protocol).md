---
tags: [ccna, exam]
priorita: medio
stato: da-ripassare
---

Questa nota è fondamentale perché i protocolli FHRP (HSRP in particolare) sono tra i pochi argomenti dove Cisco richiede di conoscere dettagli mnemonici precisi (come i VMAC).

---

## Scopo del Sistema

Fornire un **Default Gateway ridondante** a una subnet. Risolve il problema del Single Point of Failure (SPOF) del router senza dover riconfigurare i PC.

> [!INFO] **Risorse di Studio**
>
> **VIDEO:** **[First Hop Redundancy Protocols | Day 29](https://youtu.be/43WnpwQMolo?list=PLxbwE86jKRgMpuZuLBivzlM8s2Dk5lXBQ&t=1476)**

---

## Meccanica Operativa

1. **Virtual IP (VIP)**: I router condividono un indirizzo IP (es. `.254`) che i PC usano come Gateway.
2. **Virtual MAC (VMAC)**: Quando un PC fa ARP per il VIP, il router **Attivo** risponde con il VMAC.
3. **Gratuitous ARP**: Durante un failover, il nuovo router attivo invia un pacchetto ARP non richiesto.
    - **Obiettivo**: Forzare gli switch ad aggiornare la propria **MAC Address Table**, associando il VMAC alla nuova porta fisica.

---

## Confronto Protocolli (CCNA Blueprint)

|**Caratteristica**|**HSRP (Cisco)**|**VRRP (Open)**|**GLBP (Cisco)**|
|---|---|---|---|
|**Ruoli**|Active / Standby|Master / Backup|AVG / AVF|
|**Peculiarità**|Standard Cisco|Multimarca|Load Balance reale|
|**Preemption**|Off (Default)|On (Default)|On (Default)|

### Dettagli Virtual MAC (Da memorizzare)

> [!WARNING] **Analisi dei VMAC**
>
> I VMAC contengono l'ID del gruppo in esadecimale (**HEX**).
>
> - **HSRP v1**: `0000.0c07.acXX` (XX = Gruppo)
> - **HSRP v2**: `0000.0c9f.fXXX` (XXX = Gruppo)
> - **VRRP**: `0000.5e00.01XX` (XX = Gruppo)
> - **GLBP**: `0007.b400.GGFF` (GG = Gruppo, FF = Forwarder)
>

---

## 💻 CLI Core (HSRP v2)

Sebbene il blueprint si concentri sul "Purpose", la sintassi aiuta a comprendere la logica:

```
interface g0/0
 ! Necessario per supporto gruppi > 255 e IPv6
 standby version 2

 ! Imposta il Virtual IP
 standby 1 ip 172.16.0.254

 ! Default 100. Più alto = Vince
 standby 1 priority 200

 ! Permette di riprendere il ruolo se torna online
 standby 1 preempt
```

> [!TIP] **Comando di Verifica**
>
> `show standby brief` è il modo più veloce per vedere lo stato (Active/Standby), la priority e il VIP di tutti i gruppi.

---

## ⚠️ Common Mistakes (Anatomy Check)

> [!DANGER] **Errori Critici in Esame**
>
> 1. **Mancata Preemption**: Se il router principale riavvia, non tornerà "Active" senza il comando `preempt`, anche se ha la priority più alta.
> 2. **Mismatch di Versione**: HSRP v1 e v2 **non comunicano** tra loro.
> 3. **Load Balancing HSRP**: HSRP non fa load balancing nativo (usa un solo router alla volta). Per farlo, servono due gruppi diversi con VIP diversi (Multigroup HSRP).
> 4. **ARP cache**: I PC non aggiornano l'ARP dopo un failover (perché VIP e VMAC non cambiano); sono gli switch a dover aggiornare la tabella MAC.
>

---

## 🎯 Synthesis

Il gateway ridondante è un'illusione creata per i PC: loro vedono sempre lo stesso **VIP/VMAC**, mentre dietro le quinte i router negoziano chi risponde a quell'identità virtuale tramite messaggi di Hello e aggiornano la rete tramite Gratuitous ARP.
