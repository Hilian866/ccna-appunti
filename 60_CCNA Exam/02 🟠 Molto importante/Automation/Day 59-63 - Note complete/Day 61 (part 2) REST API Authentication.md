---
tags: [ccna, exam, automation]
priorita: molto-importante
stato: da-ripassare
---

> [!ABSTRACT] Core Logic
> L'autenticazione nelle **REST API** è il processo di validazione dell'identità di un utente o sistema per garantire l'accesso legittimo alle risorse. Oltre alla sicurezza, è fondamentale per l'**analytics** e il **billing** (es. tracciamento dei token in ChatGPT). [01:42](https://youtu.be/bmqr_xpt6sc&t=102s).

---

## 🏗️ Fondamenti dell'Autenticazione API
Senza autenticazione, chiunque potrebbe inviare **API requests**, accedendo a dati sensibili o modificando l'applicazione. [02:16](https://youtu.be/bmqr_xpt6sc&t=136s).

> [!INFO] Tracking e Billing
> Molte API utilizzano l'autenticazione per scopi commerciali, addebitando costi in base all'utilizzo (es. modelli **OpenAI** basati su token). [03:08](https://youtu.be/bmqr_xpt6sc&t=188s).

---

## 🔐 Metodi di Autenticazione (Authentication Schemes)

### 1. Basic Authentication
È il metodo più semplice. Invia credenziali direttamente nell'**HTTP Header**. [05:41](https://youtu.be/bmqr_xpt6sc&t=341s).
- **Formato**: `username:password`.
- **Codifica**: Le credenziali sono codificate in **Base64**. [07:33](https://youtu.be/bmqr_xpt6sc&t=453s).

> [!WARNING] Rischio Sicurezza
> La codifica **Base64** NON è cifratura. È facilmente decodificabile. È imperativo utilizzare **HTTPS (TLS)** per proteggere il traffico. [07:53](https://youtu.be/bmqr_xpt6sc&t=473s).

### 2. Bearer Authentication
Utilizza un **Token** (chiamato Bearer Token) invece delle credenziali classiche. [10:04](https://youtu.be/bmqr_xpt6sc&t=604s).
- **Processo**: Il client ottiene il token da un **Authorization Server**. [10:11](https://youtu.be/bmqr_xpt6sc&t=611s).
- **Scadenza**: I token solitamente scadono dopo un tempo prefissato per limitare i danni in caso di furto. [11:46](https://youtu.be/bmqr_xpt6sc&t=706s).

### 3. API Key Authentication
Utilizza una chiave statica univoca assegnata al client. [13:13](https://youtu.be/bmqr_xpt6sc&t=793s).
- **Posizionamento**: Può essere inviata nell'header, nell'URL o nei cookie.
- **Limitazioni**: Le chiavi inserite negli URL sono meno sicure perché loggate da web server e browser. [13:48](https://youtu.be/bmqr_xpt6sc&t=828s).

### 4. OAuth 2.0
Un framework avanzato per l'**Access Delegation**. Permette ad app terze di accedere a risorse limitate per conto dell'utente senza condividerne la password. [16:11](https://youtu.be/bmqr_xpt6sc&t=971s).

**I 4 Attori di OAuth 2.0:** [17:44](https://youtu.be/bmqr_xpt6sc&t=1064s)
1. **Resource Owner**: L'utente (tu).
2. **Client App**: L'applicazione che richiede l'accesso (es. un'app di calendario).
3. **Auth Server**: Il server che emette il token (es. Google Auth).
4. **Resource Server**: Il server che ospita i dati (es. Google Calendar).

---

## 📊 Confronto Metodi di Autenticazione

| Metodo | Meccanismo | Sicurezza | Uso Comune |
| :--- | :--- | :--- | :--- |
| **Basic** | Username/Password in **Base64** | Bassa (richiede TLS) | Ambienti legacy/semplici |
| **Bearer** | Token generato da server | Alta | Web App moderne |
| **API Key** | Stringa univoca statica | Media | Cloud Services / Tracking |
| **OAuth 2.0** | Framework di delega (Token) | Massima | Integrazioni terze parti |

---

## ⚡ Concetti Avanzati OAuth 2.0

> [!INFO] Token Refresh
> Per evitare che l'utente debba rieseguire il login ogni volta che un **Access Token** scade, OAuth 2.0 utilizza i **Refresh Tokens** per ottenere nuove chiavi automaticamente. [20:13](https://youtu.be/bmqr_xpt6sc&t=1213s).

### Flusso Operativo OAuth 2.0
1. Il Client richiede autorizzazione.
2. Il Resource Owner concede il permesso.
3. Il Client scambia il permesso con un **Access Token**.
4. Il Client usa il Token per richiedere la risorsa. [18:32](https://youtu.be/bmqr_xpt6sc&t=1112s).

---

*Nota generata per lo studio della certificazione CCNA basata sul materiale di Jeremy's IT Lab.*
