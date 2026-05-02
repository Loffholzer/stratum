#!/usr/bin/env bash

# =========================================
# 📄 DATEI: 06_disk.sh
# 💡 ZWECK: Festplattenpartitionierung & LUKS
# =========================================

# =========================================
# 📦 Funktion: unmount_all
# -----------------------------------------
# Zweck: Sicheres Aushängen bestehender Mounts
# =========================================
unmount_all() {
    local target_disk="$1"
    local log_msg
    printf -v log_msg "$STR_LOG_UNMOUNT" "$target_disk"
    log "$log_msg"

    swapoff -a 2>/dev/null || true
    umount -R /mnt 2>/dev/null || true
    
    # LUKS Container schließen, falls offen
    if [[ -b /dev/mapper/cryptroot ]]; then
        cryptsetup close cryptroot 2>/dev/null || true
    fi

    local parts
    parts=$(lsblk -rn -o NAME "$target_disk" | tail -n +2 | sort -r)
    for p in $parts; do
        umount -f "/dev/$p" 2>/dev/null || true
    done
}

# =========================================
# 📦 Funktion: partition_drive
# -----------------------------------------
# Zweck: GPT Layout mit sgdisk erstellen
# =========================================
partition_drive() {
    local log_msg
    printf -v log_msg "$STR_LOG_WIPE" "$DISK"
    log "$log_msg"
    wipefs -af "$DISK" >/dev/null

    printf -v log_msg "$STR_LOG_PARTITION" "$DISK"
    log "$log_msg"
    
    sgdisk -Z "$DISK" >/dev/null
    sgdisk -n 1:0:+1G -t 1:ef00 -c 1:"EFI" "$DISK" >/dev/null
    sgdisk -n 2:0:0   -t 2:8304 -c 2:"Linux" "$DISK" >/dev/null
    partprobe "$DISK"
    sleep 2

    if [[ "$DISK" == *nvme* || "$DISK" == *mmcblk* || "$DISK" == *loop* ]]; then
        PART_EFI="${DISK}p1"
        PART_ROOT="${DISK}p2"
    else
        PART_EFI="${DISK}1"
        PART_ROOT="${DISK}2"
    fi

    # NEU: Zerstört "Ghost-Signatures" direkt auf den neuen Partitionen
    wipefs -af "$PART_EFI" >/dev/null 2>&1 || true
    wipefs -af "$PART_ROOT" >/dev/null 2>&1 || true
}

# =========================================
# 📦 Funktion: setup_luks
# -----------------------------------------
# Zweck: LUKS Container anlegen und öffnen
# =========================================
setup_luks() {
    if [[ "$USE_LUKS" != "yes" ]]; then
        log "$STR_LOG_LUKS_SKIP"
        TARGET_ROOT_DEV="$PART_ROOT"
        return 0
    fi

    local log_msg
    printf -v log_msg "$STR_LOG_LUKS_FORMAT" "$PART_ROOT"
    log "$log_msg"
    # FIX: -q (Batch-Mode) hinzugefügt, ignoriert alte LUKS-Header Warnungen
    echo -n "$LUKS_PASSWORD" | cryptsetup luksFormat -q --type luks2 "$PART_ROOT" -

    log "$STR_LOG_LUKS_OPEN"
    echo -n "$LUKS_PASSWORD" | cryptsetup open "$PART_ROOT" cryptroot -
    
    TARGET_ROOT_DEV="/dev/mapper/cryptroot"
}

# =========================================
# 📦 Funktion: format_and_mount
# -----------------------------------------
# Zweck: Dateisysteme (BTRFS) und Mounts
# =========================================
format_and_mount() {
    local log_msg
    
    printf -v log_msg "$STR_LOG_FORMAT_EFI" "$PART_EFI"
    log "$log_msg"
    mkfs.fat -F32 "$PART_EFI" >/dev/null

    printf -v log_msg "$STR_LOG_FORMAT_BTRFS" "$TARGET_ROOT_DEV"
    log "$log_msg"
    mkfs.btrfs -f "$TARGET_ROOT_DEV" >/dev/null

    # BTRFS Subvolumes
    log "$STR_LOG_SUBVOL"
    mount "$TARGET_ROOT_DEV" /mnt
    btrfs subvolume create /mnt/@ >/dev/null
    btrfs subvolume create /mnt/@home >/dev/null
    btrfs subvolume create /mnt/@log >/dev/null
    btrfs subvolume create /mnt/@pkg >/dev/null
    btrfs subvolume create /mnt/@.snapshots >/dev/null
    umount /mnt

    # Mounten der Subvolumes
    log "$STR_LOG_MOUNT"
    local mnt_opts="rw,noatime,compress=zstd,space_cache=v2"
    
    mount -o "${mnt_opts},subvol=@" "$TARGET_ROOT_DEV" /mnt
    mkdir -p /mnt/{home,var/log,var/cache/pacman/pkg,.snapshots,boot}
    
    mount -o "${mnt_opts},subvol=@home" "$TARGET_ROOT_DEV" /mnt/home
    mount -o "${mnt_opts},subvol=@log" "$TARGET_ROOT_DEV" /mnt/var/log
    mount -o "${mnt_opts},subvol=@pkg" "$TARGET_ROOT_DEV" /mnt/var/cache/pacman/pkg
    mount -o "${mnt_opts},subvol=@.snapshots" "$TARGET_ROOT_DEV" /mnt/.snapshots

    # EFI Mountpoint Logik basierend auf LUKS
    if [[ "$USE_LUKS" == "yes" ]]; then
        mkdir -p /mnt/boot
        mount "$PART_EFI" /mnt/boot
    else
        mkdir -p /mnt/boot/efi
        mount "$PART_EFI" /mnt/boot/efi
    fi
}

# =========================================
# 📦 Funktion: run_disk
# -----------------------------------------
# Zweck: Einstiegspunkt Modul 06
# =========================================
run_disk() {
    header "$STR_DISK_PHASE_HEADER"

    if [[ "${DRY_RUN:-true}" == true ]]; then
        warn "$STR_WARN_DRY_DISK"
        # Dummy Variablen für den Dry-Run
        PART_ROOT="${DISK}2"
        PART_EFI="${DISK}1"
        return 0
    fi

    unmount_all "$DISK"
    partition_drive
    setup_luks
    format_and_mount
    
    success "$STR_OK_DISK_DONE"
}
