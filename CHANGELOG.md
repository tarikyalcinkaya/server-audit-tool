# Changelog

Tüm önemli değişiklikler bu dosyada belgelenir.

Format [Keep a Changelog](https://keepachangelog.com/tr/1.0.0/) standardına,
versiyonlama [Semantic Versioning](https://semver.org/lang/tr/) standardına uygundur.

## [0.0.3-beta] - 2026-01-30

### Added
- **İnteraktif Modül Seçimi:** `main.sh` argümansız çalıştırıldığında kullanıcıya hangi modülleri çalıştırmak istediğini soran menü eklendi.
- **CLI Argüman Desteği:** `sudo ./main.sh ssh network` gibi belirli modülleri doğrudan argüman olarak verme desteği eklendi.
- **UI İyileştirmeleri:** `lib/utils.sh` içerisine modül listeleme fonksiyonları eklendi.
- **Ağ Analizi İyileştirmesi:** "Dinleyen port" ile "İnternete açık port" ayrımı eklendi. IPv6 port tespiti düzeltildi.

## [0.3.0-beta] - 2026-01-30

### Added
- **Kapsamlı Güvenlik Genişletmesi (22+ Yeni Modül):**
  - **Forensik & İzleme:** Bash geçmişi (`190`), Giriş aktiviteleri (`200`), Cron (`230`) ve Süreç analizi (`240`).
  - **Ağ Güvenliği:** Derin Ağ Taraması (`210` - Promiscuous, ARP Spoofing).
  - **Uygulama Güvenliği:** Docker Daemon/Container (`170`), SSL Sertifika (`250`).
  - **Erişim Yönetimi:** PAM Parola Politikaları (`180`), USB Güvenliği (`280`).
  - **Dosya Sistemi:** Detaylı İzin (`220`), Boot/GRUB Güvenliği (`260`).
- **Raporlama Sistemi:** Tüm denetim sonuçları artık tarih damgalı `audit_report_YYYYMMDD.txt` dosyasına kaydediliyor.
- **Evrensel Linux Desteği:** Araç artık sadece Raspberry Pi değil, Debian/Ubuntu tabanlı genel sunucular için optimize edildi.

## [0.2.0-alpha] - 2026-01-30

### Added
- **Gelişmiş Tehdit Taraması:**
  - `110_virus_scan.sh`: ClamAV ile virüs tarama entegrasyonu.
  - `120_rootkit_scan.sh`: RKHunter ve Chkrootkit ile rootkit taraması.
  - `160_information_leakage.sh`: Hassas dosya (.env, .git, private keys) sızıntı taraması.
- **Sistem Sıkılaştırma:**
  - `130_file_integrity.sh`: Kritik sistem dosyaları (passwd, shadow, bin/*) için hash kontrolü.
  - `140_shared_memory.sh`: `/dev/shm` ve `/run/shm` güvenli mount seçenekleri kontrolü.
  - `150_system_account_hardening.sh`: Sistem hesaplarının (UID < 1000) shell erişim denetimi.

## [0.1.0-alpha] - 2026-01-30

### Added
- **Güvenlik Çekirdeği Genişletmesi:**
  - `70_kernel_hardening.sh`: Kritik kernel parametreleri (sysctl) denetimi.
  - `80_services_audit.sh`: Telnet, FTP gibi güvensiz aktif servis taraması.
  - `90_environment_security.sh`: Login banner'ları, /tmp mount güvenliği.
  - `100_suid_guid_audit.sh`: SUID/SGID bit'e sahip riskli dosya analizi.
- **Altyapı (Infrastructure):** `sys_get_sysctl_value`, `sys_find_suid_files` gibi yeni yardımcı fonksiyonlar.

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
