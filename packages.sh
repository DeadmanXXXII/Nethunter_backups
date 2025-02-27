#!/bin/bash

# Set output file name
BACKUP_FILE="installed_packages_backup_$(date +%F).txt"

# Start logging
echo "Backup created on: $(date)" > "$BACKUP_FILE"

echo -e "\n=== APT Packages ===" >> "$BACKUP_FILE"
dpkg-query -W -f='${binary:Package} ${Version} ${Architecture}\n' >> "$BACKUP_FILE" 2>/dev/null

echo -e "\n=== Pip Packages ===" >> "$BACKUP_FILE"
pip list --format=freeze >> "$BACKUP_FILE" 2>/dev/null

echo -e "\n=== Pipx Packages ===" >> "$BACKUP_FILE"
pipx list >> "$BACKUP_FILE" 2>/dev/null

echo -e "\n=== Cargo Packages ===" >> "$BACKUP_FILE"
cargo install --list >> "$BACKUP_FILE" 2>/dev/null

echo -e "\n=== Snap Packages ===" >> "$BACKUP_FILE"
snap list >> "$BACKUP_FILE" 2>/dev/null

echo -e "\n=== Flatpak Packages ===" >> "$BACKUP_FILE"
flatpak list >> "$BACKUP_FILE" 2>/dev/null

echo "Backup completed: $BACKUP_FILE"
