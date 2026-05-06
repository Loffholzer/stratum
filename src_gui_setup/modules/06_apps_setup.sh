#!/usr/bin/env bash

# =========================================
# 📄 DATEI: 06_apps_setup.sh
# 💡 ZWECK: Installation optionaler Zusatzanwendungen
# =========================================

# =========================================
# 📦 Funktion: install_libreoffice
# -----------------------------------------
# Zweck: Installiert LibreOffice inkl. passendem Sprachpaket
# Aufgabe: Liest die Locale, validiert das Sprachpaket und nutzt pacman
# =========================================
install_libreoffice() {
    echo -e "\n${STR_GUI_LOG_APPS_LO}"
    
    local sys_lang
    local lang_code
    local target_pkgs=("${LIBREOFFICE_PKGS[@]}")

    # Lokale auslesen
    if [[ -f /etc/locale.conf ]]; then
        sys_lang=$(source /etc/locale.conf 2>/dev/null && echo "$LANG")
    else
        sys_lang="${LANG:-de_DE.UTF-8}"
    fi

    lang_code="${sys_lang%%_*}"
    if [[ -n "$lang_code" ]]; then
        local lo_lang_pkg="libreoffice-still-${lang_code}"
        if pacman -Sp "$lo_lang_pkg" >/dev/null 2>&1; then
            echo -e "  -> ${STR_GUI_LOG_LANG_PKG_FOUND}: ${lo_lang_pkg}"
            target_pkgs+=("$lo_lang_pkg")
        fi
    fi

    pacman -S --needed --noconfirm "${target_pkgs[@]}" || true
}