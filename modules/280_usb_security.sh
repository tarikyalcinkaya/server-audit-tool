#!/bin/bash
# ==============================================
# Domain Layer - USB ve Çevre Birim Güvenliği
# Sorumlu: USB automount, yetkisiz cihaz engelleme
# ==============================================

run_usb_security_check() {
    print_header "28. USB GÜVENLİĞİ"
    
    # 1. USB Storage Modülü (Kritik sunucularda kapatılmalı)
    if [ -f "/etc/modprobe.d/blacklist-usb-storage.conf" ] || grep -q "install usb-storage /bin/true" /etc/modprobe.d/* 2>/dev/null; then
        print_pass "USB Storage kernel modülü yasaklanmış (Güvenli)."
    else
        print_warn "USB Storage erişimine izin veriliyor (Fiziksel erişim riski)."
        print_suggestion "USB kullanmıyorsanız devre dışı bırakın: echo 'install usb-storage /bin/true' > /etc/modprobe.d/blacklist-usb-storage.conf"
    fi
    
    # 2. USBGuard Kontrolü
    if sys_command_exists "usbguard"; then
        print_pass "USBGuard yüklü (USB cihaz beyaz listesi aktif)."
        
        # Aktif mi?
        if sys_check_service_active "usbguard"; then
            print_pass "USBGuard servisi çalışıyor."
        else
             print_warn "USBGuard yüklü ama servis çalışmıyor."
        fi
    else
        print_info "USBGuard kurulu değil (USB cihazlarını whitelist yapmak için önerilir)."
    fi
    
    # 3. Desktop Automount (Eğer masaüstü ortamı varsa)
    # usbmount paketini kontrol et
    if dpkg -l | grep -q "usbmount"; then
        print_fail "usbmount paketi yüklü! USB takıldığında otomatik bağlanır (Riskli)."
        print_suggestion "Gerekli değilse kaldırın: sudo apt remove usbmount"
    fi
}
