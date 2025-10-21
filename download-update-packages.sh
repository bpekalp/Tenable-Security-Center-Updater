#!/bin/sh

# Tenable güncelleme scripti
# REDACTED yerlerine lisans parametrelerini koy
# Çalıştırmadan önce: chmod +x nessus-update-simple-proxy.sh

WORK_DIR="/var/www/html/tenable"
LOG="$WORK_DIR/update.log"

# --- Proxy bilgisi ---
PROXY_IP=""    # Proxy IP adresi veya hostname. Yoksa boş bırak.
PROXY_PORT=""  # Proxy portu. Yoksa boş bırak.

# --- Proxy export (isteğe göre aktif/kapalı olur) ---
if [ -n "$PROXY_IP" ] && [ -n "$PROXY_PORT" ]; then
  export http_proxy="${PROXY_IP}:${PROXY_PORT}"    # Proxy belirtilir
  export https_proxy="${PROXY_IP}:${PROXY_PORT}"   # Proxy belirtilir
else
  # Proxy yoksa environment'dan kaldır (curl doğrudan internete çıkar)
  unset http_proxy
  unset https_proxy
fi

# --- Hazırlık ---
mkdir -p "$WORK_DIR"
echo "Başlat: $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG"

# --- 1) all-2.0 ---
echo "[$(date '+%Y-%m-%d %H:%M:%S')] İndir: all-2.0.tar.gz" >> "$LOG"
curl -fsSL "https://plugins.nessus.org/v2/nessus.php?f=all-2.0.tar.gz&u=REDACTED&p=REDACTED" -o "$WORK_DIR/all-2.0.tar.gz"
if [ $? -eq 0 ]; then
  sha256sum "$WORK_DIR/all-2.0.tar.gz" >> "$LOG"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] all-2.0 indirildi." >> "$LOG"
else
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] all-2.0 hata!" >> "$LOG"
fi

# --- 2) sc-plugins-diff ---
echo "[$(date '+%Y-%m-%d %H:%M:%S')] İndir: sc-plugins-diff.tar.gz" >> "$LOG"
curl -fsSL "https://plugins.nessus.org/v2/nessus.php?f=sc-plugins-diff.tar.gz&u=REDACTED&p=REDACTED" -o "$WORK_DIR/sc-plugins-diff.tar.gz"
if [ $? -eq 0 ]; then
  sha256sum "$WORK_DIR/sc-plugins-diff.tar.gz" >> "$LOG"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] sc-plugins-diff indirildi." >> "$LOG"
else
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] sc-plugins-diff hata!" >> "$LOG"
fi

# --- 3) SecurityCenterFeed48 ---
echo "[$(date '+%Y-%m-%d %H:%M:%S')] İndir: SecurityCenterFeed48.tar.gz" >> "$LOG"
curl -fsSL "https://plugins.nessus.org/v2/nessus.php?f=SecurityCenterFeed48.tar.gz&u=REDACTED&p=REDACTED" -o "$WORK_DIR/SecurityCenterFeed48.tar.gz"
if [ $? -eq 0 ]; then
  sha256sum "$WORK_DIR/SecurityCenterFeed48.tar.gz" >> "$LOG"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] SecurityCenterFeed48 indirildi." >> "$LOG"
else
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] SecurityCenterFeed48 hata!" >> "$LOG"
fi

echo "Bitti: $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG"
echo "---------------------------" >> "$LOG"
