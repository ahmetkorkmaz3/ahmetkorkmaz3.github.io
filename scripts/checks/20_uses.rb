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
