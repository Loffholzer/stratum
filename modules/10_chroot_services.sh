#!/usr/bin/env bash

# =========================================
# 📄 DATEI: chroot_services.sh
# 💡 ZWECK: Systemdienste, BTRFS-Wartung & CachyOS Snapshots
# =========================================

# =========================================
# 📦 Funktion: services_setup
# -----------------------------------------
# Zweck: Aktiviert alle nötigen Systemdienste
# =========================================
services_setup() {
    log "$STR_LOG_NM_ENABLE"
    log "$STR_LOG_BTRFS_SERVICES"
    
    # Gebündelte Ausführung der systemd-Befehle im chroot
arch-chroot /mnt /bin/bash <<EOF
    systemctl enable NetworkManager >/dev/null 2>&1
    systemctl enable fstrim.timer >/dev/null 2>&1
    systemctl enable btrfs-scrub@-.timer >/dev/null 2>&1 || true
EOF
}

# =========================================
# 📦 Funktion: snapper_setup
# -----------------------------------------
# Zweck: Installiert Snapper & Sofort-Update-Hook
# =========================================
snapper_setup() {
    log "$STR_LOG_SNAPPER_SETUP"
    
arch-chroot /mnt /bin/bash <<EOF
    pacman -S --noconfirm snapper >/dev/null 2>&1
EOF

    local conf_dir="/mnt/etc/snapper/configs"
    mkdir -p "$conf_dir"
    echo "$TPL_SNAPPER_ROOT" > "$conf_dir/root"
    
    mkdir -p /mnt/etc/conf.d
    echo "SNAPPER_CONFIGS=\"root\"" > "/mnt/etc/conf.d/snapper"

arch-chroot /mnt /bin/bash <<EOF
    systemctl enable snapper-timeline.timer snapper-cleanup.timer >/dev/null 2>&1
EOF

    # Hooks schreiben
    local hook_dir="/mnt/etc/pacman.d/hooks"
    mkdir -p "$hook_dir"
    echo "$TPL_PACMAN_SNAPPER" > "$hook_dir/50-snapper.hook"
    # NEU: Hook für sofortigen Limine Sync
    echo "$TPL_PACMAN_LIMINE_SYNC" > "$hook_dir/99-limine-snapshots.hook"

    log "$STR_LOG_SNAPPER_UPDATE"
    local root_uuid esp_uuid crypt_root_uuid=""
    root_uuid=$(blkid -s UUID -o value "$PART_ROOT")
    esp_uuid=$(blkid -s UUID -o value "$PART_EFI")
    [[ "$USE_LUKS" == "yes" ]] && crypt_root_uuid="$root_uuid"

    echo "$TPL_SNAPPER_UPDATE_SCRIPT" | sed "s/{{BOOT_PART_UUID}}/$esp_uuid/g" \
                                      | sed "s/{{ROOT_UUID}}/$root_uuid/g" \
                                      | sed "s/{{CRYPTROOT_UUID}}/$crypt_root_uuid/g" \
                                      > /mnt/usr/local/bin/limine-update-snapshots.sh
    chmod +x /mnt/usr/local/bin/limine-update-snapshots.sh

    echo "$TPL_SNAPPER_UPDATE_SERVICE" > /mnt/etc/systemd/system/limine-update-snapshots.service
    echo "$TPL_SNAPPER_UPDATE_TIMER" > /mnt/etc/systemd/system/limine-update-snapshots.timer

arch-chroot /mnt /bin/bash <<EOF
    systemctl enable limine-update-snapshots.timer >/dev/null 2>&1
EOF
}

# =========================================
# 📦 Funktion: services_setup_advanced
# -----------------------------------------
# Zweck: Firewalld, mDNS & Power Management
# =========================================
services_setup_advanced() {
    log "Installiere Firewall und mDNS (Avahi)..."
    arch-chroot /mnt pacman -S --noconfirm avahi nss-mdns firewalld >/dev/null
    
    log "Konfiguriere mDNS in nsswitch.conf..."
    # Fügt mdns_minimal sicher in die Arch-Standard-Zeile ein
    arch-chroot /mnt sed -i 's/mymachines resolve/mymachines mdns_minimal [NOTFOUND=return] resolve/' /etc/nsswitch.conf

    log "Setze Firewalld Standard-Zone auf 'home'..."
    arch-chroot /mnt firewall-offline-cmd --set-default-zone=home >/dev/null 2>&1

    log "Aktiviere Systemd-Dienste..."
arch-chroot /mnt /bin/bash <<EOF
    systemctl enable avahi-daemon.service >/dev/null 2>&1
    systemctl enable firewalld.service >/dev/null 2>&1
    
    # Prüfen, ob PPD in der Hardware-Phase (wegen Batterie) installiert wurde
    if pacman -Qs power-profiles-daemon >/dev/null 2>&1; then
        systemctl enable power-profiles-daemon.service >/dev/null 2>&1
    fi
EOF
    
    success "Erweiterte Netzwerkdienste konfiguriert."
}

# =========================================
# 📦 Funktion: run_chroot_services
# -----------------------------------------
# Zweck: Einstiegspunkt Modul 10
# =========================================
run_chroot_services() {
    phase_header "$STR_SRV_PHASE_HEADER"

    if [[ "${DRY_RUN:-true}" == true ]]; then
        warn "$STR_WARN_DRY_SERVICES"
        return 0
    fi

    services_setup
    snapper_setup
    services_setup_advanced

    success "$STR_OK_SERVICES_DONE"
}
