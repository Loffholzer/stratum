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
    "thunderbird"
    "noto-fonts"
    "noto-fonts-emoji"
    "ttf-liberation"
    "ttf-jetbrains-mono-nerd"
    "ark"
    "unzip"
    "unrar"
    "zip"
    "p7zip"
    "okular"
    "gwenview"
    "kimageformats"
    "qt6-imageformats"
    "haruna"
    "ffmpeg"
    "gst-plugins-good"
    "gst-plugins-bad"
    "gst-plugins-ugly"
    "gst-libav"
    "discover"
    "packagekit-qt6"
    "flatpak"
    "flatseal"
    "kcalc"
    "spectacle"
    "kinfocenter"
    "partitionmanager"
    "isoimagewriter"
    "cups"
    "print-manager"
    "gnome-keyring"
    "seahorse"
)

export ENABLE_BLUETOOTH=false
export ENABLE_QEMU_GA=false
export INSTALL_OOTB=false
export PURGE_CONFIGS=false

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
# 📦 Funktion: kde_detect_browser_mail_lang
# -----------------------------------------
# Zweck: Ermittelt passende Sprachpakete für Browser und Mail
# Aufgabe: Sucht i18n Pakete für Firefox und Thunderbird
# =========================================
kde_detect_browser_mail_lang() {
    local sys_lang
    local lang_code

    if [[ -f /etc/locale.conf ]]; then
        sys_lang=$(source /etc/locale.conf 2>/dev/null && echo "$LANG")
    else
        sys_lang="${LANG:-de_DE.UTF-8}"
    fi

    lang_code="${sys_lang%%_*}"
    if [[ -n "$lang_code" ]]; then
        for pkg in "firefox-i18n-${lang_code}" "thunderbird-i18n-${lang_code}"; do
            if pacman -Sp "$pkg" >/dev/null 2>&1; then
                echo -e "  -> ${STR_GUI_LOG_LANG_PKG_FOUND}: ${pkg}"
                OOTB_PKGS+=("$pkg")
            fi
        done
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
# Aufgabe: Führt pacman mit dem OOTB Array aus
# =========================================
kde_install_ootb() {
    [[ "$INSTALL_OOTB" != "true" ]] && return 0
    
    echo -e "\n${STR_GUI_LOG_OOTB_PKGS}"
    kde_detect_browser_mail_lang
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
# 📦 Funktion: kde_configure_wayland
# -----------------------------------------
# Zweck: Setzt systemweite Wayland-Variablen
# Aufgabe: Schreibt Profile-Script für Electron & Firefox
# =========================================
kde_configure_wayland() {
    echo -e "\n${STR_GUI_LOG_WAYLAND_ENV}"
    source "$(dirname "${BASH_SOURCE[0]}")/02_gui_templates.sh"
    echo "$TPL_WAYLAND_ENV" > /etc/profile.d/stratum_wayland.sh
    chmod +x /etc/profile.d/stratum_wayland.sh
}

# =========================================
# 📦 Funktion: kde_configure_keyboard
# -----------------------------------------
# Zweck: Synchronisiert das Konsolen-Layout mit der GUI
# Aufgabe: Setzt das X11/Wayland Keymap für den SDDM-Greeter
# =========================================
kde_configure_keyboard() {
    if [[ -f /etc/vconsole.conf ]]; then
        local sys_keymap
        sys_keymap=$(grep "^KEYMAP=" /etc/vconsole.conf | cut -d'=' -f2)
        if [[ -n "$sys_keymap" ]]; then
            echo -e "\n${STR_GUI_LOG_KEYMAP} (${sys_keymap})"
            localectl set-x11-keymap "$sys_keymap" 2>/dev/null || true
        fi
    fi
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
    [[ "$INSTALL_OOTB" == true ]] && systemctl enable cups.service 2>/dev/null || true
}

# =========================================
# 📦 Funktion: kde_cleanup
# -----------------------------------------
# Zweck: Bereinigt den Pacman-Cache nach der Installation
# Aufgabe: Führt pacman -Scc aus, um Speicherplatz freizugeben
# =========================================
kde_cleanup() {
    echo -e "\n${STR_GUI_LOG_CLEANUP}"
    pacman -Scc --noconfirm >/dev/null 2>&1 || true
}

# =========================================
# 📦 Funktion: run_kde_setup
# -----------------------------------------
# Zweck: Haupt-Einsprungpunkt für die KDE-Installation
# Aufgabe: Triggert Erkennung, Installation und Dienstaktivierung in Reihenfolge
# =========================================
run_kde_setup() {
    echo -e "\n${STR_GUI_KDE_PHASE}\n"
    kde_ask_ootb
    kde_detect_hardware
    kde_install_packages
    kde_install_ootb
    kde_configure_firefox
    kde_configure_wayland
    kde_configure_keyboard
    kde_enable_services
    kde_cleanup
    echo -e "\n${STR_GUI_OK_KDE}"
}

# =========================================
# 📦 Funktion: kde_ask_deep_clean
# -----------------------------------------
# Zweck: Fragt, ob User-Configs (Dotfiles) gelöscht werden sollen
# Aufgabe: Setzt das Flag PURGE_CONFIGS basierend auf User-Eingabe
# =========================================
kde_ask_deep_clean() {
    echo -e "\n${STR_GUI_ASK_DEEP_CLEAN}"
    local choice
    while true; do
        read -rp "$(echo -e "${STR_GUI_PROMPT_YN}")" choice
        case "${choice,,}" in
            j|ja|y|yes) PURGE_CONFIGS=true; break ;;
            n|nein|no)  PURGE_CONFIGS=false; break ;;
            *) echo -e "${STR_GUI_ERR_INVALID}" >&2 ;;
        esac
    done
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
    
    local installed_pkgs=()
    for pkg in "${KDE_PKGS[@]}"; do
        if pacman -Qq "$pkg" >/dev/null 2>&1; then
            installed_pkgs+=("$pkg")
        fi
    done

    if [[ ${#installed_pkgs[@]} -gt 0 ]]; then
        pacman -Rs --noconfirm "${installed_pkgs[@]}" 2>/dev/null || true
    fi
}

# =========================================
# 📦 Funktion: kde_purge_configs
# -----------------------------------------
# Zweck: Löscht KDE-spezifische Configs aus dem Home-Verzeichnis
# Aufgabe: Ermittelt den echten User und bereinigt .config, .local und .cache
# =========================================
kde_purge_configs() {
    [[ "$PURGE_CONFIGS" != "true" ]] && return 0
    echo -e "\n${STR_GUI_LOG_DEEP_CLEAN}"
    
    local target_user="${SUDO_USER:-$USER}"
    local target_home
    target_home=$(getent passwd "$target_user" | cut -d: -f6)

    if [[ -d "$target_home" ]]; then
        find "${target_home}/.config" -maxdepth 1 -name "plasma*" -exec rm -rf {} + 2>/dev/null || true
        find "${target_home}/.config" -maxdepth 1 -name "k*rc" -exec rm -rf {} + 2>/dev/null || true
        rm -f "${target_home}/.config/kdeglobals" 2>/dev/null || true
        rm -rf "${target_home}/.local/share/plasma" 2>/dev/null || true
        rm -rf "${target_home}/.cache/plasma" 2>/dev/null || true
    fi
}

# =========================================
# 📦 Funktion: remove_kde_setup
# -----------------------------------------
# Zweck: Haupt-Einsprungpunkt für die KDE-Deinstallation
# Aufgabe: Führt den sicheren Deinstallations-Ablauf durch
# =========================================
remove_kde_setup() {
    echo -e "\n${STR_GUI_KDE_RM_PHASE}\n"
    
    if [[ "${XDG_CURRENT_DESKTOP,,}" == *"kde"* ]]; then
        echo -e "${STR_GUI_ERR_GUI_RUNNING}" >&2
        return 1
    fi
    
    kde_ask_deep_clean
    kde_disable_services
    kde_remove_packages
    kde_purge_configs
    echo -e "\n${STR_GUI_OK_RM_KDE}"
}