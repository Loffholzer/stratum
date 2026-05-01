#!/usr/bin/env bash

# =========================================
# 📦 Funktion: Globaler Header / Info
# -----------------------------------------
# Zweck: Globale Hilfsfunktionen und UI (00_utils.sh)
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
    export CYAN='\033[1;36m'
    export BOLD='\033[1m'
    export NC='\033[0m'
}

# =========================================
# 📦 Funktion: header
# -----------------------------------------
# Zweck: Visuelle Trennung von Hauptphasen
# Aufgabe: Gibt eine formatierte Box aus
# =========================================
header() {
    local text="$1"
    echo -e "\n${BLUE}=========================================${NC}"
    echo -e "${BOLD}${CYAN} 🚀 ${text}${NC}"
    echo -e "${BLUE}=========================================${NC}\n"
}

# =========================================
# 📦 Funktion: phase_header
# -----------------------------------------
# Zweck: Visuelle Trennung von Sub-Schritten
# Aufgabe: Gibt einen leichten Header aus
# =========================================
phase_header() {
    local text="$1"
    echo -e "\n${BOLD}${BLUE}--- ${text} ---${NC}\n"
}

# =========================================
# 📦 Funktion: log
# -----------------------------------------
# Zweck: Standard-Informationsausgabe
# Aufgabe: Prefix [INFO] in Blau mit Text
# =========================================
log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# =========================================
# 📦 Funktion: success
# -----------------------------------------
# Zweck: Bestätigung erfolgreicher Aktionen
# Aufgabe: Prefix [OK] in Grün mit Text
# =========================================
success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

# =========================================
# 📦 Funktion: warn
# -----------------------------------------
# Zweck: Warnungen (nicht-kritische Fehler)
# Aufgabe: Prefix [WARN] in Gelb mit Text auf STDERR
# =========================================
warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" >&2
}

# =========================================
# 📦 Funktion: error
# -----------------------------------------
# Zweck: Kritische Fehler anzeigen
# Aufgabe: Prefix [ERROR] in Rot mit Text auf STDERR
# =========================================
error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
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
# Zweck: Ausgabe von Array-Suchergebnissen
# Aufgabe: Iteriert über übergebenes Array per Nameref
# =========================================
print_search_results() {
    local title="$1"
    local search="$2"
    local -n arr_ref="$3"
    local i=1

    phase_header "${title} (Suche: ${search})"

    for item in "${arr_ref[@]}"; do
        print_option "$i" "$item"
        ((i++))
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
    tput reset 2>/dev/null || clear
    log "Utilities geladen. (Terminal initialisiert)"
}
