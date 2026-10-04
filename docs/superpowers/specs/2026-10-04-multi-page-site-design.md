# Çok sayfalı site: 3D, proje detayları, Uses

Tarih: 2026-10-04
Durum: İnceleme bekliyor

## Amaç

Site şu an tek bir `index.html` sayfasıdır. Bu çalışma siteye üç yeni bölüm ekler:

1. **3D**: 3D yazıcı ile yapılan baskılar ve kendi tasarlanan modeller.
2. **Proje detayları**: Her proje için ayrı bir sayfa.
3. **Uses**: Kullanılan donanım, yazıcı, araçlar ve yazılımlar.

Yeni içerik Markdown dosyası ile eklenir. HTML yazmak gerekmez.

### Başarı ölçütleri

- Yeni bir baskı eklemek için bir `.md` dosyası ve fotoğraflar yeterlidir.
- Yeni bir proje eklemek için bir `.md` dosyası yeterlidir. Ana sayfadaki liste otomatik güncellenir.
- Tüm sayfalar aynı sidebar, menü ve stili kullanır.
- Site GitHub Pages üzerinde ek bir build adımı olmadan çalışır.
- Sayfalar 360 px genişlikte yatay kaydırma olmadan görünür.

### Kapsam dışı

- 2018 blog yazıları (`blog/2018/...`) değişmez ve taşınmaz.
- Blog ve "Now" sayfası bu sürümde yok.
- Arayüz dili İngilizce kalır. Çoklu dil desteği yok.
- Görsel tasarımda büyük değişiklik yok.

## Varsayımlar

- İçerik dili sahibin seçimidir. Arayüz metinleri İngilizcedir.
- Gerçek içerik henüz yok. Her koleksiyon için bir örnek dosya eklenir. Sahip bu dosyaları gerçek içerik ile değiştirir.
- Mevcut 5 proje `_projects/` klasörüne taşınır. Detay metni kısa bir taslaktır.

## Yaklaşım

**Seçilen: GitHub Pages içindeki Jekyll.**

GitHub Pages, repodaki Jekyll dosyalarını kendisi derler. GitHub Actions gerekmez.

Değerlendirilen diğer yollar:

- **Saf HTML**: Her öğe için HTML kopyalamak gerekir. İçerik arttıkça zahmetli olur.
- **Astro**: Daha esnektir, ama GitHub Actions ile build ve Node bağımlılıkları gerekir. Bu boyuttaki bir site için fazla bakım yükü getirir.

## Mimari

### Dosya yapısı

```
_config.yml
Gemfile                      # yerel önizleme için (github-pages gem)
_layouts/
  default.html               # <head>, iki sütunlu düzen, sidebar, footer
  page.html                  # default + başlık + Markdown içerik (Uses)
  project.html               # proje detay sayfası
  make.html                  # 3D öğe detay sayfası
_includes/
  head.html                  # meta, OG, font, CSS
  sidebar.html               # isim, ünvan, menü, sosyal linkler, Resume
  project-entry.html         # ana sayfadaki tek proje satırı
  model-viewer.html          # <model-viewer> script ve öğesi
_projects/
  prodtest.md, contra.md, craze.md, clipaste.md, guvercin.md
_makes/
  example-print.md           # örnek: kind: print
  example-model.md           # örnek: kind: model
3d/index.html                # 3D galerisi, /3d/
uses.md                      # /uses/
index.html                   # front matter + layout: default
assets/
  css/style.css              # yeni stiller buraya eklenir
  js/main.js                 # galeri filtresi buraya eklenir
  3d/<slug>/                 # baskı fotoğrafları, .glb dosyaları
  projects/<slug>/           # proje görselleri
README.md                    # içerik ekleme rehberi
```

### `_config.yml`

```yaml
title: Ahmet Korkmaz
url: https://ahmetkorkmaz3.github.io
markdown: kramdown
collections:
  projects:
    output: true
    permalink: /projects/:name/
  makes:
    output: true
    permalink: /3d/:name/
exclude: [README.md, Gemfile, Gemfile.lock, docs, .idea]
```

