#!/usr/bin/env bash

# =========================================
# 📄 DATEI: 09_chroot_users.sh
# 💡 ZWECK: Benutzer, Sudo, Shell & AUR
# =========================================

# =========================================
# 📦 Funktion: users_setup_accounts
# -----------------------------------------
# Zweck: Root und Standard-Benutzer anlegen
# =========================================
users_setup_accounts() {
    log "$STR_LOG_ROOT_LOCK"
    # Root entsperren, Passwort setzen (für sudo -i), dann sperren
    arch-chroot /mnt /bin/bash <<EOF
passwd -u root >/dev/null 2>&1
echo "root:$USER_PASSWORD" | chpasswd
passwd -l root >/dev/null 2>&1
EOF

    local log_msg
    printf -v log_msg "$STR_LOG_USER_CREATE" "$USERNAME"
    log "$log_msg"

    arch-chroot /mnt /bin/bash <<EOF
useradd -m -G wheel -s /bin/bash "$USERNAME"
echo "$USERNAME:$USER_PASSWORD" | chpasswd
EOF

    log "$STR_LOG_SUDO_SETUP"
    arch-chroot /mnt pacman -S --needed --noconfirm sudo >/dev/null 2>&1
    # Wheel-Gruppe in sudoers freischalten
    arch-chroot /mnt sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
}

# =========================================
# 📦 Funktion: users_setup_shell_tools
# -----------------------------------------
# Zweck: UX-Stack global konfigurieren (für Root & User)
# =========================================
users_setup_shell_tools() {
    log "$STR_LOG_UX_INSTALL"
    arch-chroot /mnt pacman -S --needed --noconfirm fish starship zoxide fastfetch >/dev/null
    
    # UX global konfigurieren (Root erbt dies)
    log "$STR_LOG_ROOT_UX"
    mkdir -p /mnt/etc/fish
    echo "$TPL_FISH_CONFIG_ETC" > /mnt/etc/fish/config.fish
    echo "$TPL_STARSHIP_CONFIG_ETC" > /mnt/etc/starship.toml
    # Snippet für sudo -i
    mkdir -p /mnt/etc/fish/conf.d
    echo "$TPL_FISH_UX_ROOT" > /mnt/etc/fish/conf.d/UX_root_glob.fish

    local log_msg
    printf -v log_msg "$STR_LOG_FISH_DEFAULT" "Root & $USERNAME"
    log "$log_msg"
    
    # Root-Shell auf Fish ändern
    arch-chroot /mnt usermod -s /usr/bin/fish root >/dev/null 2>&1
    # User-Shell auf Fish ändern
    arch-chroot /mnt chsh -s /usr/bin/fish "$USERNAME" >/dev/null 2>&1

    log "$STR_LOG_TOOLS_INSTALL"
    arch-chroot /mnt pacman -S --needed --noconfirm eza bat btop >/dev/null
}

# =========================================
# 📦 Funktion: users_setup_aur
# -----------------------------------------
# Zweck: Paru via Source bauen (Fix für libalpm Fehler)
# =========================================
users_setup_aur() {
    log "$STR_LOG_AUR_TEMP_USER"
    arch-chroot /mnt /bin/bash <<EOF
useradd -m builduser
EOF
    echo "$TPL_SUDOERS_AUR_BUILD" > /mnt/etc/sudoers.d/builduser
    chmod 0440 /mnt/etc/sudoers.d/builduser
    
    log "$STR_LOG_AUR_BUILD"
    # FIX: Wechsel von paru-bin auf paru (Source build)
    arch-chroot /mnt /bin/bash <<EOF
sudo -u builduser bash -c 'cd /home/builduser && git clone https://aur.archlinux.org/paru.git && cd paru && makepkg -si --noconfirm'
EOF

    local log_msg
    printf -v log_msg "$STR_LOG_PARU_CONFIG" "$USERNAME"
    log "$log_msg"
    
    mkdir -p "/mnt/home/$USERNAME/.config/paru"
    echo "$TPL_PARU_CONF" > "/mnt/home/$USERNAME/.config/paru/paru.conf"
    arch-chroot /mnt chown -R "$USERNAME:$USERNAME" "/home/$USERNAME/.config/paru"

    log "$STR_LOG_AUR_CLEANUP"
    rm -f /mnt/etc/sudoers.d/builduser
    arch-chroot /mnt /bin/bash <<EOF
userdel -r builduser 2>/dev/null
EOF
}

# =========================================
# 📦 Funktion: users_setup_extras
# -----------------------------------------
# Zweck: Nano, SSH, Fonts, XDG, Assets & GUI-Handoff
# =========================================
users_setup_extras() {
    # 1. Nano Config
    log "$STR_LOG_MICRO_CONFIG"
    echo "$TPL_MICRO_ENV" > /mnt/etc/profile.d/micro.sh

    # 2. SSH Setup
    log "$STR_LOG_SSH_INSTALL"
    arch-chroot /mnt pacman -S --needed --noconfirm openssh >/dev/null
    arch-chroot /mnt systemctl enable sshd >/dev/null

    # 3. Basis-Schriften und XDG-Ordner
    log "$STR_LOG_FONTS_XDG"
    arch-chroot /mnt pacman -S --needed --noconfirm noto-fonts noto-fonts-emoji ttf-liberation xdg-user-dirs >/dev/null

    # 4. Setup-Ordner im Home erstellen
    local target_setup="/mnt/home/$USERNAME/setup"
    mkdir -p "$target_setup"

    # 5. Asset-Transfer & Renaming (aus src_gui_setup)
    log "$STR_LOG_COPY_ASSETS"
    if [ -d "$BASE_DIR/src_gui_setup" ]; then
        # Kopiert den kompletten Inhalt (inkl. des neuen modules/ Ordners)
        cp -r "$BASE_DIR/src_gui_setup/"* "$target_setup/" 2>/dev/null || true
        
        # Die Dummy-Datei im Ziel umbenennen zu install.sh
        if [ -f "$target_setup/setup_entrypoint.sh" ]; then
            mv "$target_setup/setup_entrypoint.sh" "$target_setup/install.sh"
        fi
    fi

    # 6. Fish-Login-Hook erstellen (Handoff)
    local user_home="/mnt/home/$USERNAME"
    mkdir -p "$user_home/.config/fish/conf.d"
    echo "$TPL_FISH_HANDOFF" > "$user_home/.config/fish/conf.d/handoff.fish"
    
    # 7. Setup-Flag setzen
    touch "$user_home/.config/setup_active"

    # 8. Rechte korrigieren & Skript ausführbar machen
    arch-chroot /mnt chown -R "$USERNAME:$USERNAME" "/home/$USERNAME"
    if [ -f "$target_setup/install.sh" ]; then
        chmod +x "$target_setup/install.sh"
    fi
}

# =========================================
# 📦 Funktion: run_chroot_users
# -----------------------------------------
# Zweck: Einstiegspunkt Modul 09
# =========================================
run_chroot_users() {
    header "$STR_USR_PHASE_HEADER"

    if [[ "${DRY_RUN:-true}" == true ]]; then
        warn "$STR_WARN_DRY_USERS"
        return 0
    fi

    users_setup_accounts
    users_setup_shell_tools
    users_setup_aur
    users_setup_extras

    success "$STR_OK_USERS_DONE"
}