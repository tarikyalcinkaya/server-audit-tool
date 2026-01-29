# Katkıda Bulunma Rehberi

Server Audit Tool projesine katkıda bulunmak istediğiniz için teşekkür ederiz! 🎉

## 🚀 Hızlı Başlangıç

1. Bu repository'yi forklayın
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'feat: Add amazing feature'`)
4. Branch'inizi pushlayın (`git push origin feature/amazing-feature`)
5. Pull Request açın

## 📝 Commit Mesajı Formatı

[Conventional Commits](https://www.conventionalcommits.org/) standardını kullanıyoruz:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Tipler

| Tip | Açıklama |
|-----|----------|
| `feat` | Yeni özellik |
| `fix` | Bug düzeltme |
| `docs` | Sadece dokümantasyon |
| `style` | Kod formatı (fonksiyonellik değişmez) |
| `refactor` | Refactoring |
| `test` | Test ekleme/düzeltme |
| `chore` | Build, CI vb. |

### Örnekler

```bash
feat(modules): Add Docker container security check
fix(ssh): Handle missing sshd_config file
docs(readme): Update installation instructions
```

## 🔧 Yeni Modül Ekleme

### 1. Dosya Oluştur

`modules/NN_isim.sh` formatında dosya oluşturun:

```bash
#!/bin/bash
# modules/70_mycheck.sh - Kısa açıklama

run_mycheck_check() {
    print_header "N. MODÜL BAŞLIĞI"
    
    # Infrastructure Layer fonksiyonlarını kullan
    if sys_command_exists "mycommand"; then
        print_pass "Kontrol başarılı."
    else
        print_fail "Kontrol başarısız."
        print_suggestion "Çözüm önerisi..."
    fi
}
```

### 2. Kurallar

- ✅ `lib/system_adapter.sh` fonksiyonlarını kullan (`sys_*`)
- ✅ `lib/utils.sh` fonksiyonlarını kullan (`print_*`)
- ❌ Doğrudan `systemctl`, `apt`, `grep` vb. çağırma
- ❌ Renkler için hardcoded değerler kullanma

### 3. Yeni sys_* Fonksiyonu Gerekiyorsa

`lib/system_adapter.sh` dosyasına ekleyin:

```bash
sys_my_new_function() {
    # Açıklama
    # Kullanım: sys_my_new_function "arg1"
    local arg="$1"
    somecommand "$arg" 2>/dev/null
}
```

## 🧪 Test

```bash
# Syntax kontrolü
bash -n main.sh
bash -n lib/*.sh
bash -n modules/*.sh

# Çalıştırma testi (Linux/WSL gerekli)
sudo ./main.sh
```

## 📋 Pull Request Checklist

- [ ] Kod çalışıyor ve test edildi
- [ ] Commit mesajları Conventional Commits formatında
- [ ] CHANGELOG.md güncellendi
- [ ] README.md güncellendi (gerekiyorsa)
- [ ] Yeni fonksiyonlar dokümante edildi

## 💡 Fikirler ve Öneriler

Issue açarak önerilerinizi paylaşabilirsiniz. Etiketler:

- `enhancement` - Yeni özellik önerisi
- `bug` - Hata bildirimi
- `documentation` - Dokümantasyon iyileştirmesi
- `question` - Soru

## 📄 Lisans

Katkıda bulunarak, katkılarınızın MIT Lisansı altında lisanslanacağını kabul edersiniz.
