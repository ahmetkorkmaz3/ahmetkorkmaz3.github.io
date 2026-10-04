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
