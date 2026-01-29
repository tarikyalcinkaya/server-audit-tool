#!/bin/bash
# ==============================================
# Domain Layer - Dosya İzinleri Modülü
# Sorumlu: Kritik sistem dosyası izin kontrolleri
# ==============================================

run_permissions_check() {
    print_header "5. KRİTİK DOSYA İZİNLERİ"
    
    # --- /etc/shadow İzin Kontrolü ---
    local shadow_perm
    shadow_perm=$(sys_get_file_permissions "/etc/shadow")
    
    if [[ "$shadow_perm" == "640 root:shadow" ]] || [[ "$shadow_perm" == "600 root:root" ]]; then
        print_pass "/etc/shadow izinleri güvenli ($shadow_perm)."
    elif [[ "$shadow_perm" == "NOT_FOUND" ]]; then
        print_warn "/etc/shadow dosyası bulunamadı."
    else
        print_warn "/etc/shadow izinleri riskli olabilir: $shadow_perm (Önerilen: 640 root:shadow)"
        print_suggestion "Düzeltme: sudo chmod 640 /etc/shadow && sudo chown root:shadow /etc/shadow"
    fi
    
    # --- /etc/passwd İzin Kontrolü ---
    local passwd_perm
    passwd_perm=$(sys_get_file_permissions "/etc/passwd")
    
    if [[ "$passwd_perm" == "644 root:root" ]]; then
        print_pass "/etc/passwd izinleri güvenli ($passwd_perm)."
    elif [[ "$passwd_perm" == "NOT_FOUND" ]]; then
        print_warn "/etc/passwd dosyası bulunamadı."
    else
        print_warn "/etc/passwd izinleri kontrol edilmeli: $passwd_perm (Önerilen: 644 root:root)"
    fi
    
    # --- /etc/sudoers İzin Kontrolü ---
    local sudoers_perm
    sudoers_perm=$(sys_get_file_permissions "/etc/sudoers")
    
    if [[ "$sudoers_perm" == "440 root:root" ]] || [[ "$sudoers_perm" == "400 root:root" ]]; then
        print_pass "/etc/sudoers izinleri güvenli ($sudoers_perm)."
    elif [[ "$sudoers_perm" == "NOT_FOUND" ]]; then
        print_info "/etc/sudoers dosyası bulunamadı (sudo kurulu olmayabilir)."
    else
        print_warn "/etc/sudoers izinleri riskli: $sudoers_perm (Önerilen: 440 root:root)"
        print_suggestion "Düzeltme: sudo chmod 440 /etc/sudoers"
    fi
}
