# Multi-Page Site Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn the one-page portfolio into a Jekyll site with project detail pages, a 3D gallery (prints and own models, optional 3D viewer) and a Uses page. New content is a Markdown file.

**Architecture:** GitHub Pages builds the repo with its built-in Jekyll. A shared `default` layout holds the head, the sidebar and the footer. Two collections (`projects`, `makes`) give one page per Markdown file. A stdlib Ruby script checks the built `_site/` folder. It is the test suite.

**Tech Stack:** Jekyll 3.10 through the `github-pages` gem, Liquid, kramdown, plain CSS, plain JS, Google `<model-viewer>` 4.0.0 from cdn.jsdelivr.net, Ruby 3.3 (Homebrew) for local builds.

**Spec:** `docs/superpowers/specs/2026-10-04-multi-page-site-design.md`

## Global Constraints

- GitHub Pages builds the site. No GitHub Actions, no plugins outside the `github-pages` gem.
- Interface text is English. Content language is the owner's choice.
- Keep the current visual design: two columns, `assets/css/style.css`, Inter font, light and dark theme.
- Every page works at 360 px width with no horizontal scroll.
- Write every internal URL with the `relative_url` filter (`{{ '/path/' | relative_url }}`).
- The files in `blog/2018/` do not change.
- Load `<model-viewer>` only on a page with `model_file`. Script URL: `https://cdn.jsdelivr.net/npm/@google/model-viewer@4.0.0/dist/model-viewer.min.js`.
- The collection name is `makes`. Its URL is `/3d/<slug>/`.
- The `kind` field of a make is `print` or `model`. No other value.
- Commit messages are in English, imperative mood, and end with the attribution lines of the session.

## Review Focus

1. **A phone visitor must reach 3D and Uses.** The current CSS hides `.nav` below 1024 px. Task 2 shows the menu as a wrapping row and adds a check against the hidden rule.
2. **A typo in `kind` ("Print", "models").** The card then disappears under every filter except All. Task 4 adds a check: every `data-kind` on `/3d/` is `print` or `model`.
3. **A make with no `images` and no `cover`.** The card must show an empty frame, not a broken image. Task 4, Step 6 builds a temporary file without photos and checks the card.
4. **Internal links on nested pages.** A relative `assets/...` path breaks under `/3d/<slug>/`. The link check in `scripts/check_site.rb` (Task 1) resolves every `href`, `src` and `poster` in every built page.
5. **The 2018 posts still work.** Jekyll copies them without front matter. Task 1 checks that the three pages exist, and the link check covers their links.

---

## File map

| File | Task | Responsibility |
|---|---|---|
| `Gemfile`, `Gemfile.lock` | 1 | Local build with the `github-pages` gem |
| `_config.yml` | 1, 3, 4 | Site settings, collections, defaults |
| `.gitignore` | 1 | Ignore build output |
| `scripts/test.sh` | 1 | Build the site, then run the checks |
| `scripts/check_site.rb` | 1 | Check runner and link check |
| `scripts/checks/10_home.rb` | 1 | Home page checks |
| `scripts/checks/20_uses.rb` | 2 | Uses page and menu checks |
| `scripts/checks/30_projects.rb` | 3 | Project pages checks |
| `scripts/checks/40_makes.rb` | 4 | 3D gallery and detail checks |
| `scripts/checks/50_viewer.rb` | 5 | 3D viewer checks |
| `_layouts/default.html` | 1 | HTML shell: head, sidebar, main, footer, script |
| `_layouts/page.html` | 2 | Title + Markdown body |
| `_layouts/project.html` | 3 | Project detail page |
| `_layouts/make.html` | 4, 5 | 3D detail page |
| `_includes/head.html` | 1 | Meta tags, fonts, CSS, JSON-LD on home |
| `_includes/person-jsonld.html` | 1 | Person JSON-LD (moved from `index.html`) |
| `_includes/sidebar.html` | 1, 2, 4 | Name, menu, socials, resume |
| `_includes/stars.html` | 3 | GitHub star count with fallback |
| `_includes/project-entry.html` | 3 | One project row on the home page |
| `_includes/kind-label.html` | 4 | "Print" or "My model" label |
| `_includes/model-viewer.html` | 5 | Viewer script, element and download link |
| `index.html` | 1, 3 | Home page body |
| `uses.md` | 2 | Uses page |
| `_projects/*.md` | 3 | Five project pages |
| `3d/index.html` | 4 | 3D gallery |
| `_makes/example-print.md`, `_makes/example-model.md` | 4, 5 | Example 3D items |
| `assets/3d/example-*/` | 4, 5 | Placeholder photos, example GLB |
| `scripts/make_cube_glb.py` | 5 | Writes the example GLB |
| `assets/css/style.css` | 1–5 | Styles |
| `assets/js/main.js` | 4 | Gallery filter |
| `README.md` | 6 | How to add content and preview locally |

---

### Task 1: Jekyll setup, shared layout, home page

**Files:**
- Create: `Gemfile`, `_config.yml`, `scripts/test.sh`, `scripts/check_site.rb`, `scripts/checks/10_home.rb`, `_layouts/default.html`, `_includes/head.html`, `_includes/person-jsonld.html`, `_includes/sidebar.html`
- Modify: `.gitignore`, `index.html` (whole file)
- Test: `scripts/checks/10_home.rb`

**Interfaces:**
- Produces: layout `default`. Front matter fields it reads: `title`, `full_title` (true = use `title` as is), `description`, `summary`, `og_type`, `og_description`, `cover`, `images`, `nav` (`projects`, `3d` or `uses`).
- Produces: check helpers in `scripts/check_site.rb`: `read_page(path) -> String or nil`, `expect_match(path, regex, what)`, `expect_no_match(path, regex, what)`, the `FAILURES` array and the `SITE` path. Each later task adds one file in `scripts/checks/`.
- Produces: `scripts/test.sh`. Exit 0 when the build and all checks pass.

- [ ] **Step 1: Install Ruby 3.3 and the gems**

The system Ruby (2.6) is too old for the `github-pages` gem.

```bash
brew install ruby@3.3
export PATH="/opt/homebrew/opt/ruby@3.3/bin:$PATH"
ruby -v   # Expected: ruby 3.3.x
```

Create `Gemfile`:

```ruby
source "https://rubygems.org"

gem "github-pages", group: :jekyll_plugins
gem "webrick"
```

```bash
bundle config set --local path vendor/bundle
bundle install
```

