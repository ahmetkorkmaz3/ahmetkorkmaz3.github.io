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
