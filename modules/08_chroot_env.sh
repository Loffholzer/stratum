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

    # Hooks in die Konfiguration schreiben
    arch-chroot /mnt sed -i "s/^HOOKS=(.*/HOOKS=($hooks)/" /etc/mkinitcpio.conf
    # Kernel-Images bauen und Warnungen mit run_cmd abfangen
    run_cmd arch-chroot /mnt mkinitcpio -P

    success "$STR_OK_INITRAMFS_DONE"
}

# =========================================
# 📦 Funktion: env_bootloader
# -----------------------------------------
# Zweck: Limine Installation & Splash-Screen
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
        # Bild kopieren
        [[ -f "$BASE_DIR/splash.jpg" ]] && cp "$BASE_DIR/splash.jpg" /mnt/boot/splash.jpg
    else
        mkdir -p /mnt/boot/efi
        echo "$TPL_LIMINE_STD" | sed "s/{{ROOT_UUID}}/$root_uuid/g" > /mnt/boot/efi/limine.conf
        # Bild kopieren
        [[ -f "$BASE_DIR/splash.jpg" ]] && cp "$BASE_DIR/splash.jpg" /mnt/boot/efi/splash.jpg
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
# 📦 Funktion: env_hardware_and_locale
# -----------------------------------------
# Zweck: GPU, Batterie, Manpages & Spellcheck dynamisch laden
# =========================================
env_hardware_and_locale() {
    phase_header "$STR_ENV_HDR_HW_LOCALE"

    # 1. Locale auslesen und Pakete ermitteln
    local lang_code
    lang_code=$(grep "^LANG=" /mnt/etc/locale.conf | cut -d= -f2 | cut -d_ -f1)
    local loc_pkgs="man-db man-pages"
    
    local log_msg
    printf -v log_msg "$STR_LOG_LANG_CHECK" "$lang_code"
    log "$log_msg"
    
    if arch-chroot /mnt pacman -Sp "man-pages-$lang_code" >/dev/null 2>&1; then
        loc_pkgs+=" man-pages-$lang_code"
    fi
    if arch-chroot /mnt pacman -Sp "hunspell-$lang_code" >/dev/null 2>&1; then
        loc_pkgs+=" hunspell hunspell-$lang_code"
    fi

    # 2. Multilib Status prüfen
    local is_multilib=false
    grep -q "^\[multilib\]" /mnt/etc/pacman.conf && is_multilib=true

    # 3. GPU erkennen
    local gpu_pkgs=""
    local vga_info
    vga_info=$(lspci | grep -i vga)
    
    if echo "$vga_info" | grep -iq "nvidia"; then
        warn "$STR_WARN_GPU_NVIDIA"
        gpu_pkgs="nvidia-dkms nvidia-utils linux-headers"
        $is_multilib && gpu_pkgs+=" lib32-nvidia-utils"
    elif echo "$vga_info" | grep -iq "amd\|radeon"; then
        log "$STR_LOG_GPU_AMD"
        gpu_pkgs="mesa xf86-video-amdgpu vulkan-radeon"
        $is_multilib && gpu_pkgs+=" lib32-mesa lib32-vulkan-radeon"
    elif echo "$vga_info" | grep -iq "intel"; then
        log "$STR_LOG_GPU_INTEL"
        gpu_pkgs="mesa vulkan-intel"
        $is_multilib && gpu_pkgs+=" lib32-mesa lib32-vulkan-intel"
    fi

    # 4. Batterie erkennen
    if ls /sys/class/power_supply/BAT* >/dev/null 2>&1; then
        log "$STR_LOG_BATTERY"
        gpu_pkgs+=" power-profiles-daemon"
    fi

    # Alles in einem Rutsch installieren
    log "$STR_LOG_INSTALL_HW_LOCALE"
    arch-chroot /mnt pacman -S --noconfirm $loc_pkgs $gpu_pkgs >/dev/null
    
    success "$STR_OK_HW_LOCALE"
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
    env_hardware_and_locale
}