Expected: `Bundle complete!`. If `brew install ruby@3.3` fails, use Docker for every build in this plan: `docker run --rm -v "$PWD":/srv -w /srv ruby:3.3 bash -c "bundle install && scripts/test.sh"`.

Append to `.gitignore`:

```
_site/
.jekyll-cache/
.bundle/
vendor/
```

- [ ] **Step 2: Write the test runner and the home checks**

Create `scripts/test.sh` and run `chmod +x scripts/test.sh`:

```bash
#!/usr/bin/env bash
# Builds the site into _site/ and checks the output.
set -euo pipefail
cd "$(dirname "$0")/.."
if [ -d /opt/homebrew/opt/ruby@3.3/bin ]; then
  export PATH="/opt/homebrew/opt/ruby@3.3/bin:$PATH"
fi
bundle exec jekyll build --strict_front_matter
bundle exec ruby scripts/check_site.rb
```

Create `scripts/check_site.rb`:

```ruby
#!/usr/bin/env ruby
# frozen_string_literal: true

# Checks the built site in _site/. Run scripts/test.sh, which builds the site first.
# Each file in scripts/checks/ adds page checks. The link check below runs on every page.

Encoding.default_external = Encoding::UTF_8 # pages contain "Güvercin" and "·"

SITE = File.expand_path('../_site', __dir__)
FAILURES = []

def read_page(path)
  file = File.join(SITE, path)
  file = File.join(file, 'index.html') if File.directory?(file)
  return File.read(file) if File.file?(file)

  FAILURES << "#{path}: page not found"
  nil
end

def expect_match(path, pattern, what)
  html = read_page(path) or return
  FAILURES << "#{path}: expected #{what}" unless html.match?(pattern)
end

def expect_no_match(path, pattern, what)
  html = read_page(path) or return
  FAILURES << "#{path}: did not expect #{what}" if html.match?(pattern)
end

Dir[File.join(__dir__, 'checks', '*.rb')].sort.each { |file| require file }

# Every local href, src and poster must point at a built file.
Dir[File.join(SITE, '**', '*.html')].each do |file|
  File.read(file).scan(/(?:href|src|poster)="([^"]+)"/).flatten.uniq.each do |ref|
    next if ref.match?(%r{\A(?:[a-z][a-z0-9+.-]*:|//|#)}i)

    target = ref.sub(/[?#].*\z/, '')
    next if target.empty?

    path = target.start_with?('/') ? File.join(SITE, target) : File.expand_path(target, File.dirname(file))
    path = File.join(path, 'index.html') if File.directory?(path)
    FAILURES << "#{file.delete_prefix(SITE)}: broken link #{ref}" unless File.file?(path)
  end
end

if FAILURES.empty?
  puts 'check_site: all checks passed'
else
  puts FAILURES.map { |failure| "FAIL #{failure}" }
  exit 1
end
```

Create `scripts/checks/10_home.rb`:

```ruby
# frozen_string_literal: true

expect_match('/', %r{<title>Ahmet Korkmaz · Senior Software Developer</title>}, 'home title')
expect_match('/', %r{<h1 class="name">Ahmet Korkmaz</h1>}, 'name as h1')
expect_match('/', /"@type": "Person"/, 'Person JSON-LD')
expect_match('/', %r{rel="canonical" href="https://ahmetkorkmaz3.github.io/"}, 'canonical URL')
expect_match('/', %r{property="og:type" content="profile"}, 'profile og:type')
expect_match('/', /Built with Jekyll/, 'footer text from the default layout')
%w[about experience projects].each do |id|
  expect_match('/', %r{<section id="#{id}"}, "##{id} section")
end
%w[zorbuis sapps18 oyk18-ardindan].each do |slug|
  expect_match("/blog/2018/10/05/#{slug}/", /<html lang="tr">/, "2018 post #{slug}")
end
```

- [ ] **Step 3: Create the base config and run the checks to see them fail**

Create `_config.yml`:

```yaml
title: Ahmet Korkmaz
description: Ahmet Korkmaz is a senior full stack developer at Moneo.
url: https://ahmetkorkmaz3.github.io
baseurl: ""
og_image: https://avatars.githubusercontent.com/u/29120746?v=4
timezone: Europe/Istanbul
markdown: kramdown
liquid:
  error_mode: strict
  strict_filters: true
exclude:
  - README.md
  - Gemfile
  - Gemfile.lock
  - docs
  - scripts
  - vendor
```

Run: `scripts/test.sh`
Expected: exit 1 with `FAIL /: expected footer text from the default layout`. Jekyll still copies the old `index.html` as a static file, so the other home checks pass.

- [ ] **Step 4: Create the includes and the default layout**

Create `_includes/person-jsonld.html`. Move `index.html` lines 25–42 (the `<script type="application/ld+json">` block) into it with no change.

Create `_includes/head.html`:

```html
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
{% if page.full_title %}{% assign page_title = page.title %}{% else %}{% assign page_title = page.title | append: ' · ' | append: site.title %}{% endif %}
{% assign page_description = page.description | default: page.summary | default: site.description %}
{% assign page_image = page.cover | default: page.images.first | default: site.og_image | absolute_url %}
<title>{{ page_title }}</title>
<meta name="description" content="{{ page_description | strip_html | strip_newlines | escape }}">
<meta name="author" content="Murat Ahmet Korkmaz">
<link rel="canonical" href="{{ page.url | absolute_url }}">

<meta property="og:type" content="{{ page.og_type | default: 'article' }}">
<meta property="og:title" content="{{ page_title }}">
<meta property="og:description" content="{{ page.og_description | default: page_description | strip_html | strip_newlines | escape }}">
<meta property="og:url" content="{{ page.url | absolute_url }}">
<meta property="og:image" content="{{ page_image }}">
<meta name="twitter:card" content="summary">
<meta name="twitter:site" content="@ahmetmkorkmaz">

<link rel="icon" href="{{ '/img/favicon.ico' | relative_url }}">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="{{ '/assets/css/style.css' | relative_url }}">
{% if page.url == '/' %}{% include person-jsonld.html %}{% endif %}
```

Create `_includes/sidebar.html`. Copy the `<ul class="socials">…</ul>` block from `index.html` lines 64–77 with no change into the marked place:

