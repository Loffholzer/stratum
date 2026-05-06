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

# 3. Dialog Theme-Farben (Lila-Nebel & Gelbe Sterne)
export DIALOGRC="$SETUP_DIR/.dialogrc"
cat << 'EOF' > "$DIALOGRC"
use_colors = ON
use_shadow = OFF
screen_color = (BLACK,BLACK,OFF)
dialog_color = (CYAN,BLACK,OFF)
menubox_color = (BLACK,BLACK,OFF)
border_color = (MAGENTA,BLACK,ON)
border2_color = (MAGENTA,BLACK,ON)
menubox_border_color = (MAGENTA,BLACK,ON)
menubox_border2_color = (MAGENTA,BLACK,ON)
item_selected_color = (WHITE,MAGENTA,ON)
tag_selected_color = (WHITE,MAGENTA,ON)
tag_key_selected_color = (WHITE,MAGENTA,ON)
check_selected_color = (WHITE,MAGENTA,ON)
button_active_color = (WHITE,MAGENTA,ON)
button_label_active_color = (WHITE,MAGENTA,ON)
item_color = (YELLOW,BLACK,OFF)
tag_color = (YELLOW,BLACK,ON)
tag_key_color = (YELLOW,BLACK,ON)
check_color = (YELLOW,BLACK,OFF)
button_key_active_color = (YELLOW,MAGENTA,ON)
button_key_inactive_color = (YELLOW,BLACK,OFF)
EOF

clear

while true; do
    # Nutze Dialog-Menü, wenn geladen, ansonsten Notfall-Fallback
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
            if command -v show_apps_menu >/dev/null 2>&1; then
                app_choices=$(show_apps_menu)
                if [[ "$app_choices" != "0" && -n "$app_choices" ]]; then
                    if [[ -f "$SETUP_DIR/modules/06_apps_setup.sh" ]]; then
                        source "$SETUP_DIR/modules/06_apps_setup.sh"
                        
                        # Die Auswahl ist eine durch Zeilenumbrüche getrennte Liste von Tags
                        for choice in $app_choices; do
                            case $choice in
                                "LIBREOFFICE") install_libreoffice ;;
                                "FLATPAK") install_flatpak ;;
                                "KVM") install_kvm ;;
                                "DOCKER") install_docker ;;
                                "HARUNA") install_haruna ;;
                                "DISCORD") install_discord ;;
                                "GIMP") install_gimp ;;
                                "OBS") install_obs ;;
                                "CODIUM") install_codium ;;
                                "REMMINA") install_remmina ;;
                                "FILEZILLA") install_filezilla ;;
                                "NEXTCLOUD") install_nextcloud ;;
                            esac
                        done
                    fi
                fi
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