Koleksiyon adı `makes` olur, `3d` olmaz. Rakam ile başlayan koleksiyon adları Jekyll içinde sorun çıkarabilir. URL yine `/3d/...` olur.

`blog/2018/...` dosyalarında front matter yoktur. Jekyll bu dosyaları olduğu gibi kopyalar.

### Menü

Menü öğeleri: About · Experience · Projects · 3D · Uses.

- Ana sayfada About, Experience, Projects bugünkü gibi sayfa içi anchor linklerdir (`#about`).
- Diğer sayfalarda bu üç link ana sayfaya gider (`/#about`).
- 3D ve Uses ayrı sayfalara gider. Aktif sayfanın linki `active` sınıfını alır.
- `main.js` içindeki scroll vurgusu sadece ana sayfada çalışır. Bugünkü kod `main section[id]` yoksa zaten bir şey yapmaz.

### Düzen

Tüm sayfalar bugünkü iki sütunlu düzeni kullanır: solda sabit sidebar, sağda içerik.

Detay sayfalarında içerik sütununun üstünde bir geri linki olur: "← All projects" veya "← All 3D work".

## Koleksiyonlar

### Projeler: `_projects/*.md`

```yaml
---
title: Contra
year: 2022
order: 2                     # ana sayfadaki sıra, küçük olan üstte
summary: Merges GitHub and GitLab contribution calendars into a single view.
stack: [Vue, Nuxt, Express]
repo: ahmetkorkmaz3/contra   # isteğe bağlı, GitHub yıldız sayısı için
demo: https://contra-psi.vercel.app   # isteğe bağlı
cover: /assets/projects/contra/cover.png   # isteğe bağlı
---
Markdown gövde: problem, çözüm, teknik kararlar, ekran görüntüleri.
```

**Ana sayfa:** Projects bölümü `site.projects | sort: "order"` ile oluşur. Her satır bugünkü görünümü korur. Başlık linki detay sayfasına gider (`/projects/contra/`). Repo ve demo linkleri detay sayfasında görünür.

**Detay sayfası (`project.html`):** başlık, yıl, stack çipleri, yıldız sayısı, Repo ve Demo butonları, kapak görseli, Markdown gövde.

### 3D öğeleri: `_makes/*.md`

```yaml
---
title: Cable Organizer
date: 2026-09-12
kind: model                  # print veya model
cover: /assets/3d/cable-organizer/1.jpg
images:
  - /assets/3d/cable-organizer/1.jpg
  - /assets/3d/cable-organizer/2.jpg
printer: Bambu Lab A1        # isteğe bağlı
filament: PLA, matte black   # isteğe bağlı
designer: Ahmet Korkmaz      # print için asıl tasarımcı, isteğe bağlı
link: https://makerworld.com/...   # isteğe bağlı
model_file: /assets/3d/cable-organizer/model.glb   # isteğe bağlı
---
Markdown gövde: notlar, ayarlar, sorunlar.
```

- `kind: print` başka birinin modelinin baskısıdır. `kind: model` sahibin kendi tasarımıdır.
- `cover` yoksa `images` listesinin ilk öğesi kapak olur.

### Uses: `uses.md`

`layout: page` kullanan serbest bir Markdown sayfasıdır. Başlangıç bölümleri: Computer, Editor & Terminal, 3D Printing, Software. Her bölüm boş bir taslak listedir.

## 3D galerisi

### Liste sayfası: `/3d/`

