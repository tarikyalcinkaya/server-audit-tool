#!/bin/bash
# ==============================================
# Domain Layer - Cron Zamanlanmış Görev Denetimi
# Sorumlu: Kötü amaçlı cron işlerinin tespiti
# ==============================================

run_cron_audit_check() {
    print_header "23. CRON GÖREVLERİ DENETİMİ"
    
    print_info "Sistem genelindeki Cron işleri taranıyor..."
    
    # 1. Kullanıcı cron job'ları
    local user_crons
    # Her kullanıcı için crontab denetlemek zor olabilir (/var/spool/cron/crontabs okumak root gerektirir)
    if [ -d "/var/spool/cron/crontabs" ]; then
        if [ -r "/var/spool/cron/crontabs" ]; then
             user_crons=$(grep -rE "curl|wget|nc |bash -i|/dev/tcp" /var/spool/cron/crontabs 2>/dev/null)
             if [ -n "$user_crons" ]; then
                 print_warn "Şüpheli kullanıcı cron işleri tespit edildi (Reverse shell vb. olabilir):"
                 echo "$user_crons" | sed 's/^/   - /'
             fi
        else
             print_warn "/var/spool/cron/crontabs okunamıyor (Yetki sorunu)."
        fi
    fi
    
    # 2. Sistem cron dosyaları (/etc/cron.*)
    local system_crons
    system_crons=$(grep -rE "curl|wget|nc |bash -i|/dev/tcp" /etc/cron* 2>/dev/null)
    
    if [ -n "$system_crons" ]; then
        print_warn "Şüpheli sistem cron işleri bulundu:"
        echo "$system_crons" | sed 's/^/   - /'
    else
        print_pass "Sistem cron dosyalarında bariz şüpheli komut bulunamadı."
    fi
}
