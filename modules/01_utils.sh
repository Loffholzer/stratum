#!/usr/bin/env bash

# =========================================
# 📦 Funktion: Globaler Header / Info
# -----------------------------------------
# Zweck: Globale Hilfsfunktionen und UI (01_utils.sh)
# Aufgabe: Farben, Logging und UI-Elemente bereitstellen
# =========================================

# =========================================
# 📦 Funktion: setup_colors
# -----------------------------------------
# Zweck: Konsistente Konsolenausgabe
# Aufgabe: Exportiert ANSI-Farbcodes für alle Module
# =========================================
setup_colors() {
    export RED='\033[1;31m'
    export GREEN='\033[1;32m'
    export YELLOW='\033[1;33m'
    export BLUE='\033[1;34m'
    export MAGENTA='\033[1;35m'
    export CYAN='\033[1;36m'
    export BOLD='\033[1m'
    export NC='\033[0m'

    # UI Prefixes für konsistentes Logging
    export STR_INPUT_PREFIX="${MAGENTA}[INPUT]${NC}"
    export STR_INFO_PREFIX="${MAGENTA}[INFO]${NC}"
    export STR_OK_PREFIX="${GREEN}[OK]${NC}"
    export STR_WARN_PREFIX="${YELLOW}[WARN]${NC}"
    export STR_ERR_PREFIX="${RED}[ERROR]${NC}"
}

# =========================================
# 📦 Funktion: header
# -----------------------------------------
# Zweck: Visuelle Trennung von Hauptphasen
# Aufgabe: Gibt eine formatierte Box aus
# =========================================
header() {
    local text="$1"
    echo -e "\n${MAGENTA}=========================================${NC}"
    echo -e "${BOLD}${CYAN} 🚀 ${text}${NC}"
    echo -e "${MAGENTA}=========================================${NC}\n"
}

# =========================================
# 📦 Funktion: phase_header
# -----------------------------------------
# Zweck: Visuelle Trennung von Sub-Schritten
# Aufgabe: Gibt einen leichten Header aus
# =========================================
phase_header() {
    local text="$1"
    echo -e "\n${BOLD}${MAGENTA}--- ${text} ---${NC}\n"
}

# =========================================
# 📦 Funktion: log
# -----------------------------------------
# Zweck: Standard-Informationsausgabe
# Aufgabe: Prefix [INFO] in Blau mit Text
# =========================================
log() {
    echo -e "${STR_INFO_PREFIX} $1"
}

# =========================================
# 📦 Funktion: success
# -----------------------------------------
# Zweck: Bestätigung erfolgreicher Aktionen
# Aufgabe: Prefix [OK] in Grün mit Text
# =========================================
success() {
    echo -e "${STR_OK_PREFIX} $1"
}

# =========================================
# 📦 Funktion: warn
# -----------------------------------------
# Zweck: Warnungen (nicht-kritische Fehler)
# Aufgabe: Prefix [WARN] in Gelb mit Text auf STDERR
# =========================================
warn() {
    ((WARN_COUNT++))
    echo -e "${STR_WARN_PREFIX} $1" >&2
}

# =========================================
# 📦 Funktion: error
# -----------------------------------------
# Zweck: Kritische Fehler anzeigen
# Aufgabe: Prefix [ERROR] in Rot mit Text auf STDERR
# =========================================
error() {
    ((ERR_COUNT++))
    echo -e "${STR_ERR_PREFIX} $1" >&2
}

# =========================================
# 📦 Funktion: run_cmd
# -----------------------------------------
# Zweck: Führt Befehle stumm aus, zeigt Fehler aber ROT an
# Aufgabe: Verhindert, dass echte Fehlermeldungen übersehen werden
# =========================================
run_cmd() {
    local err_out
    local exit_code
    
    # Fange Fehlerausgabe (stderr) ein, werfe Standardausgabe (stdout) weg
    err_out=$("$@" 2>&1 >/dev/null)
    exit_code=$?
    
    # Wenn der Befehl gemeckert hat, zeige es farbig an!
    if [[ -n "$err_out" ]]; then
        if [[ $exit_code -ne 0 ]]; then
            ((ERR_COUNT++))
            echo -e "${STR_ERR_PREFIX} ${err_out}" >&2
        else
            ((WARN_COUNT++))
            echo -e "${STR_WARN_PREFIX} ${err_out}" >&2
        fi
    fi
    return $exit_code
}

