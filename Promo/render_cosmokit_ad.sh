#!/usr/bin/env bash

set -euo pipefail

ROOT="/Users/matheus/Desktop/Projetos/Appzinhos/cosmohq-project/CosmoKit"
PROMO_DIR="$ROOT/Promo"
TMP_DIR="$PROMO_DIR/.ad-build"
OUT_DIR="$PROMO_DIR/generated"

FONT_UI="/System/Library/Fonts/SFNS.ttf"
FONT_DISPLAY="/System/Library/Fonts/SFNSRounded.ttf"

VIDEO_A="$ROOT/cosmokit-privacy/demo.mp4"
VIDEO_B="$PROMO_DIR/Gravação de Tela 2026-01-25 às 13.56.34.mov"
VIDEO_C="$PROMO_DIR/Gravação de Tela 2026-01-25 às 14.06.45.mov"
SHOT_1="$ROOT/cosmokit-privacy/public/screenshots/macos-1.png"
SHOT_2="$ROOT/cosmokit-privacy/public/screenshots/macos-10.png"
SHOT_3="$ROOT/cosmokit-privacy/public/screenshots/macos-14.png"
PROMO_BG="$ROOT/Ads/promo.png"
ICON="$ROOT/brand/icons/icon-1024.png"

OUT_FILE="$OUT_DIR/cosmokit-ad-1080x1350-en.mp4"

mkdir -p "$TMP_DIR" "$OUT_DIR"
rm -f "$TMP_DIR"/seg*.mp4 "$TMP_DIR"/concat.txt "$OUT_FILE"

make_copy_card() {
  local badge="$1"
  local title="$2"
  local subtitle="$3"
  local output="$4"
  python3 - "$badge" "$title" "$subtitle" "$output" "$FONT_UI" "$FONT_DISPLAY" <<'PY'
from PIL import Image, ImageDraw, ImageFont
import sys

badge, title, subtitle, output, font_ui, font_display = sys.argv[1:7]
card = Image.new("RGBA", (996, 182), (0, 0, 0, 0))
draw = ImageDraw.Draw(card)
draw.rounded_rectangle((0, 0, 996, 182), radius=28, fill=(8, 5, 14, 210), outline=(124, 58, 237, 80), width=2)
draw.rounded_rectangle((48, 48, 260, 88), radius=18, fill=(124, 58, 237, 42))
badge_font = ImageFont.truetype(font_display, 24)
title_font = ImageFont.truetype(font_display, 58)
subtitle_font = ImageFont.truetype(font_ui, 28)
draw.text((70, 54), badge, font=badge_font, fill=(216, 200, 255, 255))
draw.text((48, 92), title, font=title_font, fill=(255, 255, 255, 255))
draw.text((50, 150), subtitle, font=subtitle_font, fill=(210, 204, 223, 255))
card.save(output)
PY
}

