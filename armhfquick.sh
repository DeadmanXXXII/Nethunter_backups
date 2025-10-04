#!/bin/bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

echo "=== Updating and installing core packages ==="
apt update && apt upgrade -y

# Core apt packages (Kali names; some may already be present)
apt install -y \
  kismet \
  netcat-openbsd \
  nmap \
  msfvenum \
  dnsmasq \
  ettercap \
  sqlmap \
  metasploit-framework \
  john \
  dirb \
  nikto \
  openssl \
  openvpn \
  openssh-client openssh-server \
  ftp \
  sslscan \
  tshark \
  wireshark \
  wget \
  curl \
  iputils-ping \
  plymouth \
  p0f \
  vpnc \
  ghostscript \
  beef-xss \
  sublist3r \
  dnsrecon \
  
  crackmapexec || true

# Development & Python helpers
apt install -y python3 python3-pip python3-venv build-essential git libssl-dev libffi-dev

# Ensure pipx is available (preferred for isolated installs)
python3 -m pip install --user pipx || true
python3 -m pipx ensurepath || true
export PATH="$PATH:$HOME/.local/bin"

echo "=== Pipx / pip installs for tools not packaged (or better via pipx) ==="
# awscli v1 (pipx ensures isolated venv)
if ! command -v aws >/dev/null 2>&1; then
  pipx install awscli || python3 -m pip install --user awscli
fi

# tools commonly installed via pip/pipx or github
# trufflehog (pipx)
if ! command -v trufflehog >/dev/null 2>&1; then
  pipx install trufflehog || python3 -m pip install --user trufflehog
fi

# slither-analyzer (may require solidity/clang; may fail on armhf)
if ! command -v slither >/dev/null 2>&1; then
  python3 -m pip install --user slither-analyzer || echo "slither install failed: consider running on x86/arm64 or in Docker"
fi

# impacket (kali package or pip)
if ! command -v impacket >/dev/null 2>&1; then
  apt install -y impacket || python3 -m pip install --user impacket
fi

echo "=== Permissions and PATH tweaks ==="
# ensure user-local bin is available
if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
  echo 'export PATH=$PATH:~/.local/bin' >> ~/.profile
  export PATH=$PATH:~/.local/bin
fi

echo "=== Quick sanity installs (force apt for cme/beef if apt failed earlier) ==="
# Try installing CrackMapExec via pip as fallback (may require wheels/build deps)
if ! command -v crackmapexec >/dev/null 2>&1; then
  python3 -m pip install --user crackmapexec || echo "cme install failed: check apt repo or build deps"
fi

echo "=== Finished installs. Now generating verification report ==="

# Create report with locations and versions
OUT="$HOME/bugtools-report.txt"
{
  echo "Report generated: $(date)"
  echo "System: $(uname -a)"
  echo "dpkg arch: $(dpkg --print-architecture)"
  echo
  echo "=== Installed packages (dpkg filter) ==="
  dpkg -l | egrep -i 'kismet|netcat|nmap|dnsmasq|ettercap|sqlmap|metasploit|john|dirb|nikto|openssl|openvpn|wireshark|sslscan|p0f|beef|crackmapexec|hydra|sublist3r|dnsrecon' || true
  echo
  echo "=== Found commands and versions ==="
  tools=(kismet nc nmap dnsmasq ettercap sqlmap msfconsole john dirb nikto openssl openvpn ssh ftp sslscan msfvenom tshark wireshark wget curl ping plymouth p0f vpnc ghostscript beef-xss crackmapexec sublist3r hydra aws trufflehog slither dnsrecon)
  for t in "${tools[@]}"; do
    printf "%-14s: " "$t"
    cmd=$(which "$t" 2>/dev/null || find / -type f -name "$t" 2>/dev/null | head -n1 || true)
    if [ -n "$cmd" ]; then
      echo "found at $cmd"
      # attempt version print (best-effort)
      case "$t" in
        nmap) "$cmd" --version 2>&1 | head -n1 ;;
        nikto) "$cmd" -Version 2>&1 | head -n1 ;;
        sqlmap) "$cmd" --version 2>&1 | head -n1 ;;
        msfconsole) "$cmd" --version 2>&1 | head -n1 || echo "(msfconsole version not returned)" ;;
        openssl) "$cmd" version 2>&1 | head -n1 ;;
        aws) "$cmd" --version 2>&1 | head -n1 ;;
        *) "$cmd" --version 2>&1 | head -n1 2>/dev/null || echo "(no --version output)";;
      esac
    else
      echo "missing"
    fi
  done
  echo
  echo "=== End of report ==="
} > "$OUT"

echo "Report saved to $OUT"
echo "If any installs failed, paste the tail of the report and I will help debug specific failures."