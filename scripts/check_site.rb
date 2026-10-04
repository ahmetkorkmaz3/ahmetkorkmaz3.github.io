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
