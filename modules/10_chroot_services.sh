#!/usr/bin/env bash

# =========================================
# 📄 DATEI: 10_chroot_services.sh
# 💡 ZWECK: Systemdienste & BTRFS-Wartung
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
# Zweck: Installiert Snapper und setzt Hooks
# =========================================
snapper_setup() {
    log "$STR_LOG_SNAPPER_SETUP"
    
    # Snapper installieren und Grundkonfiguration erstellen
arch-chroot /mnt /bin/bash <<EOF
    pacman -S --noconfirm snapper >/dev/null 2>&1
    umount /.snapshots 2>/dev/null || true
    rm -rf /.snapshots
    snapper -c root create-config /
    systemctl enable snapper-timeline.timer snapper-cleanup.timer >/dev/null 2>&1
EOF

    # Pacman Hook aus dem Template schreiben
    local hook_dir="/mnt/etc/pacman.d/hooks"
    mkdir -p "$hook_dir"
    echo "$TPL_PACMAN_SNAPPER" > "$hook_dir/50-snapper.hook"
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