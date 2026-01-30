#!/bin/bash
# ==============================================
# Domain Layer - Boot (Önyükleme) Güvenliği
# Sorumlu: GRUB, Bootloader güvenliği, Hardware arayüzleri
# ==============================================

run_boot_security_check() {
    print_header "26. BOOT GÜVENLİĞİ"
    
    # 1. GRUB Parolası (x86/x64 Debian/Linux)
    if [ -f "/boot/grub/grub.cfg" ]; then
        if grep -q "password_pbkdf2" /boot/grub/grub.cfg; then
            print_pass "GRUB bootloader parola korumalı."
        else
            print_warn "GRUB bootloader parolasız (Fiziksel erişimi olan biri root parametresiyle sistemi açabilir)."
            print_suggestion "grub-mkpasswd-pbkdf2 ile parola oluşturup /etc/grub.d/40_custom dosyasına ekleyin."
        fi
    fi
    
    # 2. Raspberry Pi Config (/boot/config.txt)
    # Donanım arayüzleri kontrolü
    if [ -f "/boot/config.txt" ] || [ -f "/boot/firmware/config.txt" ]; then
        local config_txt="/boot/config.txt"
        [ -f "/boot/firmware/config.txt" ] && config_txt="/boot/firmware/config.txt"
        
        print_info "Raspberry Pi yapılandırması ($config_txt) kontrol ediliyor..."
        
        local cam_status
        cam_status=$(grep "^start_x=1" "$config_txt")
        if [ -n "$cam_status" ]; then
            print_info "Kamera arayüzü aktif."
        fi
        
        local ssh_boot
        if [ -f "/boot/ssh" ] || [ -f "/boot/firmware/ssh" ]; then
            print_warn "Boot bölümünde 'ssh' dosyası var (SSH otomatik aktif oluyor)."
        fi
    fi
    
    # 3. Secure Boot (UEFI)
    # mokutil aracı varsa kontrol edilebilir
    if sys_command_exists "mokutil"; then
        if mokutil --sb-state 2>/dev/null | grep -q "enabled"; then
             print_pass "Secure Boot (UEFI) aktif."
        else
             print_warn "Secure Boot kapalı."
        fi
    fi
}
