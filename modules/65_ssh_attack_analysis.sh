#!/bin/bash
# ==============================================
# Domain Layer - Detaylı SSH Saldırı Analizi Modülü
# Sorumlu: SSH saldırılarının derinlemesine analizi
# ==============================================

# --- Yardımcı Fonksiyonlar ---

get_geolocation() {
    # IP için ülke bilgisi döndürür (ipinfo.io API kullanarak)
    local ip="$1"
    local country
    country=$(curl -s --max-time 3 "https://ipinfo.io/${ip}/country" 2>/dev/null)
    if [ -z "$country" ] || [ "$country" = "undefined" ]; then
        echo "Bilinmiyor"
    else
        echo "$country"
    fi
}

calculate_risk_score() {
    # Saldırı sayısına göre risk skoru (1-10)
    local attempts="$1"
    if [ "$attempts" -gt 10000 ]; then
        echo "10"
    elif [ "$attempts" -gt 5000 ]; then
        echo "9"
    elif [ "$attempts" -gt 1000 ]; then
        echo "8"
    elif [ "$attempts" -gt 500 ]; then
        echo "7"
    elif [ "$attempts" -gt 100 ]; then
        echo "5"
    elif [ "$attempts" -gt 50 ]; then
        echo "3"
    else
        echo "2"
    fi
}

get_risk_label() {
    local score="$1"
    if [ "$score" -ge 8 ]; then
        echo "🔴 KRİTİK"
    elif [ "$score" -ge 5 ]; then
        echo "🟠 YÜKSEK"
    elif [ "$score" -ge 3 ]; then
        echo "🟡 ORTA"
    else
        echo "🟢 DÜŞÜK"
    fi
}

# --- Ana Fonksiyon ---

