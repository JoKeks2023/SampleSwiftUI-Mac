# macOS App Creation Guide

This guide helps you create a macOS version of the SampleSwiftUI VoIP application.

## Overview

The codebase is designed to be cross-platform compatible between iOS and macOS. Most of the core functionality works on both platforms with minimal changes.

## Steps to Create macOS App

### 1. Add macOS Target in Xcode

1. Open `SampleSwiftUI.xcodeproj` in Xcode
2. Click on the project in the navigator
3. Click the "+" button at the bottom of the targets list
4. Select "macOS" → "App"
5. Name it "SampleSwiftUI-Mac"
6. Click "Finish"

### 2. Share Code Between iOS and macOS

The following files are already cross-platform compatible:

- ✅ `SiprixModels.swift` - Core data models
- ✅ `CallHistoryModel.swift` - Call history management
- ✅ `SettingsView.swift` - Settings UI (with conditional compilation)
- ✅ `HomeKitIntegration.swift` - HomeKit support (iOS and macOS)
- ✅ `HomeAssistantIntegration.swift` - Home Assistant webhooks (cross-platform)
- ✅ `IntegrationsSettingsView.swift` - Integration settings UI

Files requiring platform-specific modifications:

- ⚠️ `ContentView.swift` - UI needs macOS adaptations
- ⚠️ `CallHistoryView.swift` - UI needs macOS adaptations
- ⚠️ `SampleSwiftUIApp.swift` - Entry point needs macOS version
- ❌ `WatchConnectivity.swift` - iOS only (not applicable to macOS)

### 3. Platform-Specific Considerations

#### UI Differences

**iOS vs macOS:**

```swift
// Color
#if os(iOS)
Color(UIColor.systemGroupedBackground)
#elseif os(macOS)
Color(NSColor.windowBackgroundColor)
#endif

// Keyboard Type
#if os(iOS)
.keyboardType(.phonePad)
#endif

// Haptic Feedback
#if os(iOS)
let generator = UINotificationFeedbackGenerator()
generator.notificationOccurred(.success)
#endif
```

#### Window Management

macOS requires different window handling:

```swift
// In SampleSwiftUIApp.swift for macOS
#if os(macOS)
@main
struct SampleSwiftUIApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        
        Settings {
            SettingsView()
        }
    }
}
#endif
```

#### Menu Bar Integration (macOS)

Add a menu bar extra for quick access:

```swift
#if os(macOS)
.commands {
    CommandGroup(after: .appInfo) {
        Button("Check Registration Status") {
            // Action
        }
    }
    
    CommandGroup(replacing: .newItem) {
        Button("New Call...") {
            // Action
        }
        .keyboardShortcut("n", modifiers: .command)
    }
}
#endif
```

### 4. Required Changes for macOS

#### A. Update Info.plist for macOS

```xml
<key>LSMinimumSystemVersion</key>
<string>11.0</string>
<key>CFBundleIconFile</key>
<string>AppIcon</string>
```

#### B. Create macOS-specific Views

Create `ContentView+macOS.swift`:

```swift
#if os(macOS)
import SwiftUI

extension ContentView {
    var macOSLayout: some View {
        NavigationView {
            // Sidebar
            List {
                NavigationLink(destination: AccountsListView(accList)) {
                    Label("Accounts", systemImage: "person.crop.circle.fill")
                }
                
                NavigationLink(destination: CallsListView(callsList)) {
                    Label("Calls", systemImage: "phone.fill")
                        .badge(callsList.calls.count)
                }
                
                NavigationLink(destination: CallHistoryView()) {
                    Label("History", systemImage: "clock.fill")
                }
                
                NavigationLink(destination: SettingsView()) {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                
                NavigationLink(destination: IntegrationsSettingsView()) {
                    Label("Integrations", systemImage: "square.grid.2x2.fill")
                }
            }
            .listStyle(.sidebar)
            .frame(minWidth: 200)
            
            // Default content
            Text("Select an item from the sidebar")
                .font(.title)
                .foregroundColor(.secondary)
        }
    }
}
#endif
```

#### C. Platform Detection Helper

Add to your codebase:

```swift
enum Platform {
    static var isIOS: Bool {
        #if os(iOS)
        return true
        #else
        return false
        #endif
    }
    
    static var isMacOS: Bool {
        #if os(macOS)
        return true
        #else
        return false
        #endif
    }
    
    static var isWatchOS: Bool {
        #if os(watchOS)
        return true
        #else
        return false
        #endif
    }
}
```

### 5. Feature Compatibility Matrix

