#!/usr/bin/env bash

# =========================================
# 📦 Funktion: Globaler Header / Info
# -----------------------------------------
# Zweck: Chroot-Konfiguration & Bootloader (06_chroot_env.sh)
# Aufgabe: Zeit, Locales, Hostname, Initramfs und Limine einrichten
# =========================================

# =========================================
# 📦 Funktion: env_chroot_basics
# -----------------------------------------
# Zweck: Grundkonfiguration des Zielsystems
# Aufgabe: Setzt Timezone, HW-Clock, Locales, vconsole und Hostname
# =========================================
env_chroot_basics() {
    phase_header "Chroot: Basics konfigurieren"

    if [[ "${DRY_RUN:-true}" == true ]]; then
        warn "[DRY-RUN] Chroot-Basis-Setup übersprungen."
        return 0
    fi

    log "Setze Timezone ($TIMEZONE) und Locales..."

    # Variablen-Expansion findet vor dem Chroot-Sprung statt
    arch-chroot /mnt /bin/bash <<EOF
        # 1. Timezone
        ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
        hwclock --systohc

        # 2. Locales
        sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
        if [[ "$LANG_DEFAULT" != "en_US.UTF-8" ]]; then
            sed -i "s/^#\($LANG_DEFAULT UTF-8\)/\1/" /etc/locale.gen
        fi
        locale-gen >/dev/null
        echo "LANG=$LANG_DEFAULT" > /etc/locale.conf

        # 3. vconsole (TTY-Layout & Font)
        echo "KEYMAP=$KEYMAP" > /etc/vconsole.conf
        echo "FONT=$CONSOLE_FONT" >> /etc/vconsole.conf

        # 4. Hostname
        echo "$HOSTNAME" > /etc/hostname

        # 5. Hosts-Datei
        cat <<HOSTS > /etc/hosts
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
HOSTS
EOF

    success "Basiskonfiguration im Zielsystem abgeschlossen."
}

# =========================================
# 📦 Funktion: env_initramfs
# -----------------------------------------
# Zweck: Kernel-Images für den Boot generieren
# Aufgabe: Schreibt Hook-Reihenfolge (inkl. LUKS) in mkinitcpio.conf
# =========================================
env_initramfs() {
    phase_header "Chroot: Initramfs (mkinitcpio)"

    if [[ "${DRY_RUN:-true}" == true ]]; then
        warn "[DRY-RUN] mkinitcpio-Konfiguration übersprungen."
        return 0
    fi

    local hooks="base udev autodetect microcode modconf kms keyboard keymap consolefont block"

    if [[ "$USE_LUKS" == "yes" ]]; then
        log "LUKS-Profil: Füge 'encrypt' Hook nach 'block' hinzu."
        hooks="$hooks encrypt"
    fi

    hooks="$hooks filesystems fsck"
    log "Definierte Hooks: $hooks"

    arch-chroot /mnt /bin/bash <<EOF
        sed -i "s/^HOOKS=(.*/HOOKS=($hooks)/" /etc/mkinitcpio.conf
        mkinitcpio -P >/dev/null
EOF

    success "Initramfs Images erfolgreich generiert."
}

# =========================================
# 📦 Funktion: env_bootloader
# -----------------------------------------
# Zweck: Limine Bootloader Setup
# Aufgabe: Limine installieren, Config dynamisch bauen und EFI-Eintrag setzen
# =========================================
env_bootloader() {
    phase_header "Chroot: Limine Bootloader"

    if [[ "${DRY_RUN:-true}" == true ]]; then
        warn "[DRY-RUN] Limine-Setup übersprungen."
        return 0
    fi

    local root_uuid
    root_uuid=$(blkid -s UUID -o value "$PART_ROOT")

    log "Installiere Limine und efibootmgr..."
    arch-chroot /mnt pacman -S --noconfirm limine efibootmgr >/dev/null

    log "Generiere limine.conf (Limine v8+ Syntax)..."
    local limine_conf
    
    if [[ "$USE_LUKS" == "yes" ]]; then
        # LUKS: ESP liegt unter /boot, Kernel ist unverschlüsselt
        limine_conf="/mnt/boot/limine.conf"
        cat <<EOF > "$limine_conf"
timeout: 3
remember_last_entry: yes
default_entry: 1

/Arch Linux (Mainline)
    protocol: linux
    kernel_path: boot():/vmlinuz-linux
    module_path: boot():/initramfs-linux.img
    cmdline: cryptdevice=UUID=${root_uuid}:cryptroot root=/dev/mapper/cryptroot rootflags=subvol=@ rw quiet loglevel=3 udev.log_level=3

/Arch Linux (LTS)
    protocol: linux
    kernel_path: boot():/vmlinuz-linux-lts
    module_path: boot():/initramfs-linux-lts.img
    cmdline: cryptdevice=UUID=${root_uuid}:cryptroot root=/dev/mapper/cryptroot rootflags=subvol=@ rw quiet loglevel=3 udev.log_level=3
EOF
    else
        # Standard: ESP liegt unter /boot/efi, Kernel liegt auf BTRFS
        limine_conf="/mnt/boot/efi/limine.conf"
        cat <<EOF > "$limine_conf"
timeout: 3
remember_last_entry: yes
default_entry: 1

/Arch Linux (Mainline)
    protocol: linux
    kernel_path: uuid(${root_uuid}):/@/boot/vmlinuz-linux
    module_path: uuid(${root_uuid}):/@/boot/initramfs-linux.img
    cmdline: root=UUID=${root_uuid} rootflags=subvol=@ rw quiet splash

/Arch Linux (LTS)
    protocol: linux
    kernel_path: uuid(${root_uuid}):/@/boot/vmlinuz-linux-lts
    module_path: uuid(${root_uuid}):/@/boot/initramfs-linux-lts.img
    cmdline: root=UUID=${root_uuid} rootflags=subvol=@ rw quiet splash
EOF
    fi

    log "Kopiere UEFI-Bootfiles und erstelle NVRAM-Eintrag..."
    # Flucht-Zeichen (\) für Variablen, die erst im chroot evaluiert werden sollen
    arch-chroot /mnt /bin/bash <<EOF
        esp_path=\$(findmnt -n -o TARGET /dev/disk/by-uuid/\$(blkid -s UUID -o value "$PART_EFI"))
        
        mkdir -p "\$esp_path/EFI/BOOT"
        cp /usr/share/limine/BOOTX64.EFI "\$esp_path/EFI/BOOT/"

        efibootmgr --create --disk "$DISK" --part 1 --loader /EFI/BOOT/BOOTX64.EFI --label "Arch Linux (Limine)" >/dev/null 2>&1 || true
EOF

    success "Limine Bootloader erfolgreich installiert."
}

# =========================================
# 📦 Funktion: run_chroot_env
# -----------------------------------------
# Zweck: Sequenzielle Ausführung
# Aufgabe: Führt Basiskonfiguration und Bootloader-Setup aus
# =========================================
run_chroot_env() {
    header "Phase 6: Zielsystem-Umgebung"

    env_chroot_basics
    env_initramfs
    env_bootloader
}
