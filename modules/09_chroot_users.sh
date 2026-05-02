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
    if [[ "$DISABLE_ROOT" == "yes" ]]; then
        log "$STR_LOG_ROOT_LOCK"
        arch-chroot /mnt passwd -l root >/dev/null
    else
        log "$STR_LOG_ROOT_PASS"
        arch-chroot /mnt /bin/bash <<EOF
echo "root:$USER_PASSWORD" | chpasswd
EOF
    fi

    local log_msg
    printf -v log_msg "$STR_LOG_USER_CREATE" "$USERNAME"
    log "$log_msg"

    arch-chroot /mnt /bin/bash <<EOF
useradd -m -G wheel -s /bin/bash "$USERNAME"
echo "$USERNAME:$USER_PASSWORD" | chpasswd
EOF

    log "$STR_LOG_SUDO_SETUP"
    arch-chroot /mnt pacman -S --noconfirm sudo >/dev/null
    arch-chroot /mnt sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
}

# =========================================
# 📦 Funktion: users_setup_shell_tools
# -----------------------------------------
# Zweck: UX-Stack und CLI-Tools installieren
# =========================================
users_setup_shell_tools() {
    if [[ "$INSTALL_SHELL" == "yes" ]]; then
        log "$STR_LOG_UX_INSTALL"
        arch-chroot /mnt pacman -S --noconfirm fish starship zoxide fastfetch >/dev/null
        
        # Fish-Template systemweit ablegen
        echo "$TPL_FISH_CONFIG" > /mnt/etc/fish/config.fish

        local log_msg
        printf -v log_msg "$STR_LOG_FISH_DEFAULT" "$USERNAME"
        log "$log_msg"
        arch-chroot /mnt chsh -s /usr/bin/fish "$USERNAME"
    fi

    if [[ "$INSTALL_TOOLS" == "yes" ]]; then
        log "$STR_LOG_TOOLS_INSTALL"
        arch-chroot /mnt pacman -S --noconfirm eza bat btop >/dev/null
    fi
}

# =========================================
# 📦 Funktion: users_setup_aur
# -----------------------------------------
# Zweck: Paru via temporärem Builduser bauen
# =========================================
users_setup_aur() {
    [[ "$INSTALL_AUR" != "yes" ]] && return 0

    log "$STR_LOG_AUR_TEMP_USER"
    arch-chroot /mnt /bin/bash <<EOF
useradd -m builduser
EOF
    echo "$TPL_SUDOERS_AUR_BUILD" > /mnt/etc/sudoers.d/builduser
    chmod 0440 /mnt/etc/sudoers.d/builduser
    
    log "$STR_LOG_AUR_BUILD"
    arch-chroot /mnt /bin/bash <<EOF
sudo -u builduser bash -c 'cd /home/builduser && git clone https://aur.archlinux.org/paru-bin.git && cd paru-bin && makepkg -si --noconfirm'
EOF

    log "$STR_LOG_AUR_CLEANUP"
    rm -f /mnt/etc/sudoers.d/builduser
    arch-chroot /mnt /bin/bash <<EOF
userdel -r builduser 2>/dev/null
EOF
}

# =========================================
# 📦 Funktion: users_setup_extras
# -----------------------------------------
# Zweck: Nano, SSH und Handoff-Skript
# =========================================
users_setup_extras() {
    if [[ "$INSTALL_EDITOR" == "yes" ]]; then
        log "$STR_LOG_NANO_CONFIG"
        echo "$TPL_NANO_CONFIG" > /mnt/etc/nanorc
    fi

    if [[ "$INSTALL_SSH" == "yes" ]]; then
        log "$STR_LOG_SSH_INSTALL"
        arch-chroot /mnt pacman -S --noconfirm openssh >/dev/null
        arch-chroot /mnt systemctl enable sshd >/dev/null
    fi

    local log_msg
    printf -v log_msg "$STR_LOG_DESKTOP_HANDOFF" "$USERNAME"
    log "$log_msg"
    
    local handoff_path="/mnt/home/$USERNAME/desktop_setup.sh"
    echo "$TPL_DESKTOP_HANDOFF" > "$handoff_path"
    chmod +x "$handoff_path"
    arch-chroot /mnt chown "$USERNAME:$USERNAME" "/home/$USERNAME/desktop_setup.sh"
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