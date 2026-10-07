#!/usr/bin/env bash
# Gives 3D photos the site style: background removed, 4:3, model in the center, soft shadow.
#
#   scripts/prepare_photos.sh [--keep-background] OUT_DIR PHOTO...
#
# Writes OUT_DIR/1.webp, 2.webp, ... in the order of the photos (transparent, 1600x1200).
# The page gives the background color, so the photos fit the light and the dark theme.
# Also writes OUT_DIR/og.jpg from the first photo on a flat background, for link previews.
# With --keep-background the photos keep their background and their aspect ratio
# (long side 1600 px), and og.jpg is the center of the first photo.
# Needs macOS 14 or later (Apple Vision) and ImageMagick 7.
set -euo pipefail
cd "$(dirname "$0")/.."

keep_background=false
if [ "${1:-}" = --keep-background ]; then
  keep_background=true
  shift
fi
if [ $# -lt 2 ]; then
  echo "usage: scripts/prepare_photos.sh [--keep-background] OUT_DIR PHOTO..." >&2
  exit 1
fi
out=$1
shift
mkdir -p "$out"

# The metadata (GPS, camera) goes away with -strip.
if $keep_background; then
  i=1
  for photo in "$@"; do
    magick "$photo" -auto-orient -resize "1600x1600>" -strip -quality 82 "$out/$i.webp"
    echo "$photo -> $out/$i.webp"
    i=$((i + 1))
  done
  magick "$out/1.webp" -resize 1200x900^ -gravity center -extent 1200x900 -strip -quality 82 "$out/og.jpg"
  echo "$out/og.jpg"
  exit 0
fi

# Light theme --surface in assets/css/site.css
og_background='#f6f7f9'

tool_dir=${TMPDIR:-/tmp}/prepare-photos
mkdir -p "$tool_dir"
cutout=$tool_dir/cutout-$(shasum scripts/cutout.swift | cut -c1-12)
[ -x "$cutout" ] || swiftc -O scripts/cutout.swift -o "$cutout"

i=1
for photo in "$@"; do
  cut=$tool_dir/cut.png
  "$cutout" "$photo" "$cut"
  # The model fits in 1440x1000, so each side keeps a margin of at least 80 px.
  magick "$cut" -resize 1440x1000 -bordercolor none -border 60 \
    \( +clone -background black -shadow 30x22+0+26 \) +swap -background none -layers merge +repage \
    -resize "1600x1200>" -gravity center -background none -extent 1600x1200 \
    -strip -define webp:alpha-quality=90 -quality 85 "$out/$i.webp"
  echo "$photo -> $out/$i.webp"
  i=$((i + 1))
done

magick "$out/1.webp" -background "$og_background" -flatten -resize 1200x900 -strip -quality 82 "$out/og.jpg"
echo "$out/og.jpg"
