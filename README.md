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

1. Fotoğrafları site stiline çevir. Betik arka planı siler ve fotoğrafları sırayla `1.webp`, `2.webp` ... olarak yazar:
   `scripts/prepare_photos.sh assets/3d/<slug> ~/Downloads/foto1.HEIC ~/Downloads/foto2.HEIC`
   Arka planı silmek istemezsen `--keep-background` ekle. Fotoğraf kendi oranını ve arka planını korur.
   İlk fotoğraf kapak olur. Betik ayrıca link önizlemesi için `og.jpg` yazar. macOS 14 ve ImageMagick 7 gerekir.
2. Modelin tamamı kadrajda olsun. Kadrajın dışına taşan bir uç, kesimde düz görünür.
3. `_makes/<slug>.md` dosyası oluştur. URL `/3d/<slug>/` olur.

```yaml
---
title: Cable Organizer
date: 2026-09-12
kind: model          # print (başkasının modeli) veya model (kendi tasarımın)
og_image: /assets/3d/cable-organizer/og.jpg
images:
  - /assets/3d/cable-organizer/1.webp
printer: Bambu Lab A1     # isteğe bağlı
filament: PLA, black      # isteğe bağlı
designer: Ahmet Korkmaz   # isteğe bağlı
link: https://makerworld.com/...   # isteğe bağlı
icon: stand        # isteğe bağlı, fotoğraf yoksa kartta bu ikon görünür (_includes/uses-icon.html)
model_file: /assets/3d/cable-organizer/model.glb   # isteğe bağlı, 3D görüntüleyici açar
download: /assets/3d/cable-organizer/model.stl     # isteğe bağlı, indirme linki (yoksa GLB)
camera_orbit: 0deg 65deg auto                      # isteğe bağlı, görüntüleyicinin ilk açısı
video: /assets/3d/cable-organizer/video.mp4        # isteğe bağlı, galerinin ilk karesi
video_poster: /assets/3d/cable-organizer/video-poster.jpg
---
Notlar (Markdown).
```

`kind` sadece `print` veya `model` olabilir. Test bu kuralı kontrol eder.

### Videoyu küçült

Galeri videoyu sessiz ve döngülü oynatır.

```sh
ffmpeg -i IN.MOV -map 0:v:0 -an -map_metadata -1 -vf "scale=720:-2,fps=30,format=yuv420p" \
  -c:v libx264 -preset slow -crf 26 -movflags +faststart assets/3d/<slug>/video.mp4
ffmpeg -ss 0.5 -i assets/3d/<slug>/video.mp4 -frames:v 1 -q:v 4 assets/3d/<slug>/video-poster.jpg
```

### STL dosyasını GLB yap

3D görüntüleyici GLB dosyası okur:
`python3 scripts/stl_to_glb.py model.stl assets/3d/<slug>/model.glb`

Dosyayı 10 MB altında tut.

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
        author: Yazar Adı
        license: CC BY-SA 4.0
        license_url: https://creativecommons.org/licenses/by-sa/4.0/
        source: https://commons.wikimedia.org/wiki/File:Ornek.jpg
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
