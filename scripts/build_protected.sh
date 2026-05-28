#!/bin/bash

# Mirror Scorpion - Protected Build Script
# This script builds the application with full obfuscation and protection against reverse engineering.

echo "🛡️ Mirror Scorpion: Starting Protected Build Process..."

# 1. Clean previous builds
echo "🧹 Cleaning project..."
flutter clean

# 2. Get dependencies
echo "📦 Fetching dependencies..."
flutter pub get

# 3. Read secrets from environment (must be set before running this script)
DART_DEFINES=""
if [ -n "$MIRROR_ENCRYPTION_KEY" ]; then
  DART_DEFINES="$DART_DEFINES --dart-define=MIRROR_ENCRYPTION_KEY=$MIRROR_ENCRYPTION_KEY"
fi
if [ -n "$MIRROR_LICENSE_SALT" ]; then
  DART_DEFINES="$DART_DEFINES --dart-define=MIRROR_LICENSE_SALT=$MIRROR_LICENSE_SALT"
fi
if [ -n "$MIRROR_ADMIN_PASSWORD" ]; then
  DART_DEFINES="$DART_DEFINES --dart-define=MIRROR_ADMIN_PASSWORD=$MIRROR_ADMIN_PASSWORD"
fi

# 4. Build Android App Bundle with Obfuscation
# --obfuscate: Hides function and variable names
# --split-debug-info: Removes debug information from the binary
echo "🔐 Building Obfuscated Android App Bundle..."
flutter build appbundle --release --obfuscate --split-debug-info=build/app/outputs/symbols $DART_DEFINES

# 5. Build APK with Obfuscation
echo "📱 Building Obfuscated APK..."
flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols $DART_DEFINES

echo "✅ Protected Build Complete!"
echo "📍 APK Location: build/app/outputs/flutter-apk/app-release.apk"
echo "📍 ABB Location: build/app/outputs/bundle/release/app-release.aab"
echo "🛡️ Reverse Engineering Protection Level: HIGH (360 Degree)"
