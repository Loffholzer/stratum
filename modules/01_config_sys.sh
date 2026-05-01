#!/usr/bin/env bash

# =========================================
# 📦 Funktion: Globaler Header / Info
# -----------------------------------------
# Zweck: Systemkonfiguration erfassen (01_config_sys.sh)
# Aufgabe: Pre-Flight Checks, Basis-Setup (Locales, User, Pakete)
# =========================================

export AUTO_MODE="${AUTO_MODE:-false}"
export CONSOLE_FONT="${CONSOLE_FONT:-ter-v32n}"
declare -a LOCALES=()

# =========================================
# 📦 Funktion: ask_yes_no
# -----------------------------------------
# Zweck: Standardisierte Ja/Nein Abfrage
# Aufgabe: Normalisiert Antworten auf 'yes' oder 'no'
# =========================================
ask_yes_no() {
    local prompt="$1"
    local answer

    while true; do
        read -rp "$(echo -e "${BLUE}[INPUT]${NC} $prompt (j/n): ")" answer
        answer="${answer,,}"

        case "$answer" in
            j|ja|y|yes) echo "yes"; return 0 ;;
            n|nein|no)  echo "no"; return 0 ;;
            *)          warn "Bitte mit j/n antworten." >&2 ;;
        esac
    done
}

# =========================================
# 📦 Funktion: check_root
# -----------------------------------------
# Zweck: Root-Rechte prüfen
# Aufgabe: Bricht ab, wenn Script nicht als Root läuft
# =========================================
check_root() {
    if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
        error "Ausführung als Root erforderlich."
        exit 1
    fi
}

# =========================================
# 📦 Funktion: check_uefi
# -----------------------------------------
# Zweck: UEFI-Umgebung verifizieren
# Aufgabe: Verhindert Installation auf Legacy-BIOS Systemen
# =========================================
check_uefi() {
    if [[ ! -d /sys/firmware/efi ]]; then
        error "UEFI-Umgebung zwingend erforderlich."
        exit 1
    fi
}

# =========================================
# 📦 Funktion: bestimme_microcode_paket
# -----------------------------------------
# Zweck: CPU-Microcode ermitteln
# Aufgabe: Wählt intel-ucode oder amd-ucode automatisch
# =========================================
bestimme_microcode_paket() {
    local cpu_vendor
    cpu_vendor=$(grep -m1 'vendor_id' /proc/cpuinfo | awk '{print $3}')

    case "$cpu_vendor" in
        GenuineIntel) MICROCODE_PKG="intel-ucode"; log "Intel CPU erkannt." ;;
        AuthenticAMD) MICROCODE_PKG="amd-ucode"; log "AMD CPU erkannt." ;;
        *)            MICROCODE_PKG=""; warn "Unbekannte CPU. Kein Microcode." ;;
    esac
}

