# PROJECT MEMORY - Raspberry Pi Security Audit Tool (v0.3.4-beta)

## Context

**Amaç:** Raspberry Pi ve Linux sunucuları için modüler, genişletilebilir güvenlik denetim aracı.

**Hedef Kitle:** Sistem yöneticileri, güvenlik uzmanları, Raspberry Pi kullanıcıları.

**Mimari Prensipler:**
- Clean Architecture (Katmanlı yapı)
- SOLID Prensipleri (SRP, OCP)
- Separation of Concerns

---

## Architectural Map

```
rpi-audit-tool/
├── main.sh                    # Orkestrasyon - Sadece modül yükler ve çalıştırır
├── lib/
│   ├── utils.sh               # Presentation Layer - UI, renkler, log formatları
│   └── system_adapter.sh      # Infrastructure Layer - OS komut wrapper'ları
├── modules/
│   ├── 10_system.sh           # Domain - Sistem güncelleme kontrolü
│   ├── 20_users.sh            # Domain - Kullanıcı güvenliği
│   ├── 30_ssh.sh              # Domain - SSH sıkılaştırma
│   ├── 40_network.sh          # Domain - Ağ/Firewall
│   ├── 50_permissions.sh      # Domain - Dosya izinleri
│   ├── 60_logs.sh             # Domain - Log analizi
│   └── 65_ssh_attack_analysis.sh  # Domain - Detaylı SSH saldırı analizi
└── docs/                      # Dokümantasyon klasörü
    ├── ARCHITECTURE.md        # Mimari detayları
    ├── MODULES.md             # Modül referansı
    └── API.md                 # Library API referansı
```

### Katman Sorumlulukları

| Katman | Dosya | Sorumluluk |
|--------|-------|------------|
| **Orchestration** | `main.sh` | Kütüphaneleri yükle, modülleri keşfet ve çalıştır |
| **Presentation** | `lib/utils.sh` | Renkli çıktı, banner, log formatları |
| **Infrastructure** | `lib/system_adapter.sh` | `sys_*` fonksiyonları - OS'la iletişim |
| **Domain** | `modules/*.sh` | İş mantığı - Güvenlik kontrolleri |

---

## Rules

### Yeni Modül Ekleme Kuralları

1. **Dosya Adlandırma:** `modules/NN_isim.sh` formatında (NN: 2 haneli sıra numarası)
2. **Fonksiyon İsmi:** `run_MODULENAME_check()` şeklinde export edilmeli
3. **Sistem Komutları:** Doğrudan `systemctl`, `apt` vs. çağırma! `lib/system_adapter.sh` fonksiyonlarını kullan
4. **UI Çıktıları:** `lib/utils.sh` fonksiyonlarını kullan (`print_pass`, `print_fail`, vb.)
5. **Self-Contained:** Her modül bağımsız çalışabilmeli

### Örnek Modül Şablonu

```bash
#!/bin/bash
# modules/70_example.sh - Örnek modül

run_example_check() {
    print_header "7. ÖRNEK KONTROL"
    
    # Infrastructure katmanını kullan
    if sys_command_exists "example_cmd"; then
        print_pass "Örnek kontrol başarılı."
    else
        print_fail "Örnek kontrol başarısız."
        print_suggestion "Çözüm önerisi..."
    fi
}
```

---

## State

### Tamamlanan İşler

- [x] Legacy script analizi
- [x] Mimari tasarım
- [x] PROJECT_MEMORY.md oluşturuldu
- [x] lib/utils.sh (Presentation)
- [x] lib/system_adapter.sh (Infrastructure)
- [x] main.sh (Orchestration)
- [x] 6 temel güvenlik modülü (Domain)
- [x] 65_ssh_attack_analysis.sh (Gelişmiş SSH Analizi)
- [x] Merkezi dokümantasyon yapısı (docs/)
- [x] İnteraktif modül seçim desteği (main.sh)
- [x] CLI argümanları ile modül filitreleme
- [x] Port dinleme analizinde yerel/public ayrımı

### Gelecek Geliştirmeler

- [ ] HTML/JSON rapor export (Raporlama Katmanı)
- [ ] Modül bazlı severity scoring (Dinamik skorlama)
- [ ] Otomatik düzeltme (--fix) modu
- [ ] CI/CD entegrasyonu (Github Actions)
- [ ] Docker konteyner güvenlik taraması modülü

