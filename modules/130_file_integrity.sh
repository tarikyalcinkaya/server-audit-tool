#!/bin/bash
# ==============================================
# Domain Layer - Dosya Bütünlüğü Modülü
# Sorumlu: Kritik sistem dosyalarının değişip değişmediğini kontrol eder
# NOT: Basit hash kontrolü yapar, gerçek bir IDS (AIDE/Tripwire) değildir.
# ==============================================

run_file_integrity_check() {
    print_header "13. DOSYA BÜTÜNLÜĞÜ (BASİT KONTROL)"
    
    # Kontrol edilecek kritik dosyaların listesi
    local critical_files=(
        "/etc/passwd"
        "/etc/shadow"
        "/etc/group"
        "/etc/sudoers"
        "/etc/ssh/sshd_config"
        "/bin/ls"
        "/bin/ps"
        "/bin/netstat"
    )
    
    print_info "Kritik dosyalar için SHA256 hash kontrolleri..."
    
    # Normalde bu hash'lerin güvenli bir yerde saklanıp önceki değerle
    # karşılaştırılması gerekir.
    # Şimdilik sadece hash değerlerini raporluyoruz (Baseline oluşturma adımı).
    
    for file in "${critical_files[@]}"; do
        if [ -f "$file" ]; then
            local hash
            hash=$(sys_calculate_file_hash "$file")
            echo "   [HASH] $file -> $hash"
        else
            print_warn "Dosya bulunamadı: $file"
        fi
    done
    
    print_info "NOT: Bu hash değerlerini güvenli bir yerde saklayıp periyodik olarak karşılaştırmalısınız."
}
