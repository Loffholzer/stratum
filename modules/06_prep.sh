#!/usr/bin/env bash

# =========================================
# 📄 DATEI: 06_prep.sh
# 💡 ZWECK: Live-System Vorbereitung (Pacman, Reflector)
# =========================================

# =========================================
# 📦 Funktion: prep_live_env
# -----------------------------------------
# Zweck: Zeit und Paketmanager optimieren
# =========================================
prep_live_env() {
    if [[ "${DRY_RUN:-true}" == true ]]; then
        warn "$STR_WARN_DRY_PREP"
        return 0
    fi

    log "$STR_LOG_TIME_SYNC"
    timedatectl set-ntp true

    log "$STR_LOG_PACMAN_OPT"
    sed -i 's/^#Para/Para/' /etc/pacman.conf
    sed -i 's/^#Color/Color\nILoveCandy/' /etc/pacman.conf

    log "$STR_LOG_REFLECTOR"
    reflector --country Germany --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist >/dev/null 2>&1 || true
    
    # Pacman Keys aktualisieren (Sicherheitshalber, still)
    pacman -Sy archlinux-keyring --noconfirm >/dev/null 2>&1 || true
}

# =========================================
# 📦 Funktion: run_prep
# -----------------------------------------
# Zweck: Einstiegspunkt Modul 06
# =========================================
run_prep() {
    header "$STR_PREP_HEADER"
    prep_live_env
}