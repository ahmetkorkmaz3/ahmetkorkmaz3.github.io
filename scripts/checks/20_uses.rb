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
  FAILURES << "#{uses}: expected an icon on each card without an image" unless page.scan('class="use-icon"').size == 5
end

# The other pages keep the sidebar layout.
expect_match('/', /class="sidebar"/, 'sidebar on home')
expect_match('/', %r{href="/uses/"}, 'Uses link on home')
expect_no_match('/', %r{class="active" href="/uses/"}, 'Uses link active on home')
expect_no_match('/assets/css/style.css', /\.nav \{ display: none; \}/, 'menu hidden on small screens')
