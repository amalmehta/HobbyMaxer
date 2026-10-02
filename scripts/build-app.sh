#!/bin/bash
# Builds "build/Hobby Maxer.app" from the Swift package.
set -euo pipefail
cd "$(dirname "$0")/.."

APP="build/Hobby Maxer.app"
swift build -c release
BIN="$(swift build -c release --show-bin-path)/HobbyMaxer"

rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp "$BIN" "$APP/Contents/MacOS/HobbyMaxer"

ICONSET="build/AppIcon.iconset"
rm -rf "$ICONSET"
swift scripts/make-icon.swift "$ICONSET"
iconutil -c icns "$ICONSET" -o "$APP/Contents/Resources/AppIcon.icns"
rm -rf "$ICONSET"

cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key><string>Hobby Maxer</string>
    <key>CFBundleDisplayName</key><string>Hobby Maxer</string>
    <key>CFBundleIdentifier</key><string>com.amalmehta.hobbymaxer</string>
    <key>CFBundleExecutable</key><string>HobbyMaxer</string>
    <key>CFBundleIconFile</key><string>AppIcon</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleShortVersionString</key><string>1.0</string>
    <key>CFBundleVersion</key><string>1</string>
    <key>LSMinimumSystemVersion</key><string>14.0</string>
    <key>LSApplicationCategoryType</key><string>public.app-category.lifestyle</string>
    <key>NSHighResolutionCapable</key><true/>
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleURLName</key><string>com.amalmehta.hobbymaxer.results</string>
            <key>CFBundleURLSchemes</key><array><string>hobbymaxer</string></array>
        </dict>
    </array>
</dict>
</plist>
PLIST

codesign --force --sign - "$APP"
# Register the hobbymaxer:// link scheme with this copy of the app.
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$APP" || true
echo "Built $APP"
