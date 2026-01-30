#!/bin/bash
# ==============================================
# Domain Layer - Rootkit Tarama Modülü
# Sorumlu: RKHunter veya Chkrootkit entegrasyonu
# ==============================================

run_rootkit_scan_check() {
    print_header "12. ROOTKIT TARAMASI"
    
    if sys_command_exists "rkhunter"; then
        print_info "Rootkit Hunter (rkhunter) başlatılıyor (Bu işlem birkaç dakika sürebilir)..."
        
        # RKHunter çıktısını kullanıcıya gösterirken sadece warning'leri filtreleyebiliriz
        # Ancak güvenlik araçları genellikle doğrudan çıktı vermeli.
        
        if sys_run_rkhunter; then
            print_pass "RKHunter taraması tamamlandı. Uyarı (Warning) bulunamadı."
        else
            print_warn "RKHunter bazı uyarılar verdi. Logları kontrol edin: /var/log/rkhunter.log"
        fi
        
    elif sys_command_exists "chkrootkit"; then
        print_info "Chkrootkit başlatılıyor..."
        chkrootkit | grep "INFECTED"
        if [ $? -eq 0 ]; then
             print_fail "KRİTİK: Chkrootkit enfeksiyon belirtisi buldu!"
        else
             print_pass "Chkrootkit taraması temiz."
        fi
    else
        print_warn "Ne rkhunter ne de chkrootkit kurulu. Rootkit taraması yapılamadı."
        print_suggestion "Kurulum: sudo apt install rkhunter chkrootkit"
    fi
}
