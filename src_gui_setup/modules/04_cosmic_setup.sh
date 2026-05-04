#!/usr/bin/env bash

# =========================================
# 📄 DATEI: 04_cosmic_setup.sh
# 💡 ZWECK: Installation & Konfiguration von COSMIC Desktop
# =========================================

declare -a COSMIC_PKGS=(
    "cosmic"
    "cosmic-greeter"
    "xdg-desktop-portal-cosmic"
    "xdg-desktop-portal-gtk"
    "xorg-xwayland"
    "polkit"
    "power-profiles-daemon"
)

declare -a AUDIO_PKGS=(
    "pipewire"
    "pipewire-audio"
    "pipewire-pulse"
    "pipewire-alsa"
    "pipewire-jack"
    "wireplumber"
)

declare -a OOTB_PKGS=(
    "firefox"
    "noto-fonts"
    "noto-fonts-emoji"
    "ttf-liberation"
    "evince"
    "file-roller"
    "gnome-keyring"
    "seahorse"
    "ttf-jetbrains-mono-nerd"
)

export ENABLE_BLUETOOTH=false
export ENABLE_QEMU_GA=false
export INSTALL_OOTB=false

# =========================================
# 📦 Funktion: cosmic_ask_ootb
# -----------------------------------------
# Zweck: Fragt den Benutzer nach OOTB-Apps
# Aufgabe: Setzt das Flag für die Installation von Firefox & Co.
# =========================================
cosmic_ask_ootb() {
    echo -e "\n${STR_GUI_LOG_OOTB_ASK}"
    local choice
    while true; do
        read -rp "$(echo -e "${STR_GUI_PROMPT_YN}")" choice
        case "${choice,,}" in
            j|ja|y|yes) INSTALL_OOTB=true; break ;;
            n|nein|no)  INSTALL_OOTB=false; break ;;
            *) echo -e "${STR_GUI_ERR_INVALID}" >&2 ;;
        esac
    done
}

# =========================================
# 📦 Funktion: cosmic_detect_firefox_lang
# -----------------------------------------
# Zweck: Ermittelt das passende Firefox Sprachpaket
# Aufgabe: Liest System-Locale und prüft Pacman auf das i18n Paket
# =========================================
cosmic_detect_firefox_lang() {
    local sys_lang
    local lang_code
    local ff_pkg

    # Locale sicher aus dem installierten System lesen
    if [[ -f /etc/locale.conf ]]; then
        sys_lang=$(source /etc/locale.conf 2>/dev/null && echo "$LANG")
    else
        sys_lang="${LANG:-de_DE.UTF-8}"
    fi

    # Sprachcode extrahieren (z.B. 'de' aus 'de_DE.UTF-8')
    lang_code="${sys_lang%%_*}"
    
    [[ -n "$lang_code" ]] && ff_pkg="firefox-i18n-${lang_code}"

    # Prüfen ob das Paket im Repo existiert (-Sp testet ohne Download)
    if [[ -n "$ff_pkg" ]] && pacman -Sp "$ff_pkg" >/dev/null 2>&1; then
        echo -e "  -> ${STR_GUI_LOG_FF_LANG_FOUND}: ${ff_pkg}"
        OOTB_PKGS+=("$ff_pkg")
    fi
}

# =========================================
# 📦 Funktion: cosmic_detect_hardware
# -----------------------------------------
# Zweck: Hardware-spezifische GUI-Komponenten erkennen
# Aufgabe: Prüft auf VMs und Bluetooth-Adapter zur dynamischen Paketauswahl
# =========================================
cosmic_detect_hardware() {
    echo -e "${STR_GUI_LOG_HW_DETECT}"
    
    # 1. Erkennung Virtueller Maschinen
    local virt_type
    virt_type=$(systemd-detect-virt 2>/dev/null || echo "none")
    if [[ "$virt_type" != "none" ]]; then
        echo -e "${STR_GUI_LOG_VM_DETECTED}"
        COSMIC_PKGS+=("qemu-guest-agent" "spice-vdagent")
        [[ "$virt_type" == "qemu" || "$virt_type" == "kvm" ]] && ENABLE_QEMU_GA=true
    fi

    # 2. Erkennung von Bluetooth-Modulen (via lsusb, lspci oder dmesg)
    if lsusb 2>/dev/null | grep -iq "bluetooth" || lspci 2>/dev/null | grep -iq "bluetooth" || dmesg 2>/dev/null | grep -iq "bluetooth"; then
        echo -e "${STR_GUI_LOG_BT_DETECTED}"
        COSMIC_PKGS+=("bluez" "bluez-utils")
        ENABLE_BLUETOOTH=true
    fi
    
    echo -e "${STR_GUI_LOG_AUDIO}"
    COSMIC_PKGS+=("${AUDIO_PKGS[@]}")
}