```html
{% if page.url == '/' %}{% assign home = '' %}{% else %}{% assign home = '/' | relative_url %}{% endif %}
<header class="sidebar">
  <div>
    {% if page.url == '/' %}
    <h1 class="name">Ahmet Korkmaz</h1>
    {% else %}
    <p class="name"><a href="{{ '/' | relative_url }}">Ahmet Korkmaz</a></p>
    {% endif %}
    <p class="title">Senior Software Developer at <a href="https://moneo.com.tr" target="_blank" rel="noopener">Moneo</a></p>
    <p class="tagline">Full stack developer. I build web applications and APIs that stay reliable and easy to change.</p>

    <nav class="nav" aria-label="Site">
      <ul>
        <li><a href="{{ home }}#about">About</a></li>
        <li><a href="{{ home }}#experience">Experience</a></li>
        <li><a{% if page.nav == 'projects' %} class="active"{% endif %} href="{{ home }}#projects">Projects</a></li>
      </ul>
    </nav>
  </div>

  <div class="sidebar-foot">
    <!-- index.html lines 64–77: <ul class="socials"> … </ul> -->
    <a class="resume" href="{{ '/CV/Murat_Ahmet_Korkmaz_CV.pdf' | relative_url }}" target="_blank" rel="noopener">Resume <span>↗</span></a>
  </div>
</header>
```

Replace the HTML comment with the copied block. Do not leave the comment in the file.

Create `_layouts/default.html`:

```html
<!DOCTYPE html>
<html lang="en">
<head>
  {% include head.html %}
</head>
<body>
  <a class="skip" href="#content">Skip to content</a>

  <div class="layout">
    {% include sidebar.html %}

    <main class="content" id="content">
      {{ content }}

      <p class="footnote">© <span data-year>{{ site.time | date: '%Y' }}</span> Murat Ahmet Korkmaz. Built with Jekyll, hosted on GitHub Pages.</p>
    </main>
  </div>

  <script src="{{ '/assets/js/main.js' | relative_url }}"></script>
</body>
</html>
```

- [ ] **Step 5: Convert `index.html` to use the layout**

Replace the whole file. Keep lines 83–189 of the old file (the three `<section>` blocks) with no change, between the front matter and the end of the file:

```html
---
layout: default
title: Ahmet Korkmaz · Senior Software Developer
full_title: true
description: Ahmet Korkmaz is a senior full stack developer at Moneo. He builds web applications and APIs with Laravel, Symfony, React and Next.js.
og_type: profile
og_description: Senior full stack developer at Moneo. Laravel, Symfony, React and Next.js.
---
<section id="about" aria-label="About">
  …old lines 84–99…
</section>
…old lines 101–189 (experience and projects sections)…
```

The old `<head>`, sidebar, footnote and `<script>` lines leave this file. The layout and the includes now hold them.

- [ ] **Step 6: Run the checks**

Run: `scripts/test.sh`
Expected: `check_site: all checks passed`.

Then compare the old and new home pages by eye:

```bash
bundle exec jekyll serve --port 4000
```

Open `http://localhost:4000/`. The page looks the same as before, except the footer text.

- [ ] **Step 7: Commit**

```bash
git add Gemfile Gemfile.lock .gitignore _config.yml _layouts _includes index.html scripts
git commit -m "Build the site with Jekyll and a shared layout"
```

---

### Task 2: Uses page and site menu

**Files:**
- Create: `_layouts/page.html`, `uses.md`, `scripts/checks/20_uses.rb`
- Modify: `_includes/sidebar.html` (menu list), `assets/css/style.css` (page styles, mobile menu)
- Test: `scripts/checks/20_uses.rb`

**Interfaces:**
- Consumes: layout `default`, field `nav` (Task 1).
- Produces: layout `page`. Reads `title`, optional `summary`.
- Produces: CSS classes `.detail`, `.detail .back`, `.detail-head`, `.detail-meta`, `.detail-summary`, `.prose`. Tasks 3–5 use them.

- [ ] **Step 1: Write the failing checks**

Create `scripts/checks/20_uses.rb`:

```ruby
# frozen_string_literal: true

expect_match('/uses/', %r{<title>Uses · Ahmet Korkmaz</title>}, 'Uses title')
expect_match('/uses/', %r{<h1[^>]*>Uses</h1>}, 'Uses heading')
%w[Computer 3D\ Printing Software].each do |section|
  expect_match('/uses/', %r{<h2[^>]*>#{section}</h2>}, "#{section} section")
end
expect_match('/uses/', %r{<a class="active" href="/uses/"}, 'Uses menu link marked active')
expect_match('/uses/', %r{<p class="name"><a href="/">Ahmet Korkmaz</a></p>}, 'name links to home')
expect_match('/uses/', %r{href="/#about"}, 'About link points to home')
expect_match('/', %r{href="/uses/"}, 'Uses link on home')
expect_no_match('/', %r{class="active" href="/uses/"}, 'Uses link active on home')
expect_no_match('/assets/css/style.css', /\.nav \{ display: none; \}/, 'menu hidden on small screens')
```

- [ ] **Step 2: Run the checks to see them fail**

Run: `scripts/test.sh`
Expected: exit 1 with `FAIL /uses/: page not found` and `FAIL /assets/css/style.css: did not expect menu hidden on small screens`.

- [ ] **Step 3: Add the layout, the page and the menu link**

Create `_layouts/page.html`:

```html
---
layout: default
---
<article class="detail">
  <header class="detail-head">
    <h1>{{ page.title }}</h1>
    {% if page.summary %}<p class="detail-summary">{{ page.summary }}</p>{% endif %}
  </header>
  <div class="prose">
    {{ content }}
  </div>
</article>
```

Create `uses.md`:

```markdown
---
layout: page
title: Uses
nav: uses
permalink: /uses/
summary: The hardware, tools and software I use every day.
---

## Computer

- _Add your computer here._

## Editor & Terminal

- _Add your editor and terminal here._

## 3D Printing

- _Add your printer, slicer and filaments here._

## Software

- _Add the apps you use every day here._
```

In `_includes/sidebar.html`, add this line after the Projects item:

```html
        <li><a{% if page.nav == 'uses' %} class="active"{% endif %} href="{{ '/uses/' | relative_url }}">Uses</a></li>
```

- [ ] **Step 4: Add the page styles and show the menu on small screens**

In `assets/css/style.css`, add before `/* ---------- Responsive ---------- */`:

