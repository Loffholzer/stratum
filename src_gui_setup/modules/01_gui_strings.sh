#!/bin/bash
# =========================================
# 📄 Modul: 01_gui_strings
# -----------------------------------------
# Zweck: Texte und Lokalisierung für die GUI
# =========================================

export RED='\033[1;31m'
export GREEN='\033[1;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[1;34m'
export CYAN='\033[1;36m'
export BOLD='\033[1m'
export NC='\033[0m'

export STR_GUI_INFO_PREFIX="${BLUE}[INFO]${NC}"
export STR_GUI_ERR_PREFIX="${RED}[FEHLER]${NC}"
export STR_GUI_OK_PREFIX="${GREEN}[OK]${NC}"

export STR_GUI_MENU_TITLE="${BOLD}${CYAN} 🚀 DESKTOP-UMGEBUNG AUSWÄHLEN${NC}"
export STR_GUI_MENU_SUB="Wähle deine bevorzugte Oberfläche für die Installation:"
export STR_GUI_OPT_KDE="  ${CYAN}[1]${NC} KDE Plasma (Empfohlen für power-profiles-daemon)"
export STR_GUI_OPT_COSMIC="  ${CYAN}[2]${NC} COSMIC Desktop (Next-Gen Rust Desktop)"
export STR_GUI_OPT_RM_KDE="  ${CYAN}[3]${NC} KDE Plasma deinstallieren"
export STR_GUI_OPT_RM_COSMIC="  ${CYAN}[4]${NC} COSMIC Desktop deinstallieren"
export STR_GUI_OPT_EXIT="  ${CYAN}[0]${NC} Setup beenden (Später manuell über ~/setup/install.sh starten)"
export STR_GUI_PROMPT_YN="${BLUE}[INPUT]${NC} (j/n): "
export STR_GUI_PROMPT="${BLUE}[INPUT]${NC} Auswahl [0-4]: "

export STR_GUI_LOG_START_KDE="${STR_GUI_INFO_PREFIX} Bereite Installation von KDE Plasma vor..."
export STR_GUI_LOG_START_COSMIC="${STR_GUI_INFO_PREFIX} Bereite Installation von COSMIC Desktop vor..."
export STR_GUI_LOG_START_RM_KDE="${STR_GUI_INFO_PREFIX} Bereite Deinstallation von KDE Plasma vor..."
export STR_GUI_LOG_START_RM_COSMIC="${STR_GUI_INFO_PREFIX} Bereite Deinstallation von COSMIC Desktop vor..."
export STR_GUI_LOG_EXIT="${STR_GUI_INFO_PREFIX} Setup wird beendet. Viel Spaß mit deinem Basis-System!"

export STR_GUI_ERR_INVALID="${STR_GUI_ERR_PREFIX} Ungültige Auswahl. Bitte versuche es erneut."
export STR_GUI_ERR_SUDO="${STR_GUI_ERR_PREFIX} Bitte starte das Setup mit sudo: sudo ./install.sh"

export STR_GUI_DUMMY_KDE="KDE Plasma Installations-Dummy erfolgreich aufgerufen."
export STR_GUI_DUMMY_COSMIC="COSMIC Desktop Installations-Dummy erfolgreich aufgerufen."

# --- Modul: 03_kde_setup ---
export STR_GUI_KDE_PHASE="${BOLD}${CYAN}--- KDE Plasma Installation ---${NC}"
export STR_GUI_LOG_KDE_HW_DETECT="${STR_GUI_INFO_PREFIX} Starte Hardware-Erkennung für KDE Plasma..."
export STR_GUI_LOG_KDE_AUDIO="${STR_GUI_INFO_PREFIX} Konfiguriere PipeWire Audio-Stack für KDE..."
export STR_GUI_LOG_KDE_PKGS="${STR_GUI_INFO_PREFIX} Lade und installiere KDE Plasma, SDDM und Basis-Apps..."
export STR_GUI_LOG_KDE_ENABLE_SRV="${STR_GUI_INFO_PREFIX} Aktiviere Systemdienste (SDDM, Power-Profiles)..."
export STR_GUI_OK_KDE="${STR_GUI_OK_PREFIX} KDE Plasma erfolgreich installiert und konfiguriert!"

