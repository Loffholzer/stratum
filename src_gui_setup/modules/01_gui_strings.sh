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

export STR_GUI_MENU_TITLE="${BOLD}${CYAN} 🚀 DESKTOP-UMGEBUNG AUSWÄHLEN${NC}"
export STR_GUI_MENU_SUB="Wähle deine bevorzugte Oberfläche für die Installation:"
export STR_GUI_OPT_KDE="  ${CYAN}[1]${NC} KDE Plasma (Empfohlen für power-profiles-daemon)"
export STR_GUI_OPT_COSMIC="  ${CYAN}[2]${NC} COSMIC Desktop (Next-Gen Rust Desktop)"
export STR_GUI_OPT_EXIT="  ${CYAN}[0]${NC} Setup beenden (Später manuell über ~/setup/install.sh starten)"
export STR_GUI_PROMPT="${BLUE}[INPUT]${NC} Auswahl [0-2]: "

export STR_GUI_LOG_START_KDE="${STR_GUI_INFO_PREFIX} Bereite Installation von KDE Plasma vor..."
export STR_GUI_LOG_START_COSMIC="${STR_GUI_INFO_PREFIX} Bereite Installation von COSMIC Desktop vor..."
export STR_GUI_LOG_EXIT="${STR_GUI_INFO_PREFIX} Setup wird beendet. Viel Spaß mit deinem Basis-System!"

export STR_GUI_ERR_INVALID="${STR_GUI_ERR_PREFIX} Ungültige Auswahl. Bitte versuche es erneut."
