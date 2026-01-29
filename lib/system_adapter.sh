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

sys_get_listening_ports() {
    # Dinlenen portları virgülle ayrılmış liste olarak döndürür
    ss -tuln 2>/dev/null | grep LISTEN | awk '{print $5}' | cut -d: -f2 | sort -u | paste -sd "," - | sed 's/^,//'
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
    if [ -f "$file_path" ]; then
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
