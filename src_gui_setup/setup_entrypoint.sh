#!/bin/bash
# =========================================
# 🚀 STRATUM OS - GUI Setup (Entrypoint)
# -----------------------------------------
# Zweck: Hauptmenü für die Desktop-Installation
# =========================================

# Arbeitsverzeichnis ermitteln
SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# 1. Lade Basis-Strings (vom Haupt-Installer kopiert)
if [ -f "$SETUP_DIR/01_strings.sh" ]; then
    source "$SETUP_DIR/01_strings.sh"
fi

# 2. Lade GUI-spezifische Strings
if [ -f "$SETUP_DIR/modules/01_gui_strings.sh" ]; then
    source "$SETUP_DIR/modules/01_gui_strings.sh"
fi

clear
echo "========================================="
echo " $STR_HANDOFF_TITLE"
echo "========================================="
echo "$STR_GUI_MENU_TITLE"
echo "$STR_GUI_MENU_SUB"
echo ""
echo "  [1] $STR_GUI_OPT_KDE"
echo "  [2] $STR_GUI_OPT_COSMIC"
echo "  [0] $STR_GUI_OPT_EXIT"
echo "========================================="
echo -n "$STR_GUI_PROMPT"
read -r gui_choice

case $gui_choice in
    1)
        echo ""
        echo "$STR_GUI_LOG_START_KDE"
        # Später: bash "$SETUP_DIR/modules/03_kde_setup.sh"
        ;;
    2)
        echo ""
        echo "$STR_GUI_LOG_START_COSMIC"
        # Später: bash "$SETUP_DIR/modules/04_cosmic_setup.sh"
        ;;
    0)
        echo ""
        echo "$STR_GUI_LOG_EXIT"
        exit 0
        ;;
    *)
        echo ""
        echo "$STR_GUI_ERR_INVALID"
        exit 1
        ;;
esac
