# Architecture Overview

## Cross-Platform Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     SampleSwiftUI App                        │
│                   (Cross-Platform Core)                      │
└─────────────────────────────────────────────────────────────┘
                              │
                    ┌─────────┴─────────┐
                    │                   │
          ┌─────────▼────────┐ ┌───────▼──────────┐
          │   iOS Target     │ │  macOS Target    │
          │                  │ │                  │
          │  • Tab Bar UI    │ │  • Sidebar UI    │
          │  • CallKit       │ │  • Menu Bar      │
          │  • Watch Sync    │ │  • Shortcuts     │
          │  • Haptics       │ │  • Dock Badge    │
          └──────────────────┘ └──────────────────┘

```

## Code Structure

```
SampleSwiftUI/
├── Core (Shared)
│   ├── SampleSwiftUIApp.swift         ← Platform-aware app entry
│   ├── SiprixModels.swift              ← Business logic
│   ├── CallHistoryModel.swift          ← Data models
│   └── PlatformCompatibility.swift     ← Abstraction layer
│
├── Views (Shared with adaptations)
│   ├── ContentView.swift               ← iOS: TabView, macOS: NavigationView
│   ├── SettingsView.swift              ← Cross-platform
│   ├── CallHistoryView.swift           ← Cross-platform
│   └── IntegrationsSettingsView.swift  ← Cross-platform
│
├── Integrations (Cross-platform)
│   └── HomeKitIntegration.swift        ← iOS & macOS
│
└── iOS-Only
    └── WatchConnectivity.swift         ← #if os(iOS)
```

## Platform Abstraction Layer

### Color System

```swift
// Before (iOS-only)
Color(UIColor.systemGroupedBackground)
Color(UIColor.secondarySystemGroupedBackground)

// After (Cross-platform)
Color.platformBackground          // → UIColor on iOS, NSColor on macOS
Color.platformSecondaryBackground // → Adapts to platform
```

### Haptic Feedback

```swift
// Before (iOS-only)
let generator = UINotificationFeedbackGenerator()
generator.notificationOccurred(.success)

// After (Cross-platform)
HapticFeedback.success()  // Works on iOS, silent on macOS
```

### Video Views

```swift
// iOS
struct SiprixVideoView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView { }
}

// macOS
struct SiprixVideoView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView { }
}
```

## Data Flow

```
┌──────────────┐
│     User     │
└──────┬───────┘
       │
       ▼
┌──────────────────────────────────────┐
│         ContentView                   │
│  iOS: TabView  │  macOS: Sidebar     │
└──────┬───────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────┐
│      View Models                      │
│  • AccountsListModel                  │
│  • CallsListModel                     │
│  • CallHistoryModel                   │
└──────┬───────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────┐
│      SiprixModel (Singleton)          │
│  • Initialize SDK                     │
│  • Manage state                       │
└──────┬───────────────────────────────┘
       │
       ▼
┌──────────────────────────────────────┐
│      Siprix SDK                       │
│  • SIP Protocol                       │
│  • Audio/Video                        │
└──────────────────────────────────────┘
```

## Integration Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     SampleSwiftUI App                        │
└─────┬───────────────────────────────────┬───────────────────┘
      │                                   │
      ▼                                   ▼
┌─────────────────┐             ┌─────────────────┐
│   HomeKit       │             │  Home Assistant │
│  Integration    │             │   Integration   │
│                 │             │                 │
│  • Switches     │             │  • Webhooks     │
│  • Sensors      │             │  • REST API     │
│  • Scenes       │             │  • Status Push  │
└─────────────────┘             └─────────────────┘
```

## Conditional Compilation Strategy

```swift
// Feature availability
#if os(iOS)
    // iOS-specific features
    - WatchConnectivity
    - CallKit integration
    - Haptic feedback
    - Touch gestures
#elseif os(macOS)
    // macOS-specific features
    - Menu bar commands
    - Keyboard shortcuts
    - Dock integration
    - Window management
#endif

// Shared features
// (No conditional needed)
- SIP calling
- HomeKit integration
- Home Assistant webhooks
- Settings management
- Call history
```

## Build Configuration

```
┌────────────────────────────────────┐
│   SampleSwiftUI.xcodeproj          │
└────────────────────────────────────┘
          │
    ┌─────┴─────┐
    │           │
    ▼           ▼
┌─────────┐ ┌─────────────┐
│   iOS   │ │   macOS     │
│ Target  │ │  Target     │
└─────────┘ └─────────────┘
    │           │
    │           │
    ▼           ▼
┌─────────┐ ┌─────────────────────┐
│ Siprix  │ │  Siprix             │
│Framework│ │ Framework (macOS)   │
│ (iOS)   │ │  ⚠️ Required        │
└─────────┘ └─────────────────────┘
```

