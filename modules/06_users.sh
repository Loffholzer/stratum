#!/bin/bash
# ==============================================================================
# STRATUM - ARCH LINUX DEPLOYMENT FRAMEWORK
# Modul: Benutzerverwaltung & AUR
# ==============================================================================

users_setup() {
    echo "[ PHASE ] Konfiguration: Benutzer & Umgebung"

    if [[ "${DRY_RUN:-true}" == true ]]; then
        echo "[ WARN ] Dry-Run aktiv. User-Setup übersprungen."
        return 0
    fi

    echo "[ INFO ] Setze Hostname ($HOSTNAME)..."
    echo "$HOSTNAME" > /mnt/etc/hostname

    echo "[ INFO ] Konfiguriere Root-Account..."
    arch-chroot /mnt usermod -L root
    echo "[ INFO ] Root-Account gesperrt (Sudo-Only System)."

    echo "[ INFO ] Erstelle Hauptbenutzer ($USERNAME)..."
    arch-chroot /mnt useradd -m -G wheel -s /usr/bin/fish "$USERNAME"

    echo "[ INFO ] Setze Passwort für $USERNAME..."
    echo "$USERNAME:$USER_PASSWORD" | arch-chroot /mnt chpasswd

    echo "[ INFO ] Konfiguriere sudo-Rechte..."
    sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /mnt/etc/sudoers

    echo "[ OK ] Benutzer erfolgreich eingerichtet."
}

users_aur() {
    if [[ "$INSTALL_AUR" != "yes" ]]; then
        return 0
    fi
    echo "[ PHASE ] Deployment: AUR-Helper (Paru)"
    if [[ "${DRY_RUN:-true}" == true ]]; then
        echo "[ WARN ] Dry-Run aktiv. Paru-Installation übersprungen."
        return 0
    fi

    echo "[ INFO ] Erteile temporäre Build-Berechtigungen..."
    echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" > "/mnt/etc/sudoers.d/99-temp-paru-build"
    arch-chroot /mnt chmod 0440 /etc/sudoers.d/99-temp-paru-build

    echo "[ INFO ] Kompiliere paru-bin..."
    arch-chroot /mnt su - "$USERNAME" -c "
        rm -rf /tmp/paru-bin
        git clone https://aur.archlinux.org/paru-bin.git /tmp/paru-bin >/dev/null
        cd /tmp/paru-bin
        makepkg -si --noconfirm >/dev/null
        rm -rf /tmp/paru-bin
    "

    echo "[ INFO ] Entziehe temporäre Build-Berechtigungen..."
    rm -f "/mnt/etc/sudoers.d/99-temp-paru-build"

    echo "[ INFO ] Wende Stratum-Optimierungen für paru.conf an..."
    arch-chroot /mnt sed -i 's/^#BottomUp/BottomUp/' /etc/paru.conf
    arch-chroot /mnt sed -i 's/^#SudoLoop/SudoLoop/' /etc/paru.conf
    arch-chroot /mnt sed -i 's/^#CleanAfter/CleanAfter/' /etc/paru.conf

    echo "[ OK ] AUR-Helper erfolgreich eingerichtet."
}
