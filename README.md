# Nethunter_backups
Copy of my nethunter as it is with all files or just the packages

📌 Full Backup of Termux + NetHunter (All Files, Packages, and Directories)

This script will back up everything, including:
✅ All installed packages (APT, Pip, Cargo, Snap, Flatpak, etc.)
✅ All files, directories, and system configurations
✅ Everything inside Termux & NetHunter rootfs
✅ Creates a compressed .tar.gz archive


---

🔥 Full Backup Script (full_backup.sh)
```
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
```

---

🔥 How to Use the Script

1.
```
nano full_backup.sh
```

3. Give execution permission
```
chmod +x full_backup.sh
```

3. Run it inside Termux
```
./full_backup.sh
```

4. Backup file created:
```
mv
/data/data/com.termux/files/home/termux_nethunter_backup_2025-02-27.tar.gz

backup.tar.gz
```
✅ Includes all installed packages
✅ Contains all files & directories
✅ Includes full NetHunter rootfs




---

🔥 How to Restore the Backup

To fully restore Termux & NetHunter:
```
backup_2025-02-27.tar.gz -C /
```
Then, reinstall all packages:
```
xargs -a termux_packages.txt pkg install -y
xargs -a nethunter_packages.txt sudo apt install -y
xargs -a pip_packages.txt pip install
xargs -a pipx_packages.txt pipx install
xargs -a cargo_packages.txt cargo install
```

---

🔥 Upload to GitHub

To store the backup on GitHub:
```
git init
git add termux_nethunter_backup_*.tar.gz
git commit -m "Full backup of Termux & NetHunter"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
git push -u origin main
```

---

Now, you have a complete, restorable backup of everything in Termux + NetHunter the exact set up I have.

