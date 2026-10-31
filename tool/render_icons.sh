#!/bin/sh
# Renders the app icons in assets/icons/ from the SVG sources with headless
# Chrome (at 512px, its window can't be smaller) and macOS sips for the
# smaller sizes. Run from the repository root after changing an icon:
#   sh tool/render_icons.sh
set -e
chrome="${CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
out=assets/icons

render() { # <svg> <png> <background as RRGGBBAA>
  "$chrome" --headless=new --disable-gpu --hide-scrollbars \
    --default-background-color="$3" --window-size=512,512 \
    --screenshot="$PWD/$2" "file://$PWD/$1" 2>/dev/null
}

render assets/favicon.svg $out/icon-512.png 00000000
sips -Z 192 $out/icon-512.png --out $out/icon-192.png >/dev/null
render tool/icon-maskable.svg $out/icon-maskable-512.png ffffffff
# iOS rounds the corners itself and doesn't allow transparency, so the
# rounded white tile goes on a white square.
render assets/favicon.svg $out/apple-touch-icon.png ffffffff
sips -Z 180 $out/apple-touch-icon.png >/dev/null