# =========================================
# 📦 Funktion: cosmic_install_ootb
# -----------------------------------------
# Zweck: Installiert die Out-of-the-Box Anwendungen
# Aufgabe: Führt pacman mit dem OOTB Array aus
# =========================================
cosmic_install_ootb() {
    [[ "$INSTALL_OOTB" != "true" ]] && return 0
    
    echo -e "\n${STR_GUI_LOG_OOTB_PKGS}"
    cosmic_detect_firefox_lang
    pacman -S --needed --noconfirm "${OOTB_PKGS[@]}" || true
}

# =========================================
# 📦 Funktion: cosmic_configure_firefox
# -----------------------------------------
# Zweck: Härtung des Browsers via Enterprise Policies
# Aufgabe: Legt policies.json an (Setzt Brave, HTTPS-Only, No-Telemetry)
# =========================================
cosmic_configure_firefox() {
    [[ "$INSTALL_OOTB" != "true" ]] && return 0
    echo -e "\n${STR_GUI_LOG_FF_POLICY}"
    source "$(dirname "${BASH_SOURCE[0]}")/02_gui_templates.sh"
    mkdir -p /etc/firefox/policies
    echo "$TPL_FF_POLICIES" > /etc/firefox/policies/policies.json
}

# =========================================
# 📦 Funktion: cosmic_install_packages
# -----------------------------------------
# Zweck: Herunterladen und Installieren der GUI-Basis
# Aufgabe: Führt pacman mit dem dynamisch generierten Array aus
# =========================================
cosmic_install_packages() {
    echo -e "\n${STR_GUI_LOG_COSMIC_PKGS}"
    if ! pacman -S --needed --noconfirm "${COSMIC_PKGS[@]}"; then
        echo -e "${STR_GUI_ERR_PACMAN}" >&2
        exit 1
    fi
}

# =========================================
# 📦 Funktion: cosmic_enable_services
# -----------------------------------------
# Zweck: Dienste für den Systemstart aktivieren
# Aufgabe: Konfiguriert Display-Manager, Audio-Routing und Netzwerkhilfen
# =========================================
cosmic_enable_services() {
    echo -e "\n${STR_GUI_LOG_ENABLE_SRV}"
    
    systemctl enable cosmic-greeter.service
    systemctl enable power-profiles-daemon.service
    
    [[ "$ENABLE_BLUETOOTH" == true ]] && systemctl enable bluetooth.service
    [[ "$ENABLE_QEMU_GA" == true ]] && systemctl enable qemu-guest-agent.service
}

# =========================================
# 📦 Funktion: run_cosmic_setup
# -----------------------------------------
# Zweck: Haupt-Einsprungpunkt für die COSMIC-Installation
# Aufgabe: Triggert Erkennung, Installation und Dienstaktivierung in Reihenfolge
# =========================================
run_cosmic_setup() {
    echo -e "\n${STR_GUI_COSMIC_PHASE}\n"
    cosmic_ask_ootb
    cosmic_detect_hardware
    cosmic_install_packages
    cosmic_install_ootb
    cosmic_configure_firefox
    cosmic_enable_services
    echo -e "\n${STR_GUI_OK_COSMIC}"
}

# =========================================
# 📦 Funktion: cosmic_disable_services
# -----------------------------------------
# Zweck: Deaktiviert COSMIC-spezifische Systemdienste
# Aufgabe: Stoppt und deaktiviert den Cosmic-Greeter
# =========================================
cosmic_disable_services() {
    echo -e "\n${STR_GUI_LOG_COSMIC_DISABLE_SRV}"
    systemctl disable cosmic-greeter.service 2>/dev/null || true
    systemctl stop cosmic-greeter.service 2>/dev/null || true
}

# =========================================
# 📦 Funktion: cosmic_remove_packages
# -----------------------------------------
# Zweck: Entfernt die COSMIC Desktop-Umgebung
# Aufgabe: Deinstalliert die GUI-Pakete (Behält Audio & System-Treiber)
# =========================================
cosmic_remove_packages() {
    echo -e "\n${STR_GUI_LOG_COSMIC_RM_PKGS}"
    pacman -Rs --noconfirm "${COSMIC_PKGS[@]}" 2>/dev/null || true
}

# =========================================
# 📦 Funktion: remove_cosmic_setup
# -----------------------------------------
# Zweck: Haupt-Einsprungpunkt für die COSMIC-Deinstallation
# =========================================
remove_cosmic_setup() {
    echo -e "\n${STR_GUI_COSMIC_RM_PHASE}\n"
    cosmic_disable_services
    cosmic_remove_packages
    echo -e "\n${STR_GUI_OK_RM_COSMIC}"
}