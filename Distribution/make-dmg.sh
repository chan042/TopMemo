#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="TopMemo"
BUILD_DIR="$ROOT_DIR/build"
APP_DIR="$BUILD_DIR/$APP_NAME.app"
STAGING_DIR="$BUILD_DIR/dmg-staging"
DMG_PATH="$BUILD_DIR/$APP_NAME.dmg"
APP_ICON_SOURCE="$ROOT_DIR/image/TopMemo_app_ic.png"
DMG_ICON_TEMP_PNG="$BUILD_DIR/TopMemoDmgIcon.png"
ICON_RSRC="$BUILD_DIR/TopMemoDmgIcon.rsrc"

zsh "$ROOT_DIR/Distribution/build-app.sh" >/dev/null

rm -rf "$STAGING_DIR" "$DMG_PATH"
mkdir -p "$STAGING_DIR"
ditto "$APP_DIR" "$STAGING_DIR/$APP_NAME.app"
ln -s /Applications "$STAGING_DIR/Applications"

hdiutil create \
    -volname "$APP_NAME" \
    -srcfolder "$STAGING_DIR" \
    -ov \
    -format UDZO \
    "$DMG_PATH" >/dev/null

if [[ -f "$APP_ICON_SOURCE" ]]; then
    xattr -c "$DMG_PATH" 2>/dev/null || true
    rm -f "$ICON_RSRC"
    cp "$APP_ICON_SOURCE" "$DMG_ICON_TEMP_PNG"
    xattr -c "$DMG_ICON_TEMP_PNG" 2>/dev/null || true
    sips -i "$DMG_ICON_TEMP_PNG" >/dev/null
    DeRez -only icns "$DMG_ICON_TEMP_PNG" > "$ICON_RSRC"
    Rez -append "$ICON_RSRC" -o "$DMG_PATH"
    SetFile -a C "$DMG_PATH"
fi

codesign --force --sign - "$DMG_PATH" >/dev/null 2>&1 || true

echo "$DMG_PATH"
