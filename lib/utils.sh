#!/bin/bash
# ==============================================
# Presentation Layer - UI Utilities
# Renkler, log formatları ve banner fonksiyonları
# ==============================================

# --- Renk Tanımlamaları ---
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export CYAN='\033[0;36m'
export NC='\033[0m' # No Color

# --- UI Fonksiyonları ---

print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE} $1 ${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_pass() {
    echo -e "${GREEN}[✔] GEÇTİ:${NC} $1"
}

print_fail() {
    echo -e "${RED}[✘] KRİTİK:${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[!] UYARI:${NC} $1"
}

print_info() {
    echo -e "[i] BİLGİ: $1"
}

print_suggestion() {
    echo -e "    👉 ${CYAN}ÇÖZÜM ÖNERİSİ:${NC} $1"
}

# --- Banner Fonksiyonu ---

show_banner() {
    clear
    echo -e "${BLUE}"
    echo "#############################################"
    echo "  RASPBERRY PI GÜVENLİK DENETİMİ BAŞLIYOR  "
    echo "#############################################"
    echo -e "${NC}"
    echo "Tarih: $(date)"
    echo "Hostname: $(hostname)"
    echo "Kernel: $(uname -r)"
    echo "---------------------------------------------"
}

# --- Sonuç Banner'ı ---

show_completion_banner() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${GREEN} DENETİM TAMAMLANDI ${NC}"
    echo -e "${BLUE}========================================${NC}"
}

# --- Seçim Menüsü Fonksiyonları ---

print_module_list() {
    local i=1
    echo -e "${CYAN}Mevcut Güvenlik Modülleri:${NC}"
    for mod in "$@"; do
        echo -e "  $i) $mod"
        ((i++))
    done
}
