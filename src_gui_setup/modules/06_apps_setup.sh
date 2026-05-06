#!/usr/bin/env bash

# =========================================
# 📄 DATEI: 06_apps_setup.sh
# 💡 ZWECK: Installation optionaler Zusatzanwendungen
# =========================================

# =========================================
# 📦 Funktion: check_gui_present
# -----------------------------------------
# Zweck: Verhindert die Installation von GUI-Apps auf Headless-Systemen
# =========================================
check_gui_present() {
    if ! pacman -Qq plasma-desktop cosmic-session gnome-shell xfce4-session >/dev/null 2>&1; then
        echo -e "\n${STR_GUI_ERR_NO_GUI}" >&2
        sleep 3
        return 1
    fi
    return 0
}

# =========================================
# 📦 Funktion: install_libreoffice
# -----------------------------------------
# Zweck: Installiert LibreOffice inkl. passendem Sprachpaket
# Aufgabe: Liest die Locale, validiert das Sprachpaket und nutzt pacman
# =========================================
install_libreoffice() {
    check_gui_present || return 1

    echo -e "\n${STR_GUI_LOG_APPS_LO}"
    
    local sys_lang
    local lang_code
    local target_pkgs=("${LIBREOFFICE_PKGS[@]}")

    # Lokale auslesen
    if [[ -f /etc/locale.conf ]]; then
        sys_lang=$(source /etc/locale.conf 2>/dev/null && echo "$LANG")
    else
        sys_lang="${LANG:-de_DE.UTF-8}"
    fi

    lang_code="${sys_lang%%_*}"
    if [[ -n "$lang_code" ]]; then
        local lo_lang_pkg="libreoffice-still-${lang_code}"
        if pacman -Sp "$lo_lang_pkg" >/dev/null 2>&1; then
            echo -e "  -> ${STR_GUI_LOG_LANG_PKG_FOUND}: ${lo_lang_pkg}"
            target_pkgs+=("$lo_lang_pkg")
        fi
    fi

    pacman -S --needed --noconfirm "${target_pkgs[@]}" || true
}

# =========================================
# 📦 Funktion: install_flatpak
# -----------------------------------------
# Zweck: Installiert Flatpak und Flathub Repo
# =========================================
install_flatpak() {
    check_gui_present || return 1

    echo -e "\n${STR_GUI_LOG_APPS_FLATPAK}"
    pacman -S --needed --noconfirm "${FLATPAK_PKGS[@]}" || true
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
}

# =========================================
# 📦 Funktion: install_kvm
# -----------------------------------------
# Zweck: Installiert Virtualisierung (QEMU/KVM/Virt-Manager)
# =========================================
install_kvm() {
    check_gui_present || return 1

    echo -e "\n${STR_GUI_LOG_APPS_KVM}"
    pacman -S --needed --noconfirm "${KVM_PKGS[@]}" || true
    
    systemctl enable libvirtd.service 2>/dev/null || true
    systemctl start libvirtd.service 2>/dev/null || true
    
    usermod -aG libvirt "${SUDO_USER:-$USER}" 2>/dev/null || true
}