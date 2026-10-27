#!/bin/bash
#
# Takes the App Store screenshots from the debug build's sample data:
#   assets/screenshots/iphone-6.9/  (iPhone 17 Pro Max, 1320 x 2868)
#   assets/screenshots/ipad-13/     (iPad Pro 13-inch, 2064 x 2752)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DD="$ROOT/build/dd-shots"
BUNDLE=net.shtykhno.BeIrrational

shoot() { # device-name folder
  local name="$1" out="$ROOT/assets/screenshots/$2"
  local id
  id="$(xcrun simctl list devices available | grep -F "$name (" | head -1 | sed -E 's/.*\(([0-9A-F-]{36})\).*/\1/')"
  xcrun simctl boot "$id" 2>/dev/null || true
  xcodebuild -project "$ROOT/BeIrrational.xcodeproj" -scheme BeIrrational -configuration Debug \
    -destination "id=$id" -derivedDataPath "$DD" build >/dev/null
  xcrun simctl install "$id" "$DD/Build/Products/Debug-iphonesimulator/BeIrrational.app"
  xcrun simctl status_bar "$id" override --time 9:41 --batteryState charged --batteryLevel 100 \
    --wifiBars 3 --cellularMode active --cellularBars 4
  mkdir -p "$out"
  local n=0
  while read -r file args; do
    n=$((n + 1))
    xcrun simctl terminate "$id" "$BUNDLE" 2>/dev/null || true
    # shellcheck disable=SC2086
    xcrun simctl launch "$id" "$BUNDLE" -sampleData $args >/dev/null
    sleep 4
    xcrun simctl io "$id" screenshot "$out/$file.png" >/dev/null 2>&1
  done <<'SHOTS'
01-now -tab now
02-now-i-would -open scope
03-occupation -open occupation
04-someday -tab someday
05-suggestions -open suggestions
SHOTS
  xcrun simctl status_bar "$id" clear
}

shoot "iPhone 17 Pro Max" iphone-6.9
shoot "iPad Pro 13-inch (M5)" ipad-13
