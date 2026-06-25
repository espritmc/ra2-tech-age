#!/bin/bash
# RA2 Tech Age — Build Script
# Builds macOS .app and Windows .exe
set -e

GODOT="/Applications/Godot.app/Contents/MacOS/Godot"
PROJECT_DIR="$(cd "$(dirname "$0")/src" && pwd)"
BUILD_DIR="$(cd "$(dirname "$0")" && pwd)/build"

echo "=== RA2 科技时代 — 构建 ==="
echo ""

# Check Godot
if [ ! -f "$GODOT" ]; then
    echo "✗ Godot 未找到: $GODOT"
    exit 1
fi

echo "Godot: $($GODOT --version)"
echo ""

mkdir -p "$BUILD_DIR/macos" "$BUILD_DIR/windows"

# macOS build
echo "--- 构建 macOS ---"
$GODOT --path "$PROJECT_DIR" --headless --export-release "macOS" "$BUILD_DIR/macos/RA2-Tech-Age.zip" 2>&1
if [ -f "$BUILD_DIR/macos/RA2-Tech-Age.zip" ]; then
    echo "✓ macOS 构建完成: $BUILD_DIR/macos/RA2-Tech-Age.zip"
    ls -lh "$BUILD_DIR/macos/RA2-Tech-Age.zip"
else
    echo "✗ macOS 构建失败"
fi

echo ""

# Windows build (requires export templates)
echo "--- 构建 Windows ---"
$GODOT --path "$PROJECT_DIR" --headless --export-release "Windows Desktop" "$BUILD_DIR/windows/RA2-Tech-Age.exe" 2>&1
if [ -f "$BUILD_DIR/windows/RA2-Tech-Age.exe" ]; then
    echo "✓ Windows 构建完成: $BUILD_DIR/windows/RA2-Tech-Age.exe"
    ls -lh "$BUILD_DIR/windows/RA2-Tech-Age.exe"
else
    echo "⚠ Windows 构建跳过（可能需要导出模板）"
fi

echo ""
echo "=== 构建完成 ==="
