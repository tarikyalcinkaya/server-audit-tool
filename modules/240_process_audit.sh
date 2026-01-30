#!/bin/bash
# ==============================================
# Domain Layer - Çalışan İşlemler (Process) Denetimi
# Sorumlu: Anormal, gizli veya /tmp üzerinden çalışan işlemleri bulma
# ==============================================

run_process_audit_check() {
    print_header "24. SÜREÇ (PROCESS) ANALİZİ"
    
    # 1. /tmp veya /dev/shm üzerinden çalışan işlemler
    print_info "Geçici dizinlerden (/tmp, /dev/shm) çalışan işlemler taranıyor..."
    local tmp_procs
    tmp_procs=$(sys_get_processes_from_tmp)
    
    if [ -n "$tmp_procs" ]; then
        print_fail "RİSKLİ: /tmp veya /dev/shm üzerinden çalışan işlem bulundu (Malware olabilir):"
        echo "$tmp_procs" | sed 's/^/   - /'
    else
        print_pass "/tmp veya /dev/shm üzerinden çalışan işlem bulunamadı."
    fi
    
    # 2. Yüksek Kaynak Tüketimi (Basit kontrol)
    # CPU kullanımı %80 üzeri olan işlemleri raporla (Crypto miner?)
    local high_cpu
    high_cpu=$(ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 6 | awk '$5 > 80.0 {print $0}')
    
    if [ -n "$high_cpu" ]; then
        print_warn "Yüksek CPU tüketen işlem tespit edildi (Miner olabilir?):"
        echo "$high_cpu" | sed 's/^/   - /'
    fi
}
