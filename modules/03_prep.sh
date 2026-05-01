#!/usr/bin/env bash

# =========================================
# 📦 Funktion: Globaler Header / Info
# -----------------------------------------
# Zweck: Vorbereitung der Live-Umgebung (03_prep.sh)
# Aufgabe: Systemzeit synchronisieren, Pacman optimieren, Mirrors updaten
# =========================================

# =========================================
# 📦 Funktion: prep_time
# -----------------------------------------
# Zweck: Systemzeit via NTP abgleichen
# Aufgabe: Verhindert SSL/TLS Zertifikatsfehler bei Downloads
# =========================================
prep_time() {
    phase_header "Systemzeit synchronisieren"

    if [[ "${DRY_RUN:-true}" == true ]]; then
        warn "[DRY-RUN] Systemzeit-Synchronisation (NTP) übersprungen."
        return 0
    fi

    log "Aktiviere systemd-timesyncd..."
    timedatectl set-ntp true

    # Kurzer Wait, um Sync zu erlauben
    sleep 2

    if timedatectl status | grep -q "System clock synchronized: yes"; then
        success "Zeit erfolgreich synchronisiert."
    else
        warn "Zeit-Sync nicht sofort bestätigt. Setze trotzdem fort."
    fi
}

# =========================================
# 📦 Funktion: prep_pacman
# -----------------------------------------
# Zweck: Download-Geschwindigkeit maximieren
# Aufgabe: Aktiviert Color, ILoveCandy und ParallelDownloads im Live-System
# =========================================
prep_pacman() {
    phase_header "Pacman konfigurieren (Live-System)"
    local conf="/etc/pacman.conf"

    if [[ "${DRY_RUN:-true}" == true ]]; then
        warn "[DRY-RUN] Pacman-Optimierung in $conf übersprungen."
        return 0
    fi

    log "Optimiere $conf (Color, ParallelDownloads, ILoveCandy)..."

    # Color aktivieren
    sed -i 's/^#Color/Color/' "$conf"

    # ILoveCandy (Pac-Man Animation) hinzufügen, falls nicht vorhanden
    if ! grep -q "^ILoveCandy" "$conf"; then
        sed -i '/^Color/a ILoveCandy' "$conf"
    fi

    # Parallele Downloads auf 10 setzen
    sed -i 's/^#ParallelDownloads.*/ParallelDownloads = 10/' "$conf"
    if ! grep -q "^ParallelDownloads" "$conf"; then
        sed -i '/^#Misc options/a ParallelDownloads = 10' "$conf"
    fi

    success "Pacman erfolgreich optimiert."
}

# =========================================
# 📦 Funktion: prep_mirrors
# -----------------------------------------
# Zweck: Schnellste Download-Server finden
# Aufgabe: Nutzt Reflector für HTTPS und Rate-Sorting
# =========================================
prep_mirrors() {
    phase_header "Mirrorlist aktualisieren (Reflector)"

    if [[ "${DRY_RUN:-true}" == true ]]; then
        warn "[DRY-RUN] Reflector-Lauf übersprungen."
        return 0
    fi

    log "Prüfe auf Reflector..."
    if ! command -v reflector >/dev/null 2>&1; then
        warn "Reflector fehlt. Installiere temporär..."
        pacman -Sy --noconfirm reflector || {
            warn "Konnte Reflector nicht installieren. Nutze Standard-Mirrors."
            return 1
        }
    fi

    log "Suche die 15 schnellsten HTTPS-Mirrors..."

    # Ableitung des Landes aus der Zeitzone für besseres Geo-Targeting
    local country=""
    [[ "$TIMEZONE" == *"Berlin"* ]] && country="Germany"
    [[ "$TIMEZONE" == *"Vienna"* ]] && country="Austria"
    [[ "$TIMEZONE" == *"Zurich"* ]] && country="Switzerland"

    local reflector_cmd=(reflector --protocol https --latest 20 --sort rate --save /etc/pacman.d/mirrorlist)

    if [[ -n "$country" ]]; then
        log "Optimiere primär für Region: $country"
        reflector_cmd=(reflector --country "$country" --protocol https --latest 20 --sort rate --save /etc/pacman.d/mirrorlist)
    fi

    if "${reflector_cmd[@]}"; then
        success "Mirrorlist erfolgreich generiert."
    else
        warn "Reflector fehlerhaft. Falle auf alte Mirrorlist zurück."
    fi

    log "Aktualisiere Paketdatenbankbanken..."
    pacman -Syy || warn "Initiales pacman -Syy schlug fehl (Mirror-Problem?)."
}

# =========================================
# 📦 Funktion: run_prep
# -----------------------------------------
# Zweck: Sequenzielle Ausführung des Moduls
# Aufgabe: Führt Zeit-, Pacman- und Mirror-Setup durch
# =========================================
run_prep() {
    header "Phase 3: Live-System Vorbereitung"

    prep_time
    prep_pacman
    prep_mirrors

    success "Live-Umgebung ist bereit."
}
