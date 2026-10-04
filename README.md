# ahmetkorkmaz3.github.io

Kişisel site. GitHub Pages, Jekyll ile derler. Build adımı gerekmez.

## Yeni proje ekle

1. `_projects/<slug>.md` dosyası oluştur. URL `/projects/<slug>/` olur.
2. Bu alanları doldur:

```yaml
---
title: Contra
year: 2022
order: 2            # ana sayfadaki sıra, küçük olan üstte
summary: Tek cümlelik açıklama.
stack: [Vue, Nuxt]
repo: ahmetkorkmaz3/contra   # isteğe bağlı
stars: 27                    # isteğe bağlı, yıldız sayısı için yedek değer
demo: https://...            # isteğe bağlı
cover: /assets/projects/contra/cover.png   # isteğe bağlı
---
Detay metni (Markdown).
```

## Yeni baskı veya model ekle

1. Fotoğrafları `assets/3d/<slug>/` klasörüne koy.
2. Fotoğrafları küçült: `sips -Z 1600 assets/3d/<slug>/*.jpg`
3. `_makes/<slug>.md` dosyası oluştur. URL `/3d/<slug>/` olur.

```yaml
---
title: Cable Organizer
date: 2026-09-12
kind: model          # print (başkasının modeli) veya model (kendi tasarımın)
images:
  - /assets/3d/cable-organizer/1.jpg
printer: Bambu Lab A1     # isteğe bağlı
filament: PLA, black      # isteğe bağlı
designer: Ahmet Korkmaz   # isteğe bağlı
link: https://makerworld.com/...   # isteğe bağlı
model_file: /assets/3d/cable-organizer/model.glb   # isteğe bağlı, 3D görüntüleyici açar
---
Notlar (Markdown).
```

`kind` sadece `print` veya `model` olabilir. Test bu kuralı kontrol eder.

### STL dosyasını GLB yap

3D görüntüleyici GLB dosyası okur.

1. Blender aç. File → Import → STL ile dosyayı al.
2. File → Export → glTF 2.0 seç. Format: glTF Binary (.glb).
3. Dosyayı 10 MB altında tut.

## Uses sayfasına cihaz ekle

1. `_data/uses.yml` dosyasını aç.
2. Doğru bölümün `items` listesine bir öğe ekle:

```yaml
    - name: Dell S2721HS
      kind: Monitor        # Laptop, Keyboard, Trackpad, Monitor, 3D printer: ikonu seçer
      note: 27", 1080p     # isteğe bağlı
      image: /assets/uses/dell-s2721hs.jpg   # isteğe bağlı, ikonun yerine görünür
      link: https://...    # isteğe bağlı, kart bu sayfaya gider
```

Yeni bir bölüm için `- section: <ad>` ve altında `items:` ekle.

Başkasının çektiği bir fotoğrafı kullanırsan `credit` alanını doldur. CC BY ve CC BY-SA lisansları yazar ve lisans bilgisini ister:

```yaml
      credit:
        author: Joshua Kehn
        license: CC BY-SA 4.0
        license_url: https://creativecommons.org/licenses/by-sa/4.0/
        source: https://commons.wikimedia.org/wiki/File:Magic_Trackpad_2.jpg
        similar: true      # isteğe bağlı: fotoğraf benzer bir modeli gösteriyorsa
```

Kendi fotoğrafını kullanırsan `credit` alanını sil.

## Yerel önizleme

1. Ruby 3.3 kur: `brew install ruby@3.3`
2. Bağımlılıkları kur: `bundle config set --local path vendor/bundle && bundle install`
3. Siteyi aç: `bundle exec jekyll serve`, sonra http://localhost:4000

Ruby 3.3 yolu PATH içinde olmalı: `export PATH="/opt/homebrew/opt/ruby@3.3/bin:$PATH"`

## Test

`scripts/test.sh` siteyi derler ve `_site/` klasörünü kontrol eder. Kırık linkleri de bulur.
