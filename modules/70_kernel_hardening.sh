#!/bin/bash
# ==============================================
# Domain Layer - Kernel Hardening Modülü
# Sorumlu: sysctl parametreleri ile çekirdek sıkılaştırma
# ==============================================

run_kernel_hardening_check() {
    print_header "7. KERNEL SIKILAŞTIRMA (SYSCTL)"
    
    # --- IP Forwarding (Router değilse kapalı olmalı) ---
    local ip_fwd
    ip_fwd=$(sys_get_sysctl_value "net.ipv4.ip_forward")
    
    if [ "$ip_fwd" == "0" ]; then
        print_pass "IP Forwarding devre dışı."
    else
        print_warn "IP Forwarding aktif ($ip_fwd). Eğer bu cihaz bir router değilse kapatılmalı."
        print_suggestion "sudo sysctl -w net.ipv4.ip_forward=0"
    fi
    
    # --- ICMP Broadcast Ignore (Smurf saldırısı koruması) ---
    local icmp_ignore
    icmp_ignore=$(sys_get_sysctl_value "net.ipv4.icmp_echo_ignore_broadcasts")
    
    if [ "$icmp_ignore" == "1" ]; then
        print_pass "ICMP Broadcast ignore aktif."
    else
        print_fail "ICMP Broadcast ignore pasif. Smurf saldırılarına açıksınız."
        print_suggestion "sudo sysctl -w net.ipv4.icmp_echo_ignore_broadcasts=1"
    fi
    
    # --- ICMP Redirects ---
    local accept_red
    accept_red=$(sys_get_sysctl_value "net.ipv4.conf.all.accept_redirects")
    
    if [ "$accept_red" == "0" ]; then
        print_pass "ICMP Redirects kabul edilmiyor (Güvenli)."
    else
        print_warn "ICMP Redirects açık. Ortadaki adam (MITM) saldırılarına zemin hazırlayabilir."
        print_suggestion "sysctl.conf'a 'net.ipv4.conf.all.accept_redirects = 0' ekleyin."
    fi
    
    local send_red
    send_red=$(sys_get_sysctl_value "net.ipv4.conf.all.send_redirects")
    if [ "$send_red" == "0" ]; then
        print_pass "ICMP Redirects gönderimi kapalı."
    else
        print_warn "ICMP Redirects gönderimi açık (Router değilse gereksiz)."
    fi
    
    # --- SYN Cookies (SYN Flood koruması) ---
    local syn_cookies
    syn_cookies=$(sys_get_sysctl_value "net.ipv4.tcp_syncookies")
    
    if [ "$syn_cookies" == "1" ]; then
        print_pass "TCP SYN Cookies aktif (SYN Flood koruması)."
    else
        print_warn "TCP SYN Cookies pasif."
        print_suggestion "sudo sysctl -w net.ipv4.tcp_syncookies=1"
    fi
}
