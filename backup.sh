#!/bin/bash

# Set backup name with date
BACKUP_DIR="$HOME/termux_nethunter_backup_$(date +%F)"
BACKUP_FILE="$BACKUP_DIR.tar.gz"

# Create backup directory
mkdir -p "$BACKUP_DIR"

echo "Backing up installed packages..."

# Backup Termux packages
apt list --installed > "$BACKUP_DIR/termux_packages.txt"
pkg list-installed >> "$BACKUP_DIR/termux_packages.txt"

# Backup NetHunter (Kali) packages
echo "Backing up NetHunter (Kali) packages..."
nethunter -r -c "dpkg-query -W -f='\${binary:Package} \${Version} \${Architecture}\n'" > "$BACKUP_DIR/nethunter_packages.txt"

# Backup Pip (Python) packages
pip list --format=freeze > "$BACKUP_DIR/pip_packages.txt" 2>/dev/null

# Backup Pipx (Isolated Python) packages
pipx list > "$BACKUP_DIR/pipx_packages.txt" 2>/dev/null

# Backup Cargo (Rust) packages
cargo install --list > "$BACKUP_DIR/cargo_packages.txt" 2>/dev/null

# Backup Snap packages
snap list > "$BACKUP_DIR/snap_packages.txt" 2>/dev/null

# Backup Flatpak packages
flatpak list > "$BACKUP_DIR/flatpak_packages.txt" 2>/dev/null

echo "Backing up all files and directories..."

# Backup everything from Termux
rsync -a --exclude="$BACKUP_DIR" --progress /data/data/com.termux/files/home/ "$BACKUP_DIR/termux_home_backup/"

# Backup everything from NetHunter (Rootfs)
nethunter -r -c "tar -czf $BACKUP_DIR/nethunter_rootfs.tar.gz / --exclude=/proc --exclude=/sys --exclude=/dev --exclude=/mnt --exclude=/run --exclude=/media --exclude=/var/log" 

# Compress entire backup
echo "Creating compressed archive..."
tar -czf "$BACKUP_FILE" -C "$HOME" "$(basename "$BACKUP_DIR")"

# Cleanup temporary backup directory
rm -rf "$BACKUP_DIR"

echo "✅ Full Backup Completed: $BACKUP_FILE"