# =========================================
# 📦 Funktion: select_keyboard
# -----------------------------------------
# Zweck: Tastaturlayout wählen
# Aufgabe: Setzt Layout für Live-System und Zielsystem
# =========================================
select_keyboard() {
    local choice detected search selected

    [[ "${LANG:-}" =~ de ]] && detected="de"
    [[ "${LANG:-}" =~ en ]] && detected="us"

    phase_header "Tastaturlayout"

    print_option 1 "${detected:-de} (Automatisch)"
    print_option 2 "us (Standard)"
    print_option 3 "Manuell suchen"

    while true; do
        read -rp "$(echo -e "${BLUE}[INPUT]${NC} Auswahl [1-3]: ")" choice
        case "$choice" in
            1) KEYMAP="${detected:-de}"; break ;;
            2) KEYMAP="us"; break ;;
            3)
                while true; do
                    read -rp "$(echo -e "${BLUE}[INPUT]${NC} Suche (z.B. de, fr): ")" search
                    mapfile -t KEYMAP_RESULTS < <(localectl list-keymaps | grep -i "$search" | sort -u)
                    
                    if [[ ${#KEYMAP_RESULTS[@]} -eq 0 ]]; then
                        warn "Keine Treffer."
                        continue
                    fi
                    if (( ${#KEYMAP_RESULTS[@]} > 40 )); then
                        warn "Zu viele Treffer. Bitte verfeinern."
                        continue
                    fi

                    print_search_results "Keymap Treffer" "$search" KEYMAP_RESULTS
                    read -rp "$(echo -e "${BLUE}[INPUT]${NC} Nummer wählen (0 für neue Suche): ")" selected
                    if [[ "$selected" =~ ^[0-9]+$ ]] && (( selected >= 1 && selected <= ${#KEYMAP_RESULTS[@]} )); then
                        KEYMAP="${KEYMAP_RESULTS[$((selected-1))]}"
                        choice="done"
                        break 2
                    fi
                done
                ;;
            *) warn "Ungültige Auswahl." ;;
        esac
    done

    if [[ "${DRY_RUN:-true}" != true ]]; then
        loadkeys "$KEYMAP" 2>/dev/null || warn "Konnte Layout im Live-System nicht setzen."
    fi
}

# =========================================
# 📦 Funktion: select_timezone
# -----------------------------------------
# Zweck: Zeitzone ermitteln
# Aufgabe: Auto-Erkennung per IP oder manuelle Suche
# =========================================
select_timezone() {
    local tz choice search
    
    phase_header "Zeitzone"
    
    # Auto-Erkennung
    if command -v curl >/dev/null 2>&1; then
        tz="$(curl -fs --max-time 3 https://ipapi.co/timezone 2>/dev/null || true)"
    fi

    if [[ -n "$tz" && -f "/usr/share/zoneinfo/$tz" ]]; then
        log "Erkannt: $tz"
        print_option 1 "Erkannte Zeitzone nutzen"
        print_option 2 "Manuell suchen"
        
        while true; do
            read -rp "$(echo -e "${BLUE}[INPUT]${NC} Auswahl [1-2]: ")" choice
            case "$choice" in
                1) TIMEZONE="$tz"; return 0 ;;
                2) break ;;
                *) warn "Ungültige Auswahl." ;;
            esac
        done
    fi

    # Manuelle Suche
    while true; do
        read -rp "$(echo -e "${BLUE}[INPUT]${NC} Suche (z.B. berlin, tokyo): ")" search
        [[ -z "$search" ]] && continue
        
        mapfile -t TZ_RESULTS < <(timedatectl list-timezones | grep -i "$search" | sort)
        
        if [[ ${#TZ_RESULTS[@]} -eq 0 ]]; then
            warn "Keine Treffer."
            continue
        elif (( ${#TZ_RESULTS[@]} > 20 )); then
            warn "Zu viele Treffer. Bitte verfeinern."
            continue
        fi

        print_search_results "Zeitzonen Treffer" "$search" TZ_RESULTS
        read -rp "$(echo -e "${BLUE}[INPUT]${NC} Auswahl (0 für Abbruch): ")" choice
        
        if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#TZ_RESULTS[@]} )); then
            TIMEZONE="${TZ_RESULTS[$((choice-1))]}"
            return 0
        fi
    done
}

# =========================================
# 📦 Funktion: select_locale
# -----------------------------------------
# Zweck: Systemsprache wählen
# Aufgabe: Setzt LANG_DEFAULT und LOCALES Array
# =========================================
select_locale() {
    local detected choice
    
    phase_header "Systemsprache (Locale)"
    log "Hinweis: en_US.UTF-8 wird immer generiert."
    
    [[ "${LANG:-}" =~ de ]] && detected="de_DE.UTF-8"

    print_option 1 "${detected:-de_DE.UTF-8} + en_US.UTF-8"
    print_option 2 "Nur en_US.UTF-8"

    while true; do
        read -rp "$(echo -e "${BLUE}[INPUT]${NC} Auswahl [1-2]: ")" choice
        case "$choice" in
            1)
                LOCALES=("${detected:-de_DE.UTF-8}" "en_US.UTF-8")
                LANG_DEFAULT="${detected:-de_DE.UTF-8}"
                return 0 ;;
            2)
                LOCALES=("en_US.UTF-8")
                LANG_DEFAULT="en_US.UTF-8"
                return 0 ;;
            *) warn "Ungültige Auswahl." ;;
        esac
    done
}

# =========================================
# 📦 Funktion: validate_hostname_value
# -----------------------------------------
# Zweck: Hostname prüfen
# Aufgabe: Regex-Prüfung für sichere DNS-Namen
# =========================================
validate_hostname_value() {
    [[ "$1" =~ ^[a-z0-9]([a-z0-9-]*[a-z0-9])?$ ]]
}

# =========================================
# 📦 Funktion: validate_username_value
# -----------------------------------------
# Zweck: Username prüfen
# Aufgabe: Regex-Prüfung für Linux-Usernamen
# =========================================
validate_username_value() {
    [[ "$1" =~ ^[a-z_][a-z0-9_-]*$ ]]
}

# =========================================
# 📦 Funktion: ask_user_password
# -----------------------------------------
# Zweck: Benutzerpasswort erfassen
# Aufgabe: Sichert die Eingabe mit Wiederholung ab
# =========================================
ask_user_password() {
    while true; do
        read -rsp "$(echo -e "${BLUE}[INPUT]${NC} User-Passwort: ")" USER_PASSWORD
        echo
        read -rsp "$(echo -e "${BLUE}[INPUT]${NC} Passwort wiederholen: ")" USER_PASSWORD_CONFIRM
        echo

        if [[ -n "$USER_PASSWORD" && "$USER_PASSWORD" == "$USER_PASSWORD_CONFIRM" ]]; then
            break
        fi
        error "Passwörter stimmen nicht überein oder sind leer."
    done
}

# =========================================
# 📦 Funktion: collect_sys_config
# -----------------------------------------
# Zweck: Sammelt alle System-Eingaben
# Aufgabe: Führt interaktiven Leitfaden aus
# =========================================
collect_sys_config() {
    header "System-Konfiguration"
    
    check_root
    check_uefi
    bestimme_microcode_paket

    if [[ "$AUTO_MODE" == true ]]; then
        if [[ "${DRY_RUN:-true}" != true ]]; then
            error "AUTO_MODE darf nicht mit DRY_RUN=false laufen!"
            exit 1
        fi
        log "AUTO-MODE aktiv. Überspringe Eingaben."
        HOSTNAME="archtest"
        USERNAME="user"
        USER_PASSWORD="password"
        KEYMAP="de"
        TIMEZONE="Europe/Berlin"
        LOCALES=("en_US.UTF-8")
        LANG_DEFAULT="en_US.UTF-8"
        DISABLE_ROOT="yes"
        ENABLE_MULTILIB="yes"
        INSTALL_SHELL="yes"
        INSTALL_TOOLS="yes"
        INSTALL_AUR="yes"
        INSTALL_EDITOR="yes"
        INSTALL_SSH="yes"
        return 0
    fi

    select_keyboard
    select_timezone
    select_locale

    phase_header "Identität & Module"

    while true; do
        read -rp "$(echo -e "${BLUE}[INPUT]${NC} Hostname (z.B. arch-pc): ")" HOSTNAME
        validate_hostname_value "$HOSTNAME" && break
        warn "Erlaubt: a-z, 0-9, Bindestrich."
    done

    while true; do
        read -rp "$(echo -e "${BLUE}[INPUT]${NC} Username (z.B. max): ")" USERNAME
        validate_username_value "$USERNAME" && break
        warn "Erlaubt: a-z, 0-9, Unterstrich. Beginnend mit Buchstabe."
    done

    ask_user_password

    echo
    DISABLE_ROOT="$(ask_yes_no "Root-Login sperren? (Sicherer, Sudo wird genutzt)")"
    ENABLE_MULTILIB="$(ask_yes_no "Multilib (32-Bit) aktivieren?")"
    INSTALL_SHELL="$(ask_yes_no "UX-Stack (Fish, Starship, Zoxide) installieren?")"
    INSTALL_TOOLS="$(ask_yes_no "CLI-Tools (eza, bat, btop) installieren?")"
    INSTALL_AUR="$(ask_yes_no "AUR-Helper (Paru) installieren?")"
    INSTALL_EDITOR="$(ask_yes_no "Nano Virtuoso-Config anwenden?")"
    INSTALL_SSH="$(ask_yes_no "OpenSSH installieren und aktivieren?")"
}

# =========================================
# 📦 Funktion: export_sys_config
# -----------------------------------------
# Zweck: System-Variablen exportieren
# Aufgabe: Stellt Variablen für nachfolgende Module bereit
# =========================================
export_sys_config() {
    export KEYMAP TIMEZONE LANG_DEFAULT HOSTNAME USERNAME USER_PASSWORD
    export DISABLE_ROOT ENABLE_MULTILIB MICROCODE_PKG
    export INSTALL_SHELL INSTALL_TOOLS INSTALL_AUR INSTALL_EDITOR INSTALL_SSH
    
    # Locales Array serialisieren, falls in Subshells benötigt
    export EXPORTED_LOCALES="${LOCALES[*]}"
}

# =========================================
# 📦 Funktion: run_config_sys
# -----------------------------------------
# Zweck: Einstiegspunkt des Moduls
# Aufgabe: Führt Sammlung und Export durch
# =========================================
run_config_sys() {
    collect_sys_config
    export_sys_config
}
