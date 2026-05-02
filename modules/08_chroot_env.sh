#!/usr/bin/env bash

# =========================================
# 📄 DATEI: 08_chroot_env.sh
# 💡 ZWECK: System-Umgebung & Bootloader
# =========================================

# =========================================
# 📦 Funktion: env_chroot_basics
# -----------------------------------------
# Zweck: Basics (Zeit, Locale, Netz, Pacman)
# =========================================
env_chroot_basics() {
    phase_header "$STR_ENV_HDR_BASICS"
    if [[ "${DRY_RUN:-true}" == true ]]; then
        warn "$STR_WARN_DRY_BASICS"
        return 0
    fi

    local log_msg
    printf -v log_msg "$STR_LOG_TZ_LOCALE" "$TIMEZONE"
    log "$log_msg"

    log "$STR_LOG_PACMAN_TARGET"

    # Vorbereiten des Hosts-Inhalts
    local final_hosts
    final_hosts=$(echo "$TPL_HOSTS" | sed "s/{{HOSTNAME}}/$HOSTNAME/g")

arch-chroot /mnt /bin/bash <<EOF
    ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
    hwclock --systohc
    
    # Locales generieren
    sed -i "s/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/" /etc/locale.gen
    if [[ "$LANG_DEFAULT" != "en_US.UTF-8" ]]; then
        sed -i "s/^#\($LANG_DEFAULT UTF-8\)/\1/" /etc/locale.gen
    fi
    locale-gen >/dev/null
    
    # Configs schreiben
    echo "LANG=$LANG_DEFAULT" > /etc/locale.conf
    echo "KEYMAP=$KEYMAP" > /etc/vconsole.conf
    echo "FONT=$CONSOLE_FONT" >> /etc/vconsole.conf
    echo "$HOSTNAME" > /etc/hostname
    echo "$final_hosts" > /etc/hosts

    # Pacman konfigurieren (Color & ILoveCandy)
    sed -i 's/^#Para/Para/' /etc/pacman.conf
    sed -i 's/^#Color/Color\nILoveCandy/' /etc/pacman.conf
EOF

    success "$STR_OK_BASICS_DONE"
}

# =========================================
# 📦 Funktion: env_initramfs
# -----------------------------------------
# Zweck: Kernel-Images bauen
# =========================================
env_initramfs() {
    phase_header "$STR_ENV_HDR_INITRAMFS"
    if [[ "${DRY_RUN:-true}" == true ]]; then
        warn "$STR_WARN_DRY_INITRAMFS"
        return 0
    fi

    local hooks="base udev autodetect microcode modconf kms keyboard keymap consolefont block"
    if [[ "$USE_LUKS" == "yes" ]]; then
        log "$STR_LOG_HOOK_LUKS"
        hooks="$hooks encrypt"
    fi
    hooks="$hooks filesystems fsck"
    
    local log_msg
    printf -v log_msg "$STR_LOG_HOOKS_DEF" "$hooks"
    log "$log_msg"

arch-chroot /mnt /bin/bash <<EOF
    sed -i "s/^HOOKS=(.*/HOOKS=($hooks)/" /etc/mkinitcpio.conf
    mkinitcpio -P >/dev/null
EOF

    success "$STR_OK_INITRAMFS_DONE"
}

# =========================================
# 📦 Funktion: env_bootloader
# -----------------------------------------
# Zweck: Limine Installation
# =========================================
env_bootloader() {
    phase_header "$STR_ENV_HDR_BOOTLOADER"
    if [[ "${DRY_RUN:-true}" == true ]]; then
        warn "$STR_WARN_DRY_BOOTLOADER"
        return 0
    fi

    log "$STR_LOG_INSTALL_LIMINE"
    arch-chroot /mnt pacman -S --noconfirm limine efibootmgr >/dev/null

    log "$STR_LOG_GEN_LIMINE_CONF"
    local root_uuid
    root_uuid=$(blkid -s UUID -o value "$PART_ROOT")

    if [[ "$USE_LUKS" == "yes" ]]; then
        echo "$TPL_LIMINE_LUKS" | sed "s/{{ROOT_UUID}}/$root_uuid/g" > /mnt/boot/limine.conf
    else
        echo "$TPL_LIMINE_STD" | sed "s/{{ROOT_UUID}}/$root_uuid/g" > /mnt/boot/efi/limine.conf
    fi

    log "$STR_LOG_EFI_ENTRY"
    
arch-chroot /mnt /bin/bash <<EOF
    esp_uuid=\$(blkid -s UUID -o value "$PART_EFI")
    esp_path=\$(findmnt -n -o TARGET /dev/disk/by-uuid/\$esp_uuid)
    mkdir -p "\$esp_path/EFI/BOOT"
    cp /usr/share/limine/BOOTX64.EFI "\$esp_path/EFI/BOOT/"
    efibootmgr --create --disk "$DISK" --part 1 --loader /EFI/BOOT/BOOTX64.EFI --label "$STR_LBL_BOOT_LABEL" >/dev/null 2>&1 || true
EOF

    success "$STR_OK_BOOTLOADER_DONE"
}

# =========================================
# 📦 Funktion: run_chroot_env
# -----------------------------------------
# Zweck: Einstiegspunkt Modul 08
# =========================================
run_chroot_env() {
    header "$STR_ENV_PHASE_HEADER"
    env_chroot_basics
    env_initramfs
    env_bootloader
}
