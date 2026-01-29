#!/bin/bash
# ==============================================
# Domain Layer - Sistem Güncelleme Modülü
# Sorumlu: Sistem paket güncellik durumu kontrolü
# ==============================================

run_system_check() {
    print_header "1. SİSTEM GÜNCELLİK DURUMU"
    
    # Infrastructure katmanını kullan
    local updates
    updates=$(sys_check_pending_updates)
    
    if [ "$updates" -eq 0 ]; then
        print_pass "Sistem tamamen güncel."
    else
        print_warn "$updates adet güncelleme bekliyor."
        print_info "KRİTİK: Güncelleme yapmadan önce SD Kart yedeği (imajı) almanız önerilir."
        print_suggestion "sudo apt update && sudo apt upgrade -y"
    fi
}