```css
/* ---------- Pages ---------- */
.name a:hover { color: var(--accent); }
.detail .back { display: inline-block; margin-bottom: 32px; font-size: 14px; font-weight: 500; color: var(--muted); }
.detail .back:hover { color: var(--accent); }
.detail-head { margin-bottom: 40px; }
.detail-head h1 { font-size: 32px; font-weight: 700; color: var(--text); letter-spacing: -.02em; line-height: 1.2; }
.detail-meta {
  margin-bottom: 8px; font-size: 12px; font-weight: 600; letter-spacing: .06em;
  text-transform: uppercase; color: var(--muted);
}
.detail-summary { margin-top: 12px; font-size: 17px; }
.prose > * + * { margin-top: 1em; }
.prose h2 {
  margin-top: 2.5em; font-size: 12px; font-weight: 600; letter-spacing: .12em;
  text-transform: uppercase; color: var(--text);
}
.prose ul { list-style: disc; padding-left: 22px; }
.prose li + li { margin-top: 6px; }
.prose a { color: var(--accent); }
.prose img { max-width: 100%; height: auto; border-radius: 8px; }
.prose code { font-size: .9em; padding: 2px 6px; border-radius: 4px; background: var(--surface); }
```

In the `@media (max-width: 1023px)` block, replace the line `.nav { display: none; }` with:

```css
  .nav { margin-top: 28px; }
  .nav ul { display: flex; flex-wrap: wrap; gap: 0 20px; }
  .nav a { padding: 6px 0; }
  .nav a::before { display: none; }
```

- [ ] **Step 5: Run the checks**

Run: `scripts/test.sh`
Expected: `check_site: all checks passed`.

- [ ] **Step 6: Commit**

```bash
git add _layouts/page.html uses.md _includes/sidebar.html assets/css/style.css scripts/checks/20_uses.rb
git commit -m "Add the Uses page and show the menu on small screens"
```

---

### Task 3: Project collection and detail pages

**Files:**
- Create: `_layouts/project.html`, `_includes/stars.html`, `_includes/project-entry.html`, `_projects/prodtest.md`, `_projects/contra.md`, `_projects/craze.md`, `_projects/clipaste.md`, `_projects/guvercin.md`, `scripts/checks/30_projects.rb`
- Modify: `_config.yml` (collection, defaults), `index.html` (projects list), `assets/css/style.css` (`.stars`, `.btn`, `.actions`, `.detail-cover`)
- Test: `scripts/checks/30_projects.rb`

**Interfaces:**
- Consumes: layout `default`, classes `.detail*` and `.prose` (Task 2).
- Produces: collection `projects`, fields `title`, `year`, `order`, `summary`, `stack` (list), `repo` (`owner/name`), `stars` (fallback count), `demo` (URL), `cover` (path).
- Produces: `{% include stars.html repo=… count=… %}` and CSS classes `.btn`, `.actions`. Task 4 uses `.btn` and `.actions`.

- [ ] **Step 1: Write the failing checks**

Create `scripts/checks/30_projects.rb`:

```ruby
# frozen_string_literal: true

projects = {
  'prodtest' => 'Prodtest',
  'contra' => 'Contra',
  'craze' => 'Craze',
  'clipaste' => 'Clipaste',
  'guvercin' => 'Güvercin'
}

projects.each do |slug, title|
  path = "/projects/#{slug}/"
  expect_match(path, %r{<h1[^>]*>#{title}</h1>}, "#{title} heading")
  expect_match(path, %r{<title>#{title} · Ahmet Korkmaz</title>}, "#{title} page title")
  expect_match(path, %r{<a class="active" href="/#projects"}, 'Projects menu link marked active')
  expect_match(path, %r{<a class="back" href="/#projects">}, 'back link')
  expect_match('/', %r{<a href="#{path}">#{title}<span class="arrow">}, "home link to #{slug}")
end

home = read_page('/')
if home
  positions = projects.keys.map { |slug| home.index(%(href="/projects/#{slug}/")) }
  FAILURES << '/: projects missing or not in the order field order' if positions.include?(nil) || positions != positions.sort
end

expect_match('/projects/contra/', %r{href="https://github.com/ahmetkorkmaz3/contra"}, 'Contra source button')
expect_match('/projects/contra/', %r{href="https://contra-psi.vercel.app"}, 'Contra demo button')
expect_match('/projects/contra/', %r{data-repo="ahmetkorkmaz3/contra">27<}, 'Contra star fallback')
expect_no_match('/projects/craze/', /Live demo/, 'demo button without a demo field')
expect_match('/', %r{data-repo="prodtestapp/prodtest-web">32<}, 'Prodtest star fallback on home')
expect_no_match('/', %r{data-repo="craze-app/craze"}, 'star count without a stars field')
```

- [ ] **Step 2: Run the checks to see them fail**

Run: `scripts/test.sh`
Expected: exit 1 with `FAIL /projects/prodtest/: page not found` and the other project failures.

- [ ] **Step 3: Add the collection to `_config.yml`**

Add after `liquid:`:

```yaml
collections:
  projects:
    output: true
    permalink: /projects/:name/
defaults:
  - scope:
      path: ""
      type: projects
    values:
      layout: project
      nav: projects
```

- [ ] **Step 4: Create the includes and the layout**

Create `_includes/stars.html`:

```html
<span class="stars"><svg viewBox="0 0 24 24" aria-hidden="true"><path fill="currentColor" d="m12 2 3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2Z"/></svg><span data-repo="{{ include.repo }}">{{ include.count }}</span></span>
```

Create `_includes/project-entry.html`:

```html
<li class="entry">
  <span class="when">{{ include.project.year }}</span>
  <div>
    <h3><a href="{{ include.project.url | relative_url }}">{{ include.project.title }}<span class="arrow">→</span></a></h3>
    <p>{{ include.project.summary }}</p>
    {% if include.project.stars %}{% include stars.html repo=include.project.repo count=include.project.stars %}{% endif %}
    <ul class="chips">{% for item in include.project.stack %}<li>{{ item }}</li>{% endfor %}</ul>
  </div>
</li>
```

Create `_layouts/project.html`:

```html
---
layout: default
---
<article class="detail">
  <a class="back" href="{{ '/#projects' | relative_url }}">← All projects</a>
  <header class="detail-head">
    <p class="detail-meta">{{ page.year }}</p>
    <h1>{{ page.title }}</h1>
    <p class="detail-summary">{{ page.summary }}</p>
    {% if page.stars %}{% include stars.html repo=page.repo count=page.stars %}{% endif %}
    <ul class="chips">{% for item in page.stack %}<li>{{ item }}</li>{% endfor %}</ul>
    {% if page.repo or page.demo %}
    <p class="actions">
      {% if page.repo %}<a class="btn" href="https://github.com/{{ page.repo }}" target="_blank" rel="noopener">Source on GitHub ↗</a>{% endif %}
      {% if page.demo %}<a class="btn" href="{{ page.demo }}" target="_blank" rel="noopener">Live demo ↗</a>{% endif %}
    </p>
    {% endif %}
  </header>
  {% if page.cover %}<img class="detail-cover" src="{{ page.cover | relative_url }}" alt="{{ page.title }} screenshot">{% endif %}
  <div class="prose">
    {{ content }}
  </div>
</article>
```

