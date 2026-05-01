#!/bin/bash
# ==============================================================================
# STRATUM - ARCH LINUX DEPLOYMENT FRAMEWORK
# Modul: Disk (Partitionierung & LUKS)
# ==============================================================================

disk_setup() {
    echo "[ PHASE ] Partitionierung & Speicher-Setup"

    if [[ "${DRY_RUN:-true}" == true ]]; then
        echo "[ WARN ] Dry-Run aktiv. Festplatten-Modifikationen übersprungen."
        export PART_EFI="${DISK}1"
        export PART_ROOT="${DISK}2"
        return 0
    fi

    echo "[ INFO ] Unmounte bestehende Partitionen auf $DISK..."
    umount -q -R /mnt 2>/dev/null || true
    cryptsetup close cryptroot 2>/dev/null || true

    echo "[ INFO ] Lösche Partitionstabelle auf $DISK..."
    wipefs -af "$DISK" >/dev/null
    sgdisk -Z "$DISK" >/dev/null

    echo "[ INFO ] Erstelle neues GPT-Layout..."
    sgdisk -n 1:0:+1G -t 1:ef00 -c 1:"EFI System Partition" "$DISK" >/dev/null
    sgdisk -n 2:0:0   -t 2:8304 -c 2:"Linux Root Partition" "$DISK" >/dev/null

    export PART_EFI=$(lsblk -rn -o NAME "$DISK" | sed -n '2p' | sed 's|^|/dev/|')
    export PART_ROOT=$(lsblk -rn -o NAME "$DISK" | sed -n '3p' | sed 's|^|/dev/|')

    echo "[ INFO ] Formatiere EFI-Partition (FAT32)..."
    mkfs.fat -F32 "$PART_EFI" >/dev/null

    if [[ "$USE_LUKS" == "yes" ]]; then
        echo "[ INFO ] Initialisiere LUKS2 Verschlüsselung auf $PART_ROOT..."
        echo -n "$LUKS_PASSWORD" | cryptsetup luksFormat --type luks2 "$PART_ROOT" -
        echo "[ INFO ] Öffne verschlüsseltes Laufwerk..."
        echo -n "$LUKS_PASSWORD" | cryptsetup open "$PART_ROOT" cryptroot -
        export MAPPER_ROOT="/dev/mapper/cryptroot"
    else
        echo "[ INFO ] LUKS deaktiviert. Nutze Standard-Partition."
        export MAPPER_ROOT="$PART_ROOT"
    fi

    echo "[ OK ] Speicher-Setup erfolgreich."
}
