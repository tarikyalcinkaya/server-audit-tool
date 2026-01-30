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

# --- 3. Modülleri Keşfet ---
MODULE_DIR="${SCRIPT_DIR}/modules"
if [ ! -d "$MODULE_DIR" ]; then
    print_warn "Modül dizini bulunamadı: $MODULE_DIR"
    exit 1
fi

# Modülleri diziye oku
mapfile -t MODULE_FILES < <(ls -1 "${MODULE_DIR}"/*.sh 2>/dev/null | sort -V)
MODULE_NAMES=()
for mod in "${MODULE_FILES[@]}"; do
    MODULE_NAMES+=("$(basename "$mod" .sh)")
done

# --- 4. Çalıştırma Modunu Belirle ---
SELECTED_FILES=()

if [[ $# -gt 0 ]]; then
    # Argüman olarak modül adları verilmişse
    for arg in "$@"; do
        for i in "${!MODULE_NAMES[@]}"; do
            if [[ "${MODULE_NAMES[$i]}" == *"$arg"* ]]; then
                SELECTED_FILES+=("${MODULE_FILES[$i]}")
            fi
        done
    done
else
    # İnteraktif Seçim
    echo -e "${YELLOW}Denetim Modu Seçin:${NC}"
    echo "1) Tüm Modülleri Çalıştır (Full Audit)"
    echo "2) Belirli Modülleri Seç"
    read -p "Seçiminiz [1/2]: " mode

    if [[ "$mode" == "2" ]]; then
        print_module_list "${MODULE_NAMES[@]}"
        read -p "Çalıştırmak istediğiniz modül numaralarını girin (örn: 1 3 5): " selections
        for sel in $selections; do
            idx=$((sel-1))
            if [[ $idx -ge 0 && $idx -lt ${#MODULE_FILES[@]} ]]; then
                SELECTED_FILES+=("${MODULE_FILES[$idx]}")
            else
                print_warn "Geçersiz seçim: $sel"
            fi
        done
    else
        SELECTED_FILES=("${MODULE_FILES[@]}")
    fi
fi

# --- 5. Modülleri Çalıştır ---
if [ ${#SELECTED_FILES[@]} -eq 0 ]; then
    print_fail "Çalıştırılacak modül seçilmedi."
    exit 1
fi

print_info "Rapor Dosyası: $REPORT_FILE"

{
    show_banner
    for module in "${SELECTED_FILES[@]}"; do
        if [ -f "$module" ]; then
            source "$module"
            module_base=$(basename "$module" .sh | sed 's/^[0-9]*_//')
            func_name="run_${module_base}_check"
            
            if declare -f "$func_name" > /dev/null; then
                "$func_name" || print_warn "Modül hatası: $module_base"
            fi
        fi
    done
    show_completion_banner
} | tee -a "$REPORT_FILE"

# ANSI renk kodlarını rapordan temizle (Opsiyonel)
sed -i 's/\x1b\[[0-9;]*m//g' "$REPORT_FILE"

# --- 6. Tamamlanma Banner'ı ---
show_completion_banner

exit 0
