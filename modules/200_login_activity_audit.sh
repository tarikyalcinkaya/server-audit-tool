#!/bin/bash
# ==============================================
# Domain Layer - Giriş Aktivite Denetim Modülü
# Sorumlu: Başarılı/Başarısız girişlerin (last, lastb) analizi
# ==============================================

run_login_activity_audit_check() {
    print_header "20. GİRİŞ AKTİVİTE ANALİZİ"
    
    # 1. Son başarılı girişler (Şüpheli IP var mı?)
    print_info "Son başarılı girişler (Özet):"
    last -n 5 -w | head -n 5 | awk '{print "   - " $1, $3, $4, $5, $6}'
    
    # 2. Başarısız giriş denemeleri (lastb)
    # lastb genelde root yetkisi ister
    if [ -f "/var/log/btmp" ]; then
        if [ -r "/var/log/btmp" ]; then
            print_info "Son başarısız giriş denemeleri (Brute Force belirtisi olabilir):"
            local failed_logins
            failed_logins=$(lastb -n 5 2>/dev/null | head -n 5)
            if [ -n "$failed_logins" ]; then
                 echo "$failed_logins" | sed 's/^/   - /'
            else
                 print_pass "kaydedilmiş başarısız giriş bulunamadı."
            fi
        else
            print_warn "/var/log/btmp okunamıyor (Sudo gerekebilir)."
        fi
    fi
    
    # 3. Hiç giriş yapmamış kullanıcılar (Temizlik önerisi)
    # lastlog çok çıktı üretebilir, sadece "Never logged in" olmayanları veya çok eski olanları bulmak gerekir.
    # Şimdilik pas geçiyoruz veya basitçe listeleyebiliriz.
    
    # 4. Eşzamanlı oturumlar
    local active_sessions
    active_sessions=$(who | wc -l)
    if [ "$active_sessions" -gt 3 ]; then
        print_info "Şu an $active_sessions aktif oturum var. Kontrol etmenizde fayda var."
    fi
}
