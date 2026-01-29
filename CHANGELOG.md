# Changelog

Tüm önemli değişiklikler bu dosyada belgelenir.

Format [Keep a Changelog](https://keepachangelog.com/tr/1.0.0/) standardına,
versiyonlama [Semantic Versioning](https://semver.org/lang/tr/) standardına uygundur.

## [0.0.1-beta] - 2026-01-30

### Added
- 🎉 İlk beta sürümü
- Modüler mimari (Clean Architecture)
- 6 güvenlik kontrol modülü:
  - `10_system.sh` - Sistem güncellik kontrolü
  - `20_users.sh` - Kullanıcı güvenliği (UID 0, şifresiz hesaplar)
  - `30_ssh.sh` - SSH sıkılaştırma analizi
  - `40_network.sh` - UFW ve Fail2Ban kontrolü
  - `50_permissions.sh` - Kritik dosya izinleri
  - `60_logs.sh` - SSH log analizi
- Otomatik modül keşfi (OCP prensibi)
- Infrastructure Layer ile OS komut soyutlaması
- Presentation Layer ile renkli çıktı desteği
- PROJECT_MEMORY.md (Memory Bank) dokümantasyonu

### Architecture
- `main.sh` - Orchestration Layer
- `lib/utils.sh` - Presentation Layer
- `lib/system_adapter.sh` - Infrastructure Layer
- `modules/*.sh` - Domain Layer

---

## [Unreleased]

### Planned
- [ ] HTML/JSON rapor export
- [ ] Modül bazlı severity scoring
- [ ] Otomatik düzeltme (--fix) modu
- [ ] CI/CD entegrasyonu
- [ ] Docker desteği
