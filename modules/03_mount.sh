#!/bin/bash
# ==============================================================================
# STRATUM - ARCH LINUX DEPLOYMENT FRAMEWORK
# Modul: Dateisystem & Mounts (BTRFS)
# ==============================================================================

mount_btrfs() {
    echo "[ PHASE ] Dateisystem-Konfiguration (BTRFS)"

    if [[ "${DRY_RUN:-true}" == true ]]; then
        echo "[ WARN ] Dry-Run aktiv. Dateisystem-Erstellung übersprungen."
        return 0
    fi

    echo "[ INFO ] Formatiere Partition mit BTRFS..."
    mkfs.btrfs -f "$MAPPER_ROOT" >/dev/null

    echo "[ INFO ] Erstelle temporären Mountpoint für Subvolumes..."
    mount "$MAPPER_ROOT" /mnt

    echo "[ INFO ] Erstelle BTRFS Subvolumes (@, @home, @snapshots, @var_cache, @var_log)..."
    btrfs subvolume create /mnt/@ >/dev/null
    btrfs subvolume create /mnt/@home >/dev/null
    btrfs subvolume create /mnt/@snapshots >/dev/null
    btrfs subvolume create /mnt/@var_cache >/dev/null
    btrfs subvolume create /mnt/@var_log >/dev/null

    echo "[ INFO ] Unmounte temporäres Layout..."
    umount /mnt

    local BTRFS_OPTS="rw,noatime,compress=zstd:3,ssd,discard=async,space_cache=v2"

    echo "[ INFO ] Mounte Subvolumes mit Stratum-Performance-Parametern..."
    mount -o "${BTRFS_OPTS},subvol=@" "$MAPPER_ROOT" /mnt
    mkdir -p /mnt/{home,.snapshots,var/cache,var/log,boot/efi}

    mount -o "${BTRFS_OPTS},subvol=@home" "$MAPPER_ROOT" /mnt/home
    mount -o "${BTRFS_OPTS},subvol=@snapshots" "$MAPPER_ROOT" /mnt/.snapshots
    mount -o "${BTRFS_OPTS},subvol=@var_cache" "$MAPPER_ROOT" /mnt/var/cache
    mount -o "${BTRFS_OPTS},subvol=@var_log" "$MAPPER_ROOT" /mnt/var/log

    echo "[ INFO ] Mounte EFI-Partition..."
    if [[ "$USE_LUKS" == "yes" ]]; then
        mkdir -p /mnt/boot
        mount "$PART_EFI" /mnt/boot
    else
        mount "$PART_EFI" /mnt/boot/efi
    fi

    echo "[ OK ] Dateisysteme erfolgreich gemountet."
}
