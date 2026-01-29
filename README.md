# Server Audit Tool

[![Version](https://img.shields.io/badge/version-0.0.1--beta-orange.svg)](https://github.com/yourusername/server-audit-tool/releases)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20Raspberry%20Pi-lightgrey.svg)]()

🔒 **Modüler Linux/Raspberry Pi Güvenlik Denetim Aracı**

Clean Architecture ve SOLID prensiplerine uygun, genişletilebilir güvenlik tarama aracı.

## ✨ Özellikler

- 🔄 **Sistem Güncellik Kontrolü** - Bekleyen paket güncellemeleri
- 👤 **Kullanıcı Güvenliği** - UID 0 kontrolü, şifresiz hesaplar, sudo kullanıcıları
- 🔐 **SSH Sıkılaştırma** - Root login, parola auth, port analizi
- 🛡️ **Firewall Durumu** - UFW, Fail2Ban kontrolü
- 📁 **Dosya İzinleri** - /etc/shadow, /etc/passwd, /etc/sudoers
- 📊 **Log Analizi** - Başarısız SSH girişleri

## 🚀 Kurulum

```bash
# Repository'yi klonla
git clone https://github.com/tarikyalcinkaya/server-audit-tool.git
cd server-audit-tool

# Çalıştırma yetkisi ver
chmod +x main.sh

# Denetimi başlat (root gerekli)
sudo ./main.sh
```

## 📁 Proje Yapısı

```
server-audit-tool/
├── main.sh                    # Ana giriş noktası (Orchestration)
├── lib/
│   ├── utils.sh               # UI/Renkler (Presentation Layer)
│   └── system_adapter.sh      # OS Wrapper (Infrastructure Layer)
└── modules/
    ├── 10_system.sh           # Sistem güncellik
    ├── 20_users.sh            # Kullanıcı güvenliği
    ├── 30_ssh.sh              # SSH sıkılaştırma
    ├── 40_network.sh          # Ağ/Firewall
    ├── 50_permissions.sh      # Dosya izinleri
    └── 60_logs.sh             # Log analizi
```

## 🔧 Yeni Modül Ekleme

`modules/` klasörüne yeni bir `NN_isim.sh` dosyası ekle:

```bash
#!/bin/bash
# modules/70_custom.sh

run_custom_check() {
    print_header "7. ÖZEL KONTROL"
    
    if sys_command_exists "mycommand"; then
        print_pass "Kontrol başarılı."
    else
        print_fail "Kontrol başarısız."
        print_suggestion "Çözüm önerisi..."
    fi
}
```

> **Not:** `main.sh` dosyasını değiştirmeye gerek yok - modül otomatik keşfedilir!

## 🏗️ Mimari

| Katman | Dosya | Sorumluluk |
|--------|-------|------------|
| **Orchestration** | `main.sh` | Modül yükleme ve çalıştırma |
| **Presentation** | `lib/utils.sh` | Renkli çıktı, log formatları |
| **Infrastructure** | `lib/system_adapter.sh` | `sys_*` wrapper fonksiyonları |
| **Domain** | `modules/*.sh` | Güvenlik kontrol mantığı |

## 📋 Gereksinimler

- Linux (Debian/Ubuntu/Raspberry Pi OS)
- Bash 4.0+
- Root yetkisi (sudo)

## 🤝 Katkıda Bulunma

Katkılarınızı bekliyoruz! Lütfen [CONTRIBUTING.md](CONTRIBUTING.md) dosyasını okuyun.

## 📄 Lisans

Bu proje [MIT Lisansı](LICENSE) altında lisanslanmıştır.

## 📝 Changelog

Tüm değişiklikler için [CHANGELOG.md](CHANGELOG.md) dosyasına bakın.
