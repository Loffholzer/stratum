#!/bin/bash
# ==============================================================================
# STRATUM - ARCH LINUX DEPLOYMENT FRAMEWORK
# Modul: Environment (Bootloader & Kernel)
# ==============================================================================

env_bootloader() {
    echo "[ PHASE ] Konfiguration: Bootloader (Limine v8+)"

    if [[ "${DRY_RUN:-true}" == true ]]; then
        echo "[ WARN ] Dry-Run aktiv. Bootloader-Setup übersprungen."
        return 0
    fi

    local root_uuid
    root_uuid=$(blkid -s UUID -o value "$PART_ROOT")
    local esp_mount
    esp_mount=$( [[ "$USE_LUKS" == "yes" ]] && echo "/mnt/boot" || echo "/mnt/boot/efi" )

    echo "[ INFO ] Installiere Bootloader-Pakete..."
    arch-chroot /mnt pacman -S --noconfirm limine memtest86+-efi >/dev/null

    echo "[ INFO ] Integriere Hardware-Diagnose (Memtest86+)..."
    cp /mnt/boot/memtest86+/memtest.efi "$esp_mount/memtest.efi"

    local splash_src="splash.jpg"
    local bg_config=""

    if [[ -f "$splash_src" ]]; then
        echo "[ INFO ] Splash-Screen gefunden. Wende Stratum-Theme an..."
        cp "$splash_src" "$esp_mount/splash.jpg"

        bg_config=$(cat <<EOF
term_background: boot():/splash.jpg
term_background_style: stretched
term_foreground: ${LIMINE_FG}
term_background: ${LIMINE_BG}
term_foreground_active: ${LIMINE_FG_ACTIVE}
term_background_active: ${LIMINE_BG_ACTIVE}
EOF
)
    else
        echo "[ INFO ] Kein splash.jpg gefunden. Verwende Standard-Theme."
    fi

    echo "[ INFO ] Generiere limine.conf..."
    local limine_conf="$esp_mount/limine.conf"

    if [[ "$USE_LUKS" == "yes" ]]; then
        cat <<EOF > "$limine_conf"
timeout: 3
remember_last_entry: yes
default_entry: 1

${bg_config}

/Arch Linux (Mainline)
    protocol: linux
    kernel_path: boot():/vmlinuz-linux
    module_path: boot():/initramfs-linux.img
    cmdline: cryptdevice=UUID=${root_uuid}:cryptroot root=/dev/mapper/cryptroot rootflags=subvol=@ rw quiet loglevel=3 udev.log_level=3

/Hardware Diagnose (Memtest86+)
    protocol: efi_chainload
    image_path: boot():/memtest.efi
EOF
    else
        cat <<EOF > "$limine_conf"
timeout: 3
remember_last_entry: yes
default_entry: 1

${bg_config}

/Arch Linux (Mainline)
    protocol: linux
    kernel_path: uuid(${root_uuid}):/@/boot/vmlinuz-linux
    module_path: uuid(${root_uuid}):/@/boot/initramfs-linux.img
    cmdline: root=UUID=${root_uuid} rootflags=subvol=@ rw quiet loglevel=3 udev.log_level=3

/Hardware Diagnose (Memtest86+)
    protocol: efi_chainload
    image_path: boot():/memtest.efi
EOF
    fi

    echo "[ INFO ] Schreibe UEFI-Bootfiles..."
    arch-chroot /mnt /bin/bash <<EOF
        esp_path=\$(findmnt -n -o TARGET /dev/disk/by-uuid/\$(blkid -s UUID -o value "$PART_EFI"))
        mkdir -p "\$esp_path/EFI/BOOT"
        cp /usr/share/limine/BOOTX64.EFI "\$esp_path/EFI/BOOT/"
        if command -v efibootmgr >/dev/null; then
            efibootmgr --create --disk "$DISK" --part 1 --loader /EFI/BOOT/BOOTX64.EFI --label "Stratum Boot" >/dev/null 2>&1 || true
        fi
EOF

    echo "[ OK ] Bootloader erfolgreich konfiguriert."
}
