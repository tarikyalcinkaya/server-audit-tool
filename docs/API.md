# Library API Referansı

Bu belge, modül geliştiricilerinin kullanabileceği kütüphane fonksiyonlarını listeler.

## Infrastructure Katmanı (`lib/system_adapter.sh`)

Bu katman, işletim sistemi komutlarını güvenli bir şekilde sarmalar.

### Paket Yönetimi
- `sys_check_pending_updates()`: Bekleyen güncelleme sayısını döndürür.

### Kullanıcı Yönetimi
- `sys_get_uid0_users()`: UID değeri 0 olan (root yetkili) kullanıcıları listeler.
- `sys_get_empty_password_users()`: Şifresi boş olan kullanıcıları bulur.
- `sys_get_sudo_users()`: `sudo` grubundaki kullanıcıları listeler.

### Servis ve Komut Kontrolü
- `sys_command_exists(cmd)`: Belirtilen komutun sistemde kurulu olup olmadığını kontrol eder.
- `sys_check_service_active(service)`: Belirtilen servisin çalışıp çalışmadığını kontrol eder.
- `sys_check_service_exists(service)`: Servisin sistemde yüklü olup olmadığını kontrol eder.

### Dosya İşlemleri
- `sys_file_exists(path)`: Belirtilen yolda dosya olup olmadığını kontrol eder.
- `sys_get_file_permissions(path)`: Dosya izinlerini ve sahipliğini (örn: `600 root:root`) döndürür.
- `sys_grep_config(file, pattern)`: Konfigürasyon dosyasında belirli bir satırı arar.
- `sys_get_config_value(file, pattern)`: Konfigürasyon dosyasından değer (ikinci sütun) çeker.

### Ağ İşlemleri
- `sys_get_all_listening_ports()`: Sistemde dinlenen tüm portları döner.
- `sys_get_public_listening_ports()`: Dış dünyaya (0.0.0.0, [::]) açık portları döner.
- `sys_get_local_listening_ports()`: Sadece localhost (127.0.0.1, ::1) üzerinden dinlenen portları döner.
- `sys_get_ufw_status()`: UFW güvenlik duvarının ham durum çıktısını döner.

### Gelişmiş Log Analizi
- `sys_get_top_attacker_ips(n)`: En aktif N saldırgan IP adresini ve deneme sayılarını döner.
- `sys_get_targeted_usernames(n)`: En çok saldırıya uğrayan N kullanıcı adını döner.
- `sys_get_hourly_attack_distribution()`: Saatlik saldırı yoğunluğunu döner.
- `sys_check_ip_banned(ip)`: IP'nin Fail2Ban tarafından engellenip engellenmediğini kontrol eder.

## Presentation Katmanı (`lib/utils.sh`)

Bu katman, çıktıların kullanıcıya nasıl görüneceğini yönetir.

### Çıktı Fonksiyonları
- `print_header(text)`: Yeni bir denetim bölümü başlığı yazdırır.
- `print_pass(message)`: Başarılı bir kontrolü yeşil renkle yazdırır.
- `print_fail(message)`: Başarısız bir kontrolü kırmızı renkle yazdırır.
- `print_info(message)`: Bilgi mesajlarını mavi renkle yazdırır.
- `print_warning(message)`: Uyarı mesajlarını sarı renkle yazdırır.
- `print_suggestion(text)`: Çözüm önerilerini formatlı bir şekilde yazdırır.
- `print_banner()`: Uygulama logosunu ve sürüm bilgisini yazdırır.
- `print_summary(passed, failed, warnings)`: Denetim bitişinde özet raporu sunar.
