#!/bin/bash
# ==============================================
# Domain Layer - Sistem Hesapları Sıkılaştırma
# Sorumlu: Servis kullanıcılarının (UID < 1000) shell erişimini denetleme
# ==============================================

run_system_account_hardening_check() {
    print_header "15. SİSTEM HESAPLARI GÜVENLİĞİ"
    
    # UID 1000'den küçük olup shell'i /bin/bash veya /bin/sh olanları bul
    # Root (UID 0) ve sync gibi bazı özel hesaplar hariç tutulabilir.
    
    print_info "Login shell'i aktif olan sistem kullanıcıları taranıyor..."
    
    local risky_accounts
    risky_accounts=$(awk -F: '($3 < 1000 && $3 != 0 && $7 !~ /nologin|false/) {print $1, $7}' /etc/passwd)
    
    if [ -n "$risky_accounts" ]; then
        print_warn "Shell erişimi olan sistem hesapları bulundu (Riskli olabilir):"
        echo "$risky_accounts" | while read -r line; do
            echo "   - $line"
        done
        print_suggestion "Bu hesaplar için 'usermod -s /usr/sbin/nologin <user>' komutunu kullanın."
    else
        print_pass "Tüm sistem hesaplarının shell erişimi kapalı (/usr/sbin/nologin veya /bin/false)."
    fi
}
