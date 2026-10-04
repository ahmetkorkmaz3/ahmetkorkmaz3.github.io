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
