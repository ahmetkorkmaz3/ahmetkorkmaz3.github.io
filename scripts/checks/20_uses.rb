# frozen_string_literal: true

uses = '/uses/'
expect_match(uses, %r{<title>Uses · Ahmet Korkmaz</title>}, 'Uses title')
expect_match(uses, %r{<h1[^>]*>Uses</h1>}, 'Uses heading')

# The Uses page has its own wide layout: a top bar, no sidebar.
expect_match(uses, /<header class="topbar">/, 'top bar')
expect_no_match(uses, /class="sidebar"/, 'sidebar')
expect_match(uses, %r{<a class="topbar-name" href="/">Ahmet Korkmaz</a>}, 'name links to home')
expect_match(uses, %r{<a class="active" href="/uses/"}, 'Uses menu link marked active')
expect_match(uses, %r{href="/#about"}, 'About link points to home')
expect_match(uses, %r{href="/3d/"}, '3D link in the top bar')

# One card for each device in _data/uses.yml, under its section.
%w[Desk 3D\ Printing].each do |section|
  expect_match(uses, %r{<h2[^>]*>#{section}</h2>}, "#{section} section")
end
['MacBook Air M2', 'Magic Keyboard with Touch ID', 'Magic Trackpad', 'Dell S2721HS', 'Creality Ender 3 S1'].each do |name|
  expect_match(uses, %r{<h3 class="use-name">#{name}</h3>}, "#{name} card")
end
page = read_page(uses)
if page
  FAILURES << "#{uses}: expected 5 device cards" unless page.scan('class="use-card"').size == 5
  images = page.scan(%r{<img src="/assets/uses/[^"]+"}).size
  icons = page.scan('class="use-icon"').size
  FAILURES << "#{uses}: expected an icon on each card without an image" unless images + icons == 5
  # A photo credit needs a source link and a license link (CC BY and CC BY-SA ask for both).
  page.scan(%r{<p class="use-credit">.*?</p>}m).each do |credit|
    FAILURES << "#{uses}: credit without a source link: #{credit[0, 80]}" unless credit.match?(/Photo: <a href="https?:/)
    FAILURES << "#{uses}: credit without a license link: #{credit[0, 80]}" unless credit.match?(%r{href="https://creativecommons\.org/licenses/})
  end
end

# The other pages keep the sidebar layout.
expect_match('/', /class="sidebar"/, 'sidebar on home')
expect_match('/', %r{href="/uses/"}, 'Uses link on home')
expect_no_match('/', %r{class="active" href="/uses/"}, 'Uses link active on home')
expect_no_match('/assets/css/site.css', /\.nav \{ display: none; \}/, 'menu hidden on small screens')

# The github-pages gem adds the Primer theme, and Primer writes /assets/css/style.css.
# Our styles use another name, so a rebuild cannot replace them.
expect_match('/', %r{<link rel="stylesheet" href="/assets/css/site\.css">}, 'site stylesheet link')
