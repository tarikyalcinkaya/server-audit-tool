# Denetim Modülleri Referansı

Server Audit Tool, modüler bir yapıdadır. Her modül bağımsız bir güvenlik kategorisini temsil eder.

## Mevcut Modüller

### 10_system.sh - Sistem Güncellik Modülü
- **Kapsam:** Debian tabanlı sistemlerdeki paket güncellemelerini kontrol eder.
- **Kontroller:** `apt update` simülasyonu ile bekleyen güvenlik güncellemelerini tespit eder.

### 20_users.sh - Kullanıcı Güvenliği Modülü
- **Kapsam:** Sistem kullanıcıları ve yetkileri.
- **Kontroller:**
    - UID 0 (root yetkili) olan diğer kullanıcılar.
    - Boş şifresi olan hesaplar.
    - Sudo grubundaki kullanıcıların listelenmesi.

### 30_ssh.sh - SSH Sıkılaştırma Modülü
- **Kapsam:** `/etc/ssh/sshd_config` analizi.
- **Kontroller:**
    - Root login (`PermitRootLogin`).
    - Parola ile giriş (`PasswordAuthentication`).
    - Varsayılan port kullanımı.

### 40_network.sh - Ağ Modülü
- **Kapsam:** Firewall ve ağ güvenliği servisleri.
- **Kontroller:**
    - UFW (Uncomplicated Firewall) durumu.
    - Fail2Ban servis durumu ve konfigürasyonu.

### 50_permissions.sh - Dosya İzinleri Modülü
- **Kapsam:** Kritik sistem dosyalarının yetkileri.
- **Kontroller:**
    - `/etc/shadow`, `/etc/passwd`, `/etc/sudoers` gibi dosyaların izinleri (chmod).

### 60_logs.sh - Temel Log Analizi
- **Kapsam:** Sistem loglarının ilk seviye incelenmesi.
- **Kontroller:** Son başarısız giriş denemeleri.

### 65_ssh_attack_analysis.sh - Gelişmiş SSH Saldırı Analizi
- **Kapsam:** Derinlemesine log analizi ve istihbarat.
- **Kontroller:**
    - Top 10 saldırgan IP tespiti.
    - IP coğrafi konum tespiti (Geolocation).
    - Hedeflenen kullanıcı adları frekansı.
    - Saat bazlı saldırı yoğunluğu grafiği.
    - Dinamik risk skoru (1-10) hesaplama.

## Yeni Modül Oluşturma Rehberi

1. `modules/` klasöründe `90_test.sh` gibi bir dosya oluşturun.
2. `run_test_check()` isimli bir ana fonksiyon tanımlayın (isimlendirme formatı: `run_MODULENAME_check`).
3. Fonksiyon içinde `print_header` ile başlayın.
4. Kontrolleri `sys_*` fonksiyonları üzerinden yapın.
5. Sonuçları `print_pass`, `print_fail` veya `print_info` ile yazdırın.
