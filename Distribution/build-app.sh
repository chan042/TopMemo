#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_NAME="TopMemo"
BUILD_DIR="$ROOT_DIR/build"
APP_DIR="$BUILD_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
FRAMEWORKS_DIR="$CONTENTS_DIR/Frameworks"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
EXECUTABLE="$MACOS_DIR/$APP_NAME"
APP_ICON_SOURCE="$ROOT_DIR/image/TopMemo_app_ic.png"
STATUS_BAR_ICON_SOURCE="$ROOT_DIR/image/TopMemoic.png"
APP_ICON_NAME="TopMemoAppIcon"
APP_ICON_ICNS="$BUILD_DIR/$APP_ICON_NAME.icns"
APP_ICON_TEMP_PNG="$BUILD_DIR/$APP_ICON_NAME.png"
ARCH="$(uname -m)"
TARGET="$ARCH-apple-macos13.0"
MODULE_CACHE_DIR="$BUILD_DIR/ModuleCache"
SDK_MODULE_CACHE_DIR="$BUILD_DIR/SDKModuleCache"
SOURCE_FILES=("${(@f)$(find "$ROOT_DIR/TopMemo" -name '*.swift' | sort)}")

if [[ ${#SOURCE_FILES[@]} -eq 0 ]]; then
    echo "No Swift source files found." >&2
    exit 1
fi

generate_icns() {
    local source_png="$1"
    local temp_png="$2"
    local output_icns="$3"

    rm -f "$temp_png" "$output_icns"
    cp "$source_png" "$temp_png"
    xattr -c "$temp_png" 2>/dev/null || true
    sips -i "$temp_png" >/dev/null
    LC_ALL=C DeRez -only icns "$temp_png" \
        | perl -ne 'while(/\$"([^"]*)"/g){$s=$1; $s =~ s/[^0-9A-Fa-f]//g; print $s}' \
        | xxd -r -p > "$output_icns"
    xattr -c "$output_icns" 2>/dev/null || true
}

rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR" "$FRAMEWORKS_DIR" "$RESOURCES_DIR" "$MODULE_CACHE_DIR" "$SDK_MODULE_CACHE_DIR"
cp "$ROOT_DIR/Distribution/Info.plist" "$CONTENTS_DIR/Info.plist"
if [[ -f "$APP_ICON_SOURCE" ]]; then
    generate_icns "$APP_ICON_SOURCE" "$APP_ICON_TEMP_PNG" "$APP_ICON_ICNS"
    cp "$APP_ICON_ICNS" "$RESOURCES_DIR/$APP_ICON_NAME.icns"
    xattr -c "$RESOURCES_DIR/$APP_ICON_NAME.icns" 2>/dev/null || true
fi
if [[ -f "$STATUS_BAR_ICON_SOURCE" ]]; then
    cp "$STATUS_BAR_ICON_SOURCE" "$RESOURCES_DIR/TopMemoic.png"
    xattr -c "$RESOURCES_DIR/TopMemoic.png" 2>/dev/null || true
fi

xcrun swiftc \
    -target "$TARGET" \
    -parse-as-library \
    -module-cache-path "$MODULE_CACHE_DIR" \
    -sdk-module-cache-path "$SDK_MODULE_CACHE_DIR" \
    -O \
    -framework SwiftUI \
    -framework AppKit \
    -framework Combine \
    "${SOURCE_FILES[@]}" \
    -o "$EXECUTABLE"

xcrun swift-stdlib-tool \
    --copy \
    --platform macosx \
    --scan-executable "$EXECUTABLE" \
    --destination "$FRAMEWORKS_DIR"

codesign --force --deep --sign - "$APP_DIR" >/dev/null

echo "$APP_DIR"
