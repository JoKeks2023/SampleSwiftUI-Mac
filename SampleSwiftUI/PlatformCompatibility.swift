//
//  PlatformCompatibility.swift
//  SampleSwiftUI
//
//  Created by Copilot - Cross-Platform Compatibility Layer
//

import SwiftUI

#if os(iOS)
import UIKit
public typealias PlatformColor = UIColor
public typealias PlatformView = UIView
public typealias PlatformViewController = UIViewController
#elseif os(macOS)
import AppKit
public typealias PlatformColor = NSColor
public typealias PlatformView = NSView
public typealias PlatformViewController = NSViewController
#endif

///////////////////////////////////////////////////////////////////////////////////////////////////
/// Platform Detection
///

enum Platform {
    /// Returns true if running on iOS
    static var isIOS: Bool {
        #if os(iOS)
        return true
        #else
        return false
        #endif
    }
    
    /// Returns true if running on macOS
    static var isMacOS: Bool {
        #if os(macOS)
        return true
        #else
        return false
        #endif
    }
    
    /// Returns true if running on watchOS
    static var isWatchOS: Bool {
        #if os(watchOS)
        return true
        #else
        return false
        #endif
    }
    
    /// Returns true if running on tvOS
    static var isTVOS: Bool {
        #if os(tvOS)
        return true
        #else
        return false
        #endif
    }
    
