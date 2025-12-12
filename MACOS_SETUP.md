# macOS App Setup Guide

This document provides step-by-step instructions for setting up the macOS version of the SampleSwiftUI VoIP application.

## Prerequisites

- macOS Ventura (13.0) or later
- Xcode 15.2 or later
- Siprix SDK with macOS support (contact sales@siprix-voip.com)

## Code Status

✅ **All Swift code has been converted to be cross-platform compatible:**

- All iOS-specific `UIColor` references replaced with `Color.platformBackground` and `Color.platformSecondaryBackground`
- All haptic feedback calls wrapped in `HapticFeedback` helper (iOS-only, graceful on macOS)
- iOS-only features (WatchConnectivity) wrapped in `#if os(iOS)` conditional compilation
- macOS-specific UI structure added with NavigationView sidebar layout
- Video views implemented for both iOS (`UIViewRepresentable`) and macOS (`NSViewRepresentable`)
- App structure supports both platforms with proper window management

## What You Need to Do in Xcode

### Step 1: Add macOS Target

1. Open `SampleSwiftUI.xcodeproj` in Xcode
2. Click on the project in the navigator
3. Click the "+" button at the bottom of the targets list
4. Select "macOS" → "App"
5. Name it "SampleSwiftUI-macOS"
6. Set the following:
   - Interface: SwiftUI
   - Language: Swift
   - Team: Your development team
   - Organization Identifier: Your identifier
7. Click "Finish"

### Step 2: Configure Build Settings

1. Select the macOS target
2. Go to "Build Settings"
3. Set:
   - **Deployment Target**: macOS 13.0
   - **Supported Platforms**: macOS
   - **Architectures**: Standard Architectures (Apple Silicon, Intel)

### Step 3: Add Source Files to macOS Target

Select each Swift file in the Project Navigator and check the macOS target membership:

**Core Files (Required for both iOS and macOS):**
- ✅ SampleSwiftUIApp.swift
- ✅ ContentView.swift
- ✅ SiprixModels.swift
- ✅ CallHistoryModel.swift
- ✅ CallHistoryView.swift
- ✅ SettingsView.swift
- ✅ IntegrationsSettingsView.swift
- ✅ PlatformCompatibility.swift
- ✅ HomeKitIntegration.swift

**iOS-Only Files (Do NOT add to macOS target):**
- ❌ WatchConnectivity.swift (already wrapped in `#if os(iOS)`)

**Resources:**
- ✅ Assets.xcassets
- ✅ office_ringtone.mp3
- ✅ noCamera.jpg
- ✅ isrg_root_x1.pem

### Step 4: Configure Frameworks

**Important:** The current siprix.xcframework only includes iOS binaries. You will need to:

1. Contact Siprix support (sales@siprix-voip.com) to obtain macOS versions of:
   - `siprix.xcframework` (with macos-arm64 and macos-x86_64 variants)
   - `siprixMedia.xcframework` (with macOS variants)

2. Once obtained, replace the frameworks in the project:
   - Remove the iOS-only frameworks from the project
   - Add the universal frameworks that include both iOS and macOS variants
   - Ensure both targets link to the frameworks

### Step 5: Configure Entitlements

Create `SampleSwiftUI-macOS.entitlements`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <true/>
    <key>com.apple.security.network.client</key>
    <true/>
    <key>com.apple.security.network.server</key>
    <true/>
    <key>com.apple.security.device.audio-input</key>
    <true/>
    <key>com.apple.security.device.camera</key>
    <true/>
    <key>com.apple.security.files.user-selected.read-write</key>
    <true/>
</dict>
</plist>
```

### Step 6: Configure Info.plist for macOS

Add/update the following keys in the macOS target's Info.plist:

```xml
<key>LSMinimumSystemVersion</key>
<string>13.0</string>

<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access for VoIP calls.</string>

<key>NSCameraUsageDescription</key>
<string>This app needs camera access for video calls.</string>

