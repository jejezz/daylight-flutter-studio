#!/usr/bin/env bash
#
# README demo GIF without touching the mouse or keyboard (conventions/readme-guide.md §4). macOS only.
#
#   tool/readme/demo.sh
#
# Clicking through a flow needs someone at the keyboard. Instead a DEBUG build plays the flow by itself
# (lib/dev/demo_runner.dart) — edit a file, save, commit, record a verification — on a small sample project
# made here, while this script grabs the app window (not the screen, so nothing else can end up in it)
# a few times a second and turns the frames into a GIF. The build step is not really compiled; see the
# comment in demo_runner.dart.
#
# The app runs as a copy with its own bundle id, so your real Daylight Workbench and its settings are left alone.
# Needs Screen Recording permission for the terminal app, ffmpeg, Pillow, and Xcode. Close other
# "Daylight Workbench" windows first: the window is found by name.

set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
here="$root/tool/readme"
app_id="art.zoomon.daylightworkbench.demo"
work="$(mktemp -d)"
pid=""

cleanup() {
  [ -n "$pid" ] && kill "$pid" 2>/dev/null || true
  defaults delete "$app_id" >/dev/null 2>&1 || true
  rm -rf "${work:?}"
}
trap cleanup EXIT

cd "$root"
echo "building the debug app…"
flutter build macos --debug >/dev/null
name="$(grep '^PRODUCT_NAME' macos/Runner/Configs/AppInfo.xcconfig | head -1 | sed -E 's/^PRODUCT_NAME[[:space:]]*=[[:space:]]*//')"
cp -R "build/macos/Build/Products/Debug/$name.app" "$work/demo.app"
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $app_id" "$work/demo.app/Contents/Info.plist"
codesign --force --deep -s - "$work/demo.app" >/dev/null 2>&1

# Sample project: a fresh Flutter app on a feature branch, so the Git panel has something to show.
sample="$work/hello_notes"
(cd "$work" && flutter create --empty --platforms=macos hello_notes >/dev/null)
git -C "$sample" init -q -b main
git -C "$sample" add -A
git -C "$sample" -c user.name="Demo" -c user.email="demo@example.com" commit -qm "Initial commit"
git -C "$sample" checkout -q -b feat/note-count
git -C "$sample" config user.name "Demo"
git -C "$sample" config user.email "demo@example.com"

defaults write "$app_id" flutter.theme_mode -string light
defaults write "$app_id" flutter.app_locale -string en

mkdir -p "$work/signal" "$work/frames"
WORKBENCH_DEMO=1 WORKBENCH_DEMO_PROJECT="$sample" WORKBENCH_DEMO_FILE="$sample/lib/main.dart" \
  WORKBENCH_DEMO_SIGNAL="$work/signal" "$work/demo.app/Contents/MacOS/$name" >/dev/null 2>&1 &
pid=$!

for _ in $(seq 1 240); do
  [ -f "$work/signal/ready" ] && break
  sleep 0.25
done
[ -f "$work/signal/ready" ] || { echo "the demo never started" >&2; exit 1; }

read -r id _ <<<"$(swift "$here/find_window.swift" "$name")"
start=$(python3 -c 'import time;print(time.time())')
n=0
until [ -f "$work/signal/done" ] || [ "$n" -ge 80 ]; do
  n=$((n + 1))
  screencapture -x -o -l"$id" "$work/frames/f$(printf %03d $n).png"
  python3 -c "import time;print(f'{time.time()-$start:.3f}')" >> "$work/frames/t.txt"
done
sleep 0.5
echo "captured $n frames"

python3 - "$work/frames" <<'PY'
import glob, sys
d = sys.argv[1]
fs = sorted(glob.glob(d + '/f*.png'))
ts = [float(x) for x in open(d + '/t.txt').read().split()]
with open(d + '/list.txt', 'w') as o:
    for i, f in enumerate(fs):
        dur = (ts[i + 1] - ts[i]) if i + 1 < len(ts) else 0.8
        o.write(f"file '{f}'\nduration {dur:.3f}\n")
    o.write(f"file '{fs[-1]}'\n")
PY

mkdir -p docs/screenshots
# 760px like capture.sh gif; few colours and 6 fps keep it under 5 MB.
ffmpeg -loglevel error -y -f concat -safe 0 -i "$work/frames/list.txt" \
  -vf "fps=${GIF_FPS:-6},scale=${GIF_WIDTH:-760}:-1:flags=lanczos,split[a][b];[a]palettegen=max_colors=96:stats_mode=diff[p];[b][p]paletteuse=dither=bayer:bayer_scale=4:diff_mode=rectangle" \
  docs/screenshots/demo.gif
size=$(stat -f%z docs/screenshots/demo.gif)
echo "wrote docs/screenshots/demo.gif ($((size / 1024)) KB)"
[ "$size" -le 5000000 ] || echo "warning: over 5 MB — GIF_FPS=5 or GIF_WIDTH=680" >&2
