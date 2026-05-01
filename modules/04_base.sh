#!/bin/bash
# ==============================================================================
# STRATUM - ARCH LINUX DEPLOYMENT FRAMEWORK
# Modul: Base (Pacstrap & Pacman)
# ==============================================================================

base_pacstrap() {
    echo "[ PHASE ] Deployment: Basis-System"

    if [[ "${DRY_RUN:-true}" == true ]]; then
        echo "[ WARN ] Dry-Run aktiv. Pacstrap übersprungen."
        return 0
    fi

    local pkg_base=(base base-devel linux linux-firmware linux-lts linux-lts-headers btrfs-progs networkmanager systemd-timesyncd vim git fish)

    if [[ "$USE_LUKS" == "yes" ]]; then
        pkg_base+=(cryptsetup)
    fi

    echo "[ INFO ] Führe pacstrap aus..."
    pacstrap -K /mnt "${pkg_base[@]}" >/dev/null

    echo "[ INFO ] Optimiere pacman.conf im Zielsystem..."
    sed -i 's/^#Color/Color\nILoveCandy/' /mnt/etc/pacman.conf
    sed -i 's/^#ParallelDownloads/ParallelDownloads = 5/' /mnt/etc/pacman.conf

    if [[ "$ENABLE_MULTILIB" == "yes" ]]; then
        echo "[ INFO ] Aktiviere Multilib-Repository..."
        sed -i '/^#\[multilib\]/{ s/^#//; n; s/^#//; }' /mnt/etc/pacman.conf
    fi

    echo "[ INFO ] Generiere Dateisystemtabelle (fstab)..."
    genfstab -U /mnt >> /mnt/etc/fstab

    echo "[ OK ] Basis-System erfolgreich installiert."
}
