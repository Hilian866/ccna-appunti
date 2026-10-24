---
tags: [ccna, exam]
priorita: medio
stato: da-ripassare
---

## Obiettivo

Controllare l'accesso fisico allo switch limitando **quali** e **quanti** MAC address possono trasmettere frame su una specifica porta. Mitiga attacchi di _MAC Address Table Flooding_ e _DHCP Starvation_.

> [!INFO] Risorse di Studio
>
> **VIDEO:** **[Port Security | Day 49](https://youtu.be/sHN3jOJIido?list=PLxbwE86jKRgMpuZuLBivzlM8s2Dk5lXBQ&t=471)**

## Condizione Preliminare (Il "Killer" del Lab)

La Port Security **NON** può essere abilitata su porte in modalità dinamica (DTP).

- ❌ **NO**: `dynamic auto`, `dynamic desirable`.
- ✅ **SI**: `switchport mode access` o `switchport mode trunk`.

## Violation Modes (Confronto Core)

Questa tabella è il cuore del blueprint CCNA per la sicurezza L2.

|Caratteristica|Shutdown (Default)|Restrict|Protect|
|---|---|---|---|
|Stato Porta|**Err-disabled** (Down)|Up|Up|
|Traffico Errato|Bloccato|Scartato|Scartato|
|Log (Syslog/SNMP)|Sì (1 messaggio)|**Sì (Ogni frame)**|No|
|Counter Violazione|Incrementa (a 1)|**Incrementa**|No|

## Tipi di Secure MAC Address

1. **Static**: Inserito manualmente. Resiste al reboot (se salvato in startup-config).
2. **Dynamic**: Appreso dal primo frame che entra. Scompare se la porta va down o se lo switch si riavvia.
3. **Sticky**: Il meglio dei due mondi. Appreso dinamicamente ma **scritto automaticamente nel running-config**.

> [!WARNING] Persistence Check
>
> Gli **Sticky MAC** sopravvivono al reboot **SOLO SE** esegui un `write memory` (o `copy run start`). Senza salvataggio, la running-config viene persa e lo switch dovrà impararli di nuovo.

## Secure MAC Aging

L'aging definisce quando un indirizzo sicuro viene rimosso per far spazio a nuovi dispositivi.

- **Default**: Aging disabilitato (Time = 0).
- **Aging Type Absolute**: Scade allo scoccare del timer, a prescindere dal traffico.
- **Aging Type Inactivity**: Il timer si resetta ogni volta che il dispositivo trasmette (consigliato).

> [!CAUTION] Eccezione Statica
>
> Di default, l'aging si applica **solo ai MAC dinamici**. Per far scadere i MAC statici serve il comando: `switchport port-security aging static`.

## CLI Workflow

**Configurazione Base (Access Port)**

```
interface g0/1
 switchport mode access
 switchport port-security

 ! Max 2 dispositivi
 switchport port-security maximum 2

 ! Impara e scrivi in config
 switchport port-security mac-address sticky
```

**Configurazione Recovery (Automatica)**

```
errdisable recovery cause psecure-violation

! Tenta il ripristino ogni 5 minuti
errdisable recovery interval 300
```

**Verifica Rapida**

- `show port-security interface g0/1` -> Dettaglio completo (Status, Counter, Last Source MAC).
- `show mac address-table secure` -> Mostra solo i MAC "protetti" dalla feature.

## ⚠️ Common Mistakes (Anatomy Check)

> [!DANGER] Attenzione ai Quiz
>
> 1. **Metodo Manuale**: Per riaprire una porta in `err-disabled`, non basta il `no shutdown`. Bisogna dare prima `shutdown` e poi `no shutdown`.
> 2. **Restrict vs Protect**: Ricorda che `protect` è "silenzioso" (niente log, niente counter). In ambito professionale si usa quasi sempre `restrict` o `shutdown`.
> 3. **Trunk Port**: Sebbene raro, Port Security funziona sui Trunk, ma il limite di MAC è **totale** sulla porta, non per singola VLAN.
>

## 🎯 Synthesis

La Port Security trasforma una porta "stupida" in un guardiano: conta i MAC, riconosce quelli autorizzati e, in caso di violazione, decide se "gridare" (Restrict), "stare in silenzio" (Protect) o "suicidarsi" (Shutdown).