## Threading Model

```
┌─────────────────────────────────────────┐
│           Main Thread                    │
│  • UI Updates                            │
│  • User Interactions                     │
│  • @Published property changes           │
└─────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────┐
│      Background Threads                  │
│  • Siprix SDK callbacks                  │
│  • Network operations                    │
│  • File I/O                              │
└─────────────────────────────────────────┘
```

## State Management

```
SwiftUI @StateObject / @ObservedObject
           │
           ▼
   ObservableObject Classes
           │
           ├─► AccountsListModel
           │   └─► @Published var accounts
           │
           ├─► CallsListModel
           │   └─► @Published var calls
           │
           ├─► SettingsModel
           │   └─► @Published var settings
           │
           └─► NetworkModel
               └─► @Published var lost
```

## Dependency Graph

```
SampleSwiftUIApp
    │
    ├─► ContentView
    │   ├─► AccountsListView
    │   ├─► CallsListView
    │   ├─► CallHistoryView
    │   ├─► SettingsView
    │   └─► IntegrationsSettingsView
    │
    ├─► SiprixModel (Singleton)
    │   ├─► AccountsListModel
    │   ├─► CallsListModel
    │   ├─► CallHistoryModel
    │   ├─► NetworkModel
    │   └─► LogsModel
    │
    ├─► SettingsModel (Singleton)
    │   └─► UserDefaults
    │
    ├─► HomeKitIntegration (Singleton)
    │   └─► HomeKit Framework
    │
    └─► WatchConnectivityManager (iOS only)
        └─► WatchConnectivity Framework
```

## Security Layers

```
┌─────────────────────────────────────────┐
│      Application Sandbox                 │
│  • Isolated environment                  │
│  • Limited file access                   │
└─────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────┐
│      Entitlements                        │
│  • Network access                        │
│  • Microphone/Camera                     │
│  • File permissions                      │
└─────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────┐
│      App Transport Security              │
│  • HTTPS enforcement                     │
│  • Certificate validation                │
└─────────────────────────────────────────┘
```

## Platform Features Matrix

| Layer              | iOS           | macOS         | Shared |
|--------------------|---------------|---------------|--------|
| **UI Framework**   | UIKit/SwiftUI | AppKit/SwiftUI| SwiftUI|
| **Navigation**     | TabView       | Sidebar       | -      |
| **Input**          | Touch         | Mouse/Keyboard| -      |
| **Feedback**       | Haptics       | -             | Visual |
| **Notifications**  | UNNotification| UNNotification| ✓      |
| **Storage**        | UserDefaults  | UserDefaults  | ✓      |
| **Network**        | URLSession    | URLSession    | ✓      |
| **Audio/Video**    | AVFoundation  | AVFoundation  | ✓      |

## Extension Points

The architecture is designed to be extensible:

1. **New Platforms**: Add `#if os(tvOS)` or `#if os(visionOS)`
2. **New Integrations**: Implement new integration classes
3. **New Features**: Add to shared core with platform adaptations
4. **Plugins**: Protocol-based plugin system possible

## Performance Considerations

- **Lazy Loading**: Views load on demand
- **Efficient Updates**: SwiftUI's diffing algorithm
- **Background Work**: Network and I/O off main thread
- **Memory**: Singletons for shared resources
- **Caching**: Call history and settings cached

## Testing Strategy

```
┌─────────────────────────────────────────┐
│         Unit Tests                       │
│  • Model logic                           │
│  • Platform abstraction                  │
│  • Data transformations                  │
└─────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────┐
│      Integration Tests                   │
│  • View model interactions               │
│  • SDK integration                       │
│  • State management                      │
└─────────────────────────────────────────┘
                    │
                    ▼
┌─────────────────────────────────────────┐
│         UI Tests                         │
│  • User flows                            │
│  • Navigation                            │
│  • Platform-specific UI                  │
└─────────────────────────────────────────┘
```

## Deployment Pipeline

```
Developer
    │
    ▼
Git Commit
    │
    ├─► iOS Build
    │   ├─► Test
    │   ├─► Archive
    │   └─► App Store
    │
    └─► macOS Build
        ├─► Test
        ├─► Archive
        └─► App Store / Direct
```

---

**Architecture Version**: 1.0
**Last Updated**: December 2024
**Platforms**: iOS 14.0+, macOS 13.0+
