#!/usr/bin/env bash
# Builds the site into _site/ and checks the output.
set -euo pipefail
cd "$(dirname "$0")/.."
if [ -d /opt/homebrew/opt/ruby@3.3/bin ]; then
  export PATH="/opt/homebrew/opt/ruby@3.3/bin:$PATH"
fi
bundle exec jekyll build --strict_front_matter
bundle exec ruby scripts/check_site.rb
