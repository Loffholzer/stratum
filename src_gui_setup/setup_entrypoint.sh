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

# 1.5 Lade GUI Paketlisten
if [ -f "$SETUP_DIR/modules/00_gui_packages.sh" ]; then
    source "$SETUP_DIR/modules/00_gui_packages.sh"
fi

# 1.6 Lade interaktives GUI Menü (Whiptail)
if [ -f "$SETUP_DIR/modules/05_gui_menu.sh" ]; then
    source "$SETUP_DIR/modules/05_gui_menu.sh"
fi

# 2. Root-Rechte prüfen
if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
    echo -e "${STR_GUI_ERR_SUDO}"
    exit 1
fi

clear

while true; do
    # Nutze Whiptail-Menü, wenn geladen, ansonsten Notfall-Fallback
    if command -v show_gui_menu >/dev/null 2>&1; then
        gui_choice=$(show_gui_menu)
    else
        echo -e "${STR_GUI_MENU_TITLE}\n[1] KDE Plasma\n[2] COSMIC Desktop\n[3] RM KDE\n[4] RM COSMIC\n[0] Exit"
        read -rp "Auswahl: " gui_choice
    fi

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
