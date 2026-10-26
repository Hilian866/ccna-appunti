---
tags: [ccna, exam]
priorita: molto-importante
stato: da-ripassare
---

> [!ABSTRACT] Cosa serve per l'esame
> Blueprint **1.11** (principi wireless: canali non sovrapposti, SSID, RF, cifratura), **2.9** (leggere la configurazione di una WLAN nella GUI del WLC), **5.9** (WPA, WPA2, WPA3) e **5.10** (creare una WLAN WPA2-PSK dalla GUI).
> Devi saper scegliere banda e canali, distinguere SSID, BSSID, BSS ed ESS, collegare ogni versione di WPA alla sua cifratura, e conoscere i passi e le schede della GUI del WLC. Modalità degli AP, cablaggio e accesso di gestione sono in [[Wireless - AP Modes & Management Access]].

## 1. Cosa cambia rispetto alla rete cablata

- **Il mezzo è condiviso**: chiunque sia nel raggio riceve i frame, quindi la cifratura serve anche dentro la LAN.
- **Half duplex**: un dispositivo non può trasmettere e ricevere insieme.
- **CSMA/CA** (Collision **Avoidance**): ascolta, attende, poi trasmette. L'Ethernet cablata usa invece CSMA/CD (Collision **Detection**). RTS/CTS è un'opzione non richiesta.
- **IEEE** scrive gli standard 802.11; la **Wi-Fi Alliance** certifica che i prodotti funzionino insieme.

## 2. RF e canali

Le onde radio si descrivono con **ampiezza** (la forza del segnale), **frequenza** (cicli al secondo, in Hz) e **periodo** (la durata di un ciclo, 1/frequenza).

| | 2,4 GHz | 5 GHz | 6 GHz (Wi-Fi 6E) |
| :--- | :--- | :--- | :--- |
| Portata e attraversamento dei muri | la migliore | media | la peggiore |
| Interferenze | alte (Bluetooth, microonde) | basse | quasi nulle |
| Canali non sovrapposti | **1, 6, 11** | molti (fino a 24) | moltissimi |

Nella banda a 2,4 GHz i canali si sovrappongono: per AP vicini si usano solo **1, 6 e 11**.

Cosa indebolisce il segnale:

| Fenomeno | Cosa succede | Esempio |
| :--- | :--- | :--- |
| Absorption | il segnale attraversa un materiale e perde energia (diventa calore) | muri |
| Reflection | rimbalza (e crea percorsi multipli) | metallo |
| Refraction | cambia direzione attraversando un materiale | vetro, acqua |
| Diffraction | aggira un ostacolo, lasciando zone d'ombra dietro | colonne |
| Scattering | si disperde in più direzioni | superfici irregolari, polvere |

## 3. Standard 802.11

| Standard | Nome | Bande | Velocità massima teorica |
| :--- | :--- | :--- | :--- |
| 802.11a | — | 5 GHz | 54 Mbps |
| 802.11b | — | 2,4 GHz | 11 Mbps |
| 802.11g | — | 2,4 GHz | 54 Mbps |
| 802.11n | Wi-Fi 4 | 2,4 e 5 GHz | 600 Mbps |
| 802.11ac | Wi-Fi 5 | 5 GHz | ~6,9 Gbps |
| 802.11ax | Wi-Fi 6 / 6E | 2,4, 5 (e 6) GHz | ~9,6 Gbps |

## 4. Service set

- **SSID**: il **nome** della rete, quello che vede l'utente.
- **BSSID**: il **MAC** della radio dell'AP, che identifica un BSS.
- **BSS** (Basic Service Set): un AP e i suoi client. L'area coperta si chiama **BSA**.
- **ESS** (Extended Service Set): più AP con lo **stesso SSID** (e BSSID diversi) collegati alla rete cablata. Il client passa da un AP all'altro (**roaming**); le aree vanno sovrapposte del **10–15%**, con canali diversi.
- **IBSS** (ad hoc): client che parlano direttamente, senza AP.
- **MBSS** (mesh): AP collegati tra loro via radio; solo il root AP è cablato.

La rete cablata a cui l'AP si collega è il **DS** (Distribution System). Ogni SSID corrisponde a una VLAN, e ogni SSID su un AP ha un suo BSSID.

Altri modi in cui un AP autonomo può lavorare: **repeater** (ripete il segnale; con una sola radio dimezza la banda), **workgroup bridge** (collega via radio un dispositivo solo cablato), **outdoor bridge** (collega edifici lontani).

## 5. Frame e associazione

| Tipo di frame | A cosa serve | Esempi |
| :--- | :--- | :--- |
| Management | gestire il BSS | beacon, probe request/response, authentication, association |
| Control | regolare l'accesso al mezzo | ACK, RTS/CTS |
| Data | trasportare i dati | — |

Come un client si collega:

