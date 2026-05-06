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

# 3. Theme-Farben für das Whiptail-Menü (Passend zum Cosmic Splash-Screen)
export NEWT_COLORS="
root=white,black
window=white,black
border=magenta,black
shadow=black,black
title=yellow,black
button=magenta,black
actbutton=white,magenta
listbox=white,black
actlistbox=white,magenta
sellistbox=white,magenta
checkbox=magenta,black
actcheckbox=white,magenta
"

clear

while true; do
    # Nutze Whiptail-Menü, wenn geladen, ansonsten Notfall-Fallback
    if command -v show_gui_menu >/dev/null 2>&1; then
        gui_choice=$(show_gui_menu)
    else
        echo -e "${STR_GUI_MENU_TITLE}\n[1] KDE Plasma\n[2] COSMIC Desktop\n[3] GNOME\n[4] XFCE\n[5] Deinstallieren...\n[6] Apps\n[0] Exit"
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
            echo -e "\n${STR_GUI_LOG_START_GNOME}"
            if [[ -f "$SETUP_DIR/modules/07_gnome_setup.sh" ]]; then
                source "$SETUP_DIR/modules/07_gnome_setup.sh"
                run_gnome_setup
                break
            else
                echo -e "${STR_GUI_ERR_PREFIX} Modul 07_gnome_setup.sh nicht gefunden." >&2
                exit 1
            fi
            ;;
        4)
            echo -e "\n${STR_GUI_LOG_START_XFCE}"
            if [[ -f "$SETUP_DIR/modules/08_xfce_setup.sh" ]]; then
                source "$SETUP_DIR/modules/08_xfce_setup.sh"
                run_xfce_setup
                break
            else
                echo -e "${STR_GUI_ERR_PREFIX} Modul 08_xfce_setup.sh nicht gefunden." >&2
                exit 1
            fi
            ;;
        5)
            while true; do
                if command -v show_uninstall_menu >/dev/null 2>&1; then
                    un_choice=$(show_uninstall_menu)
                else
                    echo -e "\nDeinstallations-Menü:\n[1] KDE Plasma\n[2] COSMIC Desktop\n[3] GNOME\n[4] XFCE\n[0] Zurück"
                    read -rp "Auswahl: " un_choice
                fi
                
                case $un_choice in
                    1)
                        echo -e "\n${STR_GUI_LOG_START_RM_KDE}"
                        if [[ -f "$SETUP_DIR/modules/03_kde_setup.sh" ]]; then
                            source "$SETUP_DIR/modules/03_kde_setup.sh"
                            remove_kde_setup
                            break 2
                        else
                            echo -e "${STR_GUI_ERR_PREFIX} Modul 03_kde_setup.sh nicht gefunden." >&2
                            exit 1
                        fi
                        ;;
                    2)
                        echo -e "\n${STR_GUI_LOG_START_RM_COSMIC}"
                        if [[ -f "$SETUP_DIR/modules/04_cosmic_setup.sh" ]]; then
                            source "$SETUP_DIR/modules/04_cosmic_setup.sh"
                            remove_cosmic_setup
                            break 2
                        else
                            echo -e "${STR_GUI_ERR_PREFIX} Modul 04_cosmic_setup.sh nicht gefunden." >&2
                            exit 1
                        fi
                        ;;
                    3)
                        echo -e "\n${STR_GUI_LOG_START_RM_GNOME}"
                        if [[ -f "$SETUP_DIR/modules/07_gnome_setup.sh" ]]; then
                            source "$SETUP_DIR/modules/07_gnome_setup.sh"
                            remove_gnome_setup
                            break 2
                        else
                            echo -e "${STR_GUI_ERR_PREFIX} Modul 07_gnome_setup.sh nicht gefunden." >&2
                            exit 1
                        fi
                        ;;
                    4)
                        echo -e "\n${STR_GUI_LOG_START_RM_XFCE}"
                        if [[ -f "$SETUP_DIR/modules/08_xfce_setup.sh" ]]; then
                            source "$SETUP_DIR/modules/08_xfce_setup.sh"
                            remove_xfce_setup
                            break 2
                        else
                            echo -e "${STR_GUI_ERR_PREFIX} Modul 08_xfce_setup.sh nicht gefunden." >&2
                            exit 1
                        fi
                        ;;
                    0)
                        break
                        ;;
                esac
            done
            ;;
        6)
            while true; do
                if command -v show_apps_menu >/dev/null 2>&1; then
                    app_choice=$(show_apps_menu)
                else
                    echo -e "\nAnwendungs-Menü:\n[1] LibreOffice\n[0] Zurück"
                    read -rp "Auswahl: " app_choice
                fi
                
                case $app_choice in
                    1)
                        if [[ -f "$SETUP_DIR/modules/06_apps_setup.sh" ]]; then
                            source "$SETUP_DIR/modules/06_apps_setup.sh"
                            install_libreoffice
                        else
                            echo -e "${STR_GUI_ERR_PREFIX} Modul 06_apps_setup.sh nicht gefunden." >&2
                        fi
                        ;;
                    0)
                        break
                        ;;
                esac
            done
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
