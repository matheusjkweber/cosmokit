#!/usr/bin/env bash

set -euo pipefail

ROOT="/Users/matheus/Desktop/Projetos/Appzinhos/cosmohq-project/CosmoKit"
PROMO_DIR="$ROOT/Promo"
TMP_DIR="$PROMO_DIR/.tiktok-build"
OUT_DIR="$PROMO_DIR/generated"

FONT_UI="/System/Library/Fonts/SFNS.ttf"
FONT_DISPLAY="/System/Library/Fonts/SFNSRounded.ttf"

VIDEO_A="$ROOT/cosmokit-privacy/demo.mp4"
VIDEO_B="$PROMO_DIR/Gravação de Tela 2026-01-25 às 13.56.34.mov"
VIDEO_C="$PROMO_DIR/Gravação de Tela 2026-01-25 às 14.06.45.mov"
SHOT_1="$ROOT/cosmokit-privacy/public/screenshots/macos-1.png"
SHOT_2="$ROOT/cosmokit-privacy/public/screenshots/macos-10.png"
PROMO_BG="$ROOT/Ads/promo.png"
ICON="$ROOT/brand/icons/icon-1024.png"

OUT_FILE="$OUT_DIR/cosmokit-tiktok-ad-1080x1920-en.mp4"

mkdir -p "$TMP_DIR" "$OUT_DIR"
rm -f "$TMP_DIR"/seg*.mp4 "$TMP_DIR"/card*.png "$TMP_DIR"/concat.txt "$OUT_FILE"

make_copy_card() {
  local badge="$1"
  local title="$2"
  local subtitle="$3"
  local output="$4"
  python3 - "$badge" "$title" "$subtitle" "$output" "$FONT_UI" "$FONT_DISPLAY" <<'PY'
from PIL import Image, ImageDraw, ImageFont
import sys

badge, title, subtitle, output, font_ui, font_display = sys.argv[1:7]
card = Image.new("RGBA", (980, 320), (0, 0, 0, 0))
draw = ImageDraw.Draw(card)

draw.rounded_rectangle((0, 0, 980, 320), radius=34, fill=(7, 9, 16, 222), outline=(104, 224, 255, 84), width=2)
draw.rounded_rectangle((42, 36, 274, 86), radius=18, fill=(33, 102, 255, 56))

badge_font = ImageFont.truetype(font_display, 24)
title_font = ImageFont.truetype(font_display, 56)
subtitle_font = ImageFont.truetype(font_ui, 30)

draw.text((66, 47), badge, font=badge_font, fill=(196, 235, 255, 255))
draw.text((44, 104), title, font=title_font, fill=(255, 255, 255, 255))
draw.text((46, 244), subtitle, font=subtitle_font, fill=(204, 218, 230, 255))

card.save(output)
PY
}

