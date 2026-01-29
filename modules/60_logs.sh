#!/bin/bash
# ==============================================
# Domain Layer - Log Analizi Modülü
# Sorumlu: SSH başarısız giriş denemeleri analizi
# ==============================================

run_logs_check() {
    print_header "6. LOG ANALİZİ"
    
    # Modern sistemler journalctl, eski sistemler auth.log kullanır
    if sys_command_exists "journalctl"; then
        print_info "Log kaynağı: Systemd Journal (Modern Sistem)"
        
        local failed_attempts
        failed_attempts=$(sys_get_ssh_failed_attempts_journal)
        
        if [ "$failed_attempts" -gt 0 ]; then
            print_warn "Bugün $failed_attempts adet başarısız SSH giriş denemesi tespit edildi."
            echo "   Son 3 başarısız IP (Journal):"
            sys_get_failed_ssh_ips_journal
        else
            print_pass "Bugün için başarısız SSH giriş denemesi bulunamadı."
        fi
        
    elif sys_file_exists "/var/log/auth.log"; then
        print_info "Log kaynağı: /var/log/auth.log (Eski Sistem)"
        
        local failed_attempts
        failed_attempts=$(sys_get_ssh_failed_attempts_authlog)
        
        if [ "$failed_attempts" -gt 0 ]; then
            print_warn "Loglarda $failed_attempts adet başarısız SSH giriş denemesi var."
            echo "   Son 3 başarısız IP:"
            sys_get_failed_ssh_ips_authlog
        else
            print_pass "Auth loglarında başarısız giriş denemesi görünmüyor."
        fi
        
    else
        print_info "SSH loglarına erişilemedi (auth.log yok ve journalctl bulunamadı)."
    fi
}
