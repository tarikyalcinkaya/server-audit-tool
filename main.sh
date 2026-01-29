#!/bin/bash
# ==============================================
# Raspberry Pi Güvenlik Denetim Aracı
# Orchestration Layer - Ana Giriş Noktası
# 
# Bu script sadece:
# 1. Root yetkisini kontrol eder
# 2. Kütüphaneleri yükler
# 3. Modülleri otomatik keşfeder ve çalıştırır
#
# İŞ MANTIĞI BARINDIRMAZ!
# ==============================================

# Not using set -e to allow modules to handle errors gracefully

# Script'in bulunduğu dizini tespit et
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- 0. Root Yetkisi Kontrolü ---
if [[ $EUID -ne 0 ]]; then
    echo -e "\033[0;31mHata: Bu script tam tarama için root yetkisiyle (sudo) çalıştırılmalıdır.\033[0m"
    exit 1
fi

# --- 1. Kütüphaneleri Yükle ---
source "${SCRIPT_DIR}/lib/utils.sh"
source "${SCRIPT_DIR}/lib/system_adapter.sh"

# --- 2. Başlangıç Banner'ı ---
show_banner

# --- 3. Modülleri Otomatik Keşfet ve Çalıştır ---
# OCP Prensibi: Yeni modül eklemek için bu dosyayı değiştirmeye gerek yok
# modules/ klasörüne yeni bir *.sh dosyası eklemek yeterli

MODULE_DIR="${SCRIPT_DIR}/modules"

if [ -d "$MODULE_DIR" ]; then
    # Modülleri sıralı olarak yükle (10_, 20_, 30_ ... sırasıyla)
    for module in $(ls -1 "${MODULE_DIR}"/*.sh 2>/dev/null | sort); do
        if [ -f "$module" ]; then
            # Modülü source et
            source "$module"
            
            # Modül adından fonksiyon adını türet
            # Örn: 10_system.sh -> run_system_check
            module_name=$(basename "$module" .sh | sed 's/^[0-9]*_//')
            func_name="run_${module_name}_check"
            
            # Fonksiyon varsa çalıştır (hata yakalama ile)
            if declare -f "$func_name" > /dev/null; then
                "$func_name" || print_warn "Modül hatası: $module_name"
            fi
        fi
    done
else
    print_warn "Modül dizini bulunamadı: $MODULE_DIR"
fi

# --- 4. Tamamlanma Banner'ı ---
show_completion_banner

exit 0
