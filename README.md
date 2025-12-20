# 🔒 Tenable Security Center Updater for Air-Gapped Networks

Bu proje, internet erişimi olmayan (air-gapped) ağlarda çalışan Tenable Security Center ve Nessus instance'larının güncelleme sürecini otomatikleştiren scriptler sağlar.

## 🎯 Genel Bakış

Air-gapped ağlarda Tenable ürünlerinin güncel tutulması kritik bir güvenlik gereksinimidir. Bu proje, iki aşamalı bir yaklaşım sunar:

1. **Download Phase**: İnternete erişimi olan bir makine, Tenable plugin ve feed güncellemelerini indirir
2. **Update Phase**: İndirilen paketler güvenli kanal üzerinden air-gapped ağa taşınır ve Nessus instance'ına yüklenir

### Temel Özellikler
- ✅ Otomatik plugin paketi indirme
- ✅ Hash kontrolü ile gereksiz güncellemeleri önleme
- ✅ Proxy desteği
- ✅ Detaylı loglama
- ✅ Servis yönetimi ve otomatik restart
- ✅ Offline güncelleme desteği

## 🏗️ Mimari

```
┌─────────────────────────┐         ┌──────────────────────────┐
│  Internet Gateway       │         │  Air-Gapped Network      │
│  (Download Machine)     │         │  (Tenable Server)        │
│                         │         │                          │
│  ┌──────────────────┐   │         │  ┌───────────────────┐   │
│  │ download-update- │   │  USB/   │  │ nessus-updater.sh │   │
│  │   packages.sh    │───┼─Secure──┼─▶│                   │   │
│  │                  │   │ Transfer│  │  Updates Nessus   │   │
│  └──────────────────┘   │         │  └───────────────────┘   │
│          │              │         │                          │
│          ▼              │         │                          │
│   Tenable Servers       │         │                          │
│   (plugins.nessus.org)  │         │                          │
└─────────────────────────┘         └──────────────────────────┘
```

## 📦 Ön Gereksinimler

### Download Machine (İnternet Erişimi Olan)
- ✓ Bash shell
- ✓ `curl` komutu
- ✓ İnternet bağlantısı
- ✓ Tenable lisans bilgileri (activation code)
- ✓ (Opsiyonel) Proxy ayarları

### Tenable Server (Air-Gapped)
- ✓ Bash shell
- ✓ `wget` komutu
- ✓ Çalışan Nessus/Tenable Security Center instance
- ✓ Root/sudo yetkisi
- ✓ Yerel web server (HTTP) veya dosya paylaşım mekanizması

## 🚀 Kurulum

### 1. Repository'yi Klonlayın
```bash
git clone https://github.com/peksec/Tenable-Security-Center-Updater.git
cd Tenable-Security-Center-Updater
```

### 2. Scriptleri Çalıştırılabilir Yapın
```bash
chmod +x download-update-packages.sh nessus-updater.sh
```

### 3. Lisans Bilgilerini Yapılandırın
`download-update-packages.sh` dosyasını düzenleyin ve `REDACTED` kısımlarını kendi lisans bilgilerinizle değiştirin:

```bash
# Örnek:
curl -fsSL "https://plugins.nessus.org/v2/nessus.php?f=all-2.0.tar.gz&u=YOUR_ACTIVATION_CODE&p=YOUR_PASSWORD"
```

## 📖 Kullanım

### Adım 1: Güncellemeleri İndirin (Download Machine)

İnternet erişimi olan makinede:

```bash
./download-update-packages.sh
```

Bu script şu dosyaları indirir:
- `all-2.0.tar.gz` - Tüm Nessus pluginleri
- `sc-plugins-diff.tar.gz` - Security Center plugin farklılıkları
- `SecurityCenterFeed48.tar.gz` - Security Center feed

**İndirilen Dosyalar**: `/var/www/html/tenable/` dizininde saklanır.

### Adım 2: Dosyaları Transfer Edin

İndirilen paketleri güvenli bir şekilde air-gapped ağa taşıyın:
- USB medya
- Güvenli dosya transferi
- Onaylı medya transfer protokolü

### Adım 3: Güncellemeleri Yükleyin (Tenable Server)

Air-gapped Tenable server'da, önce yerel HTTP server'ınızı yapılandırın:

```bash
# nessus-updater.sh içindeki URL'yi düzenleyin
URL="http://<LOCAL_SERVER_IP>/tenable/all-2.0.tar.gz"
```

Ardından güncellemeyi çalıştırın:

```bash
sudo ./nessus-updater.sh
```

Script otomatik olarak:
1. Paketi indirir
2. Hash kontrolü yapar (gereksiz güncellemeyi önler)
3. Nessus'u günceller
4. Servisi yeniden başlatır

## ⚙️ Yapılandırma

### Download Script Ayarları

| Parametre | Açıklama | Varsayılan |
|-----------|----------|------------|
| `WORK_DIR` | İndirme dizini | `/var/www/html/tenable` |
| `PROXY_IP` | Proxy sunucu IP | Boş (proxy yok) |
| `PROXY_PORT` | Proxy portu | Boş (proxy yok) |

### Updater Script Ayarları

| Parametre | Açıklama | Varsayılan |
|-----------|----------|------------|
| `URL` | Paket indirme URL'i | `http://<IP>/tenable/all-2.0.tar.gz` |
| `UPDATE_DIR` | Güncelleme dizini | `/opt/nessus_update` |
| `NESSUS_BIN` | Nessus CLI yolu | `/opt/nessus/sbin/nessuscli` |
| `LOG_FILE` | Log dosyası | `/tmp/nessus_plugin_updater.txt` |

### Proxy Yapılandırması

Proxy kullanıyorsanız, `download-update-packages.sh` içinde:

```bash
PROXY_IP="proxy.example.com"
PROXY_PORT="8080"
```

## 🔧 Troubleshooting

### İndirme Hataları
```bash
# Log kontrolü
tail -f /var/www/html/tenable/update.log

# Yaygın sorunlar:
# - Hatalı lisans bilgileri
# - Proxy ayarları
# - Network bağlantısı
```

### Güncelleme Hataları
```bash
# Log kontrolü
tail -f /tmp/nessus_plugin_updater.txt

# Yaygın sorunlar:
# - Yetersiz disk alanı
# - Yetki problemleri
# - Bozuk paket dosyası
```

### Hash Uyumsuzluğu
Eğer hash kontrolü sürekli başarısız oluyorsa:
```bash
# Manuel hash kontrolü
sha256sum /opt/nessus_update/all-2.0.tar.gz
sha256sum /tmp/all-2.0.tar.gz
```

## 🔄 Otomatik Güncelleme

### Cron ile Planlama

**Download Machine**:
```bash
# Her gün 02:00'da güncelleme kontrolü
0 2 * * * /path/to/download-update-packages.sh
```

**Tenable Server** (manuel transfer sonrası):
```bash
# Her hafta Pazar 03:00'da güncelleme
0 3 * * 0 /path/to/nessus-updater.sh
```
