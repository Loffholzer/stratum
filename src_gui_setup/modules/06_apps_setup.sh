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

# =========================================
# 📦 Funktion: install_docker
# -----------------------------------------
# Zweck: Installiert Docker und Docker Compose
# Aufgabe: Installiert Pakete, aktiviert Dienst und fügt User zur Gruppe hinzu
# =========================================
install_docker() {
    check_gui_present || return 1

    echo -e "\n${STR_GUI_LOG_APPS_DOCKER:-${STR_GUI_INFO_PREFIX} Installiere Docker und Docker Compose...}"
    pacman -S --needed --noconfirm "${DOCKER_PKGS[@]}" || true
    
    systemctl enable docker.service 2>/dev/null || true
    
    usermod -aG docker "${SUDO_USER:-$USER}" 2>/dev/null || true
}

# =========================================
# 📦 Funktion: install_haruna
# =========================================
install_haruna() {
    check_gui_present || return 1
    echo -e "\n${STR_GUI_INFO_PREFIX} Installiere Haruna Media Player..."
    pacman -S --needed --noconfirm "${HARUNA_PKGS[@]}" || true
}

# =========================================
# 📦 Funktion: install_discord
# =========================================
install_discord() {
    check_gui_present || return 1
    echo -e "\n${STR_GUI_INFO_PREFIX} Installiere Discord..."
    pacman -S --needed --noconfirm "${DISCORD_PKGS[@]}" || true
}

# =========================================
# 📦 Funktion: install_gimp
# =========================================
install_gimp() {
    check_gui_present || return 1
    echo -e "\n${STR_GUI_INFO_PREFIX} Installiere GIMP..."
    pacman -S --needed --noconfirm "${GIMP_PKGS[@]}" || true
}

# =========================================
# 📦 Funktion: install_obs
# =========================================
install_obs() {
    check_gui_present || return 1
    echo -e "\n${STR_GUI_INFO_PREFIX} Installiere OBS Studio..."
    pacman -S --needed --noconfirm "${OBS_PKGS[@]}" || true
}

# =========================================
# 📦 Funktion: install_codium
# =========================================
install_codium() {
    check_gui_present || return 1
    echo -e "\n${STR_GUI_INFO_PREFIX} Installiere VSCodium..."
    pacman -S --needed --noconfirm "${CODIUM_PKGS[@]}" || true
}

# =========================================
# 📦 Funktion: install_remmina
# =========================================
install_remmina() {
    check_gui_present || return 1
    echo -e "\n${STR_GUI_INFO_PREFIX} Installiere Remmina..."
    pacman -S --needed --noconfirm "${REMMINA_PKGS[@]}" || true
}

# =========================================
# 📦 Funktion: install_filezilla
# =========================================
install_filezilla() {
    check_gui_present || return 1
    echo -e "\n${STR_GUI_INFO_PREFIX} Installiere FileZilla..."
    pacman -S --needed --noconfirm "${FILEZILLA_PKGS[@]}" || true
}

# =========================================
# 📦 Funktion: install_nextcloud
# =========================================
install_nextcloud() {
    check_gui_present || return 1
    echo -e "\n${STR_GUI_INFO_PREFIX} Installiere Nextcloud Client..."
    pacman -S --needed --noconfirm "${NEXTCLOUD_PKGS[@]}" || true
}