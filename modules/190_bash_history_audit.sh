#!/bin/bash
# ==============================================
# Domain Layer - Bash Geçmişi Analiz Modülü
# Sorumlu: Kullanıcıların şüpheli komut kullanımlarını tespit etmek
# ==============================================

run_bash_history_check() {
    print_header "19. BASH KOMUT GEÇMİŞİ ANALİZİ"
    
    # Tüm kullanıcı ev dizinlerini tara
    # .bash_history dosyalarını oku
    
    print_info "Kullanıcıların .bash_history dosyaları taranıyor..."
    
    local found_suspicious=0
    
    # Döngü ile /home/* ve /root taraması
    for user_home in /home/* /root; do
        if [ -d "$user_home" ]; then
            local hist_file="$user_home/.bash_history"
            if [ -f "$hist_file" ]; then
                # Şüpheli anahtar kelimeler
                # nc -e, /dev/tcp, wget, curl, rm -rf /, > /dev/null 2>&1 (log gizleme), :(){ :|:& };: (fork bomb)
                
                local suspicious_cmds
                suspicious_cmds=$(grep -E "nc |netcat |/dev/tcp|wget |curl |rm -rf /|> /dev/null|chmod 777|chown root" "$hist_file" 2>/dev/null | tail -n 5)
                
                if [ -n "$suspicious_cmds" ]; then
                     print_warn "Şüpheli komutlar tespit edildi ($user_home):"
                     echo "$suspicious_cmds" | sed 's/^/   - /'
                     found_suspicious=1
                fi
            fi
        fi
    done
    
    if [ "$found_suspicious" -eq 0 ]; then
        print_pass "Bash geçmişlerinde bariz şüpheli bir komut dizisi bulunamadı."
    else
        print_info "NOT: Bu komutlar meşru kullanım da olabilir, bağlama göre değerlendirin."
    fi
}
