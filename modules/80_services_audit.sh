#!/bin/bash
# ==============================================
# Domain Layer - Servis Denetim Modülü
# Sorumlu: Gereksiz veya güvensiz servislerin tespiti
# ==============================================

run_services_audit_check() {
    print_header "8. SERVİS VE DAEMON DENETİMİ"
    
    local insecure_services="telnet ftp rsh nis ypserv tftp"
    local found_insecure=0
    
    for svc in $insecure_services; do
        if sys_check_service_active "$svc"; then
            print_fail "GÜVENSİZ SERVİS AKTİF: $svc"
            print_suggestion "Bu servisi kesinlikle devre dışı bırakın: systemctl disable --now $svc"
            found_insecure=1
        fi
    done
    
    if [ "$found_insecure" -eq 0 ]; then
        print_pass "Bilinen güvensiz servisler (telnet, ftp vb.) çalışmıyor."
    fi

    # Aktif servislerin listesi (Bilgi amaçlı)
    # print_info "Sistemde şu an aktif olan servisler:"
    # sys_get_active_services | paste -sd ", " - | fold -s -w 80 | head -n 3
    # echo "   (...tam liste için 'systemctl list-units --type=service' kullanın)"
    
    # Avahi (mDNS) kontrolü
    if sys_check_service_active "avahi-daemon"; then
        print_info "Avahi Daemon (mDNS) aktif. Yerel ağda cihazın bulunmasını kolaylaştırır ama bilgi sızdırabilir."
    fi
    
    # CUPS (Yazıcı) kontrolü
    if sys_check_service_active "cups"; then
        print_info "CUPS (Yazıcı Servisi) aktif. Yazıcı kullanmıyorsanız kapatın."
    fi
}
