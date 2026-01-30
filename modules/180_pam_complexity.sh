#!/bin/bash
# ==============================================
# Domain Layer - Parola Politikası (PAM) Denetimi Module
# Sorumlu: pam_pwquality ayarlarının kontrolü
# ==============================================

run_pam_check() {
    print_header "18. PAROLA POLİTİKASI (PAM)"
    
    local PAM_FILE="/etc/pam.d/common-password"
    local PWQUALITY_CONF="/etc/security/pwquality.conf"
    
    if grep -q "pam_pwquality.so" "$PAM_FILE" 2>/dev/null; then
        print_pass "pam_pwquality modülü aktif (Güçlü şifre zorlama)."
        
        # Detaylı ayar kontrolü
        if [ -f "$PWQUALITY_CONF" ]; then
             local minlen
             minlen=$(grep "^minlen" "$PWQUALITY_CONF" | cut -d= -f2 | tr -d ' ')
             if [ -n "$minlen" ] && [ "$minlen" -ge 12 ]; then
                 print_pass "Minimum şifre uzunluğu yeterli ($minlen)."
             else
                 print_warn "Minimum şifre uzunluğu düşük veya ayarlanmamış (Önerilen: 12+)."
             fi
        fi
        
    elif grep -q "pam_cracklib.so" "$PAM_FILE" 2>/dev/null; then
        print_pass "pam_cracklib modülü aktif (Eski ama etkili)."
    else
        print_warn "Parola karmaşıklık modülü (pwquality/cracklib) aktif görünmüyor."
        print_suggestion "libpam-pwquality paketini kurun."
    fi
    
    # Hesap Kilitlenme Politikası (Tally/Faillock)
    if grep -qE "pam_tally2.so|pam_faillock.so" /etc/pam.d/common-auth 2>/dev/null; then
        print_pass "Hesap kilitleme modülü (Brute-force koruması) aktif."
    else
        print_warn "Hesap kilitleme modülü (pam_faillock/tally2) bulunamadı."
        print_suggestion "Çok sayıda başarısız girişte hesap kilitlenmiyor olabilir."
    fi
}
