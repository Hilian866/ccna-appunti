#!/bin/sh
# Costanti e funzioni condivise dagli hook pre-commit e pre-push.
#
# Responsabilità: definire cosa è "personale o segreto" e dove leggere l'email personale.
# Non si occupa di: bloccare commit o push (lo fanno pre-commit e pre-push).
# Dipendenze: git, grep.
#
# Attivazione (una volta per clone):
#   git config core.hooksPath .githooks
#   git config hook.personalEmail "tua-email@esempio.it"
# PERCHÉ: l'email personale sta in .git/config e non in questo file, che viene pubblicato.

# Percorsi che non devono mai entrare nel repository (espressione regolare estesa, per grep -E).
FORBIDDEN_PATH_REGEX='^note personali/|^\.obsidian/|^\.claude/|^CLAUDE\.md$|\.(apkg|colpkg|pta)$|(^|/)[^/]*\.local\.[^/]*$|(^|/)\.env$|200-301-CCNA[^/]*\.pdf$'

# Lista dei percorsi consentiti: tutto il resto è bloccato finché non lo aggiungi qui di proposito.
# PERCHÉ: il repository è pubblico, quindi un file in un posto nuovo deve essere una scelta consapevole.
ALLOWED_PATH_REGEX='^(00_Inbox|10_Fondamenti|20_Routing_Switching|30_Servizi|40_Sicurezza|50_Wireless_Wan|60_CCNA Exam|Labs|allegati|Tools|\.githooks)/|^(_Index_CCNA\.md|\.gitignore)$'

# Note segnate come private nel frontmatter: tag "personale" o "privato", "draft: true", "publish: false".
PRIVATE_MARKER_REGEX='^(tags:.*(personale|privato|private)|draft:[[:space:]]*true|publish:[[:space:]]*false)'

# Segreti riconoscibili dal formato: token GitHub, chiavi private, chiavi AWS.
SECRET_REGEX='gh[pousr]_[A-Za-z0-9]{36,}|github_pat_[A-Za-z0-9_]{20,}|-----BEGIN [A-Z ]*PRIVATE KEY-----|AKIA[0-9A-Z]{16}'

# Hash nullo: git lo usa quando un riferimento non esiste (ramo nuovo o ramo cancellato).
ZERO_SHA=0000000000000000000000000000000000000000

# Stampa l'email personale configurata in locale (vuota se non configurata).
personal_email() {
    git config --get hook.personalEmail || true
}

# Stampa le parole vietate configurate in locale, una per riga (nome, datori di lavoro, città...).
# Si aggiungono con: git config --add hook.privateWord "parola"
# PERCHÉ: stanno in .git/config e non in questo file, che viene pubblicato.
private_words() {
    git config --get-all hook.privateWord || true
}

# Interrompe con un messaggio se l'email personale non è configurata.
# PERCHÉ: senza email il controllo non può funzionare, e fallire in silenzio sarebbe peggio.
require_personal_email() {
    if [ -z "$(personal_email)" ]; then
        echo "hook: email personale non configurata, controllo impossibile." >&2
        echo "      Esegui: git config hook.personalEmail \"tua-email@esempio.it\"" >&2
        exit 1
    fi
}
