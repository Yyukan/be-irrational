#!/bin/bash
#
# Archive, export and upload Be Irrational to App Store Connect.
#
# Needs an App Store Connect API key (.p8) and its Issuer ID:
#   App Store Connect > Users and Access > Integrations > App Store Connect API
#
# Usage:
#   ASC_KEY_PATH=<path to AuthKey_XXXXXXXXXX.p8> \
#   ASC_KEY_ID=<key id> \
#   ASC_ISSUER_ID=<issuer uuid> \
#   [BUILD_NUMBER=<n>] ./scripts/resubmit.sh [--upload]
#
# Without --upload the script stops after producing an .ipa, so it can be checked first. With
# --upload, xcodebuild exports straight to App Store Connect with the same key. Every run stamps a
# fresh build number (default: the current time, yyyyMMddHHmm), since App Store Connect refuses a
# second upload of the same version and build.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
KEY_PATH="${ASC_KEY_PATH:?set ASC_KEY_PATH to the AuthKey_*.p8 file}"
KEY_ID="${ASC_KEY_ID:?set ASC_KEY_ID (the id in the AuthKey file name)}"
ISSUER_ID="${ASC_ISSUER_ID:?set ASC_ISSUER_ID (issuer UUID from App Store Connect)}"
BUILD_NUMBER="${BUILD_NUMBER:-$(date +%Y%m%d%H%M)}"
BUILD_DIR="${BUILD_DIR:-$ROOT/build}"
ARCHIVE="$BUILD_DIR/BeIrrational.xcarchive"
EXPORT_DIR="$BUILD_DIR/export"
OPTIONS="$ROOT/scripts/ExportOptions.plist"

AUTH_FLAGS=(-allowProvisioningUpdates
            -authenticationKeyPath "$KEY_PATH"
            -authenticationKeyID "$KEY_ID"
            -authenticationKeyIssuerID "$ISSUER_ID")

mkdir -p "$BUILD_DIR"
rm -rf "$ARCHIVE" "$EXPORT_DIR"

echo "==> archiving build $BUILD_NUMBER"
xcodebuild -project "$ROOT/BeIrrational.xcodeproj" -scheme BeIrrational \
  -configuration Release -destination 'generic/platform=iOS' \
  -archivePath "$ARCHIVE" "${AUTH_FLAGS[@]}" \
  CURRENT_PROJECT_VERSION="$BUILD_NUMBER" archive

if [[ "${1:-}" == "--upload" ]]; then
  # Same options, but the export goes to App Store Connect instead of a local .ipa.
  UPLOAD_OPTIONS="$BUILD_DIR/ExportOptions-upload.plist"
  cp "$OPTIONS" "$UPLOAD_OPTIONS"
  /usr/libexec/PlistBuddy -c "Set :destination upload" "$UPLOAD_OPTIONS"
  OPTIONS="$UPLOAD_OPTIONS"
  echo "==> exporting and uploading"
else
  echo "==> exporting"
fi

xcodebuild -exportArchive -archivePath "$ARCHIVE" \
  -exportPath "$EXPORT_DIR" \
  -exportOptionsPlist "$OPTIONS" \
  "${AUTH_FLAGS[@]}"

if [[ "${1:-}" == "--upload" ]]; then
  echo "==> done, build $BUILD_NUMBER shows up in App Store Connect after processing"
else
  echo "==> ipa: $(find "$EXPORT_DIR" -name '*.ipa' | head -1)"
  echo "==> skipping upload (pass --upload to send it to App Store Connect)"
fi
