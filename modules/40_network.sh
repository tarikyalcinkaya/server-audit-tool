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
        ufw_status=$(sys_get_ufw_status 2>/dev/null | grep "Status: active" || true)
        
        if [ -n "$ufw_status" ]; then
            print_pass "UFW Güvenlik Duvarı AKTİF."
            echo "   --- Kurallar ---"
            sys_get_ufw_status 2>/dev/null | grep -E "^\[|^--" | head -n 5 || true
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
    print_info "Ağ Port Analizi:"
    
    local public_ports
    public_ports=$(sys_get_public_listening_ports)
    if [ -n "$public_ports" ]; then
        print_warn "Dış dünyaya (İnternet) açık portlar: $public_ports"
    else
        print_pass "İnternete doğrudan açık port bulunamadı."
    fi

    local local_ports
    local_ports=$(sys_get_local_listening_ports)
    if [ -n "$local_ports" ]; then
        print_info "Sadece yerel (localhost) dinlenen portlar: $local_ports"
    fi
    
    # Riskli port uyarıları
    if [[ "$public_ports" == *"139"* ]] || [[ "$public_ports" == *"445"* ]]; then
        print_fail "KRİTİK: Samba (Dosya Paylaşımı) İNTERNETE AÇIK! Hemen kapatın veya VPN arkasına alın."
    fi
    
    if [[ "$public_ports" == *"5900"* ]]; then
        print_fail "KRİTİK: VNC internete açık! SSH tünel kullanın."
    fi
}