| Feature | iOS | macOS | Notes |
|---------|-----|-------|-------|
| SIP Calling | ✅ | ✅ | Full support |
| Video Calls | ✅ | ✅ | Requires camera permission |
| CallKit | ✅ | ❌ | iOS only |
| HomeKit | ✅ | ✅ | Both platforms supported |
| Home Assistant | ✅ | ✅ | Webhook-based, fully cross-platform |
| Apple Watch | ✅ | ❌ | Pairs with iOS only |
| Notifications | ✅ | ✅ | Different APIs on each platform |
| Touch/Haptics | ✅ | ❌ | iOS only |
| Menu Bar Extra | ❌ | ✅ | macOS only |
| Dock Badge | ❌ | ✅ | macOS only |

### 6. macOS-Specific Features to Add

#### Status Bar Menu (macOS)

```swift
#if os(macOS)
import SwiftUI

@main
struct SampleSwiftUIApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        
        MenuBarExtra("Siprix", systemImage: "phone.fill") {
            Button("Active Calls: \(callsList.calls.count)") {
                // Show calls window
            }
            
            Divider()
            
            Button("New Call...") {
                // Open new call dialog
            }
            
            Divider()
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
    }
}
#endif
```

#### Dock Badge for Active Calls

```swift
#if os(macOS)
func updateDockBadge(_ count: Int) {
    if count > 0 {
        NSApp.dockTile.badgeLabel = "\(count)"
    } else {
        NSApp.dockTile.badgeLabel = nil
    }
}
#endif
```

### 7. Testing Checklist

- [ ] Build succeeds on macOS target
- [ ] SIP registration works
- [ ] Can make and receive calls
- [ ] Audio routing works properly
- [ ] Video calls work (if camera available)
- [ ] Settings persist correctly
- [ ] Call history saves and loads
- [ ] HomeKit integration works (if enabled)
- [ ] Home Assistant webhooks work
- [ ] Window resizing works properly
- [ ] Keyboard shortcuts work
- [ ] Menu bar integration works

### 8. Distribution

#### macOS App Store

Requirements:
- App Sandbox enabled
- Hardened Runtime enabled
- Code signing with Developer ID
- Notarization by Apple

#### Direct Distribution

1. Archive the macOS app
2. Export as "Developer ID-signed application"
3. Notarize with Apple
4. Create DMG installer
5. Distribute via website

### 9. Known Limitations

1. **CallKit**: Not available on macOS - implement native macOS notifications instead
2. **Haptic Feedback**: Not available on macOS
3. **Watch Connectivity**: Not applicable to macOS
4. **Touch Gestures**: Use mouse/trackpad equivalents

### 10. Recommended Project Structure

```
SampleSwiftUI/
├── Shared/                 # Shared between iOS and macOS
│   ├── Models/
│   │   ├── SiprixModels.swift
│   │   ├── CallHistoryModel.swift
│   │   └── SettingsModel.swift
│   ├── Services/
│   │   ├── HomeKitIntegration.swift
│   │   ├── HomeAssistantIntegration.swift
│   │   └── SiprixService.swift
│   └── Views/
│       └── Shared UI components
├── iOS/                    # iOS-specific
│   ├── SampleSwiftUIApp.swift
│   ├── ContentView.swift
│   └── WatchConnectivity.swift
├── macOS/                  # macOS-specific
│   ├── SampleSwiftUIApp-macOS.swift
│   ├── ContentView-macOS.swift
│   └── MenuBarController.swift
└── watchOS/                # Watch app
    └── Watch App files
```

### 11. Quick Start Script

To quickly add macOS support:

1. Run this in Terminal from project root:

```bash
# Create macOS-specific directories
mkdir -p SampleSwiftUI-macOS
mkdir -p Shared

# Copy shared files
cp SampleSwiftUI/SiprixModels.swift Shared/
cp SampleSwiftUI/CallHistoryModel.swift Shared/
cp SampleSwiftUI/HomeKitIntegration.swift Shared/
cp SampleSwiftUI/HomeAssistantIntegration.swift Shared/

echo "Ready to add macOS target in Xcode"
```

2. Open Xcode and add macOS target
3. Add Shared files to both targets
4. Create platform-specific App files

### 12. Additional Resources

- [Apple's Documentation: Building a macOS App](https://developer.apple.com/documentation/swiftui/building-a-macos-app)
- [SwiftUI for Mac](https://developer.apple.com/tutorials/swiftui-concepts/swiftui-for-mac)
- [Distributing macOS Apps](https://developer.apple.com/documentation/xcode/distributing-your-app-for-beta-testing-and-releases)

## Support

For issues specific to macOS implementation, check:
- macOS deployment target (minimum 11.0)
- Signing & Capabilities
- App Sandbox permissions
- Network client entitlement for VoIP

## Next Steps

After creating the macOS app:
1. Test all core functionality
2. Add macOS-specific features (menu bar, dock badge)
3. Optimize UI for larger screens
4. Add keyboard shortcuts
5. Consider Touch Bar support
6. Implement proper window management
7. Add Spotlight integration
8. Implement Share extension for contacts