- [ ] **Step 5: Create the five project files**

`_projects/prodtest.md`:

```markdown
---
title: Prodtest
year: 2021
order: 1
summary: A no-code end-to-end API testing tool. Second place in the Teknasyon hackathon.
stack: [Laravel, Vue]
repo: prodtestapp/prodtest-web
stars: 32
---

## What it does

Prodtest lets you write end-to-end API tests without code.

## Recognition

Prodtest won second place in the Teknasyon hackathon.
```

`_projects/contra.md`:

```markdown
---
title: Contra
year: 2022
order: 2
summary: Merges GitHub and GitLab contribution calendars into a single view.
stack: [Vue, Nuxt, Express]
repo: ahmetkorkmaz3/contra
stars: 27
demo: https://contra-psi.vercel.app
---

## What it does

Contra reads your GitHub and GitLab contribution calendars and shows them as one calendar.

## How it works

A Nuxt frontend shows the calendar. A separate Express API collects the data.
```

`_projects/craze.md`:

```markdown
---
title: Craze
year: 2022
order: 3
summary: An open source desktop app that brings useful developer tools together in one place, on any platform.
stack: [TypeScript, Desktop]
repo: craze-app/craze
---

## What it does

Craze puts the small tools a developer uses every day into one desktop app. It works on macOS, Windows and Linux.
```

`_projects/clipaste.md`:

```markdown
---
title: Clipaste
year: 2020
order: 4
summary: A cross-platform clipboard manager for macOS, Windows and Linux. Keeps the history of copied text.
stack: [Electron, JavaScript]
repo: ahmetkorkmaz3/clipaste
stars: 17
demo: https://ahmetkorkmaz3.github.io/clipaste/
---

## What it does

Clipaste keeps the history of the text you copy. You can paste an older item again.
```

`_projects/guvercin.md`:

```markdown
---
title: Güvercin
year: 2020
order: 5
summary: A desktop REST API client to send requests and examine the responses.
stack: [Electron, JavaScript]
repo: ahmetkorkmaz3/guvercin
---

## What it does

Güvercin sends HTTP requests to a REST API and shows the responses.
```

- [ ] **Step 6: Build the home projects list from the collection**

In `index.html`, replace everything between `<ul class="entries">` and its `</ul>` inside `<section id="projects">` with:

```html
          {% assign projects = site.projects | sort: 'order' %}
          {% for project in projects %}{% include project-entry.html project=project %}{% endfor %}
```

Keep the `<h2 class="section-title">` line and the "All projects on GitHub" link.

- [ ] **Step 7: Add the styles**

In `assets/css/style.css`:

1. Replace `.entry .stars { … }` with `.stars { display: inline-flex; align-items: center; gap: 4px; margin-top: 10px; font-size: 13px; color: var(--muted); }`.
2. Replace `.entry .stars svg { … }` with `.stars svg { width: 14px; height: 14px; }`.
3. Change the selector `.resume {` to `.resume, .btn {`, and `.resume:hover {` to `.resume:hover, .btn:hover {`.
4. Add at the end of the `/* ---------- Pages ---------- */` block:

```css
.detail-head .stars { display: flex; width: max-content; }
.actions { display: flex; flex-wrap: wrap; gap: 12px; margin-top: 24px; }
.detail-cover { display: block; width: 100%; height: auto; margin-bottom: 40px; border-radius: 10px; border: 1px solid var(--line); }
```

- [ ] **Step 8: Run the checks**

Run: `scripts/test.sh`
Expected: `check_site: all checks passed`.

- [ ] **Step 9: Commit**

```bash
git add _config.yml _layouts/project.html _includes/stars.html _includes/project-entry.html _projects index.html assets/css/style.css scripts/checks/30_projects.rb
git commit -m "Add a detail page for each project"
```

---

### Task 4: 3D gallery and detail pages

**Files:**
- Create: `_layouts/make.html`, `_includes/kind-label.html`, `3d/index.html`, `_makes/example-print.md`, `_makes/example-model.md`, `assets/3d/example-print/1.svg`, `assets/3d/example-print/2.svg`, `assets/3d/example-model/1.svg`, `scripts/checks/40_makes.rb`
- Modify: `_config.yml` (collection, defaults), `_includes/sidebar.html` (3D link), `assets/js/main.js` (filter), `assets/css/style.css` (gallery styles)
- Test: `scripts/checks/40_makes.rb`

**Interfaces:**
- Consumes: layout `default`, `.detail*`, `.prose` (Task 2), `.btn`, `.actions` (Task 3).
- Produces: collection `makes`, fields `title`, `date`, `kind` (`print` or `model`), `cover`, `images` (list), `printer`, `filament`, `designer`, `link`, `model_file`.
- Produces: in `_layouts/make.html`, the line `{% comment %} viewer {% endcomment %}`. Task 5 replaces this line.

- [ ] **Step 1: Write the failing checks**

Create `scripts/checks/40_makes.rb`:

```ruby
# frozen_string_literal: true

expect_match('/3d/', %r{<title>3D · Ahmet Korkmaz</title>}, '3D title')
expect_match('/3d/', %r{<a class="active" href="/3d/"}, '3D menu link marked active')
expect_match('/', %r{href="/3d/"}, '3D link on home')
expect_match('/3d/', /<div class="filters" hidden/, 'filters hidden without JavaScript')
%w[all print model].each do |kind|
  expect_match('/3d/', %r{data-filter="#{kind}"}, "#{kind} filter button")
end

gallery = read_page('/3d/')
if gallery
  kinds = gallery.scan(/data-kind="([^"]*)"/).flatten
  FAILURES << '/3d/: expected at least 2 cards' if kinds.size < 2
  unknown = kinds - %w[print model]
  FAILURES << "/3d/: unknown kind #{unknown.uniq.join(', ')} (use print or model)" unless unknown.empty?
  dates = gallery.scan(/<time datetime="([^"]+)"/).flatten
  FAILURES << '/3d/: cards not sorted newest first' unless dates == dates.sort.reverse
end

print_page = '/3d/example-print/'
expect_match(print_page, %r{<h1[^>]*>Example print: 3DBenchy</h1>}, 'print heading')
expect_match(print_page, %r{<a class="back" href="/3d/">}, 'back link')
expect_match(print_page, %r{<dt>Printer</dt>\s*<dd>Bambu Lab A1</dd>}, 'printer fact')
expect_match(print_page, %r{<dt>Designer</dt>\s*<dd>CreativeTools</dd>}, 'designer fact')
expect_match(print_page, /View on printables\.com/, 'external link button')
expect_match(print_page, %r{<img src="/assets/3d/example-print/2\.svg"}, 'second photo')
expect_match(print_page, %r{property="og:image" content="https://ahmetkorkmaz3.github.io/assets/3d/example-print/1\.svg"}, 'first photo as og:image')
expect_no_match(print_page, /model-viewer/, '3D viewer without model_file')
expect_no_match('/3d/example-model/', %r{<dt>Printer</dt>}, 'empty facts')
```

