#!/bin/bash
# ==============================================
# Domain Layer - Otomatik Güncelleme Denetimi
# Sorumlu: Unattended-upgrades durumu
# ==============================================

run_auto_updates_check() {
    print_header "27. OTOMATİK GÜNCELLEME"
    
    # unattended-upgrades paket kontrolü
    if sys_command_exists "unattended-upgrade"; then
        print_pass "unattended-upgrades paketi kurulu."
    else
        print_warn "unattended-upgrades paketi kurulu değil."
        print_suggestion "Kurulum ve yapılandırma: sudo apt install unattended-upgrades"
        return
    fi
    
    # Yapılandırma kontrolü (/etc/apt/apt.conf.d/20auto-upgrades)
    local auto_upgrade_conf="/etc/apt/apt.conf.d/20auto-upgrades"
    if [ -f "$auto_upgrade_conf" ]; then
        if grep -q 'APT::Periodic::Update-Package-Lists "1"' "$auto_upgrade_conf" && \
           grep -q 'APT::Periodic::Unattended-Upgrade "1"' "$auto_upgrade_conf"; then
            print_pass "Otomatik güvenlik güncellemeleri AKTİF."
        else
            print_warn "Otomatik güncelleme kurulu ama yapılandırma pasif görünüyor."
            print_suggestion "Etkinleştirme: sudo dpkg-reconfigure --priority=low unattended-upgrades"
        fi
    else
        print_warn "Otomatik güncelleme yapılandırma dosyası bulunamadı."
    fi
}
