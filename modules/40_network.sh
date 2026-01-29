#!/bin/bash
# ==============================================
# Domain Layer - Ağ ve Firewall Modülü
# Sorumlu: UFW, Fail2Ban, açık port analizi
# ==============================================

run_network_check() {
    print_header "4. AĞ VE FIREWALL"
    
    # --- UFW Durumu ---
    if sys_command_exists "ufw"; then
        local ufw_status
        ufw_status=$(sys_get_ufw_status | grep "Status: active")
        
        if [ -n "$ufw_status" ]; then
            print_pass "UFW Güvenlik Duvarı AKTİF."
            echo "   --- Kurallar ---"
            ufw status numbered 2>/dev/null | head -n 5
        else
            print_fail "UFW kurulu ama PASİF durumda."
            print_suggestion "Aktifleştirin: sudo ufw allow ssh && sudo ufw enable"
        fi
    else
        print_warn "UFW (Uncomplicated Firewall) kurulu değil."
        print_suggestion "Kurulum: sudo apt install ufw && sudo ufw allow ssh && sudo ufw enable"
    fi
    
    # --- Fail2Ban Kontrolü ---
    if sys_check_service_active "fail2ban"; then
        print_pass "Fail2Ban servisi çalışıyor."
    else
        print_warn "Fail2Ban çalışmıyor veya kurulu değil (Brute-force koruması yok)."
        print_suggestion "Kurulum: sudo apt install fail2ban && sudo systemctl enable fail2ban --now"
    fi
    
    # --- Açık Port Analizi ---
    print_info "Dış dünyaya açık portlar (Listen):"
    local ports
    ports=$(sys_get_listening_ports)
    echo "   $ports"
    
    # Riskli port uyarıları
    if [[ "$ports" == *"139"* ]] || [[ "$ports" == *"445"* ]]; then
        print_suggestion "Samba (Dosya Paylaşımı) açık. İnternete açıksa VPN arkasına alın!"
    fi
    
    if [[ "$ports" == *"5900"* ]]; then
        print_suggestion "VNC açık. Çok riskli! SSH Tünel üzerinden kullanın."
    fi
}