- [ ] **Step 2: Run the checks to see them fail**

Run: `scripts/test.sh`
Expected: exit 1 with `FAIL /3d/: page not found` and the other 3D failures.

- [ ] **Step 3: Add the collection to `_config.yml`**

Under `collections:` add:

```yaml
  makes:
    output: true
    permalink: /3d/:name/
```

Under `defaults:` add:

```yaml
  - scope:
      path: ""
      type: makes
    values:
      layout: make
      nav: 3d
```

- [ ] **Step 4: Create the label, the layout, the gallery and the menu link**

Create `_includes/kind-label.html`:

```html
{% if include.kind == 'model' %}<span class="tag tag-model">My model</span>{% else %}<span class="tag tag-print">Print</span>{% endif %}
```

Create `_layouts/make.html`:

```html
---
layout: default
---
{% assign cover = page.cover | default: page.images.first %}
<article class="detail">
  <a class="back" href="{{ '/3d/' | relative_url }}">← All 3D work</a>
  <header class="detail-head">
    <p class="detail-meta"><time datetime="{{ page.date | date_to_xmlschema }}">{{ page.date | date: '%b %Y' }}</time> · {% include kind-label.html kind=page.kind %}</p>
    <h1>{{ page.title }}</h1>
  </header>

  {% comment %} viewer {% endcomment %}

  {% if page.images %}
  <div class="gallery">
    {% for image in page.images %}<img src="{{ image | relative_url }}" alt="{{ page.title }}, photo {{ forloop.index }}" loading="lazy">{% endfor %}
  </div>
  {% endif %}

  {% if page.printer or page.filament or page.designer %}
  <dl class="facts">
    {% if page.printer %}<dt>Printer</dt>
    <dd>{{ page.printer }}</dd>{% endif %}
    {% if page.filament %}<dt>Filament</dt>
    <dd>{{ page.filament }}</dd>{% endif %}
    {% if page.designer %}<dt>Designer</dt>
    <dd>{{ page.designer }}</dd>{% endif %}
  </dl>
  {% endif %}

  {% if page.link %}
  {% assign link_parts = page.link | split: '/' %}
  {% assign link_host = link_parts[2] | remove_first: 'www.' %}
  <p class="actions"><a class="btn" href="{{ page.link }}" target="_blank" rel="noopener">View on {{ link_host }} ↗</a></p>
  {% endif %}

  <div class="prose">
    {{ content }}
  </div>
</article>
```

Create `3d/index.html`:

```html
---
layout: default
title: 3D
nav: 3d
description: 3D prints and models by Ahmet Korkmaz.
---
<article class="detail">
  <header class="detail-head">
    <h1>3D</h1>
    <p class="detail-summary">Things I print on my 3D printer, and models I design myself.</p>
  </header>

  <div class="filters" hidden role="group" aria-label="Filter by kind">
    <button type="button" data-filter="all" aria-pressed="true">All</button>
    <button type="button" data-filter="print" aria-pressed="false">Prints</button>
    <button type="button" data-filter="model" aria-pressed="false">My models</button>
  </div>

  {% assign items = site.makes | sort: 'date' | reverse %}
  <ul class="cards">
    {% for item in items %}
    {% assign cover = item.cover | default: item.images.first %}
    <li class="card" data-kind="{{ item.kind }}">
      <a href="{{ item.url | relative_url }}">
        {% if cover %}<img src="{{ cover | relative_url }}" alt="" loading="lazy">{% else %}<span class="card-empty" aria-hidden="true"></span>{% endif %}
        <h2>{{ item.title }}</h2>
        <p class="card-meta"><time datetime="{{ item.date | date_to_xmlschema }}">{{ item.date | date: '%b %Y' }}</time> · {% include kind-label.html kind=item.kind %}</p>
      </a>
    </li>
    {% endfor %}
  </ul>
</article>
```

In `_includes/sidebar.html`, add this line between the Projects item and the Uses item:

```html
        <li><a{% if page.nav == '3d' %} class="active"{% endif %} href="{{ '/3d/' | relative_url }}">3D</a></li>
```

- [ ] **Step 5: Create the example items and placeholder photos**

Create `assets/3d/example-print/1.svg`. Create `2.svg` in the same folder and `assets/3d/example-model/1.svg` with the same content. Change only the text "Example photo 1" to "Example photo 2" and "Example model", in that order.

```svg
<svg xmlns="http://www.w3.org/2000/svg" width="1600" height="1200" viewBox="0 0 1600 1200"><rect width="1600" height="1200" fill="#e2e8f0"/><text x="800" y="620" font-family="system-ui, sans-serif" font-size="72" fill="#64748b" text-anchor="middle">Example photo 1</text></svg>
```

Create `_makes/example-print.md`:

```markdown
---
title: "Example print: 3DBenchy"
date: 2026-09-12
kind: print
images:
  - /assets/3d/example-print/1.svg
  - /assets/3d/example-print/2.svg
printer: Bambu Lab A1
filament: PLA, red
designer: CreativeTools
link: https://www.printables.com/model/3161-3d-benchy
---

This is an example print. Replace this file with a real print.
```

Create `_makes/example-model.md`:

```markdown
---
title: "Example model: Calibration Cube"
date: 2026-09-20
kind: model
images:
  - /assets/3d/example-model/1.svg
---

This is an example model. Replace this file with a real model.
```

- [ ] **Step 6: Add the filter script and the styles, then test a make without photos**

In `assets/js/main.js`, add before the line `  // Live GitHub star counts`:

