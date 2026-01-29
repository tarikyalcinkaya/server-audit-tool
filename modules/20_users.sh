#!/bin/bash
# ==============================================
# Domain Layer - Kullanıcı Güvenliği Modülü
# Sorumlu: UID 0, şifresiz hesaplar, sudo kullanıcıları
# ==============================================

run_users_check() {
    print_header "2. KULLANICI GÜVENLİĞİ"
    
    # --- UID 0 Kontrolü ---
    local uid0_users
    uid0_users=$(sys_get_uid0_users)
    
    if [ "$uid0_users" == "root" ]; then
        print_pass "UID 0 olan tek kullanıcı 'root'."
    else
        print_fail "UID 0 olan bilinmeyen kullanıcılar var: $uid0_users (BACKDOOR RİSKİ!)"
        print_suggestion "Bu kullanıcıyı tanımıyorsanız hemen silin: userdel <kullanıcı>"
    fi
    
    # --- Şifresiz Hesap Kontrolü ---
    local empty_pass
    empty_pass=$(sys_get_empty_password_users)
    
    if [ -z "$empty_pass" ]; then
        print_pass "Parolasız kullanıcı bulunamadı."
    else
        print_fail "Parolasız kullanıcılar tespit edildi: $empty_pass"
        print_suggestion "Şifre belirleyin: passwd <kullanıcı>"
    fi
    
    # --- Sudo Kullanıcıları ---
    local sudoers
    sudoers=$(sys_get_sudo_users)
    print_info "Sudo grubundaki kullanıcılar: ${sudoers:-Yok}"
}
