#!/usr/bin/env bash

# =========================================
# 📄 DATEI: 03_config_sys.sh
# 💡 ZWECK: Systemkonfiguration erfassen
# =========================================

export AUTO_MODE="${AUTO_MODE:-false}"
export CONSOLE_FONT="${CONSOLE_FONT:-ter-v32n}"
declare -a LOCALES=()

# =========================================
# 📦 Funktion: ask_yes_no
# -----------------------------------------
# Zweck: Standardisierte Ja/Nein Abfrage
# =========================================
ask_yes_no() {
    local prompt="$1"
    local answer

    while true; do
        # Hier greift nun die saubere Sprach-Variable für "(j/n)"
        read -rp "$(echo -e "${STR_INPUT_PREFIX} $prompt ${STR_PROMPT_YN}: ")" answer
        answer="${answer,,}"

        # Die Fallunterscheidung selbst bleibt mehrsprachig, 
        # da sie reine Logik ist und für den User unsichtbar arbeitet.
        case "$answer" in
            j|ja|y|yes) echo "yes"; return 0 ;;
            n|nein|no)  echo "no"; return 0 ;;
            *)          warn "$STR_WARN_YES_NO" >&2 ;;
        esac
    done
}

# =========================================
# 📦 Funktion: check_root
# -----------------------------------------
# Zweck: Root-Rechte prüfen
# =========================================
check_root() {
    if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
        error "$STR_ERR_ROOT_REQ"
        exit 1
    fi
}

# =========================================
# 📦 Funktion: check_uefi
# -----------------------------------------
# Zweck: UEFI-Umgebung verifizieren
# =========================================
check_uefi() {
    if [[ ! -d /sys/firmware/efi ]]; then
        error "$STR_ERR_UEFI_REQ"
        exit 1
    fi
}

# =========================================
# 📦 Funktion: bestimme_microcode_paket
# -----------------------------------------
# Zweck: CPU-Microcode ermitteln
# =========================================
bestimme_microcode_paket() {
    local cpu_vendor
    cpu_vendor=$(grep -m1 'vendor_id' /proc/cpuinfo | awk '{print $3}')

    case "$cpu_vendor" in
        GenuineIntel) MICROCODE_PKG="intel-ucode"; log "$STR_LOG_INTEL_CPU" ;;
        AuthenticAMD) MICROCODE_PKG="amd-ucode"; log "$STR_LOG_AMD_CPU" ;;
        *)            MICROCODE_PKG=""; warn "$STR_WARN_UNKNOWN_CPU" ;;
    esac
}