```js
  // 3D gallery filter. Without JavaScript the buttons stay hidden and every card shows.
  var filters = document.querySelector('.filters');
  if (filters) {
    var cards = document.querySelectorAll('.cards [data-kind]');
    filters.hidden = false;
    filters.addEventListener('click', function (event) {
      var button = event.target.closest('[data-filter]');
      if (!button) return;
      var kind = button.getAttribute('data-filter');
      filters.querySelectorAll('[data-filter]').forEach(function (b) {
        b.setAttribute('aria-pressed', String(b === button));
      });
      cards.forEach(function (card) {
        card.hidden = kind !== 'all' && card.getAttribute('data-kind') !== kind;
      });
    });
  }

```

In `assets/css/style.css`, add before `/* ---------- Responsive ---------- */`:

```css
/* ---------- 3D ---------- */
.filters { display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 24px; }
.filters[hidden] { display: none; }
.filters button {
  font: inherit; font-size: 13px; font-weight: 500; padding: 6px 12px; border-radius: 999px;
  border: 1px solid var(--line); background: none; color: var(--muted); cursor: pointer;
}
.filters button:hover { color: var(--text); }
.filters button[aria-pressed="true"] { background: var(--accent-soft); border-color: transparent; color: var(--accent); }
.cards { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 24px; }
.card[hidden] { display: none; }
.card a { display: block; }
.card img, .card-empty {
  display: block; width: 100%; aspect-ratio: 4 / 3; object-fit: cover;
  border-radius: 10px; border: 1px solid var(--line); background: var(--surface);
}
.card h2 { margin-top: 12px; font-size: 16px; font-weight: 500; color: var(--text); line-height: 1.4; }
.card a:hover h2 { color: var(--accent); }
.card-meta { margin-top: 4px; font-size: 13px; color: var(--muted); }
.tag { font-size: 11px; font-weight: 600; letter-spacing: .06em; text-transform: uppercase; }
.tag-model { color: var(--accent); }
.gallery { display: flex; flex-direction: column; gap: 16px; margin-bottom: 40px; }
.gallery img { display: block; width: 100%; height: auto; border-radius: 10px; border: 1px solid var(--line); }
.facts { display: grid; grid-template-columns: max-content 1fr; gap: 8px 24px; margin-bottom: 32px; font-size: 15px; }
.facts dt { color: var(--muted); }
.facts dd { margin: 0; color: var(--text); }
```

In the `@media (max-width: 600px)` block, add:

```css
  .cards { grid-template-columns: 1fr; }
```

Run: `scripts/test.sh`
Expected: `check_site: all checks passed`.

Then test a make without photos (Review Focus 3). Create a temporary file:

```bash
printf -- '---\ntitle: No photo\ndate: 2026-01-01\nkind: print\n---\n' > _makes/zz-no-photo.md
scripts/test.sh
grep -A3 'data-kind="print"' _site/3d/index.html | grep -c 'card-empty'
rm _makes/zz-no-photo.md
```

Expected: `check_site: all checks passed`, then `1`.

- [ ] **Step 7: Commit**

```bash
git add _config.yml _layouts/make.html _includes/kind-label.html _includes/sidebar.html 3d _makes assets/3d assets/js/main.js assets/css/style.css scripts/checks/40_makes.rb
git commit -m "Add the 3D gallery with print and model filters"
```

---

### Task 5: 3D viewer

**Files:**
- Create: `_includes/model-viewer.html`, `scripts/make_cube_glb.py`, `assets/3d/example-model/model.glb`, `scripts/checks/50_viewer.rb`
- Modify: `_layouts/make.html` (viewer line), `_makes/example-model.md` (`model_file`), `assets/css/style.css` (viewer styles)
- Test: `scripts/checks/50_viewer.rb`

**Interfaces:**
- Consumes: `_layouts/make.html` with the line `{% comment %} viewer {% endcomment %}` and the `cover` variable (Task 4).
- Produces: `{% include model-viewer.html src=… poster=… alt=… %}`.

- [ ] **Step 1: Write the failing checks**

Create `scripts/checks/50_viewer.rb`:

```ruby
# frozen_string_literal: true

model_page = '/3d/example-model/'
expect_match(model_page, %r{<model-viewer[^>]*src="/assets/3d/example-model/model\.glb"}, 'viewer with the model file')
expect_match(model_page, /<model-viewer[^>]*camera-controls/, 'camera controls')
expect_match(model_page, /<model-viewer[^>]*auto-rotate/, 'auto rotate')
expect_match(model_page, %r{<model-viewer[^>]*poster="/assets/3d/example-model/1\.svg"}, 'cover as poster')
expect_match(model_page, %r{src="https://cdn\.jsdelivr\.net/npm/@google/model-viewer@4\.0\.0/dist/model-viewer\.min\.js"}, 'viewer script')
expect_match(model_page, %r{href="/assets/3d/example-model/model\.glb" download>Download \.glb</a>}, 'download link')

glb = File.join(SITE, 'assets/3d/example-model/model.glb')
FAILURES << 'model.glb: not a binary glTF file' unless File.file?(glb) && File.binread(glb, 4) == 'glTF'
```

- [ ] **Step 2: Run the checks to see them fail**

Run: `scripts/test.sh`
Expected: exit 1 with `FAIL /3d/example-model/: expected viewer with the model file` and `FAIL model.glb: not a binary glTF file`.

- [ ] **Step 3: Write the example GLB**

Create `scripts/make_cube_glb.py`:

```python
"""Writes a 20 mm cube as a binary glTF (GLB) file: python3 scripts/make_cube_glb.py OUT.glb"""
import json
import struct
import sys

HALF = 0.01  # half edge in metres

positions, normals, indices = [], [], []
for axis in range(3):
    for sign in (1, -1):
        normal = [0.0, 0.0, 0.0]
        normal[axis] = float(sign)
        u = [0.0, 0.0, 0.0]
        u[(axis + 1) % 3] = 1.0
        v = [0.0, 0.0, 0.0]
        v[(axis + 2) % 3] = 1.0
        corners = [
            [normal[i] * HALF + HALF * (a * u[i] + b * v[i]) for i in range(3)]
            for a, b in ((-1, -1), (1, -1), (1, 1), (-1, 1))
        ]
        if sign < 0:
            corners.reverse()  # keep the winding counter-clockwise seen from outside
        base = len(positions)
        positions += corners
        normals += [normal] * 4
        indices += [base, base + 1, base + 2, base, base + 2, base + 3]

pos_bytes = b"".join(struct.pack("<3f", *p) for p in positions)
nrm_bytes = b"".join(struct.pack("<3f", *n) for n in normals)
idx_bytes = struct.pack(f"<{len(indices)}H", *indices)
binary = pos_bytes + nrm_bytes + idx_bytes
binary += b"\0" * (-len(binary) % 4)

gltf = {
    "asset": {"version": "2.0", "generator": "make_cube_glb.py"},
    "scene": 0,
    "scenes": [{"nodes": [0]}],
    "nodes": [{"mesh": 0}],
    "meshes": [{"primitives": [{"attributes": {"POSITION": 0, "NORMAL": 1}, "indices": 2, "material": 0}]}],
    "materials": [{"pbrMetallicRoughness": {"baseColorFactor": [0.11, 0.31, 0.85, 1.0], "metallicFactor": 0.0, "roughnessFactor": 0.6}}],
    "buffers": [{"byteLength": len(binary)}],
    "bufferViews": [
        {"buffer": 0, "byteOffset": 0, "byteLength": len(pos_bytes), "target": 34962},
        {"buffer": 0, "byteOffset": len(pos_bytes), "byteLength": len(nrm_bytes), "target": 34962},
        {"buffer": 0, "byteOffset": len(pos_bytes) + len(nrm_bytes), "byteLength": len(idx_bytes), "target": 34963},
    ],
    "accessors": [
        {"bufferView": 0, "componentType": 5126, "count": len(positions), "type": "VEC3", "min": [-HALF] * 3, "max": [HALF] * 3},
        {"bufferView": 1, "componentType": 5126, "count": len(normals), "type": "VEC3"},
        {"bufferView": 2, "componentType": 5123, "count": len(indices), "type": "SCALAR"},
    ],
}
json_bytes = json.dumps(gltf, separators=(",", ":")).encode()
json_bytes += b" " * (-len(json_bytes) % 4)

total = 12 + 8 + len(json_bytes) + 8 + len(binary)
with open(sys.argv[1], "wb") as out:
    out.write(struct.pack("<III", 0x46546C67, 2, total))
    out.write(struct.pack("<II", len(json_bytes), 0x4E4F534A) + json_bytes)
    out.write(struct.pack("<II", len(binary), 0x004E4942) + binary)
```

Run: `python3 scripts/make_cube_glb.py assets/3d/example-model/model.glb && head -c 4 assets/3d/example-model/model.glb; echo`
Expected: `glTF`.

- [ ] **Step 4: Add the viewer include and use it**

Create `_includes/model-viewer.html`:

```html
<script type="module" src="https://cdn.jsdelivr.net/npm/@google/model-viewer@4.0.0/dist/model-viewer.min.js"></script>
<div class="viewer">
  <model-viewer src="{{ include.src | relative_url }}"{% if include.poster %} poster="{{ include.poster | relative_url }}"{% endif %} alt="3D model of {{ include.alt }}" camera-controls auto-rotate></model-viewer>
  <a class="more" href="{{ include.src | relative_url }}" download>Download .glb</a>
</div>
```

In `_layouts/make.html`, replace the line `{% comment %} viewer {% endcomment %}` with:

```html
  {% if page.model_file %}{% include model-viewer.html src=page.model_file poster=cover alt=page.title %}{% endif %}
```

In `_makes/example-model.md`, add this line after `kind: model`:

```yaml
model_file: /assets/3d/example-model/model.glb
```

In `assets/css/style.css`, add at the end of the `/* ---------- 3D ---------- */` block:

```css
.viewer { margin-bottom: 40px; }
.viewer model-viewer {
  display: block; width: 100%; aspect-ratio: 4 / 3;
  border-radius: 10px; border: 1px solid var(--line); background: var(--surface);
}
.viewer .more { margin-top: 12px; }
```

- [ ] **Step 5: Run the checks**

Run: `scripts/test.sh`
Expected: `check_site: all checks passed`. The Task 4 check `expect_no_match(print_page, /model-viewer/ …)` still passes, because the print has no `model_file`.

- [ ] **Step 6: Commit**

```bash
git add _includes/model-viewer.html _layouts/make.html _makes/example-model.md scripts/make_cube_glb.py assets/3d/example-model/model.glb assets/css/style.css scripts/checks/50_viewer.rb
git commit -m "Show a 3D viewer for makes with a model file"
```

---

### Task 6: README and browser check

**Files:**
- Create: `README.md`
- Test: `scripts/test.sh`, manual browser check with Playwright

**Interfaces:**
- Consumes: all fields and commands from Tasks 1–5.

- [ ] **Step 1: Write `README.md`**

````markdown
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

## Yerel önizleme

1. Ruby 3.3 kur: `brew install ruby@3.3`
2. Bağımlılıkları kur: `bundle config set --local path vendor/bundle && bundle install`
3. Siteyi aç: `bundle exec jekyll serve`, sonra http://localhost:4000

Ruby 3.3 yolu PATH içinde olmalı: `export PATH="/opt/homebrew/opt/ruby@3.3/bin:$PATH"`

## Test

`scripts/test.sh` siteyi derler ve `_site/` klasörünü kontrol eder. Kırık linkleri de bulur.
````

Run: `scripts/test.sh`
Expected: `check_site: all checks passed`. `README.md` is in `exclude`, so the site does not change.

- [ ] **Step 2: Check the pages in a browser**

```bash
bundle exec jekyll serve --port 4000
```

Run this in the background. Use Playwright for each URL: `/`, `/projects/contra/`, `/3d/`, `/3d/example-print/`, `/3d/example-model/`, `/uses/`, `/blog/2018/10/05/zorbuis/`.

For each URL, at widths 360 px and 1280 px, and in light and dark color scheme:

1. Take a screenshot.
2. Run `document.documentElement.scrollWidth <= window.innerWidth` in the page. Expected: `true`.
3. At 360 px, make sure the menu shows About, Experience, Projects, 3D, Uses.

On `/3d/` at 1280 px:

1. Click "Prints". Expected: only the "Example print" card shows.
2. Click "My models". Expected: only the "Example model" card shows.
3. Click "All". Expected: both cards show.

On `/3d/example-model/`, wait 3 seconds. Expected: the blue cube shows in the viewer, and the browser console shows no errors.

Save the screenshots to the session scratchpad, not to the repo.

- [ ] **Step 3: Commit**

```bash
git add README.md
git commit -m "Add a README that explains how to add content"
```