    /// Human-readable platform name
    static var name: String {
        #if os(iOS)
        return "iOS"
        #elseif os(macOS)
        return "macOS"
        #elseif os(watchOS)
        return "watchOS"
        #elseif os(tvOS)
        return "tvOS"
        #else
        return "Unknown"
        #endif
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
/// Cross-Platform Color Extensions
///

extension Color {
    /// Background color that adapts to the platform
    static var platformBackground: Color {
        #if os(iOS)
        return Color(UIColor.systemGroupedBackground)
        #elseif os(macOS)
        return Color(NSColor.windowBackgroundColor)
        #else
        return Color.gray.opacity(0.1)
        #endif
    }
    
    /// Secondary background color that adapts to the platform
    static var platformSecondaryBackground: Color {
        #if os(iOS)
        return Color(UIColor.secondarySystemGroupedBackground)
        #elseif os(macOS)
        return Color(NSColor.controlBackgroundColor)
        #else
        return Color.gray.opacity(0.2)
        #endif
    }
    
    /// System fill color
    static var platformSystemFill: Color {
        #if os(iOS)
        return Color(UIColor.systemFill)
        #elseif os(macOS)
        return Color(NSColor.separatorColor)
        #else
        return Color.gray.opacity(0.3)
        #endif
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
/// Cross-Platform Haptic Feedback
///

struct HapticFeedback {
    /// Trigger success haptic feedback
    static func success() {
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
    }
    
    /// Trigger warning haptic feedback
    static func warning() {
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        #endif
    }
    
    /// Trigger error haptic feedback
    static func error() {
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
        #endif
    }
    
    /// Trigger light impact haptic feedback
    static func lightImpact() {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        #endif
    }
    
    /// Trigger medium impact haptic feedback
    static func mediumImpact() {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        #endif
    }
    
    /// Trigger heavy impact haptic feedback
    static func heavyImpact() {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        #endif
    }
    
    /// Trigger selection changed haptic feedback
    static func selectionChanged() {
        #if os(iOS)
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
        #endif
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
/// Cross-Platform View Modifiers
///

extension View {
    /// Apply platform-specific keyboard type
    /// - Parameter type: The keyboard type (only applies on iOS)
    func platformKeyboardType(_ type: UIKeyboardType) -> some View {
        #if os(iOS)
        return self.keyboardType(type)
        #else
        return self
        #endif
    }
    
    /// Apply platform-specific text content type
    /// - Parameter type: The content type (only applies on iOS)
    func platformTextContentType(_ type: UITextContentType?) -> some View {
        #if os(iOS)
        return self.textContentType(type)
        #else
        return self
        #endif
    }
    
    /// Hide keyboard on iOS
    func hideKeyboard() {
        #if os(iOS)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        #endif
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
/// Cross-Platform Notifications
///

class PlatformNotifications {
    /// Request notification permissions
    static func requestAuthorization(completion: @escaping (Bool) -> Void) {
        #if os(iOS)
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
        #elseif os(macOS)
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
        #else
        completion(false)
        #endif
    }
    
    /// Show local notification
    /// - Parameters:
    ///   - title: Notification title
    ///   - body: Notification body
    ///   - identifier: Unique identifier
    static func showNotification(title: String, body: String, identifier: String = UUID().uuidString) {
        #if os(iOS) || os(macOS)
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
        #endif
    }
    
    /// Update app badge count
    /// - Parameter count: Badge count (0 to clear)
    static func updateBadge(_ count: Int) {
        #if os(iOS)
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = count
        }
        #elseif os(macOS)
        DispatchQueue.main.async {
            if count > 0 {
                NSApp.dockTile.badgeLabel = "\(count)"
            } else {
                NSApp.dockTile.badgeLabel = nil
            }
        }
        #endif
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
/// Cross-Platform Window Management
///

class PlatformWindow {
    /// Make window key and visible
    static func makeKeyAndVisible() {
        #if os(iOS)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.makeKeyAndVisible()
        }
        #elseif os(macOS)
        NSApp.activate(ignoringOtherApps: true)
        NSApp.windows.first?.makeKeyAndOrderFront(nil)
        #endif
    }
    
    /// Get safe area insets
    static var safeAreaInsets: EdgeInsets {
        #if os(iOS)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            let insets = window.safeAreaInsets
            return EdgeInsets(top: insets.top, leading: insets.left, bottom: insets.bottom, trailing: insets.right)
        }
        return EdgeInsets()
        #else
        return EdgeInsets()
        #endif
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
/// Cross-Platform Application Lifecycle
///

class PlatformLifecycle {
    /// Open URL in default browser
    /// - Parameter url: URL to open
    static func openURL(_ url: URL) {
        #if os(iOS)
        UIApplication.shared.open(url)
        #elseif os(macOS)
        NSWorkspace.shared.open(url)
        #endif
    }
    
    /// Terminate the application
    static func terminate() {
        #if os(iOS)
        // Not recommended on iOS, but available for special cases
        exit(0)
        #elseif os(macOS)
        NSApp.terminate(nil)
        #endif
    }
    
    /// Open settings
    static func openSettings() {
        #if os(iOS)
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
        #elseif os(macOS)
        // Open System Preferences
        NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Applications/System Preferences.app"))
        #endif
    }
    
    /// Get app version
    static var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    /// Get app build number
    static var buildNumber: String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
/// Cross-Platform Pasteboard
///

class PlatformPasteboard {
    /// Copy text to clipboard
    /// - Parameter text: Text to copy
    static func copy(_ text: String) {
        #if os(iOS)
        UIPasteboard.general.string = text
        #elseif os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #endif
    }
    
    /// Get text from clipboard
    /// - Returns: Text from clipboard, or nil if none
    static func paste() -> String? {
        #if os(iOS)
        return UIPasteboard.general.string
        #elseif os(macOS)
        return NSPasteboard.general.string(forType: .string)
        #else
        return nil
        #endif
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
/// Cross-Platform File Management
///

class PlatformFiles {
    /// Get documents directory
    static var documentsDirectory: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    /// Get temporary directory
    static var temporaryDirectory: URL {
        return FileManager.default.temporaryDirectory
    }
    
    /// Open file picker
    /// - Parameter completion: Called with selected URL or nil if cancelled
    static func pickFile(completion: @escaping (URL?) -> Void) {
        #if os(iOS)
        // Would use UIDocumentPickerViewController
        completion(nil)
        #elseif os(macOS)
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        
        panel.begin { response in
            if response == .OK {
                completion(panel.url)
            } else {
                completion(nil)
            }
        }
        #else
        completion(nil)
        #endif
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
/// Debug Helper
///

func platformLog(_ message: String) {
    print("[\(Platform.name)] \(message)")
}
