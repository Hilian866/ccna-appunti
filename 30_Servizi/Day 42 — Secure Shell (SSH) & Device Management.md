

> [!ABSTRACT]
> Questa nota analizza i metodi di accesso alla **CLI** dei dispositivi Cisco, confrontando la gestione via porta console e l'accesso remoto. Il focus principale è la migrazione dal protocollo insicuro **Telnet** allo standard crittografato **SSHv2**.

### Console Port Security
L'accesso fisico tramite porta console è aperto per default. Per proteggerlo, è necessario configurare la `line console 0`.

*   **Login Semplice**: Richiede solo una password.
*   **Login Locale**: Utilizza un database di utenti locale (`username/password`), offrendo maggiore granularità.
*   **Timestamp**: [01:57](https://youtu.be/AvgYqI2qSD4&t=117s)

```ios
R1(config)# username jeremy secret ccnp
R1(config)# line console 0
R1(config-line)# login local
R1(config-line)# exec-timeout 3 30  ! Disconnessione automatica dopo 3m 30s
```

### Management IP su Switch Layer 2
Sebbene gli switch L2 non effettuino routing IP, necessitano di un indirizzo per la gestione remota tramite **SVI** (Switch Virtual Interface).

> [!INFO] SVI & Default Gateway
> Per permettere a uno switch di rispondere a connessioni provenienti da reti diverse dalla propria, è indispensabile configurare il **Default Gateway**.
> Timestamp: [05:15](https://youtu.be/AvgYqI2qSD4&t=315s)

```ios
SW1(config)# interface vlan 1
SW1(config-if)# ip address 192.168.1.253 255.255.255.0
SW1(config-if)# no shutdown
SW1(config)# ip default-gateway 192.168.1.254
```

### Telnet vs SSH: Tabella Comparativa
La differenza fondamentale risiede nella sicurezza del trasporto dati nel **Control Plane**.

| Caratteristica | Telnet | SSH |
| :--- | :--- | :--- |
| Porta TCP | 23 | 22 |
| Sicurezza | In chiaro (Plain Text) | Crittografato |
| Rischio | Sniffing (Wireshark) | Protetto da intercettazione |
| Standard Attuale | Deprecato | Standard di settore (**SSHv2**) |
| Timestamp | [07:19](https://youtu.be/AvgYqI2qSD4&t=439s) | [13:10](https://youtu.be/AvgYqI2qSD4&t=790s) |

> [!CAUTION] Pericolo Telnet
> Utilizzando Telnet, qualsiasi utente malevolo in grado di catturare il traffico può leggere username e password in chiaro. **Non usare mai Telnet in reti di produzione.**

### Configurazione SSH (Secure Shell)
Per abilitare SSH su un dispositivo Cisco, è necessario seguire una sequenza logica precisa per generare le chiavi crittografiche.

#### 1. Prerequisiti: FQDN
Il dispositivo deve avere un **Hostname** non di default e un **Domain Name**. La combinazione dei due forma il FQDN (Fully Qualified Domain Name), usato per nominare le chiavi RSA.
Timestamp: [16:36](https://youtu.be/AvgYqI2qSD4&t=996s)

```ios
SW1(config)# hostname R1
R1(config)# ip domain name jeremysitlab.com
```

#### 2. Generazione Chiavi RSA
> [!INFO] SSH Versione 2
> Per abilitare SSHv2, la lunghezza della chiave RSA deve essere di almeno **768 bit** (raccomandato 1024 o 2048).

```ios
R1(config)# crypto key generate rsa
! Scegliere la lunghezza (es. 2048)
R1(config)# ip ssh version 2
```

#### 3. Configurazione Linee VTY
Le linee **VTY** gestiscono le connessioni virtuali (Remote Access).

```ios
R1(config)# line vty 0 15
R1(config-line)# login local
R1(config-line)# transport input ssh  ! Disabilita Telnet, permette solo SSH
```

### Verifica e Connessione
Comandi per verificare lo stato del servizio e connettersi da un altro dispositivo.

*   **Verifica**: `show ip ssh` (mostra versione e timeout) o `show ssh` (connessioni attive).
*   **Connessione da PC/Router**:
    *   Formato 1: `ssh -l <username> <ip-address>`
    *   Formato 2: `ssh <username>@<ip-address>`

> [!ABSTRACT] Workflow SSH Riassunto
> 1. Hostname 2. Domain-name 3. Generazione Chiavi RSA 4. Username/Password locali 5. `transport input ssh` sulle VTY. 
> Timestamp riassuntivo: [19:05](https://youtu.be/AvgYqI2qSD4&t=1145s)