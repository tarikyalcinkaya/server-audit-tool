#!/bin/bash
# ==============================================
# Domain Layer - Paylaşılan Bellek (Shared Memory) Güvenliği
# Sorumlu: /run/shm ve /dev/shm mount point sıkılaştırma
# ==============================================

run_shared_memory_check() {
    print_header "14. PAYLAŞILAN BELLEK GÜVENLİĞİ"
    
    # Modern Linux'ta /dev/shm genellikle bir tmpfs mount'udur.
    # Güvenlik için 'noexec,nosuid,nodev' seçenekleri ile mount edilmemeli.
    
    if sys_check_mount_options "/dev/shm" | grep -q "noexec"; then
        print_pass "/dev/shm 'noexec' ile mount edilmiş."
    else
        print_warn "/dev/shm üzerinde uygulama çalıştırılabilir (noexec eksik)."
        print_suggestion "/etc/fstab dosyasına /dev/shm için 'noexec,nosuid,nodev' ekleyin."
    fi
    
    # /run/shm kontrolü (Eski Debian/Ubuntu sistemler için alias)
    if [ -d "/run/shm" ] && ! [ -L "/run/shm" ]; then
         if sys_check_mount_options "/run/shm" | grep -q "noexec"; then
            print_pass "/run/shm 'noexec' ile mount edilmiş."
        else
            print_info "/run/shm mount seçeneklerini kontrol edin."
        fi
    fi
}
