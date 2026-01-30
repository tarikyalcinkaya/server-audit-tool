#!/bin/bash
# ==============================================
# Domain Layer - Bilgi Sızıntısı Denetimi
# Sorumlu: Unutulan .env, .git, private key dosyalarının tespiti
# ==============================================

run_information_leakage_check() {
    print_header "16. BİLGİ SIZINTISI TARAMASI"
    
    # Tüm diski taramak çok uzun sürer, bu yüzden web dizinlerine odaklanıyoruz
    # Ancak kullanıcı ev dizinlerini de katmak mantıklı olabilir.
    
    local search_dirs=("/var/www" "/home" "/opt")
    
    print_info "Hassas dosyalar taranıyor (.env, .git, private keys)..."
    
    for dir in "${search_dirs[@]}"; do
        if [ -d "$dir" ]; then
            print_info "Dizin taranıyor: $dir"
            
            # .env dosyaları
            local env_files
            env_files=$(find "$dir" -maxdepth 4 -type f -name ".env" 2>/dev/null)
            if [ -n "$env_files" ]; then
                print_warn "Potansiyel .env dosyaları bulundu:"
                echo "$env_files" | sed 's/^/   - /'
            fi
            
            # .git dizinleri
            local git_dirs
            git_dirs=$(find "$dir" -maxdepth 4 -type d -name ".git" 2>/dev/null)
            if [ -n "$git_dirs" ]; then
                print_warn "Production ortamında .git dizini bulundu (Kaynak kod sızıntısı riski):"
                echo "$git_dirs" | sed 's/^/   - /'
            fi
            
            # Private Keys (id_rsa, *.pem)
            # Sadece dosya ismine bakıyoruz, içerik analizi yapmıyoruz (yetki/mahremiyet)
            local keys
            keys=$(find "$dir" -maxdepth 4 -type f \( -name "id_rsa" -o -name "*.pem" -o -name "*.key" \) 2>/dev/null)
            if [ -n "$keys" ]; then
                print_fail "GÜVENSİZ YERDE PRİVATE KEY OLABİLİR:"
                echo "$keys" | sed 's/^/   - /'
            fi
        fi
    done
    
    print_pass "Bilgi sızıntısı taraması tamamlandı."
}
