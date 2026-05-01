#!/bin/bash
# ==============================================================================
# STRATUM - ARCH LINUX DEPLOYMENT FRAMEWORK
# Konfigurationsdatei
# ==============================================================================

export FRAMEWORK_NAME="Stratum"
export VERSION="1.0.0"

# -----------------------------------------
# SYSTEM & HARDWARE
# -----------------------------------------
export HOSTNAME="arch-dt"
export USERNAME="mc"
export ENABLE_MULTILIB="yes"
export INSTALL_AUR="yes"

# -----------------------------------------
# BOOTLOADER THEME (LIMINE)
# -----------------------------------------
# Farben passend zum splash.jpg (Galaxie/Nebel)
export LIMINE_FG="ffffff"           # Weiß (Sterne)
export LIMINE_BG="000000"           # Schwarz (Hintergrund)
export LIMINE_FG_ACTIVE="ff8c00"    # Orange (Lichtschweife)
export LIMINE_BG_ACTIVE="4b0082"    # Tiefes Violett (Nebel)
