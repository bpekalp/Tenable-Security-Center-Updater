#!/bin/bash

# ============================================
# Nessus Plugin Updater - Version 2
# Date: 2025-10-20
# ============================================

# --- Ayarlar ---
URL="http://<IP Adres>/tenable/all-2.0.tar.gz"   # Güncelleme dosyası alınacak adres
TMP_FILE="/tmp/all-2.0.tar.gz"
LOG_FILE="/tmp/nessus_plugin_updater.txt"
UPDATE_DIR="/opt/nessus_update"
NESSUS_BIN="/opt/nessus/sbin/nessuscli"
NESSUS_SERVICE="nessusd"

# --- Log Başlangıcı ---
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Güncelleme işlemi başlatıldı." > "$LOG_FILE"

# --- Eski dosya ve log temizliği ---
if [ -f "$TMP_FILE" ]; then
    rm -f "$TMP_FILE"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Eski geçici dosya silindi." >> "$LOG_FILE"
fi

# --- Güncelleme dosyasını indir ---
cd /tmp || exit 1
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Yeni plugin paketi indiriliyor..." >> "$LOG_FILE"
wget "$URL" --no-check-certificate -O "$TMP_FILE"

if [ $? -ne 0 ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] HATA: Plugin paketi indirilemedi!" >> "$LOG_FILE"
    exit 1
fi

# --- Nessus update klasörünü kontrol et ---
if [ ! -d "$UPDATE_DIR" ]; then
    mkdir -p "$UPDATE_DIR"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $UPDATE_DIR klasörü oluşturuldu." >> "$LOG_FILE"
fi

# --- Hash kontrolü ---
MOVED=0
if [ -f "$UPDATE_DIR/all-2.0.tar.gz" ]; then
    HASH_NEW=$(sha256sum "$TMP_FILE" | awk '{print $1}')
    HASH_OLD=$(sha256sum "$UPDATE_DIR/all-2.0.tar.gz" | awk '{print $1}')

    if [ "$HASH_NEW" != "$HASH_OLD" ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Yeni dosya eskiyle farklı, güncellenecek." >> "$LOG_FILE"
        MOVED=1
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Plugin paketi zaten güncel, işlem sonlandırılıyor." >> "$LOG_FILE"
        exit 0
    fi
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Eski paket bulunamadı, yeni dosya kullanılacak." >> "$LOG_FILE"
    MOVED=1
fi

# --- Yeni dosyayı taşı ---
if [ $MOVED -eq 1 ]; then
    mv -f "$TMP_FILE" "$UPDATE_DIR/all-2.0.tar.gz"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Yeni dosya taşındı." >> "$LOG_FILE"
fi

# --- Nessus güncellemesi ---
"$NESSUS_BIN" update "$UPDATE_DIR/all-2.0.tar.gz" >> "$LOG_FILE" 2>&1
if [ $? -eq 0 ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Güncelleme başarıyla tamamlandı." >> "$LOG_FILE"
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] HATA: Güncelleme sırasında bir sorun oluştu." >> "$LOG_FILE"
fi

# --- Nessus servisini yeniden başlat ---
/sbin/service "$NESSUS_SERVICE" restart >> "$LOG_FILE" 2>&1
if [ $? -eq 0 ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Nessus servisi başarıyla yeniden başlatıldı." >> "$LOG_FILE"
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] HATA: Nessus servisi yeniden başlatılamadı!" >> "$LOG_FILE"
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] İşlem tamamlandı." >> "$LOG_FILE"
echo "--------------------------------------------" >> "$LOG_FILE"

