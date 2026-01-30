#!/bin/bash
# ==============================================
# Domain Layer - Virüs Tarama Modülü (ClamAV)
# Sorumlu: Dosya sistemi virüs taraması
# ==============================================

run_virus_scan_check() {
    print_header "11. VİRÜS TARAMASI (ClamAV)"
    
    if sys_check_clamav; then
        print_info "ClamAV tespit edildi. Kritik dizinler taranıyor (/tmp, /var/tmp)..."
        
        # Tarama işlemi uzun sürmemesi için sadece kritik yerleri tarıyoruz.
        # Kullanıcı isterse tam tarama yapabilir, bu bir 'quick scan'.
        
        # /tmp ve /var/tmp taraması
        print_info "Tmp dizinleri taranıyor..."
        sys_run_clamav_scan "/tmp"
        sys_run_clamav_scan "/var/tmp"
        
        # Enfekte dosya var mı loglardan kontrol etmek daha iyi olurdu ama
        # şimdilik ekrana basılan çıktıyı kullanıcı görecek.
        
        print_pass "Virüs taraması tamamlandı (Bulgular yukarıdadır)."
        print_suggestion "Veritabanını güncellemeyi unutmayın: sudo freshclam"
    else
        print_warn "ClamAV kurulu değil. Virüs taraması yapılamadı."
        print_suggestion "Kurulum: sudo apt install clamav && sudo freshclam"
    fi
}
