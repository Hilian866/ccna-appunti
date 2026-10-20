
---


### Core Concept

Il DHCP automatizza l'assegnazione dei parametri IP. Senza di esso, ogni host richiederebbe una configurazione manuale (**Static IP**), aumentando drasticamente il rischio di errori umani e conflitti.

- **Target:** Principalmente End-device (PC, telefoni, tablet).
    
- **Statici:** Router, Switch e Server richiedono IP fissi per garantire la raggiungibilità costante.
    

---

### I 4 Pilastri (Processo DORA)

Il client e il server comunicano attraverso quattro fasi sequenziali:

1. **Discover (D):** Il client invia un **Broadcast** (`255.255.255.255`) per cercare un server.
    
2. **Offer (O):** Il server risponde (Uni/Broadcast) offrendo un indirizzo IP disponibile.
    
3. **Request (R):** Il client invia un **Broadcast** per confermare l'accettazione di _quella_ offerta specifica.
    
4. **Acknowledgment (A):** Il server conferma la transazione e il client configura l'interfaccia.
    

> [!IMPORTANT]
> 
> **Nota Esame:** La **Request** è un Broadcast perché serve anche ad avvisare eventuali altri server DHCP in ascolto che la loro offerta non è stata scelta, permettendo loro di liberare l'IP proposto.

---

### DHCP Relay: Il ruolo del Router

I router **non inoltrano i broadcast**. Se il client e il server sono in subnet diverse, il processo DORA si interrompe al primo router.

- **Soluzione:** Il comando `ip helper-address [IP_SERVER]`.
    
- **Funzionamento:** Il router trasforma il broadcast in un pacchetto **Unicast** e lo inoltra al server.
    
- **Selezione del Pool:** Il server capisce da quale pool pescare l'IP leggendo l'indirizzo dell'interfaccia del router che ha inoltrato la richiesta (campo _Giaddr_).
    
- **Posizionamento:** Va configurato sull'interfaccia del router **vicina ai client** (es. la SVI della VLAN).
    

---

### Configurazione Cisco IOS

**1. Esclusioni (Fondamentale)**

Vanno configurate **prima** del pool per evitare che il server assegni IP già usati da gateway o server.

Bash

```
ip dhcp excluded-address 192.168.1.1 192.168.1.10
```

**2. Creazione del Pool**

Bash

```
ip dhcp pool NOME_POOL
  network 192.168.1.0 255.255.255.0
  default-router 192.168.1.1      # Il Gateway
  dns-server 8.8.8.8              # Il DNS
  domain-name lab.com
  lease 0 8 0                     # Giorni Ore Minuti
```

---

### Verifica e Troubleshooting

- **`show ip dhcp binding`**: La tabella più importante. Mostra quali IP sono stati assegnati e a quale MAC address.
    
- **`show ip dhcp pool`**: Mostra lo stato di utilizzo degli indirizzi.
    
- **`show ip dhcp conflict`**: Elenca gli IP che il server ha cercato di assegnare ma che erano già occupati.
    

---

### Common Mistakes

- **Lease infinite:** In reti guest (come la tua VLAN 200), usare lease troppo lunghe esaurisce gli IP disponibili.
    
- **Helper address mancante:** Causa numero 1 del fallimento del DHCP in reti multi-VLAN.
    
- **Porte UDP:** Ricorda sempre **67 (Server)** e **68 (Client)**.
    

---

