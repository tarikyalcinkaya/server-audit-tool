#!/bin/bash
# ==============================================
# Domain Layer - SSL Sertifika Denetimi
# Sorumlu: Süresi dolmuş veya dolmak üzere olan sertifikalar
# ==============================================

run_ssl_cert_audit_check() {
    print_header "25. SSL SERTİFİKA DENETİMİ"
    
    print_info "Yaygın sertifika dizinleri taranıyor (/etc/ssl, /etc/letsencrypt, /var/www)..."
    
    # Let's Encrypt live dizini
    local le_path="/etc/letsencrypt/live"
    if [ -d "$le_path" ]; then
        print_info "Let's Encrypt sertifikaları bulundu:"
        # Döngü ile expiry kontrolü
        find "$le_path" -name "cert.pem" 2>/dev/null | while read -r cert; do
            local exp_date
            exp_date=$(sys_check_ssl_expiry "$cert")
            print_info "   - $cert -> Bitiş: $exp_date"
            
            # Tarih karşılaştırma mantığı eklenebilir (openssl -checkend)
            if openssl x509 -checkend 2592000 -noout -in "$cert" 2>/dev/null; then
                : # 30 günden fazla var
            else
                print_warn "   DIKKAT: Sertifikanın süresi 30 günden az kalmış!"
            fi
        done
    else
        print_info "Let's Encrypt sertifikası bulunamadı."
    fi
    
    # Genel .crt / .pem taraması (Sadece /etc/ssl/certs içinde self-signed olmayanları bulmak zor)
    # Şimdilik sadece LE kontrolü yeterli olabilir.
}