<key>CFBundleIconFile</key>
<string>AppIcon</string>
```

### Step 7: Build and Test

1. Select the macOS target and scheme
2. Choose "My Mac" as the destination
3. Build (⌘B) to check for compilation errors
4. Run (⌘R) to launch the app

## macOS-Specific Features

The app now includes:

### Native macOS UI
- Sidebar navigation (instead of tab bar)
- Native macOS window chrome
- Proper menu bar integration

### Menu Commands
- **File > New Call...** (⌘N)
- **Help > Check Registration Status** (⇧⌘R)
- **Settings** accessed via app menu

### Keyboard Shortcuts
- ⌘N - New Call
- ⇧⌘R - Check Registration Status
- ⌘, - Settings (standard macOS)

### Dock Integration
- Badge shows active call count
- Full app name in dock

## Feature Compatibility

| Feature | iOS | macOS | Notes |
|---------|-----|-------|-------|
| SIP Calling | ✅ | ✅ | Full support on both |
| Video Calls | ✅ | ✅ | Requires camera permission |
| Audio Routing | ✅ | ✅ | Different devices available |
| CallKit | ✅ | ❌ | iOS system integration only |
| HomeKit | ✅ | ✅ | Cross-platform support |
| Home Assistant | ✅ | ✅ | Webhook-based |
| Apple Watch | ✅ | ❌ | Pairs with iOS app only |
| Haptic Feedback | ✅ | ❌ | iOS feature, graceful no-op on macOS |
| Notifications | ✅ | ✅ | Platform-specific implementations |

## Troubleshooting

### "Framework not found siprix"
- Ensure you have the macOS-compatible siprix.xcframework
- Check that the framework is added to the macOS target's "Frameworks and Libraries"

### "Use of undeclared type 'UIColor'"
- This should not occur as all code has been converted
- If you see this, the file may not be using the platform compatibility layer

### "Cannot find 'WCSession' in scope"
- This is expected; WatchConnectivity is iOS-only
- The code is already wrapped in `#if os(iOS)` guards

### App crashes on launch
- Check Console.app for error messages
- Verify all entitlements are properly configured
- Ensure microphone and camera permissions are granted in System Settings

## Testing Checklist

- [ ] App launches successfully
- [ ] Can add SIP accounts
- [ ] Accounts register correctly
- [ ] Can make outgoing calls
- [ ] Can receive incoming calls
- [ ] Audio works in both directions
- [ ] Video calls work (if camera available)
- [ ] Settings persist across app restarts
- [ ] Call history is recorded and displayed
- [ ] Network connectivity changes are detected
- [ ] Menu commands work
- [ ] Keyboard shortcuts function
- [ ] Window can be resized properly
- [ ] App respects macOS system preferences
- [ ] HomeKit integration works (if enabled)
- [ ] Home Assistant webhooks work (if configured)

## Integration with iOS App

The codebase is now unified:

### Shared Code
All business logic, models, and most UI code is shared between iOS and macOS using conditional compilation where needed.

### Platform-Specific Code
- iOS: Tab bar UI, WatchConnectivity, CallKit
- macOS: Sidebar UI, Menu bar commands, Dock integration

### Data Compatibility
Both versions use the same data formats:
- UserDefaults keys are identical
- Call history format is compatible
- Settings are portable between platforms

## Next Steps

1. **Obtain macOS Frameworks**: Contact Siprix to get macOS-compatible SDK
2. **Add macOS Target**: Follow steps above in Xcode
3. **Test Thoroughly**: Use the testing checklist
4. **Optimize for macOS**: Consider adding:
   - Touch Bar support
   - Quick Look preview
   - Share extension
   - Spotlight integration
   - Services menu items

## Support

For Siprix SDK support:
- Email: sales@siprix-voip.com
- Website: https://siprix-voip.com
- Documentation: https://docs.siprix-voip.com

For code issues:
- Check existing GitHub issues
- Review MACOS_GUIDE.md for additional details
- Review INTEGRATIONS.md for integration-specific help

---

**Last Updated**: December 2024
**Compatible with**: macOS 13.0+, Xcode 15.2+
