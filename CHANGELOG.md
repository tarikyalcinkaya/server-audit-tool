# Changelog

Tüm önemli değişiklikler bu dosyada belgelenir.

Format [Keep a Changelog](https://keepachangelog.com/tr/1.0.0/) standardına,
versiyonlama [Semantic Versioning](https://semver.org/lang/tr/) standardına uygundur.

## [0.0.2-beta] - 2026-01-30

### Added
- `65_ssh_attack_analysis.sh` - Coğrafi konum destekli detaylı SSH saldırı analizi
- Gelişmiş `docs/` klasör yapısı ve teknik dokümantasyon:
  - `ARCHITECTURE.md` - Mimari detaylar ve Clean Architecture katmanları
  - `MODULES.md` - Tüm test modüllerinin detaylı açıklaması
  - `API.md` - Geliştiriciler için kütüphane fonksiyonları referansı
- Risk skorlama algoritması başlangıcı (SSH modülü içinde)
- Proje Memory Bank (`PROJECT_MEMORY.md`) kapsamlı güncellemesi

## [0.0.1-beta] - 2026-01-30

### Added
- 🎉 İlk beta sürümü
- Modüler mimari (Clean Architecture)
- 6 temel güvenlik kontrol modülü
- Infrastructure Layer ile OS komut soyutlaması
- Presentation Layer ile renkli çıktı desteği

---

## [Unreleased]

### Planned
- [ ] HTML/JSON rapor export (Raporlama Katmanı)
- [ ] Modül bazlı severity scoring (Dinamik skorlama)
- [ ] Otomatik düzeltme (--fix) modu
- [ ] CI/CD entegrasyonu (Github Actions)
- [ ] Docker konteyner güvenlik taraması modülü
