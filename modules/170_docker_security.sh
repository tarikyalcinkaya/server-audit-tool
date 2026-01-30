#!/bin/bash
# ==============================================
# Domain Layer - Docker Güvenlik Kontrol Modülü
# Sorumlu: Docker daemon ve konteyner güvenliği
# ==============================================

run_docker_security_check() {
    print_header "17. DOCKER GÜVENLİĞİ"
    
    if sys_command_exists "docker"; then
        print_info "Docker yüklü, güvenlik kontrolleri yapılıyor..."
        
        # 1. Docker Daemon Root Yetkisi
        # Docker varsayılan olarak root yetkisiyle çalışır, ama socket izinleri önemli.
        if [ -S "/var/run/docker.sock" ]; then
            local sock_perm
            sock_perm=$(sys_get_file_permissions "/var/run/docker.sock")
            if [[ "$sock_perm" == *"docker"* ]] || [[ "$sock_perm" == *"root"* ]]; then
                 print_pass "Docker socket izinleri makul görünüyor ($sock_perm)."
            else
                 print_warn "Docker socket izinleri alışılmadık: $sock_perm"
            fi
        fi
        
        # 2. Privileged Container Taraması
        # Privileged konteynerler host'a tam erişim sağlayabilir.
        local priv_containers
        # JSON çıktısını grep ile parse etmek naive bir yaklaşım ama bağımlılık gerektirmez.
        # Docker inspect ile tüm çalışan konteynerleri kontrol ediyoruz.
        priv_containers=$(docker ps --quiet | xargs docker inspect --format '{{.Name}}: {{.HostConfig.Privileged}}' 2>/dev/null | grep "true")
        
        if [ -n "$priv_containers" ]; then
            print_fail "KRİTİK: Privileged (Ayrıcalıklı) modda çalışan konteynerler var!"
            echo "$priv_containers" | sed 's/^/   - /'
            print_suggestion "Mümkünse '--privileged' bayrağını kaldırın veya capabilities kullanın."
        else
            print_pass "Privileged modda çalışan konteyner bulunamadı."
        fi
        
        # 3. Docker User Namespace Remapping
        # /etc/docker/daemon.json kontrolü
        if [ -f "/etc/docker/daemon.json" ]; then
            if grep -q "userns-remap" "/etc/docker/daemon.json"; then
                print_pass "User Namespace Remapping aktif (Ekstra izolasyon)."
            else
                print_info "User Namespace Remapping aktif görünmüyor."
            fi
        fi
        
    else
        print_info "Docker kurulu değil, bu adım geçiliyor."
    fi
}