1. **Scopre l'AP**: in modo **passivo** ascoltando i **beacon** che l'AP manda periodicamente, oppure **attivo** inviando una **probe request** (e ricevendo una probe response).
2. **Authentication**.
3. **Association** (request e response).

Stati del client: non autenticato e non associato → autenticato ma non associato → autenticato e associato. Solo nell'ultimo può mandare dati.

Un frame 802.11 può avere fino a **4 indirizzi** (destinazione, sorgente, ricevitore, trasmettitore).

## 6. Architetture (in breve)

| Architettura | Come funziona |
| :--- | :--- |
| **Autonomous** | ogni AP si configura da solo; non scala |
| **Lightweight** | gli AP sono gestiti da un **WLC**, che ne riceve il traffico attraverso un tunnel **CAPWAP** (split-MAC) |
| **Cloud-based** (Meraki) | gestione da una dashboard cloud; i dati restano in locale |

- **Split-MAC**: l'AP fa le funzioni radio in tempo reale; il WLC fa gestione RF, sicurezza, QoS, autenticazione e roaming.
- **CAPWAP**: tunnel di **controllo UDP 5246** (cifrato) e tunnel **dati UDP 5247** (non cifrato di default). Anche il traffico tra due client sullo stesso AP passa dal WLC.

| WLC | Dove sta | AP gestiti (circa) |
| :--- | :--- | :--- |
| Unified | appliance dedicata | 6000 |
| Cloud-based | macchina virtuale | 3000 |
| Embedded | dentro uno switch | 200 |
| Mobility Express | dentro un AP | 100 |

## 7. Sicurezza (5.9)

Tre esigenze distinte:

- **autenticazione**: chi sei (idealmente in entrambe le direzioni, così il client non si collega a un AP falso);
- **cifratura**: chi può leggere;
- **integrità**: nessuno ha modificato il messaggio (con un **MIC**, Message Integrity Check).

### Autenticazione

- **Open**: nessuna credenziale. Si usa con un captive portal (Wi-Fi pubblici).
- **WEP**: chiave condivisa e RC4. **Rotto**, da non usare.
- **802.1X/EAP** (Enterprise). Tre ruoli:
  - **supplicant**: il client;
  - **authenticator**: l'AP o il WLC;
  - **authentication server**: un server **RADIUS**.

**EAP** è un contenitore di metodi:

| Metodo | Come funziona | Giudizio |
| :--- | :--- | :--- |
| LEAP | utente e password, chiavi WEP dinamiche | ❌ vulnerabile, obsoleto |
| EAP-FAST | tunnel TLS creato con una PAC (Protected Access Credential) | più sicuro di LEAP, poco diffuso |
| **PEAP** | certificato **solo sul server**; il client si autentica nel tunnel (es. con password) | ✅ il più comune |
| **EAP-TLS** | certificato **sul server e sul client**, nessuna password | ✅ il più sicuro, il più complesso |

### Cifratura e integrità

Linea temporale: **WEP → TKIP → CCMP → GCMP**.

| Protocollo | Usato in | Cifratura | Integrità | Stato |
| :--- | :--- | :--- | :--- | :--- |
| WEP | — | RC4 | — | 🔴 rotto |
| TKIP | WPA | RC4 migliorato | MIC | ⚠️ deprecato |
| CCMP | WPA2 | **AES** | CBC-MAC | ✅ standard attuale |
| GCMP | WPA3 | **AES** | GMAC | ✅ il migliore |

### WPA

WPA è una **certificazione** che combina autenticazione, cifratura e integrità. Ogni versione ha due modi:

- **Personal**: password condivisa (**PSK**);
- **Enterprise**: **802.1X/EAP**.

| Versione | Cifratura | Personal |
| :--- | :--- | :--- |
| WPA | TKIP | PSK |
| WPA2 | **CCMP** (AES) | PSK |
| WPA3 | **GCMP** (AES) | **SAE** |

Cosa aggiunge WPA3:

- **SAE** (Simultaneous Authentication of Equals): protegge la fase di accesso con password; chi intercetta lo scambio non può provare password a tappeto.
- **PMF** (Protected Management Frames): i frame di gestione sono protetti, ed è obbligatorio.
- **Forward secrecy**: anche se in futuro la password viene scoperta, il traffico registrato prima non si può decifrare.

## 8. Configurazione dalla GUI del WLC (2.9 e 5.10)

### Porte e interfacce

- **Porte**: fisiche, dove si attaccano i cavi. Più porte si uniscono in un **LAG** (solo statico).
- **Interfacce**: logiche, come le SVI di uno switch.
  - **Management**: GUI, SSH, CAPWAP verso gli AP.
  - **Dynamic**: collega una WLAN a una **VLAN** (una per ogni VLAN dei client).
  - **Virtual**: usata per funzioni verso i client, come web authentication e DHCP relay.

