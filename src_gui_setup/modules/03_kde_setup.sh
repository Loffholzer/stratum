#!/usr/bin/env bash

# =========================================
# 📄 Modul: 03_kde_setup.sh
# -----------------------------------------
# Zweck: Installation & Konfiguration von KDE Plasma
# =========================================

declare -a KDE_PKGS=(
    "plasma-desktop"
    "sddm"
    "konsole"
    "dolphin"
    "power-profiles-daemon"
    "networkmanager-qt"
    "xdg-desktop-portal-kde"
    "xorg-xwayland"
    "qt6-wayland"
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
)

export ENABLE_BLUETOOTH=false
export ENABLE_QEMU_GA=false
export INSTALL_OOTB=false

# =========================================
# 📦 Funktion: kde_ask_ootb
# -----------------------------------------
# Zweck: Fragt den Benutzer nach OOTB-Apps
# Aufgabe: Setzt das Flag für die Installation von Firefox & Co.
# =========================================
kde_ask_ootb() {
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
# 📦 Funktion: kde_detect_firefox_lang
# -----------------------------------------
# Zweck: Ermittelt das passende Firefox Sprachpaket
# =========================================
kde_detect_firefox_lang() {
    local sys_lang
    local lang_code
    local ff_pkg

    if [[ -f /etc/locale.conf ]]; then
        sys_lang=$(source /etc/locale.conf 2>/dev/null && echo "$LANG")
    else
        sys_lang="${LANG:-de_DE.UTF-8}"
    fi

    lang_code="${sys_lang%%_*}"
    [[ -n "$lang_code" ]] && ff_pkg="firefox-i18n-${lang_code}"

    if [[ -n "$ff_pkg" ]] && pacman -Sp "$ff_pkg" >/dev/null 2>&1; then
        echo -e "  -> ${STR_GUI_LOG_FF_LANG_FOUND}: ${ff_pkg}"
        OOTB_PKGS+=("$ff_pkg")
    fi
}

# =========================================
# 📦 Funktion: kde_detect_hardware
# -----------------------------------------
# Zweck: Hardware-spezifische GUI-Komponenten erkennen
# Aufgabe: Prüft auf VMs und Bluetooth-Adapter zur dynamischen Paketauswahl
# =========================================
kde_detect_hardware() {
    echo -e "${STR_GUI_LOG_KDE_HW_DETECT}"
    
    # 1. Erkennung Virtueller Maschinen
    local virt_type
    virt_type=$(systemd-detect-virt 2>/dev/null || echo "none")
    if [[ "$virt_type" != "none" ]]; then
        echo -e "${STR_GUI_LOG_VM_DETECTED}"
        KDE_PKGS+=("qemu-guest-agent" "spice-vdagent")
        [[ "$virt_type" == "qemu" || "$virt_type" == "kvm" ]] && ENABLE_QEMU_GA=true
    fi

    # 2. Erkennung von Bluetooth-Modulen
    if lsusb 2>/dev/null | grep -iq "bluetooth" || lspci 2>/dev/null | grep -iq "bluetooth" || dmesg 2>/dev/null | grep -iq "bluetooth"; then
        echo -e "${STR_GUI_LOG_BT_DETECTED}"
        # Bluedevil ist das native KDE-Bluetooth Applet
        KDE_PKGS+=("bluez" "bluez-utils" "bluedevil")
        ENABLE_BLUETOOTH=true
    fi
    
    echo -e "${STR_GUI_LOG_KDE_AUDIO}"
    KDE_PKGS+=("${AUDIO_PKGS[@]}")
}

# =========================================
# 📦 Funktion: kde_install_ootb
# -----------------------------------------
# Zweck: Installiert die Out-of-the-Box Anwendungen
# =========================================
kde_install_ootb() {
    [[ "$INSTALL_OOTB" != "true" ]] && return 0
    
    echo -e "\n${STR_GUI_LOG_OOTB_PKGS}"
    kde_detect_firefox_lang
    pacman -S --needed --noconfirm "${OOTB_PKGS[@]}" || true
}

# =========================================
# 📦 Funktion: kde_configure_firefox
# -----------------------------------------
# Zweck: Härtung des Browsers via Enterprise Policies
# Aufgabe: Legt policies.json an (Setzt Brave, HTTPS-Only, No-Telemetry)
# =========================================
kde_configure_firefox() {
    [[ "$INSTALL_OOTB" != "true" ]] && return 0
    echo -e "\n${STR_GUI_LOG_FF_POLICY}"
    source "$(dirname "${BASH_SOURCE[0]}")/02_gui_templates.sh"
    mkdir -p /etc/firefox/policies
    echo "$TPL_FF_POLICIES" > /etc/firefox/policies/policies.json
}

# =========================================
# 📦 Funktion: kde_install_packages
# -----------------------------------------
# Zweck: Herunterladen und Installieren der GUI-Basis
# Aufgabe: Führt pacman mit dem dynamisch generierten Array aus
# =========================================
kde_install_packages() {
    echo -e "\n${STR_GUI_LOG_KDE_PKGS}"
    if ! pacman -S --needed --noconfirm "${KDE_PKGS[@]}"; then
        echo -e "${STR_GUI_ERR_PACMAN}" >&2
        exit 1
    fi
}

# =========================================
# 📦 Funktion: kde_enable_services
# -----------------------------------------
# Zweck: Dienste für den Systemstart aktivieren
# Aufgabe: Konfiguriert Display-Manager (SDDM) und Hardware-Dienste
# =========================================
kde_enable_services() {
    echo -e "\n${STR_GUI_LOG_KDE_ENABLE_SRV}"
    
    systemctl enable sddm.service
    systemctl enable power-profiles-daemon.service
    
    [[ "$ENABLE_BLUETOOTH" == true ]] && systemctl enable bluetooth.service
    [[ "$ENABLE_QEMU_GA" == true ]] && systemctl enable qemu-guest-agent.service
}

# =========================================
# 📦 Funktion: run_kde_setup
# -----------------------------------------
# Zweck: Haupt-Einsprungpunkt für die KDE-Installation
# =========================================
run_kde_setup() {
    echo -e "\n${STR_GUI_KDE_PHASE}\n"
    kde_ask_ootb
    kde_detect_hardware
    kde_install_packages
    kde_install_ootb
    kde_configure_firefox
    kde_enable_services
    echo -e "\n${STR_GUI_OK_KDE}"
}

# =========================================
# 📦 Funktion: kde_disable_services
# -----------------------------------------
# Zweck: Deaktiviert KDE-spezifische Systemdienste
# Aufgabe: Stoppt und deaktiviert den SDDM Display-Manager
# =========================================
kde_disable_services() {
    echo -e "\n${STR_GUI_LOG_KDE_DISABLE_SRV}"
    systemctl disable sddm.service 2>/dev/null || true
    systemctl stop sddm.service 2>/dev/null || true
}

# =========================================
# 📦 Funktion: kde_remove_packages
# -----------------------------------------
# Zweck: Entfernt die KDE Plasma Desktop-Umgebung
# Aufgabe: Deinstalliert die GUI-Pakete (Behält Audio & System-Treiber)
# =========================================
kde_remove_packages() {
    echo -e "\n${STR_GUI_LOG_KDE_RM_PKGS}"
    pacman -Rs --noconfirm "${KDE_PKGS[@]}" 2>/dev/null || true
}

# =========================================
# 📦 Funktion: remove_kde_setup
# -----------------------------------------
# Zweck: Haupt-Einsprungpunkt für die KDE-Deinstallation
# =========================================
remove_kde_setup() {
    echo -e "\n${STR_GUI_KDE_RM_PHASE}\n"
    kde_disable_services
    kde_remove_packages
    echo -e "\n${STR_GUI_OK_RM_KDE}"
}