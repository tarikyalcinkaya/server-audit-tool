# Mimari Dokümantasyon

Bu belge, Server Audit Tool'un teknik mimarisini ve tasarım kararlarını detaylandırır.

## Clean Architecture Yaklaşımı

Proje, bağımlılıkların yönetimi ve test edilebilirliği artırmak için katmanlı bir yapıda tasarlanmıştır.

### 1. Orchestration Layer (`main.sh`)
- **Görevi:** Diğer katmanları bir araya getirmek.
- **Sorumluluklar:**
    - Gerekli kütüphaneleri (`lib/*`) yüklemek.
    - `modules/` klasöründeki denetim modüllerini otomatik keşfetmek.
    - Modülleri sırayla çalıştırmak.
    - İstisnaları (permission denied vb.) yönetmek.

### 2. Presentation Layer (`lib/utils.sh`)
- **Görevi:** Kullanıcı arayüzü ve çıktı formatlama.
- **Sorumluluklar:**
    - Renk tanımlamaları (ANSI kodları).
    - Standart çıktı fonksiyonları (`print_pass`, `print_fail`, `print_header`).
    - Banner ve rapor özeti oluşturma.

### 3. Infrastructure Layer (`lib/system_adapter.sh`)
- **Görevi:** İşletim sistemiyle doğrudan iletişim kuran "adapter" katmanı.
- **Sorumluluklar:**
    - OS komutlarını sarmalamak (wrapper).
    - Komut varlığı kontrolü (`sys_command_exists`).
    - Paket kontrolü (`sys_package_installed`).
    - Dosya ve servis kontrolleri.

### 4. Domain Layer (`modules/*.sh`)
- **Görevi:** Gerçek güvenlik denetim mantığı (Business Logic).
- **Sorumluluklar:**
    - Belirli bir güvenlik alanını (SSH, Users, Network) denetlemek.
    - Infrastructure katmanını kullanarak veri toplamak.
    - Verileri analiz edip sonuç üretmek.
    - Presentation katmanını kullanarak sonucu raporlamak.

## Open-Closed Principle (OCP) Uygulaması

Yeni bir güvenlik kontrolü eklemek için mevcut kodun (örneğin `main.sh`) değiştirilmesine gerek yoktur. `modules/` dizinine eklenen her yeni `.sh` dosyası otomatik olarak sisteme dahil edilir ve çalıştırılır.

## Bağımlılık Kuralı

Bağımlılıklar her zaman dıştan içe doğru olmalıdır:
`Modules` -> `System Adapter` & `Utils`
`Main` -> `Everything`
