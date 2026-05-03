#!/usr/bin/env bash

# =========================================
# 📄 DATEI: 07_base.sh
# 💡 ZWECK: Installation des Arch Grundsystems
# =========================================

# =========================================
# 📦 Funktion: install_base_system
# -----------------------------------------
# Zweck: Führt pacstrap für das Kernsystem aus
# =========================================
install_base_system() {
    log "$STR_LOG_PACSTRAP"

    # Basis-Pakete definieren
    local pkgs=(
        base
        base-devel
        linux
        linux-lts
        linux-headers
        linux-lts-headers
        linux-firmware
        btrfs-progs
        micro
        git
        wget
        curl
        networkmanager
        terminus-font
        memtest86+-efi
        pciutils
        rust
    )

    # Hardware-spezifischer Microcode (aus Modul 03)
    if [[ -n "$MICROCODE_PKG" ]]; then
        pkgs+=("$MICROCODE_PKG")
    fi

    # LVM2/Cryptsetup Pakete für LUKS
    if [[ "$USE_LUKS" == "yes" ]]; then
        pkgs+=("cryptsetup" "lvm2")
    fi

    # Pacstrap ausführen
    pacstrap -K /mnt "${pkgs[@]}" >/dev/null
}

# =========================================
# 📦 Funktion: generate_fstab
# -----------------------------------------
# Zweck: Dateisystem-Tabelle (fstab) generieren
# =========================================
generate_fstab() {
    log "$STR_LOG_FSTAB"
    genfstab -U /mnt >> /mnt/etc/fstab
    
    # Optional: subvolid aus der fstab entfernen, falls du später 
    # BTRFS-Rollbacks mit Snapper machen möchtest (Best Practice).
    sed -i 's/subvolid=[0-9]*,//g' /mnt/etc/fstab
}

# =========================================
# 📦 Funktion: run_base
# -----------------------------------------
# Zweck: Einstiegspunkt Modul 07
# =========================================
run_base() {
    header "$STR_BASE_PHASE_HEADER"

    if [[ "${DRY_RUN:-true}" == true ]]; then
        warn "$STR_WARN_DRY_BASE"
        return 0
    fi

    install_base_system
    generate_fstab
    
    success "$STR_OK_BASE_DONE"
}