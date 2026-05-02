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
# Zweck: Installiert Snapper, Hook und Snapshot-Update-Dienst
# =========================================
snapper_setup() {
    log "$STR_LOG_SNAPPER_SETUP"
    
    # Snapper installieren
arch-chroot /mnt /bin/bash <<EOF
    pacman -S --noconfirm snapper >/dev/null 2>&1
EOF

    # Manuelles Setup der Snapper-Konfiguration, da DBus im chroot nicht läuft
    local conf_dir="/mnt/etc/snapper/configs"
    mkdir -p "$conf_dir"
    echo "$TPL_SNAPPER_ROOT" > "$conf_dir/root"
    
    # Snapper muss wissen, welche Configs existieren
    local sysconfig="/mnt/etc/conf.d/snapper"
    mkdir -p /mnt/etc/conf.d
    echo "SNAPPER_CONFIGS=\"root\"" > "$sysconfig"

arch-chroot /mnt /bin/bash <<EOF
    # Timers aktivieren
    systemctl enable snapper-timeline.timer snapper-cleanup.timer >/dev/null 2>&1
EOF

    # Pacman Hook aus dem Template schreiben
    local hook_dir="/mnt/etc/pacman.d/hooks"
    mkdir -p "$hook_dir"
    echo "$TPL_PACMAN_SNAPPER" > "$hook_dir/50-snapper.hook"

    # Snapshot-Update Skript und Dienste (CachyOS Style)
    log "$STR_LOG_SNAPPER_UPDATE"

    # PART_ROOT und PART_EFI kommen aus Modul 06
    local root_uuid esp_uuid crypt_root_uuid=""
    root_uuid=$(blkid -s UUID -o value "$PART_ROOT")
    esp_uuid=$(blkid -s UUID -o value "$PART_EFI")
    
    # Falls LUKS, UUID des Containers ermitteln
    if [[ "$USE_LUKS" == "yes" ]]; then
        crypt_root_uuid="$root_uuid"
    fi

    # Snapshot-Update Skript schreiben
    echo "$TPL_SNAPPER_UPDATE_SCRIPT" | sed "s/{{BOOT_PART_UUID}}/$esp_uuid/g" \
                                      | sed "s/{{ROOT_UUID}}/$root_uuid/g" \
                                      | sed "s/{{CRYPTROOT_UUID}}/$crypt_root_uuid/g" \
                                      > /mnt/usr/local/bin/limine-update-snapshots.sh
    chmod +x /mnt/usr/local/bin/limine-update-snapshots.sh

    # Systemd Service & Timer schreiben
    echo "$TPL_SNAPPER_UPDATE_SERVICE" > /mnt/etc/systemd/system/limine-update-snapshots.service
    echo "$TPL_SNAPPER_UPDATE_TIMER" > /mnt/etc/systemd/system/limine-update-snapshots.timer

    # Timer aktivieren
arch-chroot /mnt /bin/bash <<EOF
    systemctl enable limine-update-snapshots.timer >/dev/null 2>&1
EOF
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

    success "$STR_OK_SERVICES_DONE"
}
