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
require 'yaml'
items = YAML.load_file(File.expand_path('../../_data/uses.yml', __dir__)).flat_map { |group| group['items'] }
items.each do |item|
  name = Regexp.escape(item['name'].gsub('"', '&quot;'))
  expect_match(uses, %r{<h3 class="use-name">#{name}</h3>}, "#{item['name']} card")
end
page = read_page(uses)
if page
  cards = page.scan('class="use-card"').size
  FAILURES << "#{uses}: expected #{items.size} device cards, found #{cards}" unless cards == items.size
  FAILURES << "#{uses}: expected an icon on each card" unless page.scan('class="use-icon"').size == items.size

  # The desk photo has one spot for each device with a spot field, and each spot points at a card.
  expect_match(uses, %r{<figure class="desk">\s*<img src="/img/uses/desk-2400\.jpg"}, 'desk photo')
  spots = page.scan(/class="desk-spot"[^>]*data-card="([^"]+)"/).flatten
  expected_spots = items.count { |item| item['spot'] }
  FAILURES << "#{uses}: expected #{expected_spots} desk spots, found #{spots.size}" unless spots.size == expected_spots
  card_ids = page.scan(/class="use-card" id="([^"]+)"/).flatten
  (spots - card_ids).each { |id| FAILURES << "#{uses}: desk spot without a card: #{id}" }
end
# A printed stand links to its 3D page in the same tab.
expect_match(uses, %r{<a class="use-inner" href="/3d/macbook-stand/">}, 'MacBook stand card links to its 3D page')
expect_match(uses, %r{<a class="use-inner" href="/3d/magsafe-charger-stand/">}, 'MagSafe stand card links to its 3D page')

# The other pages keep the sidebar layout.
expect_match('/', /class="sidebar"/, 'sidebar on home')
expect_match('/', %r{href="/uses/"}, 'Uses link on home')
expect_no_match('/', %r{class="active" href="/uses/"}, 'Uses link active on home')
expect_no_match('/assets/css/site.css', /\.nav \{ display: none; \}/, 'menu hidden on small screens')

# The github-pages gem adds the Primer theme, and Primer writes /assets/css/style.css.
# Our styles use another name, so a rebuild cannot replace them.
expect_match('/', %r{<link rel="stylesheet" href="/assets/css/site\.css">}, 'site stylesheet link')