run_ssh_attack_analysis_check() {
    print_header "6.5 DETAYLI SSH SALDIRI ANALİZİ"
    
    local total_attempts=0
    local top_ips=""
    local log_source=""
    
    # Log kaynağını belirle
    if sys_command_exists "journalctl"; then
        log_source="journal"
        total_attempts=$(journalctl -u ssh -S today --no-pager 2>/dev/null | grep "Failed password" | wc -l)
        top_ips=$(journalctl -u ssh -S today --no-pager 2>/dev/null | grep "Failed password" | awk '{print $(NF-3)}' | sort | uniq -c | sort -nr | head -n 10)
    elif sys_file_exists "/var/log/auth.log"; then
        log_source="authlog"
        total_attempts=$(grep "Failed password" /var/log/auth.log 2>/dev/null | wc -l)
        top_ips=$(grep "Failed password" /var/log/auth.log 2>/dev/null | awk '{print $(NF-3)}' | sort | uniq -c | sort -nr | head -n 10)
    fi
    
    if [ "$total_attempts" -eq 0 ]; then
        print_pass "Analiz edilecek başarısız SSH denemesi bulunamadı."
        return 0
    fi
    
    # Risk Skoru Hesapla
    local risk_score
    risk_score=$(calculate_risk_score "$total_attempts")
    local risk_label
    risk_label=$(get_risk_label "$risk_score")
    
    echo ""
    echo "   ┌─────────────────────────────────────────────────────────┐"
    echo "   │               SSH SALDIRI RAPORU                        │"
    echo "   └─────────────────────────────────────────────────────────┘"
    echo ""
    echo "   📊 GENEL DURUM:"
    echo "   ├─ Toplam Başarısız Deneme: $total_attempts"
    echo "   ├─ Risk Skoru: $risk_score/10"
    echo "   └─ Risk Seviyesi: $risk_label"
    echo ""
    
    # Top 10 Saldırgan IP Analizi
    echo "   🎯 EN AKTİF SALDIRGAN IP'LER (Top 10):"
    echo "   ┌──────────┬─────────────────────┬─────────┬────────────┐"
    echo "   │  Deneme  │         IP          │  Ülke   │   Durum    │"
    echo "   ├──────────┼─────────────────────┼─────────┼────────────┤"
    
    echo "$top_ips" | while read -r count ip; do
        if [ -n "$ip" ] && [ -n "$count" ]; then
            # Geolocation al (paralel çalışma için cache kullanılabilir)
            local country
            country=$(get_geolocation "$ip")
            
            # Fail2ban'da banlı mı kontrol et
            local status="⚠️ Aktif"
            if sys_command_exists "fail2ban-client"; then
                if fail2ban-client status sshd 2>/dev/null | grep -q "$ip"; then
                    status="🔒 Banlı"
                fi
            fi
            
            printf "   │ %8s │ %-19s │ %-7s │ %-10s │\n" "$count" "$ip" "$country" "$status"
        fi
    done
    
    echo "   └──────────┴─────────────────────┴─────────┴────────────┘"
    echo ""
    
    # Hedeflenen Kullanıcı Adları
    echo "   👤 EN ÇOK HEDEFLENEN KULLANICI ADLARI:"
    if [ "$log_source" = "journal" ]; then
        journalctl -u ssh -S today --no-pager 2>/dev/null | grep "Failed password" | \
            grep -oP "for \K\S+" | head -c -1 | sort | uniq -c | sort -nr | head -n 5 | \
            while read -r count user; do
                echo "   ├─ $user: $count deneme"
            done
    else
        grep "Failed password" /var/log/auth.log 2>/dev/null | \
            grep -oP "for \K\S+" | sort | uniq -c | sort -nr | head -n 5 | \
            while read -r count user; do
                echo "   ├─ $user: $count deneme"
            done
    fi
    echo ""
    
    # Zaman Bazlı Analiz
    echo "   ⏰ SAAT BAZLI SALDIRI DAĞILIMI (Bugün):"
    if [ "$log_source" = "journal" ]; then
        journalctl -u ssh -S today --no-pager 2>/dev/null | grep "Failed password" | \
            awk '{print substr($3,1,2)":00"}' | sort | uniq -c | sort -k2 | head -n 6 | \
            while read -r count hour; do
                local bar=""
                local bar_len=$((count / 100))
                [ $bar_len -gt 30 ] && bar_len=30
                for ((i=0; i<bar_len; i++)); do bar+="█"; done
                printf "   ├─ %s │ %s (%d)\n" "$hour" "$bar" "$count"
            done
    fi
    echo ""
    
    # Öneriler
    echo "   📋 AKSİYON ÖNERİLERİ:"
    
    if [ "$risk_score" -ge 8 ]; then
        print_fail "ACİL: Sistem yoğun brute-force saldırısı altında!"
        echo ""
        echo "   1. ÖNCELİKLİ ADIMLAR:"
        print_suggestion "En aktif saldırgan IP'leri manuel olarak engelle:"
        echo "      sudo ufw deny from 179.63.15.10"
        echo "      sudo ufw deny from 129.212.183.32"
        echo ""
        echo "   2. ORTA VADELİ:"
        print_suggestion "Fail2Ban ayarlarını sıkılaştır (daha agresif bantime):"
        echo "      sudo nano /etc/fail2ban/jail.local"
        echo "      # bantime = 24h, findtime = 10m, maxretry = 3"
        echo ""
        echo "   3. UZUN VADELİ:"
        print_suggestion "SSH'ı sadece anahtar tabanlı girişe çevirip port değiştir:"
        echo "      # /etc/ssh/sshd_config:"
        echo "      # Port 2222"
        echo "      # PasswordAuthentication no"
        echo "      # PermitRootLogin no"
    else
        print_info "Risk seviyesi yönetilebilir durumda."
        print_suggestion "Düzenli log takibi yapın ve Fail2Ban aktif tutun."
    fi
    
    echo ""
    echo "   ─────────────────────────────────────────────────────────"
}