# =========================================
# 📦 Funktion: select_keyboard
# -----------------------------------------
# Zweck: Tastaturlayout wählen
# =========================================
select_keyboard() {
    local choice detected search selected

    [[ "${LANG:-}" =~ de ]] && detected="de"
    [[ "${LANG:-}" =~ en ]] && detected="us"

    phase_header "$STR_PHASE_KEYMAP"

    print_option 1 "${detected:-de} $STR_OPT_AUTO"
    print_option 2 "$STR_OPT_US_STD"
    print_option 3 "$STR_OPT_MANUAL_SEARCH"

    while true; do
        read -rp "$(echo -e "${STR_INPUT_PREFIX} ${STR_PROMPT_SEL_1_3}")" choice
        case "$choice" in
            1) KEYMAP="${detected:-de}"; break ;;
            2) KEYMAP="us"; break ;;
            3)
                while true; do
                    read -rp "$(echo -e "${STR_INPUT_PREFIX} $STR_PROMPT_SEARCH_KEYMAP")" search
                    mapfile -t KEYMAP_RESULTS < <(localectl list-keymaps | grep -i "$search" | sort -u)
                    
                    if [[ ${#KEYMAP_RESULTS[@]} -eq 0 ]]; then
                        warn "$STR_WARN_NO_HITS"
                        continue
                    fi
                    if (( ${#KEYMAP_RESULTS[@]} > 40 )); then
                        warn "$STR_WARN_TOO_MANY_HITS"
                        continue
                    fi

                    print_search_results "$STR_TITLE_KEYMAP_HITS" "$search" KEYMAP_RESULTS
                    read -rp "$(echo -e "${STR_INPUT_PREFIX} $STR_PROMPT_SELECT_NUM")" selected
                    if [[ "$selected" =~ ^[0-9]+$ ]] && (( selected >= 1 && selected <= ${#KEYMAP_RESULTS[@]} )); then
                        KEYMAP="${KEYMAP_RESULTS[$((selected-1))]}"
                        choice="done"
                        break 2
                    fi
                done
                ;;
            *) warn "$STR_WARN_INVALID_SEL" ;;
        esac
    done

    if [[ "${DRY_RUN:-true}" != true ]]; then
        loadkeys "$KEYMAP" 2>/dev/null || warn "$STR_WARN_KEYMAP_LIVE_FAIL"
    fi
}

# =========================================
# 📦 Funktion: select_timezone
# -----------------------------------------
# Zweck: Zeitzone ermitteln
# =========================================
select_timezone() {
    local tz choice search
    
    phase_header "$STR_PHASE_TIMEZONE"
    
    if command -v curl >/dev/null 2>&1; then
        tz="$(curl -fs --max-time 3 https://ipapi.co/timezone 2>/dev/null || true)"
    fi

    if [[ -n "$tz" && -f "/usr/share/zoneinfo/$tz" ]]; then
        log "${STR_LOG_RECOGNIZED}$tz"
        print_option 1 "$STR_OPT_USE_RECOGNIZED_TZ"
        print_option 2 "$STR_OPT_MANUAL_SEARCH"
        
        while true; do
            read -rp "$(echo -e "${STR_INPUT_PREFIX} ${STR_PROMPT_SEL_1_2}")" choice
            case "$choice" in
                1) TIMEZONE="$tz"; return 0 ;;
                2) break ;;
                *) warn "$STR_WARN_INVALID_SEL" ;;
            esac
        done
    else
        log "$STR_LOG_TZ_AUTO_FAIL"
    fi

    while true; do
        read -rp "$(echo -e "${STR_INPUT_PREFIX} $STR_PROMPT_SEARCH_TZ")" search
        [[ -z "$search" ]] && continue
        
        mapfile -t TZ_RESULTS < <(timedatectl list-timezones | grep -i "$search" | sort)
        
        if [[ ${#TZ_RESULTS[@]} -eq 0 ]]; then
            warn "$STR_WARN_NO_HITS"
            continue
        elif (( ${#TZ_RESULTS[@]} > 20 )); then
            warn "$STR_WARN_TOO_MANY_HITS"
            continue
        fi

        print_search_results "$STR_TITLE_TZ_HITS" "$search" TZ_RESULTS
        read -rp "$(echo -e "${STR_INPUT_PREFIX} $STR_PROMPT_SELECT_NUM")" choice
        
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
# =========================================
select_locale() {
    local detected choice search selected
    
    phase_header "$STR_PHASE_LOCALE"
    log "$STR_LOG_LOCALE_HINT"
    
    [[ "${LANG:-}" =~ de ]] && detected="de_DE.UTF-8"

    print_option 1 "${detected:-de_DE.UTF-8}${STR_OPT_PLUS_EN_US}"
    print_option 2 "$STR_OPT_ONLY_EN_US"
    print_option 3 "$STR_OPT_MANUAL_SEARCH"

    while true; do
        read -rp "$(echo -e "${STR_INPUT_PREFIX} ${STR_PROMPT_SEL_1_3}")" choice
        case "$choice" in
            1)
                LOCALES=("${detected:-de_DE.UTF-8}" "en_US.UTF-8")
                LANG_DEFAULT="${detected:-de_DE.UTF-8}"
                return 0 ;;
            2)
                LOCALES=("en_US.UTF-8")
                LANG_DEFAULT="en_US.UTF-8"
                return 0 ;;
            3)
                while true; do
                    read -rp "$(echo -e "${STR_INPUT_PREFIX} $STR_PROMPT_SEARCH_LOCALE")" search
                    [[ -z "$search" ]] && continue
                    
                    # Liest unterstützte Locales aus der Systemdatei (strikt gefiltert auf UTF-8)
                    mapfile -t LOCALE_RESULTS < <(grep -i "$search" /usr/share/i18n/SUPPORTED | grep -i "UTF-8" | awk '{print $1}' | sort -u)
                    
                    if [[ ${#LOCALE_RESULTS[@]} -eq 0 ]]; then
                        warn "$STR_WARN_NO_HITS"
                        continue
                    elif (( ${#LOCALE_RESULTS[@]} > 40 )); then
                        warn "$STR_WARN_TOO_MANY_HITS"
                        continue
                    fi

                    print_search_results "$STR_TITLE_LOCALE_HITS" "$search" LOCALE_RESULTS
                    read -rp "$(echo -e "${STR_INPUT_PREFIX} $STR_PROMPT_SELECT_NUM")" selected
                    
                    if [[ "$selected" =~ ^[0-9]+$ ]] && (( selected >= 1 && selected <= ${#LOCALE_RESULTS[@]} )); then
                        local chosen_locale="${LOCALE_RESULTS[$((selected-1))]}"
                        LOCALES=("$chosen_locale" "en_US.UTF-8")
                        LANG_DEFAULT="$chosen_locale"
                        return 0
                    fi
                done
                ;;
            *) warn "$STR_WARN_INVALID_SEL" ;;
        esac
    done
}

# =========================================
# 📦 Funktion: validate_hostname_value
# -----------------------------------------
# Zweck: Hostname prüfen
# =========================================
validate_hostname_value() {
    [[ "$1" =~ ^[a-z0-9]([a-z0-9-]*[a-z0-9])?$ ]]
}

# =========================================
# 📦 Funktion: validate_username_value
# -----------------------------------------
# Zweck: Username prüfen
# =========================================
validate_username_value() {
    [[ "$1" =~ ^[a-z_][a-z0-9_-]*$ ]]
}

# =========================================
# 📦 Funktion: ask_user_password
# -----------------------------------------
# Zweck: Benutzerpasswort erfassen
# =========================================
ask_user_password() {
    while true; do
        read -rsp "$(echo -e "${STR_INPUT_PREFIX} $STR_PROMPT_PASS_USER")" USER_PASSWORD
        echo
        read -rsp "$(echo -e "${STR_INPUT_PREFIX} $STR_PROMPT_PASS_CONFIRM")" USER_PASSWORD_CONFIRM
        echo

        if [[ -n "$USER_PASSWORD" && "$USER_PASSWORD" == "$USER_PASSWORD_CONFIRM" ]]; then
            break
        fi
        error "$STR_ERR_PASS_MISMATCH"
    done
}

# =========================================
# 📦 Funktion: collect_sys_config
# -----------------------------------------
# Zweck: Sammelt alle System-Eingaben
# =========================================
collect_sys_config() {
    header "$STR_SYS_HEADER"
    
    check_root
    check_uefi
    bestimme_microcode_paket

    if [[ "$AUTO_MODE" == true ]]; then
        if [[ "${DRY_RUN:-true}" != true ]]; then
            error "$STR_ERR_AUTO_DRY_RUN"
            exit 1
        fi
        log "$STR_LOG_AUTO_ACTIVE"
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

    phase_header "$STR_PHASE_IDENTITY"

    while true; do
        read -rp "$(echo -e "${STR_INPUT_PREFIX} $STR_PROMPT_HOSTNAME")" HOSTNAME
        validate_hostname_value "$HOSTNAME" && break
        warn "$STR_WARN_HOSTNAME_RULES"
    done

    while true; do
        read -rp "$(echo -e "${STR_INPUT_PREFIX} $STR_PROMPT_USERNAME")" USERNAME
        validate_username_value "$USERNAME" && break
        warn "$STR_WARN_USERNAME_RULES"
    done

    ask_user_password

    echo
    DISABLE_ROOT="$(ask_yes_no "$STR_ASK_ROOT_LOCK")"
    ENABLE_MULTILIB="$(ask_yes_no "$STR_ASK_MULTILIB")"
    INSTALL_SHELL="$(ask_yes_no "$STR_ASK_SHELL_UX")"
    INSTALL_TOOLS="$(ask_yes_no "$STR_ASK_TOOLS")"
    INSTALL_AUR="$(ask_yes_no "$STR_ASK_AUR")"
    INSTALL_EDITOR="$(ask_yes_no "$STR_ASK_EDITOR")"
    INSTALL_SSH="$(ask_yes_no "$STR_ASK_SSH")"
}

# =========================================
# 📦 Funktion: export_sys_config
# -----------------------------------------
# Zweck: System-Variablen exportieren
# =========================================
export_sys_config() {
    export KEYMAP TIMEZONE LANG_DEFAULT HOSTNAME USERNAME USER_PASSWORD
    export DISABLE_ROOT ENABLE_MULTILIB MICROCODE_PKG
    export INSTALL_SHELL INSTALL_TOOLS INSTALL_AUR INSTALL_EDITOR INSTALL_SSH
    export EXPORTED_LOCALES="${LOCALES[*]}"
}

# =========================================
# 📦 Funktion: run_config_sys
# -----------------------------------------
# Zweck: Einstiegspunkt des Moduls
# =========================================
run_config_sys() {
    collect_sys_config
    export_sys_config
}
