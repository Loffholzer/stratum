#!/usr/bin/env bash

# =========================================
# 📄 Modul: 05_gui_menu.sh
# -----------------------------------------
# Zweck: Interaktives grafisches Auswahlmenü (Whiptail)
# Aufgabe: Fängt Fehleingaben ab und bietet einen CLI-Fallback
# =========================================

# =========================================
# 📦 Funktion: show_gui_menu
# -----------------------------------------
# Zweck: Zeigt das Hauptmenü und gibt die Auswahl (0-4) zurück
# =========================================
show_gui_menu() {
    local kde_mark=""
    local cosmic_mark=""
    local gnome_mark=""
    local xfce_mark=""
    pacman -Qq plasma-desktop >/dev/null 2>&1 && kde_mark=" [Installiert]"
    pacman -Qq cosmic-session >/dev/null 2>&1 && cosmic_mark=" [Installiert]"
    pacman -Qq gnome-shell >/dev/null 2>&1 && gnome_mark=" [Installiert]"
    pacman -Qq xfce4-session >/dev/null 2>&1 && xfce_mark=" [Installiert]"

    # Fallback auf Standard-Bash-Eingabe, falls whiptail fehlt
    if ! command -v whiptail >/dev/null 2>&1; then
        echo -e "\n${STR_GUI_MENU_TITLE}"
        echo -e "${STR_GUI_MENU_SUB}"
        echo -e "  ${CYAN}[1]${NC} KDE Plasma${kde_mark}"
        echo -e "${STR_GUI_DESC_KDE}"
        echo -e "  ${CYAN}[2]${NC} COSMIC Desktop${cosmic_mark}"
        echo -e "${STR_GUI_DESC_COSMIC}"
        echo -e "  ${CYAN}[3]${NC} GNOME${gnome_mark}"
        echo -e "${STR_GUI_DESC_GNOME}"
        echo -e "  ${CYAN}[4]${NC} XFCE${xfce_mark}"
        echo -e "${STR_GUI_DESC_XFCE}"
        echo -e "${STR_GUI_OPT_UNINSTALL}"
        echo -e "${STR_GUI_OPT_APPS}"
        echo -e "${STR_GUI_OPT_EXIT}"
        read -rp "$(echo -e "\n${STR_GUI_PROMPT}")" choice
        echo "$choice"
        return 0
    fi

    # Whiptail Menü aufrufen (STDERR auf STDOUT umleiten für Variable)
    local choice
    choice=$(whiptail --title "$STR_WT_TITLE" --menu "$STR_WT_MSG" 20 95 7 \
        "1" "${STR_WT_OPT_1}${kde_mark}" \
        "2" "${STR_WT_OPT_2}${cosmic_mark}" \
        "3" "${STR_WT_OPT_3}${gnome_mark}" \
        "4" "${STR_WT_OPT_4}${xfce_mark}" \
        "5" "${STR_WT_OPT_5}" \
        "6" "${STR_WT_OPT_6}" \
        "0" "$STR_WT_OPT_0" 3>&1 1>&2 2>&3)

    # Wenn User ESC, Abbrechen drückt oder das Fenster schließt, werte es als "0"
    if [[ $? -ne 0 || -z "$choice" ]]; then
        echo "0"
    else
        echo "$choice"
    fi
}

# =========================================
# 📦 Funktion: show_apps_menu
# -----------------------------------------
# Zweck: Zeigt das Menü für zusätzliche Anwendungen an
# =========================================
show_apps_menu() {
    if ! command -v whiptail >/dev/null 2>&1; then
        echo -e "\n${BOLD}${CYAN} 📦 ANWENDUNGEN${NC}"
        echo -e "${STR_GUI_APPS_SUB}"
        echo -e "${STR_GUI_OPT_LO}"
        echo -e "${STR_GUI_DESC_LO}"
        echo -e "${STR_GUI_OPT_BACK}"
        read -rp "$(echo -e "\n${STR_GUI_PROMPT}")" choice
        echo "$choice"
        return 0
    fi

    local choice
    choice=$(whiptail --title "$STR_WT_APPS_TITLE" --menu "$STR_WT_APPS_MSG" 20 95 6 \
        "1" "$STR_WT_OPT_LO" \
        "0" "$STR_WT_OPT_BACK" 3>&1 1>&2 2>&3)

    if [[ $? -ne 0 || -z "$choice" ]]; then
        echo "0"
    else
        echo "$choice"
    fi
}

# =========================================
# 📦 Funktion: show_uninstall_menu
# -----------------------------------------
# Zweck: Zeigt das Deinstallations-Submenü
# =========================================
show_uninstall_menu() {
    local kde_mark=""
    local cosmic_mark=""
    local gnome_mark=""
    local xfce_mark=""
    pacman -Qq plasma-desktop >/dev/null 2>&1 && kde_mark=" [Installiert]"
    pacman -Qq cosmic-session >/dev/null 2>&1 && cosmic_mark=" [Installiert]"
    pacman -Qq gnome-shell >/dev/null 2>&1 && gnome_mark=" [Installiert]"
    pacman -Qq xfce4-session >/dev/null 2>&1 && xfce_mark=" [Installiert]"

    if ! command -v whiptail >/dev/null 2>&1; then
        echo -e "\n${STR_GUI_MENU_UNINSTALL_TITLE}"
        echo -e "Wähle die zu entfernende Oberfläche:"
        echo -e "  ${CYAN}[1]${NC} KDE Plasma${kde_mark}"
        echo -e "  ${CYAN}[2]${NC} COSMIC Desktop${cosmic_mark}"
        echo -e "  ${CYAN}[3]${NC} GNOME${gnome_mark}"
        echo -e "  ${CYAN}[4]${NC} XFCE${xfce_mark}"
        echo -e "${STR_GUI_OPT_BACK}"
        read -rp "$(echo -e "\n${STR_GUI_PROMPT}")" choice
        echo "$choice"
        return 0
    fi

    local choice
    choice=$(whiptail --title "$STR_WT_UNINSTALL_TITLE" --menu "$STR_WT_UNINSTALL_MSG" 20 70 7 \
        "1" "KDE Plasma${kde_mark}" \
        "2" "COSMIC Desktop${cosmic_mark}" \
        "3" "GNOME${gnome_mark}" \
        "4" "XFCE${xfce_mark}" \
        "0" "$STR_WT_OPT_BACK" 3>&1 1>&2 2>&3)

    if [[ $? -ne 0 || -z "$choice" ]]; then
        echo "0"
    else
        echo "$choice"
    fi
}