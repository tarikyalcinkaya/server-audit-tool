#!/bin/bash
# ==============================================
# Domain Layer - SUID/SGID Dosya Denetim Modülü
# Sorumlu: Yetki yükseltme riski taşıyan dosyaları bulma
# ==============================================

run_suid_check() {
    print_header "10. SUID/SGID DOSYA TARAMASI"
    
    # SUID: Sahibi yetkisiyle çalışan dosyalar (Örn: ping, passwd)
    # Bazıları gereklidir, ancak bilinmeyenler tehlikeli olabilir.
    
    print_info "Sistem genelinde SUID bit'e sahip dosyalar taranıyor (Bu işlem biraz sürebilir)..."
    
    local suid_files
    suid_files=$(sys_find_suid_files)
    
    if [ -n "$suid_files" ]; then
        print_warn "SUID dosyaları tespit edildi. Listeyi kontrol edin:"
        echo "$suid_files" | xargs ls -lh 2>/dev/null | awk '{print $1, $3, $9}' | head -n 10
        
        local count
        count=$(echo "$suid_files" | wc -l)
        if [ "$count" -gt 10 ]; then
             echo "... ve $count adet daha."
        fi
        
        # GTFOBins kontrolü için basit bir uyarı
        if echo "$suid_files" | grep -qE "vim|find|bash|perl|python|nmap|less|more|awk"; then
            print_fail "KRİTİK: Bilinen GTFOBins araçlarında SUID biti var! (vim, find, python vb.)"
            print_suggestion "Bu dosyaların SUID bitini kaldırın: chmod u-s <dosya>"
        fi
    else
        print_pass "SUID bit'e sahip dosya bulunamadı (Nadir görülen bir durum)."
    fi
}
