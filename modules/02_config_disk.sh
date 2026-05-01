#!/usr/bin/env bash

# =========================================
# 📦 Funktion: Globaler Header / Info
# -----------------------------------------
# Zweck: Laufwerkskonfiguration & Profil (02_config_disk.sh)
# Aufgabe: Ziellaufwerk wählen, LUKS konfigurieren, Bestätigung
# =========================================

# =========================================
# 📦 Funktion: select_disk
# -----------------------------------------
# Zweck: Sichere Laufwerksauswahl
# Aufgabe: Erkennt reale Zielgeräte, filtert das Live-System heraus
# =========================================
select_disk() {
    local choice entry dev root_source root_parent
    local i=1

    phase_header "Ziellaufwerk"

    # Live-Medium ermitteln, um es auszublenden
    root_source="$(findmnt -n -o SOURCE / 2>/dev/null || true)"
    if [[ -n "$root_source" && -b "$root_source" ]]; then
        root_parent="$(lsblk -no PKNAME "$root_source" 2>/dev/null | head -n1 || true)"
        [[ -n "$root_parent" ]] && root_parent="/dev/${root_parent}"
    fi

    # Lade alle Disks (ohne Loop-Devices = -e7)
    mapfile -t DISKS < <(
        lsblk -dn -e7 -o NAME,SIZE,TYPE,MODEL | awk '
        $3=="disk" {
            model=$4
            for (j=5; j<=NF; j++) model=model" "$j
            print "/dev/"$1" | "$2" | "model
        }'
    )

    if [[ ${#DISKS[@]} -eq 0 ]]; then
        error "Keine geeigneten Laufwerke gefunden."
        exit 1
    fi

    FILTERED_DISKS=()
    for entry in "${DISKS[@]}"; do
        dev="${entry%% | *}"
        if [[ -n "$root_parent" && "$dev" == "$root_parent" ]]; then
            warn "Überspringe Live-Laufwerk: $dev"
            continue
        fi
        FILTERED_DISKS+=("$entry")
    done

    if [[ ${#FILTERED_DISKS[@]} -eq 0 ]]; then
        error "Keine Ziel-Laufwerke nach Filterung übrig."
        exit 1
    fi

    for entry in "${FILTERED_DISKS[@]}"; do
        print_option "$i" "$entry"
        ((i++))
    done

    while true; do
        read -rp "$(echo -e "${BLUE}[INPUT]${NC} Ziellaufwerk wählen [1-${#FILTERED_DISKS[@]}]: ")" choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#FILTERED_DISKS[@]} )); then
            entry="${FILTERED_DISKS[$((choice-1))]}"
            DISK="${entry%% | *}"
            
            [[ -b "$DISK" ]] || { error "Gerät existiert nicht: $DISK"; exit 1; }
            log "Gewählt: $DISK"
            break
        fi
        warn "Ungültige Auswahl."
    done
}

# =========================================
# 📦 Funktion: select_install_profile
# -----------------------------------------
# Zweck: Installationsprofil bestimmen
# Aufgabe: Auswahl zwischen unverschlüsselt und LUKS2
# =========================================
select_install_profile() {
    local choice

    phase_header "Disk-Setup / Verschlüsselung"

    print_option 1 "Standard | EFI + BTRFS"
    print_option 2 "LUKS     | EFI + LUKS2 + BTRFS"

    while true; do
        read -rp "$(echo -e "${BLUE}[INPUT]${NC} Auswahl [1-2]: ")" choice
        case "$choice" in
            1)
                INSTALL_PROFILE="standard"
                USE_LUKS="no"
                break ;;
            2)
                INSTALL_PROFILE="luks"
                USE_LUKS="yes"
                break ;;
            *) warn "Ungültige Auswahl." ;;
        esac
    done
}

# =========================================
# 📦 Funktion: ask_luks_password
# -----------------------------------------
# Zweck: LUKS-Passwort erfassen
# Aufgabe: Abfrage nur, wenn LUKS aktiviert wurde
# =========================================
ask_luks_password() {
    if [[ "$USE_LUKS" != "yes" ]]; then
        LUKS_PASSWORD=""
        return 0
    fi

    while true; do
        read -rsp "$(echo -e "${BLUE}[INPUT]${NC} LUKS-Passwort (Verschlüsselung): ")" LUKS_PASSWORD
        echo
        read -rsp "$(echo -e "${BLUE}[INPUT]${NC} LUKS-Passwort wiederholen: ")" LUKS_PASSWORD_CONFIRM
        echo

        if [[ -n "$LUKS_PASSWORD" && "$LUKS_PASSWORD" == "$LUKS_PASSWORD_CONFIRM" ]]; then
            break
        fi
        error "LUKS-Passwörter stimmen nicht überein oder sind leer."
    done
}

# =========================================
# 📦 Funktion: confirm_config
# -----------------------------------------
# Zweck: Finale Installationsübersicht
# Aufgabe: Letzte Sperre vor destruktiven Aktionen
# =========================================
confirm_config() {
    if [[ "${AUTO_MODE:-false}" == true ]]; then
        warn "[AUTO-MODE] Bestätigung wird übersprungen."
        return 0
    fi

    clear
    header "Zusammenfassung (Point of no Return)"

    echo -e "${CYAN}System:${NC}      ${USERNAME}@${HOSTNAME}"
    echo -e "${CYAN}Keyboard:${NC}    $KEYMAP"
    echo -e "${CYAN}Timezone:${NC}    $TIMEZONE"
    echo -e "${CYAN}Locales:${NC}     ${EXPORTED_LOCALES:-en_US.UTF-8}"
    echo
    echo -e "${CYAN}Disk:${NC}        $DISK"
    echo -e "${CYAN}Profil:${NC}      $INSTALL_PROFILE (LUKS: $USE_LUKS)"
    echo
    echo -e "${CYAN}Sicherheit:${NC}  Root gesperrt: $DISABLE_ROOT"
    echo -e "${CYAN}Zusätze:${NC}     Shell-UX: $INSTALL_SHELL | AUR: $INSTALL_AUR | SSH: $INSTALL_SSH"
    echo

    if [[ "${DRY_RUN:-true}" == true ]]; then
        warn "DRY-RUN AKTIV: Es werden keine Daten gelöscht oder geschrieben."
        echo
    else
        warn "ACHTUNG: Alle Daten auf $DISK werden unwiderruflich GELÖSCHT!"
        echo
    fi

    if [[ "$(ask_yes_no "Installation jetzt starten?")" != "yes" ]]; then
        error "Installation durch Benutzer abgebrochen."
        exit 0
    fi
}

# =========================================
# 📦 Funktion: export_config_disk
# -----------------------------------------
# Zweck: Disk-Konfiguration exportieren
# Aufgabe: Parameter für Laufwerksmodule bereitstellen
# =========================================
export_config_disk() {
    export DISK INSTALL_PROFILE USE_LUKS LUKS_PASSWORD
}

# =========================================
# 📦 Funktion: run_config_disk
# -----------------------------------------
# Zweck: Einstiegspunkt des Moduls
# Aufgabe: Sequenzielle Abfrage und Bestätigung
# =========================================
run_config_disk() {
    if [[ "$AUTO_MODE" == true ]]; then
        DISK="${DISK:-/dev/sda}"
        INSTALL_PROFILE="standard"
        USE_LUKS="no"
        LUKS_PASSWORD=""
    else
        select_disk
        select_install_profile
        ask_luks_password
    fi
    
    export_config_disk
    confirm_config
}
