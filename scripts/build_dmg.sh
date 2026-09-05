#!/bin/bash
set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"

echo "🔨 Building Clippy (Release)..."
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild \
  -project clippy.xcodeproj \
  -scheme clippy \
  -configuration Release \
  -derivedDataPath ./build \
  build

STAGING_DIR="/tmp/clippy_dmg_staging"
DMG_PATH="$PROJECT_DIR/Clippy.dmg"

echo "📦 Packaging Clippy.dmg..."
rm -rf "$STAGING_DIR"
mkdir -p "$STAGING_DIR"
cp -R "$PROJECT_DIR/build/Build/Products/Release/clippy.app" "$STAGING_DIR/Clippy.app"
ln -s /Applications "$STAGING_DIR/Applications"

rm -f "$DMG_PATH"
hdiutil create -volname "Clippy" -srcfolder "$STAGING_DIR" -ov -format UDZO "$DMG_PATH"
rm -rf "$STAGING_DIR"

echo "✅ Clippy.dmg successfully created at: $DMG_PATH"
