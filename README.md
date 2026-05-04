# Stratum – Arch Linux Deployment Framework

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

---

## 🇩🇪 Deutsch

### 1. Über das Projekt
**Stratum** ist ein modulares Installations-Framework für Arch Linux. Es ist darauf optimiert, ein hochperformantes, verschlüsseltes Fundament mit moderner Snapshot-Verwaltung (BTRFS & Snapper) zu erstellen. Der Fokus liegt auf technischer Präzision, Schnelligkeit und Wartbarkeit.

### 2. Rechtlicher Hinweis (Disclaimer)
Dieses Skript wird "wie besehen" (as is) zur Verfügung gestellt. Die Nutzung erfolgt auf eigene Gefahr. Der Autor übernimmt keine Haftung für Datenverlust oder Hardware-Schäden. Arch Linux ist eine Marke von Aaron Griffin. Stratum steht in keiner Verbindung zum offiziellen Arch Linux Projekt.

### 3. Voraussetzungen
* Aktuelles Arch Linux Live-Medium (UEFI-Modus).
* Aktive Internetverbindung.
* Ziel-Datenträger ohne wichtige Daten (vollständige Löschung).

---

## 🇺🇸 English

### 1. About the Project
**Stratum** is a modular deployment framework for Arch Linux. It is designed to build a high-performance, encrypted foundation with modern snapshot management (BTRFS & Snapper). Stratum focuses on technical precision, speed, and maintainability.

### 2. Legal Disclaimer
This script is provided "as is", without warranty of any kind. Use at your own risk. The author is not responsible for any data loss or hardware damage. Arch Linux is a trademark of Aaron Griffin. Stratum is not affiliated with the official Arch Linux project.

### 3. Prerequisites
* Current Arch Linux Live Medium (UEFI mode).
* Active internet connection.
* Target drive without important data (will be completely wiped).

---

## 🛠 Features (Stratum Base)

* **Filesystem:** BTRFS with optimized subvolumes (`@`, `@home`, `@snapshots`, `@var_cache`, `@var_log`).
* **Compression:** ZSTD:3 enabled by default.
* **Security:** Optional LUKS2 Full-Disk Encryption.
* **Bootloader:** Limine v8+ (Modern, minimalist, with snapshot boot support).
* **Performance:** ZRAM configuration, optimized Pacman settings, automatic hardware detection (Microcode/GPU).
* **Maintenance:** Integrated Snapper setup with automatic Pacman hooks for system rollbacks.
* **Localization:** Fully bilingual installer (English / Deutsch).
* **Modularity:** Seamless "Handoff" to an independent Post-Install GUI Framework via Fish Shell.

---

## ⚖️ License / Lizenz (MIT)

Copyright (c) 2026 Loffholzer

Distributed under the MIT License. See `LICENSE` for more information.
