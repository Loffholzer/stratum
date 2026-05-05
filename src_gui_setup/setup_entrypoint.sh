#!/usr/bin/env bash
# =========================================
# 🚀 STRATUM OS - GUI Setup (Entrypoint)
# -----------------------------------------
# Zweck: Hauptmenü für die Desktop-Installation
# =========================================

# Arbeitsverzeichnis ermitteln
SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# 1. Lade GUI-spezifische Strings
if [ -f "$SETUP_DIR/modules/01_gui_strings.sh" ]; then
    source "$SETUP_DIR/modules/01_gui_strings.sh"
fi

# 2. Root-Rechte prüfen
if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
    echo -e "${STR_GUI_ERR_SUDO}"
    exit 1
fi

clear
echo -e "${BLUE}=========================================${NC}"
echo -e "${BOLD}${CYAN} ${STR_HANDOFF_TITLE:-Willkommen}${NC}"
echo -e "${BLUE}=========================================${NC}"
echo -e "${STR_GUI_MENU_TITLE}"
echo -e "${STR_GUI_MENU_SUB}"
echo -e ""
echo -e "${STR_GUI_OPT_KDE}"
echo -e "${STR_GUI_OPT_COSMIC}"
echo -e "${STR_GUI_OPT_RM_KDE}"
echo -e "${STR_GUI_OPT_RM_COSMIC}"
echo -e "${STR_GUI_OPT_EXIT}"
echo -e "${BLUE}=========================================${NC}"

# Farben im Prompt erzwingen durch Evaluierung via Subshell
while true; do
    read -rp "$(echo -e "${STR_GUI_PROMPT}")" gui_choice

    case $gui_choice in
        1)
            echo -e "\n${STR_GUI_LOG_START_KDE}"
            if [[ -f "$SETUP_DIR/modules/03_kde_setup.sh" ]]; then
                source "$SETUP_DIR/modules/03_kde_setup.sh"
                run_kde_setup
                break
            else
                echo -e "${STR_GUI_ERR_PREFIX} Modul 03_kde_setup.sh nicht gefunden." >&2
                exit 1
            fi
            ;;
        2)
            echo -e "\n${STR_GUI_LOG_START_COSMIC}"
            if [[ -f "$SETUP_DIR/modules/04_cosmic_setup.sh" ]]; then
                source "$SETUP_DIR/modules/04_cosmic_setup.sh"
                run_cosmic_setup
                break
            else
                echo -e "${STR_GUI_ERR_PREFIX} Modul 04_cosmic_setup.sh nicht gefunden." >&2
                exit 1
            fi
            ;;
        3)
            echo -e "\n${STR_GUI_LOG_START_RM_KDE}"
            if [[ -f "$SETUP_DIR/modules/03_kde_setup.sh" ]]; then
                source "$SETUP_DIR/modules/03_kde_setup.sh"
                remove_kde_setup
                break
            else
                echo -e "${STR_GUI_ERR_PREFIX} Modul 03_kde_setup.sh nicht gefunden." >&2
                exit 1
            fi
            ;;
        4)
            echo -e "\n${STR_GUI_LOG_START_RM_COSMIC}"
            if [[ -f "$SETUP_DIR/modules/04_cosmic_setup.sh" ]]; then
                source "$SETUP_DIR/modules/04_cosmic_setup.sh"
                remove_cosmic_setup
                break
            else
                echo -e "${STR_GUI_ERR_PREFIX} Modul 04_cosmic_setup.sh nicht gefunden." >&2
                exit 1
            fi
            ;;
        0)
            echo -e "\n${STR_GUI_LOG_EXIT}"
            exit 0
            ;;
        *)
            echo -e "${STR_GUI_ERR_INVALID}" >&2
            ;;
    esac
done
