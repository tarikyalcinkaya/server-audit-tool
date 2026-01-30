#!/bin/bash
# ==============================================
# Domain Layer - Ortam Güvenliği Modülü
# Sorumlu: Shell ortamı, banner ve geçici dosya alanı güvenliği
# ==============================================

run_environment_security_check() {
    print_header "9. ORTAM GÜVENLİĞİ"
    
    # --- Login Banner ---
    # Saldırganlara OS bilgisi vermemek için banner'lar temizlenmeli
    if [ -s /etc/issue.net ]; then
        print_warn "/etc/issue.net dosyası dolu. Dışarıdan bağlananlara OS bilgisi veriyor olabilir."
        print_suggestion "Banner dosyasını temizleyin veya yanıltıcı bilgi girin."
    else
        print_pass "Remote login banner (/etc/issue.net) temiz veya boş."
    fi
    
    # --- /tmp Mount Options ---
    # /tmp noexec, nosuid, nodev ile mount edilmeli
    if sys_check_mount_options "/tmp" | grep -q "noexec"; then
        print_pass "/tmp dizini 'noexec' ile mount edilmiş."
    else
        print_warn "/tmp dizininde uygulama çalıştırılabilir (noexec eksik)."
        print_suggestion "/etc/fstab dosyasına /tmp için 'noexec,nosuid,nodev' ekleyin."
    fi
    
    # --- HISTSIZE ---
    # Bu değişkeni script içinden kontrol etmek zor olabilir (subshell).
    # Genelde /etc/profile veya ~/.bashrc kontrolü gerekir.
    if grep -q "HISTSIZE" /etc/profile /home/*/.bashrc 2>/dev/null; then
         print_info "HISTORY boyutu yapılandırması bulundu."
    fi
    
    # --- Core Dumps ---
    # Hata ayıklama dosyaları hassas bilgi içerebilir
    if grep -q "* hard core 0" /etc/security/limits.conf 2>/dev/null; then
        print_pass "Core dump oluşumu kısıtlanmış."
    else
        print_info "Core dump kısıtlaması /etc/security/limits.conf içinde görünmüyor."
    fi
}
