#!/bin/bash
# ==============================================
# Infrastructure Layer - System Adapter
# OS komutlarını soyutlayan wrapper fonksiyonları
# Modüller doğrudan sistemle konuşmaz, bu katmanı kullanır
# ==============================================

# --- Paket Yönetimi ---

sys_check_pending_updates() {
    # Bekleyen güncelleme sayısını döndürür
    apt-get update -qq 2>/dev/null
    apt list --upgradable 2>/dev/null | grep -v "Listing..." | wc -l
}

# --- Kullanıcı Yönetimi ---

sys_get_uid0_users() {
    # UID 0 olan kullanıcıları döndürür
    awk -F: '($3 == 0) {print $1}' /etc/passwd
}

sys_get_empty_password_users() {
    # Şifresi olmayan kullanıcıları döndürür
    awk -F: '($2 == "" ) {print $1}' /etc/shadow 2>/dev/null
}

sys_get_sudo_users() {
    # Sudo grubundaki kullanıcıları döndürür
    grep -Po '^sudo:.*:\K.*$' /etc/group 2>/dev/null
}

# --- Servis Yönetimi ---

sys_check_service_active() {
    # Servis aktif mi kontrol eder
    # Kullanım: sys_check_service_active "fail2ban"
    local service_name="$1"
    systemctl is-active --quiet "$service_name"
}

sys_check_service_exists() {
    # Servis kurulu mu kontrol eder
    local service_name="$1"
    systemctl list-unit-files | grep -q "^${service_name}"
}

# --- Komut Varlık Kontrolü ---

sys_command_exists() {
    # Komut sistemde var mı kontrol eder
    # Kullanım: sys_command_exists "ufw"
    command -v "$1" >/dev/null 2>&1
}

# --- Ağ ---

sys_get_all_listening_ports() {
    # Tüm dinlenen portları döndürür
    ss -tuln 2>/dev/null | grep LISTEN | awk '{print $5}' | sed 's/.*://' | sort -un | paste -sd "," -
}

sys_get_public_listening_ports() {
    # 0.0.0.0, [::] veya dış IP üzerinden dinlenen (gerçekten açık) portlar
    ss -tuln 2>/dev/null | grep LISTEN | awk '$5 !~ /127.0.0.1|::1/ {print $5}' | sed 's/.*://' | sort -un | paste -sd "," -
}

sys_get_local_listening_ports() {
    # Sadece 127.0.0.1 veya ::1 üzerinden dinlenen (yerel) portlar
    ss -tuln 2>/dev/null | grep LISTEN | awk '$5 ~ /127.0.0.1|::1/ {print $5}' | sed 's/.*://' | sort -un | paste -sd "," -
}

sys_get_ufw_status() {
    # UFW durumunu döndürür
    ufw status 2>/dev/null
}

# --- Dosya Sistemi ---

sys_get_file_permissions() {
    # Dosya izinlerini "perm owner:group" formatında döndürür
    # Kullanım: sys_get_file_permissions "/etc/shadow"
    local file_path="$1"
    if [ -e "$file_path" ]; then
        stat -c "%a %U:%G" "$file_path" 2>/dev/null
    else
        echo "NOT_FOUND"
    fi
}

sys_file_exists() {
    # Dosya var mı kontrol eder
    [ -f "$1" ]
}

# --- Konfigürasyon Okuma ---

sys_grep_config() {
    # Config dosyasında pattern arar
    # Kullanım: sys_grep_config "/etc/ssh/sshd_config" "^PermitRootLogin"
    local config_file="$1"
    local pattern="$2"
    grep -q "$pattern" "$config_file" 2>/dev/null
}

sys_get_config_value() {
    # Config dosyasından değer okur
    # Kullanım: sys_get_config_value "/etc/ssh/sshd_config" "^Port"
    local config_file="$1"
    local pattern="$2"
    grep "$pattern" "$config_file" 2>/dev/null | awk '{print $2}'
}

# --- Log Analizi ---

sys_get_ssh_failed_attempts_journal() {
    # Journalctl'dan bugünkü başarısız SSH denemelerini sayar
    journalctl -u ssh -S today --no-pager 2>/dev/null | grep "Failed password" | wc -l
}

sys_get_ssh_failed_attempts_authlog() {
    # auth.log'dan başarısız SSH denemelerini sayar
    grep "Failed password" /var/log/auth.log 2>/dev/null | wc -l
}

sys_get_failed_ssh_ips_journal() {
    # Journalctl'dan başarısız IP'leri döndürür
    journalctl -u ssh -S today --no-pager 2>/dev/null | grep "Failed password" | awk '{print $(NF-3)}' | sort | uniq -c | sort -nr | head -n 3
}

sys_get_failed_ssh_ips_authlog() {
    # auth.log'dan başarısız IP'leri döndürür
    grep "Failed password" /var/log/auth.log 2>/dev/null | awk '{print $(NF-3)}' | sort | uniq -c | sort -nr | head -n 3
}

# --- Gelişmiş SSH Analiz Fonksiyonları ---

sys_get_top_attacker_ips() {
    # Top N saldırgan IP'yi döndürür (varsayılan 10)
    local count="${1:-10}"
    if sys_command_exists "journalctl"; then
        journalctl -u ssh -S today --no-pager 2>/dev/null | \
            grep "Failed password" | \
            awk '{print $(NF-3)}' | \
            sort | uniq -c | sort -nr | head -n "$count"
    elif sys_file_exists "/var/log/auth.log"; then
        grep "Failed password" /var/log/auth.log 2>/dev/null | \
            awk '{print $(NF-3)}' | \
            sort | uniq -c | sort -nr | head -n "$count"
    fi
}

