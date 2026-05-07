#!/usr/bin/env bash

# =========================================
# 📄 Modul: 05_gui_menu.sh
# -----------------------------------------
# Zweck: Interaktives grafisches Auswahlmenü (Dialog)
# Aufgabe: Fängt Fehleingaben ab und bietet einen CLI-Fallback
# =========================================

# =========================================
# 📦 Funktion: _setup_dialog_theme
# -----------------------------------------
# Zweck: Setzt ein konsistentes Theme für 'dialog', das schwarze Hintergründe respektiert
# Aufgabe: Erstellt eine temporäre .dialogrc, um unschöne weiße Artefakte zu vermeiden
# =========================================
_setup_dialog_theme() {
    # Nur einmal ausführen und nur wenn 'dialog' existiert
    if [[ -z "$STRATUM_DIALOG_THEME_SET" && -n "$(command -v dialog)" ]]; then
        export DIALOGRC
        DIALOGRC=$(mktemp)
        # Aufräumen bei Skript-Ende sicherstellen
        trap 'rm -f "$DIALOGRC"' EXIT
        
        # Minimal-Konfiguration, die den Terminal-Hintergrund respektiert
        cat > "$DIALOGRC" <<EOF
use_shadow = OFF
screen_color = (WHITE,BLACK,OFF)
title_color = (BLUE,BLACK,ON)
button_active_color = (WHITE,BLUE,ON)
EOF
        export STRATUM_DIALOG_THEME_SET=true
    fi
}

# =========================================
# 📦 Funktion: show_gui_menu
# -----------------------------------------
# Zweck: Zeigt das Hauptmenü und gibt die Auswahl (0-4) zurück
# =========================================
show_gui_menu() {
    _setup_dialog_theme
    local kde_mark=""
    local cosmic_mark=""
    local gnome_mark=""
    local xfce_mark=""
    pacman -Qq plasma-desktop >/dev/null 2>&1 && kde_mark=" [Installiert]"
    pacman -Qq cosmic-session >/dev/null 2>&1 && cosmic_mark=" [Installiert]"
    pacman -Qq gnome-shell >/dev/null 2>&1 && gnome_mark=" [Installiert]"
    pacman -Qq xfce4-session >/dev/null 2>&1 && xfce_mark=" [Installiert]"

    # Fallback auf Standard-Bash-Eingabe, falls dialog fehlt
    if ! command -v dialog >/dev/null 2>&1; then
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

    # Dialog Menü aufrufen (STDERR auf STDOUT umleiten für Variable)
    local choice
    choice=$(dialog --clear --title "$STR_DLG_TITLE" --menu "$STR_DLG_MSG" 20 95 7 \
        "1" "${STR_DLG_OPT_1}${kde_mark}" \
        "2" "${STR_DLG_OPT_2}${cosmic_mark}" \
        "3" "${STR_DLG_OPT_3}${gnome_mark}" \
        "4" "${STR_DLG_OPT_4}${xfce_mark}" \
        "5" "${STR_DLG_OPT_5}" \
        "6" "${STR_DLG_OPT_6}" \
        "0" "$STR_DLG_OPT_0" 3>&1 1>&2 2>&3)

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
    _setup_dialog_theme
    if ! command -v dialog >/dev/null 2>&1; then
        echo -e "\n${BOLD}${CYAN} 📦 ANWENDUNGEN${NC}"
        echo -e "${STR_GUI_APPS_SUB}"
        echo -e "${STR_GUI_OPT_LO}"
        echo -e "${STR_GUI_DESC_LO}"
        echo -e "${STR_GUI_OPT_FLATPAK}"
        echo -e "${STR_GUI_DESC_FLATPAK}"
        echo -e "${STR_GUI_OPT_KVM}"
        echo -e "${STR_GUI_DESC_KVM}"
        echo -e "${STR_GUI_OPT_BACK}"
        read -rp "$(echo -e "\n${STR_GUI_PROMPT}")" choice
        echo "$choice"
        return 0
    fi

    local choice
    # Wir geben die Tags (VLC, GIMP etc.) zurück, getrennt durch Zeilenumbrüche
    choice=$(dialog --clear --title "$STR_DLG_APPS_TITLE" --separate-output --checklist "$STR_DLG_APPS_CHECKLIST_MSG" 20 95 15 \
        "LIBREOFFICE" "$STR_DLG_OPT_LO" off \
        "FLATPAK" "$STR_DLG_OPT_FLATPAK" off \
        "KVM" "$STR_DLG_OPT_KVM" off \
        "DOCKER" "$STR_DLG_OPT_DOCKER" off \
        "---" "--------------------------------------------" off \
        "HARUNA" "$STR_DLG_APPS_HARUNA" off \
        "DISCORD" "$STR_DLG_APPS_DISCORD" off \
        "GIMP" "$STR_DLG_APPS_GIMP" off \
        "OBS" "$STR_DLG_APPS_OBS" off \
        "CODIUM" "$STR_DLG_APPS_CODIUM" off \
        "REMMINA" "$STR_DLG_APPS_REMMINA" off \
        "FILEZILLA" "$STR_DLG_APPS_FILEZILLA" off \
        "NEXTCLOUD" "$STR_DLG_APPS_NEXTCLOUD" off \
        3>&1 1>&2 2>&3)

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
    _setup_dialog_theme
    local kde_mark=""
    local cosmic_mark=""
    local gnome_mark=""
    local xfce_mark=""
    pacman -Qq plasma-desktop >/dev/null 2>&1 && kde_mark=" [Installiert]"
    pacman -Qq cosmic-session >/dev/null 2>&1 && cosmic_mark=" [Installiert]"
    pacman -Qq gnome-shell >/dev/null 2>&1 && gnome_mark=" [Installiert]"
    pacman -Qq xfce4-session >/dev/null 2>&1 && xfce_mark=" [Installiert]"

    if ! command -v dialog >/dev/null 2>&1; then
        echo -e "\n${STR_GUI_MENU_UNINSTALL_TITLE}"
        echo -e "${STR_DLG_UNINSTALL_MSG}"
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
    choice=$(dialog --clear --title "$STR_DLG_UNINSTALL_TITLE" --menu "$STR_DLG_UNINSTALL_MSG" 20 70 7 \
        "1" "KDE Plasma${kde_mark}" \
        "2" "COSMIC Desktop${cosmic_mark}" \
        "3" "GNOME${gnome_mark}" \
        "4" "XFCE${xfce_mark}" \
        "0" "$STR_DLG_OPT_BACK" 3>&1 1>&2 2>&3)

    if [[ $? -ne 0 || -z "$choice" ]]; then
        echo "0"
    else
        echo "$choice"
    fi
}