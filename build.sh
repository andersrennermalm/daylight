#!/bin/bash

# Build script for Daylight.app
# Creates a proper macOS app bundle

set -e

APP_NAME="Daylight"
BUILD_DIR=".build/release"
APP_BUNDLE="${APP_NAME}.app"
CONTENTS_DIR="${APP_BUNDLE}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"

echo "Building ${APP_NAME}..."

# Build release version
swift build -c release

echo "Creating app bundle..."

# Clean previous bundle
rm -rf "${APP_BUNDLE}"

# Create directory structure
mkdir -p "${MACOS_DIR}"
mkdir -p "${RESOURCES_DIR}"

# Copy executable
cp "${BUILD_DIR}/${APP_NAME}" "${MACOS_DIR}/"

# Copy Info.plist
cp "Daylight/Info.plist" "${CONTENTS_DIR}/"

# Create PkgInfo
echo -n "APPL????" > "${CONTENTS_DIR}/PkgInfo"

# Sign the app (ad-hoc signing for local use)
codesign --force --deep --sign - "${APP_BUNDLE}"

echo ""
echo "Build complete: ${APP_BUNDLE}"
echo ""
echo "To install:"
echo "  cp -r ${APP_BUNDLE} /Applications/"
echo ""
echo "To run:"
echo "  open ${APP_BUNDLE}"
echo ""
