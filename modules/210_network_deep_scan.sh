#!/bin/bash
# ==============================================
# Domain Layer - Derin Ağ Analiz Modülü
# Sorumlu: Promiscuous mod, ARP zehirlenmesi ve DNS güvenliği
# ==============================================

run_network_deep_scan_check() {
    print_header "21. DERİN AĞ ANALİZİ"
    
    # 1. Promiscuous Mode (Sniffer Tespiti)
    local promisc
    promisc=$(sys_check_promiscuous)
    if [ -n "$promisc" ]; then
        print_fail "KRİTİK: Promiscuous modda ağ kartı bulundu (Sniffer olabilir!):"
        echo "$promisc" | awk '{print "   - " $2}'
    else
        print_pass "Promiscuous modda çalışan arayüz bulunamadı."
    fi
    
    # 2. ARP Tablosu (Basit manipülasyon kontrolü)
    # Aynı MAC adresine sahip birden fazla IP varsa şüphelidir (ARP Spoofing)
    print_info "ARP tablosu kontrol ediliyor..."
    local arp_dups
    arp_dups=$(sys_get_arp_table | awk '{print $5}' | sort | uniq -d)
    
    if [ -n "$arp_dups" ]; then
        print_warn "Dikkat: Aynı MAC adresine sahip birden fazla IP var (ARP Spoofing olabilir veya normal Router davranışı):"
        echo "$arp_dups" | sed 's/^/   - /'
    else
        print_pass "ARP tablosunda mükerrer MAC adresi görülmedi."
    fi
    
    # 3. DNS Ayarları (/etc/resolv.conf)
    if [ -f "/etc/resolv.conf" ]; then
        local nameservers
        nameservers=$(grep "nameserver" /etc/resolv.conf | awk '{print $2}')
        if [ -n "$nameservers" ]; then
            print_info "Kullanılan DNS Sunucuları: $(echo $nameservers | tr '\n' ' ')"
        else
            print_warn "DNS sunucusu bulunamadı (/etc/resolv.conf boş veya yönetiliyor)."
        fi
    fi
}
