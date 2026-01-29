#!/bin/bash
# ==============================================
# Domain Layer - SSH Sıkılaştırma Modülü
# Sorumlu: SSH yapılandırma güvenlik analizi
# ==============================================

run_ssh_check() {
    print_header "3. SSH SIKILAŞTIRMA (HARDENING)"
    
    local SSHD_CONFIG="/etc/ssh/sshd_config"
    
    if ! sys_file_exists "$SSHD_CONFIG"; then
        print_warn "SSH konfigürasyon dosyası bulunamadı veya SSH kurulu değil."
        return
    fi
    
    # --- Root Login Kontrolü ---
    if sys_grep_config "$SSHD_CONFIG" "^PermitRootLogin no"; then
        print_pass "SSH Root girişi engelli."
    else
        print_fail "SSH Root girişine izin veriliyor veya varsayılan ayarda (Riskli)."
        print_suggestion "Düzenleyin: sudo nano $SSHD_CONFIG -> 'PermitRootLogin no' yapın."
    fi
    
    # --- Parola ile Giriş Kontrolü ---
    if sys_grep_config "$SSHD_CONFIG" "^PasswordAuthentication no"; then
        print_pass "Parola ile giriş kapalı (Sadece SSH Key)."
    else
        print_warn "Parola ile SSH girişi aktif. Brute-force saldırılarına açıksınız."
        print_suggestion "SSH Anahtarı kurduktan sonra: 'PasswordAuthentication no' yapın."
    fi
    
    # --- Port Kontrolü ---
    local ssh_port
    ssh_port=$(sys_get_config_value "$SSHD_CONFIG" "^Port")
    
    if [ "$ssh_port" != "22" ] && [ -n "$ssh_port" ]; then
        print_pass "SSH varsayılan portu değiştirilmiş: $ssh_port"
    else
        print_info "SSH standart 22 portunu kullanıyor."
        print_suggestion "Botlardan kaçınmak için portu değiştirebilirsiniz (Örn: 2022)."
    fi
}
