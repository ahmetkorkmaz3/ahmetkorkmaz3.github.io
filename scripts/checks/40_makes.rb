# frozen_string_literal: true

expect_match('/3d/', %r{<title>3D · Ahmet Korkmaz</title>}, '3D title')
expect_match('/3d/', %r{<a class="active" href="/3d/"}, '3D menu link marked active')
expect_match('/', %r{href="/3d/"}, '3D link on home')

# The 3D page uses the wide layout of the Uses page: a top bar, no sidebar.
expect_match('/3d/', /<header class="topbar">/, 'top bar on 3D')
expect_no_match('/3d/', /class="sidebar"/, 'sidebar on 3D')
expect_match('/3d/', %r{<h1[^>]*>3D</h1>}, '3D heading')
expect_no_match('/3d/', /class="filters"/, 'filters on 3D')

gallery = read_page('/3d/')
if gallery
  kinds = gallery.scan(/data-kind="([^"]*)"/).flatten
  FAILURES << '/3d/: expected at least 1 card' if kinds.empty?
  unknown = kinds - %w[print model]
  FAILURES << "/3d/: unknown kind #{unknown.uniq.join(', ')} (use print or model)" unless unknown.empty?
  dates = gallery.scan(/<time datetime="([^"]+)"/).flatten
  FAILURES << '/3d/: cards not sorted newest first' unless dates == dates.sort.reverse
end
expect_match('/3d/', %r{<a class="use-inner" href="/3d/contra-heatmap/">}, 'Contra card links to its page')
expect_match('/3d/', %r{<h2 class="use-name">Contra Heatmap Calendar</h2>}, 'Contra card title')
expect_match('/3d/', %r{<img src="/assets/3d/contra-heatmap/1\.webp"}, 'Contra card photo')

contra_page = '/3d/contra-heatmap/'
expect_match(contra_page, %r{<h1[^>]*>Contra Heatmap Calendar</h1>}, 'Contra heading')
expect_match(contra_page, %r{<title>Contra Heatmap Calendar · Ahmet Korkmaz</title>}, 'Contra page title')
expect_match(contra_page, %r{name="description" content="My GitHub and GitLab contributions}, 'description from the first paragraph')
expect_match(contra_page, /<header class="topbar">/, 'top bar on the detail page')
expect_no_match(contra_page, /class="sidebar"/, 'sidebar on the detail page')
expect_match(contra_page, %r{<a class="back" href="/3d/">}, 'back link')
expect_match(contra_page, %r{<dt>Designer</dt>\s*<dd>Ahmet Korkmaz, with Contra</dd>}, 'designer fact')

# The printed stands from the Uses page.
{ 'macbook-stand' => ['MacBook Stand', 'PLA, black', '612620'],
  'magsafe-charger-stand' => ['MagSafe Charger Stand', 'PLA, white', '582465'] }.each do |slug, (title, filament, model)|
  page = "/3d/#{slug}/"
  expect_match('/3d/', %r{<img src="/assets/3d/#{slug}/1\.webp"}, "#{title} card photo")
  expect_match(page, %r{<h1[^>]*>#{title}</h1>}, "#{title} heading")
  expect_match(page, %r{<dt>Filament</dt>\s*<dd>#{filament}</dd>}, "#{title} filament fact")
  expect_match(page, %r{<a class="btn" href="https://www\.printables\.com/model/#{model}-}, "#{title} Printables link")
end

# The footer must not touch the end of a page article.
expect_match('/assets/css/site.css', /\.detail \{ margin-bottom: 64px; \}/, 'space between an article and the footer')