# =========================================
# 📦 Funktion: verify_packages
# -----------------------------------------
# Zweck: Prüft Paketverfügbarkeit vor der Installation
# Aufgabe: Simuliert Download (-Sp) und bricht bei Fehlern ab (Base-Installer)
# =========================================
verify_packages() {
    local target_chroot=""
    
    # Prüfen, ob wir im Zielsystem (chroot) oder auf dem Live-Medium prüfen
    if [[ "$1" == "--chroot" ]]; then
        target_chroot="$2"
        shift 2
    fi
    
    local pkgs=("$@")
    [[ ${#pkgs[@]} -eq 0 ]] && return 0
    
    log "${STR_LOG_VERIFY_PKGS:-Verifiziere Paketverfügbarkeit...}"
    
    local missing
    if [[ -n "$target_chroot" ]]; then
        if ! missing=$(arch-chroot "$target_chroot" pacman -Sp --noconfirm "${pkgs[@]}" 2>&1 >/dev/null); then
            error "${STR_ERR_MISSING_PKGS:-Fehlende Pakete:}\n${missing}"
            exit 1
        fi
    else
        if ! missing=$(pacman -Sp --noconfirm "${pkgs[@]}" 2>&1 >/dev/null); then
            error "${STR_ERR_MISSING_PKGS:-Fehlende Pakete:}\n${missing}"
            exit 1
        fi
    fi
}

# =========================================
# 📦 Funktion: print_option
# -----------------------------------------
# Zweck: Darstellung von Auswahlmöglichkeiten
# Aufgabe: Formatiert Nummer und Beschreibung
# =========================================
print_option() {
    local num="$1"
    local desc="$2"
    echo -e "  ${CYAN}[${num}]${NC} ${desc}"
}

# =========================================
# 📦 Funktion: print_search_results
# -----------------------------------------
# Zweck: Ausgabe von Array-Suchergebnissen in Spalten
# Aufgabe: Dynamische Spaltenberechnung (spaltenweise sortiert)
# =========================================
print_search_results() {
    local title="$1"
    local search="$2"
    local -n arr_ref="$3"
    local total="${#arr_ref[@]}"

    phase_header "${title} (Suche: ${search})"

    if (( total == 0 )); then
        return 0
    fi

    # Längsten Eintrag ermitteln
    local max_len=0
    for item in "${arr_ref[@]}"; do
        (( ${#item} > max_len )) && max_len=${#item}
    done

    # Spaltenbreite: Max. Länge + Platz für "[XX] " (ca. 8 Zeichen) + 2 Puffer
    local col_width=$((max_len + 10))
    local term_width=$(tput cols 2>/dev/null || echo 80)
    local cols=$(( term_width / col_width ))
    
    # Fallback, falls das Terminal extrem schmal ist
    (( cols < 1 )) && cols=1

    # Benötigte Zeilen berechnen (aufgerundet)
    local rows=$(( (total + cols - 1) / cols ))

    # Zeilenweise iterieren, aber Indizes spaltenweise (Column-Major) berechnen
    for (( r=0; r<rows; r++ )); do
        local line=""
        for (( c=0; c<cols; c++ )); do
            local idx=$(( c * rows + r ))
            
            # Prüfen, ob der errechnete Index noch im Array liegt
            if (( idx < total )); then
                local num=$((idx + 1))
                local val="${arr_ref[$idx]}"
                
                # Farb-Codes verwirren die Längenberechnung von Bash.
                # Daher formatieren wir erst roh, berechnen Padding und färben dann.
                local raw_str
                if (( total > 9 )); then
                    raw_str=$(printf "  [%2d] %s" "$num" "$val")
                else
                    raw_str=$(printf "  [%d] %s" "$num" "$val")
                fi
                
                local pad_len=$(( col_width - ${#raw_str} ))
                (( pad_len < 0 )) && pad_len=0
                local pad=$(printf "%*s" "$pad_len" "")

                # Finale Formatierung mit den globalen Farben aus 00_utils.sh
                local colored_str
                if (( total > 9 )); then
                    colored_str=$(printf "  ${CYAN}[%2d]${NC} %s" "$num" "$val")
                else
                    colored_str=$(printf "  ${CYAN}[%d]${NC} %s" "$num" "$val")
                fi
                
                line+="${colored_str}${pad}"
            fi
        done
        echo -e "$line"
    done
    echo
}

# =========================================
# 📦 Funktion: run_utils
# -----------------------------------------
# Zweck: Zentraler Aufrufpunkt des Moduls
# Aufgabe: Initialisiert Farben und Terminal-Reset
# =========================================
run_utils() {
    setup_colors
    export WARN_COUNT=0
    export ERR_COUNT=0
    tput reset 2>/dev/null || clear
    log "Utilities geladen. (Terminal initialisiert)"
}
