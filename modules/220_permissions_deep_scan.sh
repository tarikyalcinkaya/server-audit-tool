#!/bin/bash
# ==============================================
# Domain Layer - Detaylı İzin ve Hakimiyet Kontrolü
# Sorumlu: World-writeable, sahipsiz dosya ve sticky bit kontrolleri
# ==============================================

run_permissions_deep_scan_check() {
    print_header "22. DETAYLI İZİN TARAMASI"
    
    # 1. World Writeable Dosyalar
    print_info "Herkesin yazabildiği (World Writeable) dosyalar taranıyor..."
    local ww_files
    ww_files=$(sys_find_world_writeable_files | grep -vE "/proc|/sys|/dev" | head -n 10)
    
    if [ -n "$ww_files" ]; then
        print_warn "World Writeable dosyalar bulundu (Riskli olabilir):"
        echo "$ww_files" | sed 's/^/   - /'
        local count=$(sys_find_world_writeable_files | grep -vE "/proc|/sys|/dev" | wc -l)
        if [ "$count" -gt 10 ]; then echo "   ... ve diğerleri (Toplam $count)"; fi
    else
        print_pass "Kritik bölgelerde world-writeable dosya bulunamadı."
    fi
    
    # 2. Sahipsiz Dosyalar (Unowned)
    print_info "Sahipsiz (kullanıcısı silinmiş) dosyalar taranıyor..."
    local unowned
    unowned=$(sys_find_unowned_files | grep -vE "/proc|/sys|/dev" | head -n 10)
    
    if [ -n "$unowned" ]; then
        print_warn "Sahipsiz dosyalar tespit edildi (Bir saldırganın bıraktığı izler olabilir):"
        echo "$unowned" | sed 's/^/   - /'
    else
        print_pass "Sahipsiz dosya tespit edilmedi."
    fi
}