export STR_GUI_KDE_RM_PHASE="${BOLD}${CYAN}--- KDE Plasma Deinstallation ---${NC}"
export STR_GUI_LOG_KDE_DISABLE_SRV="${STR_GUI_INFO_PREFIX} Stoppe und deaktiviere KDE-Dienste (SDDM)..."
export STR_GUI_LOG_KDE_RM_PKGS="${STR_GUI_INFO_PREFIX} Entferne KDE Plasma Pakete (ohne Hardware-Treiber)..."
export STR_GUI_OK_RM_KDE="${STR_GUI_OK_PREFIX} KDE Plasma erfolgreich restlos entfernt!"

# --- Modul: 04_cosmic_setup ---
export STR_GUI_COSMIC_PHASE="${BOLD}${CYAN}--- COSMIC Desktop Installation ---${NC}"
export STR_GUI_LOG_HW_DETECT="${STR_GUI_INFO_PREFIX} Starte Hardware-Erkennung für COSMIC..."
export STR_GUI_LOG_VM_DETECTED="${STR_GUI_INFO_PREFIX} Virtuelle Maschine erkannt. Füge VM-Tools hinzu (spice-vdagent, qemu-guest-agent)..."
export STR_GUI_LOG_BT_DETECTED="${STR_GUI_INFO_PREFIX} Bluetooth-Controller erkannt. Füge BlueZ-Stack hinzu..."
export STR_GUI_LOG_AUDIO="${STR_GUI_INFO_PREFIX} Konfiguriere modernes Audio-Setup (PipeWire & WirePlumber)..."
export STR_GUI_LOG_OOTB_ASK="${STR_GUI_INFO_PREFIX} Möchtest du Out-of-the-Box Apps (Firefox, Fonts, Gnome-Keyring, Evince, Archive-Tools) mitinstallieren?"
export STR_GUI_LOG_FF_LANG_FOUND="${STR_GUI_INFO_PREFIX} Passendes Firefox-Sprachpaket gefunden und zur Installation markiert"
export STR_GUI_LOG_OOTB_PKGS="${STR_GUI_INFO_PREFIX} Lade und installiere Out-of-the-Box Anwendungen..."
export STR_GUI_LOG_FF_POLICY="${STR_GUI_INFO_PREFIX} Wende gehärtete Firefox Enterprise Policies an (Brave, HTTPS-Only, Telemetry-Off)..."
export STR_GUI_LOG_COSMIC_PKGS="${STR_GUI_INFO_PREFIX} Lade und installiere COSMIC Core-Pakete und Greeter..."
export STR_GUI_LOG_ENABLE_SRV="${STR_GUI_INFO_PREFIX} Aktiviere Systemdienste (Display Manager, Network, Bluetooth)..."
export STR_GUI_OK_COSMIC="${STR_GUI_OK_PREFIX} COSMIC Desktop erfolgreich installiert und konfiguriert!"
export STR_GUI_ERR_PACMAN="${STR_GUI_ERR_PREFIX} Fehler bei der Paketinstallation (Pacman). Abbruch."

export STR_GUI_COSMIC_RM_PHASE="${BOLD}${CYAN}--- COSMIC Desktop Deinstallation ---${NC}"
export STR_GUI_LOG_COSMIC_DISABLE_SRV="${STR_GUI_INFO_PREFIX} Stoppe und deaktiviere COSMIC-Dienste (Greeter)..."
export STR_GUI_LOG_COSMIC_RM_PKGS="${STR_GUI_INFO_PREFIX} Entferne COSMIC Desktop Pakete (ohne Hardware-Treiber)..."
export STR_GUI_OK_RM_COSMIC="${STR_GUI_OK_PREFIX} COSMIC Desktop erfolgreich restlos entfernt!"
