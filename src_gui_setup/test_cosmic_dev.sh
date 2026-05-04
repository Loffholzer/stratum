#!/usr/bin/env bash
# ==============================================================================
# 🧪 STRATUM DEV-TOOL: COSMIC SETUP TESTER
# 💡 ZWECK: Autarker Start des COSMIC-Moduls ohne Menüs (Nur für Entwicklung)
# ⚠️ WICHTIG: Nicht für das finale Release vorgesehen!
# ==============================================================================

set -e

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# =========================================
# 📦 Funktion: verify_root
# -----------------------------------------
# Zweck: Stellt sicher, dass pacman und systemctl Rechte haben
# Aufgabe: Überprüft EUID und bricht andernfalls mit Meldung ab
# =========================================
verify_root() {
    if [[ "$EUID" -ne 0 ]]; then
        echo -e "\033[1;31m[FEHLER]\033[0m Dieses Test-Skript muss mit Root-Rechten (sudo) gestartet werden."
        exit 1
    fi
}

verify_root

echo "=============================================================================="
echo " 🧪 STRATUM DEV-TEST: COSMIC EPOCH INSTALLATION"
echo "=============================================================================="

# Module sicher laden
source "${BASE_DIR}/modules/01_gui_strings.sh"
source "${BASE_DIR}/modules/04_cosmic_setup.sh"

# Ausführen der eigentlichen Routine
run_cosmic_setup

echo -e "\n${STR_GUI_INFO_PREFIX} Testlauf beendet. Bitte System neustarten, um Greeter zu prüfen."