make_cta_card() {
  local output="$1"
  python3 - "$output" "$ICON" "$FONT_UI" "$FONT_DISPLAY" <<'PY'
from PIL import Image, ImageDraw, ImageFont
import sys

output, icon_path, font_ui, font_display = sys.argv[1:5]
card = Image.new("RGBA", (920, 980), (0, 0, 0, 0))
draw = ImageDraw.Draw(card)

draw.rounded_rectangle((0, 0, 920, 980), radius=42, fill=(7, 9, 16, 224), outline=(104, 224, 255, 90), width=2)

icon = Image.open(icon_path).convert("RGBA").resize((220, 220))
card.alpha_composite(icon, ((920 - 220) // 2, 104))

title_font = ImageFont.truetype(font_display, 78)
subtitle_font = ImageFont.truetype(font_display, 36)
body_font = ImageFont.truetype(font_ui, 28)
meta_font = ImageFont.truetype(font_display, 26)

def centered_text(y, text, font, fill):
    bbox = draw.textbbox((0, 0), text, font=font)
    x = (920 - (bbox[2] - bbox[0])) // 2
    draw.text((x, y), text, font=font, fill=fill)

centered_text(380, "COSMOKIT", title_font, (255, 255, 255, 255))
centered_text(500, "The Simulator cockpit for iOS devs", subtitle_font, (204, 228, 242, 255))
centered_text(584, "Deep links. Pushes. QA. Capture.", body_font, (191, 209, 223, 255))
centered_text(642, "Free tools now. Pro workflows when you need them.", body_font, (191, 209, 223, 255))
centered_text(794, "Mac App Store", meta_font, (104, 224, 255, 255))

card.save(output)
PY
}

render_video_segment() {
  local input="$1"
  local start="$2"
  local duration="$3"
  local card="$4"
  local output="$5"
  local fade_out
  fade_out=$(perl -e "printf '%.2f', ${duration} - 0.40")
  ffmpeg -y -ss "$start" -t "$duration" -i "$input" -loop 1 -t "$duration" -i "$card" -filter_complex "\
[0:v]fps=30,scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,gblur=sigma=26,eq=brightness=-0.22:saturation=0.92,format=yuv420p[bg]; \
[0:v]fps=30,scale=972:-2:force_original_aspect_ratio=decrease,format=rgba[fg]; \
[1:v]fps=30,format=rgba[card]; \
[bg][fg]overlay=x=(W-w)/2:y=448:format=auto[stack]; \
[stack]drawbox=x=52:y=430:w=976:h=1054:color=0xFFFFFF@0.12:t=2[framed]; \
[framed][card]overlay=x=50:y=84:format=auto,fade=t=in:st=0:d=0.28,fade=t=out:st=${fade_out}:d=0.40,format=yuv420p[v]" \
    -map "[v]" -an -r 30 -c:v libx264 -pix_fmt yuv420p -preset veryfast -crf 18 "$output"
}

render_image_segment() {
  local input="$1"
  local duration="$2"
  local card="$3"
  local output="$4"
  local fade_out
  fade_out=$(perl -e "printf '%.2f', ${duration} - 0.40")
  ffmpeg -y -loop 1 -t "$duration" -i "$input" -loop 1 -t "$duration" -i "$card" -filter_complex "\
[0:v]fps=30,scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,gblur=sigma=24,eq=brightness=-0.28:saturation=0.9,format=yuv420p[bg]; \
[0:v]fps=30,scale=980:-2:force_original_aspect_ratio=decrease,format=rgba[fg]; \
[1:v]fps=30,format=rgba[card]; \
[bg][fg]overlay=x=(W-w)/2:y=500:format=auto[stack]; \
[stack]drawbox=x=42:y=482:w=996:h=820:color=0xFFFFFF@0.12:t=2[framed]; \
[framed][card]overlay=x=50:y=84:format=auto,fade=t=in:st=0:d=0.28,fade=t=out:st=${fade_out}:d=0.40,format=yuv420p[v]" \
    -map "[v]" -an -r 30 -c:v libx264 -pix_fmt yuv420p -preset veryfast -crf 18 "$output"
}

render_cta_segment() {
  local duration="$1"
  local card="$2"
  local output="$3"
  local fade_out
  fade_out=$(perl -e "printf '%.2f', ${duration} - 0.55")
  ffmpeg -y -loop 1 -t "$duration" -i "$PROMO_BG" -loop 1 -t "$duration" -i "$card" -filter_complex "\
[0:v]fps=30,scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,gblur=sigma=30,eq=brightness=-0.34:saturation=0.78,format=yuv420p[bg]; \
[1:v]fps=30,format=rgba[card]; \
[bg][card]overlay=x=(W-w)/2:y=430:format=auto,fade=t=in:st=0:d=0.35,fade=t=out:st=${fade_out}:d=0.55,format=yuv420p[v]" \
    -map "[v]" -an -r 30 -c:v libx264 -pix_fmt yuv420p -preset veryfast -crf 18 "$output"
}

make_copy_card "IOS DEV TOOL" "Your Simulator needs a cockpit" "Stop juggling manual test setup" "$TMP_DIR/card01.png"
make_copy_card "TEST FASTER" "Pushes, deep links, mocked location" "Trigger hidden flows in seconds" "$TMP_DIR/card02.png"
make_copy_card "QA TOOLKIT" "Permissions, biometrics, app resets" "Repeat edge cases without setup pain" "$TMP_DIR/card03.png"
make_copy_card "CAPTURE" "Screenshots and video that ship" "QA proof, docs, and App Store assets" "$TMP_DIR/card04.png"
make_copy_card "PRO MODE" "Proxy, overrides, multi-simulator" "For heavier debugging sessions" "$TMP_DIR/card05.png"
make_cta_card "$TMP_DIR/card06.png"

render_video_segment "$VIDEO_A" "0.9" "2.8" "$TMP_DIR/card01.png" "$TMP_DIR/seg01.mp4"
render_video_segment "$VIDEO_B" "6.5" "3.0" "$TMP_DIR/card02.png" "$TMP_DIR/seg02.mp4"
render_video_segment "$VIDEO_C" "8.8" "3.0" "$TMP_DIR/card03.png" "$TMP_DIR/seg03.mp4"
render_image_segment "$SHOT_1" "3.0" "$TMP_DIR/card04.png" "$TMP_DIR/seg04.mp4"
render_image_segment "$SHOT_2" "3.0" "$TMP_DIR/card05.png" "$TMP_DIR/seg05.mp4"
render_cta_segment "3.8" "$TMP_DIR/card06.png" "$TMP_DIR/seg06.mp4"

printf "file '%s'\n" \
  "$TMP_DIR/seg01.mp4" \
  "$TMP_DIR/seg02.mp4" \
  "$TMP_DIR/seg03.mp4" \
  "$TMP_DIR/seg04.mp4" \
  "$TMP_DIR/seg05.mp4" \
  "$TMP_DIR/seg06.mp4" > "$TMP_DIR/concat.txt"

ffmpeg -y -f concat -safe 0 -i "$TMP_DIR/concat.txt" -c copy "$OUT_FILE"

echo "Rendered $OUT_FILE"
