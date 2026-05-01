#!/bin/bash
# ==============================================================================
# STRATUM - ARCH LINUX DEPLOYMENT FRAMEWORK
# Modul: Services (Systemd Daemons)
# ==============================================================================

services_enable() {
    echo "[ PHASE ] Konfiguration: Systemd-Dienste"

    if [[ "${DRY_RUN:-true}" == true ]]; then
        echo "[ WARN ] Dry-Run aktiv. Dienst-Aktivierung übersprungen."
        return 0
    fi

    echo "[ INFO ] Aktiviere Netzwerk- und Zeit-Dienste..."
    arch-chroot /mnt systemctl enable NetworkManager >/dev/null 2>&1
    arch-chroot /mnt systemctl enable systemd-timesyncd >/dev/null 2>&1

    echo "[ INFO ] Aktiviere SSD-Pflege (FSTRIM)..."
    arch-chroot /mnt systemctl enable fstrim.timer >/dev/null 2>&1

    echo "[ OK ] Systemd-Dienste erfolgreich konfiguriert."
}
