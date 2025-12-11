#!/bin/bash
# Setup script for adding macOS target support
# This script helps prepare the project structure for macOS

set -e

echo "======================================"
echo "SampleSwiftUI macOS Target Setup"
echo "======================================"
echo ""

# Check if running from project root
if [ ! -f "SampleSwiftUI.xcodeproj/project.pbxproj" ]; then
    echo "❌ Error: Please run this script from the project root directory"
    exit 1
fi

echo "✅ Project found"
echo ""

# Check for required files
echo "Checking for cross-platform code..."
REQUIRED_FILES=(
    "SampleSwiftUI/PlatformCompatibility.swift"
    "SampleSwiftUI/SampleSwiftUIApp.swift"
    "SampleSwiftUI/ContentView.swift"
    "SampleSwiftUI/SampleSwiftUI-macOS.entitlements"
)

ALL_FOUND=true
for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file"
    else
        echo "❌ Missing: $file"
        ALL_FOUND=false
    fi
done

echo ""

if [ "$ALL_FOUND" = false ]; then
    echo "⚠️  Some required files are missing"
    echo "Please ensure all cross-platform code is committed"
    exit 1
fi

# Check for Xcode
if ! command -v xcodebuild &> /dev/null; then
    echo "⚠️  Xcode command line tools not found"
    echo "Please install Xcode and run: xcode-select --install"
    exit 1
fi

echo "✅ Xcode found: $(xcodebuild -version | head -1)"
echo ""

# Check Xcode version
XCODE_VERSION=$(xcodebuild -version | head -1 | cut -d ' ' -f 2 | cut -d '.' -f 1)
if [ "$XCODE_VERSION" -lt 15 ]; then
    echo "⚠️  Warning: Xcode 15.2 or later is recommended"
    echo "Current version: $(xcodebuild -version | head -1)"
fi

echo ""
echo "======================================"
echo "Next Steps:"
echo "======================================"
echo ""
echo "1. Open SampleSwiftUI.xcodeproj in Xcode"
echo ""
echo "2. Add macOS Target:"
echo "   - Click project in navigator"
echo "   - Click '+' at bottom of targets list"
echo "   - Select 'macOS' → 'App'"
echo "   - Name it 'SampleSwiftUI-macOS'"
echo "   - Set deployment target to macOS 13.0"
echo ""
echo "3. Add source files to macOS target:"
echo "   Select each Swift file and check macOS target membership"
echo "   (EXCEPT WatchConnectivity.swift - iOS only)"
echo ""
echo "4. Add frameworks:"
echo "   ⚠️  IMPORTANT: You need macOS-compatible versions of:"
echo "   - siprix.xcframework (with macos-arm64 variant)"
echo "   - siprixMedia.xcframework (with macOS variant)"
echo "   Contact: sales@siprix-voip.com"
echo ""
echo "5. Configure entitlements:"
echo "   - Use SampleSwiftUI-macOS.entitlements for macOS target"
echo ""
echo "6. Build and test:"
echo "   - Select macOS target"
echo "   - Choose 'My Mac' destination"
echo "   - Build and run (⌘R)"
echo ""
echo "📖 See MACOS_SETUP.md for detailed instructions"
echo ""

