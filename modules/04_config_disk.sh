#!/usr/bin/env bash

# =========================================
# 📄 DATEI: 04_config_disk.sh
# 💡 ZWECK: Laufwerksauswahl & Verschlüsselung
# =========================================

export AUTO_MODE="${AUTO_MODE:-false}"
declare -a DISK_ARRAY=()

# =========================================
# 📦 Funktion: get_available_disks
# -----------------------------------------
# Zweck: Ermittelt installierbare Laufwerke
# =========================================
get_available_disks() {
    # Filtert loop, rom und das Live-Medium (oft iso9660) heraus
    mapfile -t DISK_ARRAY < <(lsblk -d -n -p -o NAME,TYPE | awk '$2=="disk" {print $1}')
    
    # Erweitert: Filtere den aktuellen Live-USB-Stick heraus
    local live_disk
    live_disk=$(findmnt -n -o SOURCE /run/archiso/bootmnt 2>/dev/null | grep -o '^/dev/[a-z]*')
    
    local filtered_disks=()
    for d in "${DISK_ARRAY[@]}"; do
        if [[ "$d" != "$live_disk" ]]; then
            filtered_disks+=("$d")
        fi
    done
    DISK_ARRAY=("${filtered_disks[@]}")
}

# =========================================
# 📦 Funktion: select_disk
# -----------------------------------------
# Zweck: Benutzer wählt das Ziellaufwerk
# =========================================
select_disk() {
    phase_header "$STR_PHASE_DISK_SEL"

    get_available_disks

    if [[ ${#DISK_ARRAY[@]} -eq 0 ]]; then
        error "$STR_ERR_NO_DISK"
        exit 1
    fi

    log "$STR_LOG_FOUND_DISKS"
    local i=1
    for d in "${DISK_ARRAY[@]}"; do
        local size
        size=$(lsblk -d -n -o SIZE "$d" 2>/dev/null)
        local model
        model=$(lsblk -d -n -o MODEL "$d" 2>/dev/null)
        echo -e "  ${CYAN}$i)${NC} $d ($size) - $model"
        ((i++))
    done

    local choice
    while true; do
        read -rp "$(echo -e "${STR_INPUT_PREFIX} $STR_PROMPT_SELECT_NUM")" choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#DISK_ARRAY[@]} )); then
            DISK="${DISK_ARRAY[$((choice-1))]}"
            return 0
        elif [[ "$choice" == "0" ]]; then
            log "$STR_LOG_USER_ABORT"
            exit 0
        else
            warn "$STR_WARN_INVALID_SEL"
        fi
    done
}

# =========================================
# 📦 Funktion: select_install_profile
# -----------------------------------------
# Zweck: Auswahl zwischen Standard und LUKS
# =========================================
select_install_profile() {
    phase_header "$STR_PHASE_PROFIL_SEL"

    print_option 1 "$STR_OPT_PROF_STD"
    print_option 2 "$STR_OPT_PROF_LUKS"

    local choice
    while true; do
        read -rp "$(echo -e "${STR_INPUT_PREFIX} $STR_PROMPT_SEL_1_2")" choice
        case "$choice" in
            1) USE_LUKS="no"; break ;;
            2) USE_LUKS="yes"; break ;;
            *) warn "$STR_WARN_INVALID_SEL" ;;
        esac
    done

    if [[ "$USE_LUKS" == "yes" ]]; then
        while true; do
            read -rsp "$(echo -e "${STR_INPUT_PREFIX} $STR_PROMPT_LUKS_PASS")" LUKS_PASSWORD
            echo
            read -rsp "$(echo -e "${STR_INPUT_PREFIX} $STR_PROMPT_PASS_CONFIRM")" LUKS_PASSWORD_CONFIRM
            echo

            if [[ -n "$LUKS_PASSWORD" && "$LUKS_PASSWORD" == "$LUKS_PASSWORD_CONFIRM" ]]; then
                break
            fi
            error "$STR_ERR_PASS_MISMATCH"
        done
    fi
}

# =========================================
# 📦 Funktion: show_summary
# -----------------------------------------
# Zweck: Zusammenfassung und Bestätigung
# =========================================
show_summary() {
    header "$STR_SUMMARY_HEADER"
    
    echo -e "  ${CYAN}${STR_LBL_HOST}${NC}     $HOSTNAME"
    echo -e "  ${CYAN}${STR_LBL_USER}${NC}     $USERNAME"
    echo -e "  ${CYAN}${STR_LBL_KEY}${NC}     $KEYMAP"
    echo -e "  ${CYAN}${STR_LBL_TZ}${NC}     $TIMEZONE"
    echo -e "  ${CYAN}${STR_LBL_LANG}${NC}      $LANG_DEFAULT"
    echo -e "  ${CYAN}${STR_LBL_DISK}${NC}     $DISK"
    echo -e "  ${CYAN}${STR_LBL_LUKS}${NC}         $USE_LUKS"
    echo
    
    # printf formatiert die Variable %s aus der Sprachdatei sauber mit dem Laufwerksnamen
    local warn_msg
    printf -v warn_msg "$STR_WARN_DELETE" "$DISK"
    echo -e "${RED}${BOLD}${warn_msg}${NC}"
    echo

    local answer
    answer="$(ask_yes_no "$STR_ASK_START_INSTALL")"
    if [[ "$answer" != "yes" ]]; then
        log "$STR_LOG_USER_ABORT"
        exit 0
    fi
}

# =========================================
# 📦 Funktion: run_config_disk
# -----------------------------------------
# Zweck: Einstiegspunkt Modul 04
# =========================================
run_config_disk() {
    if [[ "$AUTO_MODE" == true ]]; then
        DISK="/dev/sda"
        USE_LUKS="yes"
        LUKS_PASSWORD="password"
        return 0
    fi

    header "$STR_DISK_HEADER"
    select_disk
    select_install_profile
    show_summary
}