make_cta_card() {
  local output="$1"
  python3 - "$output" "$ICON" "$FONT_UI" "$FONT_DISPLAY" <<'PY'
from PIL import Image, ImageDraw, ImageFont
import sys

output, icon_path, font_ui, font_display = sys.argv[1:5]
card = Image.new("RGBA", (912, 760), (0, 0, 0, 0))
draw = ImageDraw.Draw(card)
draw.rounded_rectangle((0, 0, 912, 760), radius=32, fill=(8, 5, 14, 214), outline=(124, 58, 237, 80), width=2)

icon = Image.open(icon_path).convert("RGBA").resize((186, 186))
card.alpha_composite(icon, ((912 - 186) // 2, 88))

title_font = ImageFont.truetype(font_display, 66)
subtitle_font = ImageFont.truetype(font_ui, 34)
body_font = ImageFont.truetype(font_ui, 26)
meta_font = ImageFont.truetype(font_display, 24)

def centered_text(y, text, font, fill):
    bbox = draw.textbbox((0, 0), text, font=font)
    x = (912 - (bbox[2] - bbox[0])) // 2
    draw.text((x, y), text, font=font, fill=fill)

centered_text(330, "COSMOKIT", title_font, (255, 255, 255, 255))
centered_text(428, "The control center for iOS Simulator", subtitle_font, (216, 210, 229, 255))
centered_text(496, "Free on Mac App Store and upgrade to Pro when you need more", body_font, (190, 183, 203, 255))
centered_text(642, "Pushes   Deep Links   Capture   Proxy", meta_font, (216, 200, 255, 255))

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
  fade_out=$(perl -e "printf '%.2f', ${duration} - 0.45")
  ffmpeg -y -ss "$start" -t "$duration" -i "$input" -loop 1 -t "$duration" -i "$card" -filter_complex "\
[0:v]fps=30,scale=1080:1350:force_original_aspect_ratio=increase,crop=1080:1350,gblur=sigma=30,eq=brightness=-0.26:saturation=0.8,format=yuv420p[bg]; \
[0:v]fps=30,scale=920:-2:force_original_aspect_ratio=decrease,format=rgba[fg]; \
[1:v]fps=30,format=rgba[card]; \
[bg][fg]overlay=x=(W-w)/2:y=286:format=auto[tmp]; \
[tmp]drawbox=x=68:y=268:w=944:h=1010:color=0xFFFFFF@0.12:t=2[framed]; \
[framed][card]overlay=x=42:y=42,fade=t=in:st=0:d=0.35,fade=t=out:st=${fade_out}:d=0.45[v]" \
    -map "[v]" -an -r 30 -c:v libx264 -preset veryfast -crf 18 "$output"
}

render_image_segment() {
  local input="$1"
  local duration="$2"
  local card="$3"
  local output="$4"
  local fade_out
  fade_out=$(perl -e "printf '%.2f', ${duration} - 0.45")
  ffmpeg -y -loop 1 -t "$duration" -i "$input" -loop 1 -t "$duration" -i "$card" -filter_complex "\
[0:v]fps=30,scale=1080:1350:force_original_aspect_ratio=increase,crop=1080:1350,gblur=sigma=26,eq=brightness=-0.3:saturation=0.85,format=yuv420p[bg]; \
[0:v]fps=30,scale=940:-2:force_original_aspect_ratio=decrease,format=rgba[fg]; \
[1:v]fps=30,format=rgba[card]; \
[bg][fg]overlay=x=(W-w)/2:y=300:format=auto[tmp]; \
[tmp]drawbox=x=58:y=282:w=964:h=760:color=0xFFFFFF@0.12:t=2[framed]; \
[framed][card]overlay=x=42:y=42,fade=t=in:st=0:d=0.35,fade=t=out:st=${fade_out}:d=0.45[v]" \
    -map "[v]" -an -r 30 -c:v libx264 -preset veryfast -crf 18 "$output"
}

render_cta_segment() {
  local duration="$1"
  local card="$2"
  local output="$3"
  local fade_out
  fade_out=$(perl -e "printf '%.2f', ${duration} - 0.55")
  ffmpeg -y -loop 1 -t "$duration" -i "$PROMO_BG" -loop 1 -t "$duration" -i "$card" -filter_complex "\
[0:v]fps=30,scale=1080:1350:force_original_aspect_ratio=increase,crop=1080:1350,gblur=sigma=34,eq=brightness=-0.4:saturation=0.75,format=yuv420p[bg]; \
[1:v]fps=30,format=rgba[card]; \
[bg][card]overlay=x=(W-w)/2:y=200,fade=t=in:st=0:d=0.45,fade=t=out:st=${fade_out}:d=0.55[v]" \
    -map "[v]" -an -r 30 -c:v libx264 -preset veryfast -crf 18 "$output"
}

make_copy_card "FOR IOS DEVELOPERS" "Control every simulator task" "Without living in xcrun simctl" "$TMP_DIR/card01.png"
make_copy_card "TEST FASTER" "Pushes Deep Links and mocked location" "Validate hidden flows in seconds" "$TMP_DIR/card02.png"
make_copy_card "QA TOOLKIT" "Permissions biometrics and app resets" "Everything you repeat centralized" "$TMP_DIR/card03.png"
make_copy_card "CAPTURE" "Screenshots and video for QA and App Store" "Documentation marketing and reviews" "$TMP_DIR/card04.png"
make_copy_card "PRO WORKFLOWS" "Proxy response overrides and multiple simulators" "Built for heavier debugging sessions" "$TMP_DIR/card05.png"
make_cta_card "$TMP_DIR/card06.png"

render_video_segment "$VIDEO_A" "1.2" "5" "$TMP_DIR/card01.png" "$TMP_DIR/seg01.mp4"
render_video_segment "$VIDEO_B" "7.0" "5" "$TMP_DIR/card02.png" "$TMP_DIR/seg02.mp4"
render_video_segment "$VIDEO_C" "9.0" "5" "$TMP_DIR/card03.png" "$TMP_DIR/seg03.mp4"
render_image_segment "$SHOT_1" "4" "$TMP_DIR/card04.png" "$TMP_DIR/seg04.mp4"
render_image_segment "$SHOT_2" "4" "$TMP_DIR/card05.png" "$TMP_DIR/seg05.mp4"
render_cta_segment "6" "$TMP_DIR/card06.png" "$TMP_DIR/seg06.mp4"

printf "file '%s'\n" \
  "$TMP_DIR/seg01.mp4" \
  "$TMP_DIR/seg02.mp4" \
  "$TMP_DIR/seg03.mp4" \
  "$TMP_DIR/seg04.mp4" \
  "$TMP_DIR/seg05.mp4" \
  "$TMP_DIR/seg06.mp4" > "$TMP_DIR/concat.txt"

ffmpeg -y -f concat -safe 0 -i "$TMP_DIR/concat.txt" -c copy "$OUT_FILE"

echo "Rendered $OUT_FILE"
