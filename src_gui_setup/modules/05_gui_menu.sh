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
    # Fallback auf Standard-Bash-Eingabe, falls whiptail fehlt
    if ! command -v whiptail >/dev/null 2>&1; then
        echo -e "\n${STR_GUI_MENU_TITLE}"
        echo -e "${STR_GUI_MENU_SUB}"
        echo -e "${STR_GUI_OPT_KDE}"
        echo -e "${STR_GUI_OPT_COSMIC}"
        echo -e "${STR_GUI_OPT_RM_KDE}"
        echo -e "${STR_GUI_OPT_RM_COSMIC}"
        echo -e "${STR_GUI_OPT_EXIT}"
        read -rp "$(echo -e "\n${STR_GUI_PROMPT}")" choice
        echo "$choice"
        return 0
    fi

    # Whiptail Menü aufrufen (STDERR auf STDOUT umleiten für Variable)
    local choice
    choice=$(whiptail --title "$STR_WT_TITLE" --menu "$STR_WT_MSG" 20 70 6 \
        "1" "$STR_WT_OPT_1" \
        "2" "$STR_WT_OPT_2" \
        "3" "$STR_WT_OPT_3" \
        "4" "$STR_WT_OPT_4" \
        "0" "$STR_WT_OPT_0" 3>&1 1>&2 2>&3)

    # Wenn User ESC, Abbrechen drückt oder das Fenster schließt, werte es als "0"
    if [[ $? -ne 0 || -z "$choice" ]]; then
        echo "0"
    else
        echo "$choice"
    fi
}