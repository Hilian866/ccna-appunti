### 1. Il Protocollo e la Porta DNS

Il DNS è un protocollo "ibrido" che usa quasi sempre **UDP** sulla porta 53 per le query standard, ma può usare anche **TCP** (sempre porta 53) per il trasferimento di zone o risposte molto grandi.

Per bloccare il DNS dalla LAN verso un server specifico, la sintassi è questa:

Bash

```
R1(config-ext-nacl)# deny udp 172.16.2.0 0.0.0.255 host 192.168.1.100 eq 53
R1(config-ext-nacl)# deny tcp 172.16.2.0 0.0.0.255 host 192.168.1.100 eq 53
```


deny udp [LAN] [SERVER] eq 53