- Üstte filtre butonları: All · Prints · My models.
- Altta kart ızgarası. Masaüstünde 2 sütun, mobilde 1 sütun olur. İçerik sütunu dar olduğu için 3 sütun kullanılmaz.
- Kart içeriği: kapak fotoğrafı (4:3, `object-fit: cover`), başlık, tarih, `print` veya `model` etiketi.
- Kartlar tarihe göre sıralanır, yeni olan üstte.
- Her kartın `data-kind` niteliği vardır. `main.js` filtre butonlarına göre kartları gizler veya gösterir.
- JavaScript yoksa filtre butonları gizli kalır ve tüm kartlar görünür.
- Görseller `loading="lazy"` ile yüklenir.

### Detay sayfası: `/3d/<slug>/`

Sıra:

1. Başlık, tarih, etiket.
2. 3D görüntüleyici. Sadece `model_file` doluysa görünür.
3. Fotoğraflar. Tek sütunda alt alta, her biri tam genişlikte.
4. Bilgi tablosu: printer, filament, designer. Sadece dolu alanlar görünür.
5. Dış link butonu ("View on MakerWorld" gibi). Sadece `link` doluysa görünür.
6. Markdown gövde.

### 3D görüntüleyici

- Google `<model-viewer>` bileşeni kullanılır. Script cdn.jsdelivr.net üzerinden ve sadece `model_file` dolu sayfalarda yüklenir.
- Ayarlar: `camera-controls`, `auto-rotate`, `poster` olarak kapak fotoğrafı.
- Dosya biçimi GLB'dir. STL dosyasını GLB'ye çevirme adımı README içinde yazılıdır (Blender veya bir online çevirici).
- Görüntüleyicinin altında "Download .glb" linki olur.

## Görseller ve repo boyutu

- Fotoğraflar `assets/3d/<slug>/` klasörüne konur.
- README önerisi: fotoğrafı eklemeden önce uzun kenarı 1600 px olacak şekilde küçült. macOS komutu: `sips -Z 1600 *.jpg`.
- GLB dosyası için öneri: 10 MB altında tut. GitHub 100 MB üzerindeki dosyaları reddeder.
- Git LFS kullanılmaz. GitHub Pages LFS dosyalarını sunmaz.

## SEO

- Her sayfanın kendi `<title>`, `description`, `canonical` ve `og:*` etiketleri olur. Bu değerler front matter alanlarından gelir.
- Detay sayfalarında `og:image` olarak kapak görseli kullanılır.
- Ana sayfadaki JSON-LD `Person` verisi değişmez.

## Yerel önizleme

- Sistem Ruby sürümü 2.6'dır. `github-pages` gem güncel sürümü için daha yeni bir Ruby gerekebilir.
- README içinde iki seçenek yazılır: Homebrew Ruby ile `bundle exec jekyll serve`, veya Docker ile `jekyll/jekyll` imajı.
- Uygulama sırasında hangisinin çalıştığı denenir ve README buna göre yazılır.

## Test

1. Yerelde build al. Build uyarı veya hata vermez.
2. Bu sayfaları aç: `/`, `/projects/contra/`, `/3d/`, `/3d/example-model/`, `/uses/`, `/blog/2018/10/05/zorbuis/`.
3. Her sayfada menü linklerini kontrol et. Kırık link olmaz.
4. `/3d/` sayfasında üç filtreyi dene. JavaScript kapalıyken de dene.
5. `/3d/example-model/` sayfasında 3D görüntüleyicinin yüklendiğini kontrol et.
6. Playwright ile her sayfanın 360 px ve 1280 px ekran görüntüsünü al. Açık ve koyu temada yatay kaydırma olmadığını kontrol et.

## Riskler

- **Ruby sürümü**: Yerel build başarısız olabilir. Çözüm Docker veya Homebrew Ruby kullanmaktır. GitHub Pages tarafı bundan etkilenmez.
- **Mutlak yollar**: Site kök alan adında (`ahmetkorkmaz3.github.io`) çalışır. Bu yüzden `/assets/...` yolları doğru çalışır. `clipaste` gibi alt repo sayfaları etkilenmez.
- **Repo boyutu**: Çok sayıda fotoğraf repoyu büyütür. README içindeki küçültme adımı bu riski azaltır.