### Creare una WLAN WPA2-PSK

1. **Controller → Interfaces → New**: crea la **dynamic interface** (nome, VLAN ID, IP, maschera, gateway, server DHCP).
2. **WLANs → Create New**: tipo WLAN, **profile name** (nome interno), **SSID** (nome trasmesso), **ID**.
3. Scheda **General**: stato **Enabled** e interfaccia = la dynamic interface creata.
4. Scheda **Security → Layer 2**: **WPA+WPA2**, cifratura **AES**, gestione chiavi **PSK**, password (ASCII, almeno **8 caratteri**).
5. Scheda **QoS**: il profilo (vedi sotto).
6. **Apply**.

| Scheda della WLAN | Cosa si imposta |
| :--- | :--- |
| General | profile name, SSID, stato (Enabled), interfaccia/VLAN, broadcast dell'SSID |
| Security | Layer 2 (WPA2/WPA3, PSK o 802.1X), Layer 3 (web auth), server AAA |
| QoS | profilo Platinum / Gold / Silver / Bronze |
| Advanced | opzioni come timeout di sessione, FlexConnect local switching |

| Profilo QoS | Traffico |
| :--- | :--- |
| 💎 Platinum | voce |
| 🥇 Gold | video |
| 🥈 Silver | best effort (**default**) |
| 🥉 Bronze | background |

La configurazione iniziale del WLC (nome, utente, IP di management, VLAN) si fa con un wizard dalla console; poi si entra nella GUI via browser sull'IP di management. Le **CPU ACL** del WLC filtrano solo il traffico diretto **al** WLC, non quello che lo attraversa.

## ⚠️ Trappole d'esame

> [!WARNING] Gli errori più frequenti
> 1. **SSID e BSSID**: il primo è un nome, il secondo il MAC della radio.
> 2. **Canali a 2,4 GHz**: solo 1, 6, 11 non si sovrappongono.
> 3. **Versioni e cifratura**: WPA = TKIP, WPA2 = CCMP, WPA3 = GCMP (entrambi i secondi con AES).
> 4. **PEAP ed EAP-TLS**: certificato solo sul server, oppure su server e client.
> 5. **Ruoli 802.1X**: l'authenticator è l'AP/WLC, non il server RADIUS.
> 6. **WLAN senza Enabled**: creata ma non trasmessa.
> 7. **QoS di default**: Silver.
> 8. **CAPWAP**: il controllo (5246) è cifrato, i dati (5247) no.

## Esercizi

> [!QUESTION]- Tre AP vicini a 2,4 GHz: quali canali assegni?
> 1, 6 e 11, uno per AP.

> [!QUESTION]- Un ufficio ha 4 AP con lo stesso SSID "AZIENDA". Quanti SSID, BSSID e BSS ci sono, e come si chiama l'insieme?
> 1 SSID, 4 BSSID, 4 BSS: insieme formano un ESS.

> [!QUESTION]- Un'azienda vuole autenticare i dipendenti con il certificato sul portatile, senza password. Che metodo EAP usa?
> EAP-TLS: certificato su client e server.

> [!QUESTION]- Che cifratura usa una WLAN WPA2-Personal, e con quale algoritmo?
> CCMP con AES, password condivisa (PSK).

> [!QUESTION]- Nella GUI, la WLAN "GUEST" deve finire nella VLAN 200. Cosa serve?
> Una dynamic interface con VLAN 200, selezionata nella scheda General della WLAN.

## Check da esame

- [ ] Canali non sovrapposti a 2,4 GHz? **1, 6, 11**.
- [ ] Porte CAPWAP? **UDP 5246 controllo, 5247 dati**.
- [ ] Chi fa da authenticator in 802.1X? **L'AP o il WLC**.
- [ ] Differenza tra WPA2 e WPA3? **CCMP contro GCMP, e SAE al posto della PSK classica**.
- [ ] Come scopre un AP un client in modo passivo? **Ascoltando i beacon**.
- [ ] Lunghezza minima di una PSK? **8 caratteri**.
- [ ] Profili QoS del WLC? **Platinum, Gold, Silver (default), Bronze**.
- [ ] A cosa serve una dynamic interface? **A collegare una WLAN a una VLAN**.

## 🎯 Synthesis

Il Wi-Fi è un mezzo condiviso e half duplex (CSMA/CA): a 2,4 GHz si usano i canali 1, 6, 11. Un ESS è fatto di più BSS con lo stesso SSID. La sicurezza va da WEP (rotto) a WPA3: WPA2 usa CCMP/AES, WPA3 GCMP e SAE; in Enterprise c'è 802.1X con un server RADIUS. Sul WLC una WLAN si lega a una VLAN con una dynamic interface.

> [!EXAMPLE] Laboratori pratici
> - [[Day 58 Lab - Wireless LANs.pkt]]