sys_get_targeted_usernames() {
    # En çok hedeflenen kullanıcı adlarını döndürür
    local count="${1:-5}"
    if sys_command_exists "journalctl"; then
        journalctl -u ssh -S today --no-pager 2>/dev/null | \
            grep "Failed password" | \
            grep -oP "for \K\w+" | \
            sort | uniq -c | sort -nr | head -n "$count"
    elif sys_file_exists "/var/log/auth.log"; then
        grep "Failed password" /var/log/auth.log 2>/dev/null | \
            grep -oP "for \K\w+" | \
            sort | uniq -c | sort -nr | head -n "$count"
    fi
}

sys_get_hourly_attack_distribution() {
    # Saat bazlı saldırı dağılımını döndürür
    if sys_command_exists "journalctl"; then
        journalctl -u ssh -S today --no-pager 2>/dev/null | \
            grep "Failed password" | \
            awk '{print substr($3,1,2)":00"}' | \
            sort | uniq -c | sort -k2
    elif sys_file_exists "/var/log/auth.log"; then
        grep "Failed password" /var/log/auth.log 2>/dev/null | \
            awk '{print substr($3,1,2)":00"}' | \
            sort | uniq -c | sort -k2
    fi
}

sys_check_ip_banned() {
    # IP'nin Fail2Ban'da banlı olup olmadığını kontrol eder
    local ip="$1"
    if sys_command_exists "fail2ban-client"; then
        fail2ban-client status sshd 2>/dev/null | grep -q "$ip"
        return $?
    fi
    return 1
}

# --- Kernel Hardening ---

sys_get_sysctl_value() {
    # Kernel parametresini okur
    # Kullanım: sys_get_sysctl_value "net.ipv4.ip_forward"
    sysctl -n "$1" 2>/dev/null
}

# --- Servis ve Süreçler ---

sys_get_active_services() {
    # Aktif servisleri listeler
    systemctl list-units --type=service --state=active --no-pager --plain | awk '{print $1}'
}

sys_get_listening_processes() {
    # Dinleyen süreçleri ve portları getirir
    ss -tulpn 2>/dev/null
}

sys_get_processes_from_tmp() {
    # /tmp veya /dev/shm üzerinden çalışan süreçleri bulur
    ls -l /proc/*/exe 2>/dev/null | grep -E "/tmp/|/dev/shm/" | awk '{print $9, $11}'
}

# --- Dosya ve İzinler ---

sys_find_suid_files() {
    # SUID bit set edilmiş dosyaları bulur
    find / -type f -perm -4000 2>/dev/null
}

sys_find_world_writeable_files() {
    # Herkesin yazabildiği dosyaları bulur
    find / -xdev -type f -perm -0002 2>/dev/null
}

sys_find_unowned_files() {
    # Sahibi olmayan dosyaları bulur
    find / -xdev \( -nouser -o -nogroup \) 2>/dev/null
}

sys_find_sensitive_files() {
    # Hassas olabilecek dosyaları arar (.env, .pem, vb)
    # Bu işlem uzun sürebilir, sadece belirli dizinlerde aranmalı
    local search_path="${1:-/var/www}"
    find "$search_path" -type f \( -name ".env" -o -name "*.pem" -o -name "*.key" -o -name "id_rsa" \) 2>/dev/null
}

sys_calculate_file_hash() {
    # Dosyanın SHA256 hash'ini hesaplar
    local file_path="$1"
    if [ -f "$file_path" ]; then
        sha256sum "$file_path" | awk '{print $1}'
    fi
}

sys_check_mount_options() {
    # Mount seçeneklerini kontrol eder (/tmp noexec mi?)
    mount | grep "on $1 type"
}

# --- Kötü Amaçlı Yazılım Taraması ---

sys_check_clamav() {
    # ClamAV kurulu mu?
    command -v clamscan >/dev/null 2>&1
}

sys_run_clamav_scan() {
    # Belirtilen dizini tarar (Örn: /tmp)
    local scan_dir="$1"
    if sys_check_clamav; then
        clamscan -r --no-summary --infected "$scan_dir" 2>/dev/null
    fi
}

sys_run_rkhunter() {
    # RKHunter kontrolü (warning verenleri döndürür)
    if command -v rkhunter >/dev/null 2>&1; then
        rkhunter --check --rwo --sk 2>/dev/null
    fi
}

# --- Ağ Keşfi ---

sys_check_promiscuous() {
    # Promiscuous moddaki arayüzleri bulur
    ip link | grep "PROMISC"
}

sys_get_arp_table() {
    # ARP tablosunu döndürür
    ip neigh show
}

# --- Boot ve SSL ---

sys_read_file_content() {
    # Dosya içeriğini okur
    local file_path="$1"
    if [ -f "$file_path" ]; then
        cat "$file_path"
    fi
}

sys_check_ssl_expiry() {
    # SSL sertifikasının bitiş tarihini kontrol eder
    local cert_file="$1"
    if [ -f "$cert_file" ]; then
        openssl x509 -enddate -noout -in "$cert_file" 2>/dev/null | cut -d= -f2
    fi
}

# --- Cron ve Geçmiş ---

sys_get_cron_jobs() {
    # Tüm kullanıcıların cron işlerini listeler
    for user in $(cut -f1 -d: /etc/passwd); do
        crontab -u "$user" -l 2>/dev/null | grep -v "^#"
    done
    ls -1 /etc/cron.* 2>/dev/null
}

sys_get_login_history() {
    # Giriş geçmişini alır
    last -n 20
}
