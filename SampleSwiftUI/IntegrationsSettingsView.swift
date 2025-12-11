//
//  IntegrationsSettingsView.swift
//  SampleSwiftUI
//
//  Created by Copilot - Integrations Settings
//

import SwiftUI

/// Integrations Settings View
/// Compatible with both iOS and macOS
struct IntegrationsSettingsView: View {
    @StateObject private var homeKitIntegration = HomeKitIntegration.shared
    @StateObject private var homeAssistantIntegration = HomeAssistantIntegration.shared
    @StateObject private var watchConnectivity = WatchConnectivityManager.shared
    
    @State private var showHomeKitInfo = false
    @State private var showHomeAssistantInfo = false
    @State private var showWatchInfo = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.platformBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Apple Watch Section
                        SettingsSection(title: "Apple Watch", icon: "applewatch") {
                            VStack(spacing: 0) {
                                HStack {
                                    Image(systemName: "applewatch.watchface")
                                        .foregroundColor(.blue)
                                        .frame(width: 24)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Watch App Status")
                                            .font(.system(size: 16))
                                        Text(watchStatusText)
                                            .font(.system(size: 13))
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    if watchConnectivity.isWatchReachable {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                    } else if watchConnectivity.isWatchAppInstalled {
                                        Image(systemName: "exclamationmark.circle.fill")
                                            .foregroundColor(.orange)
                                    } else {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding()
                                
                                Divider()
                                    .padding(.leading, 60)
                                
                                Button(action: {
                                    watchConnectivity.syncAccounts()
                                    watchConnectivity.syncActiveCalls()
                                    watchConnectivity.syncCallHistory()
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.triangle.2.circlepath")
                                            .foregroundColor(.blue)
                                            .frame(width: 24)
                                        Text("Sync to Watch")
                                            .foregroundColor(.primary)
                                        Spacer()
                                    }
                                    .padding()
                                }
                                .disabled(!watchConnectivity.isWatchReachable)
                                
                                Divider()
                                    .padding(.leading, 60)
                                
                                Button(action: { showWatchInfo = true }) {
                                    HStack {
                                        Image(systemName: "info.circle")
                                            .foregroundColor(.blue)
                                            .frame(width: 24)
                                        Text("Setup Instructions")
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.secondary)
                                            .font(.system(size: 14))
                                    }
                                    .padding()
                                }
                            }
                            .background(Color.platformSecondaryBackground)
                            .cornerRadius(12)
                        }
                        
                        // HomeKit Section
                        SettingsSection(title: "HomeKit", icon: "house.fill") {
                            VStack(spacing: 0) {
                                Toggle(isOn: Binding(
                                    get: { homeKitIntegration.isEnabled },
                                    set: { enabled in
                                        if enabled {
                                            homeKitIntegration.enable()
                                        } else {
                                            homeKitIntegration.disable()
                                        }
                                    }
                                )) {
                                    HStack {
                                        Image(systemName: "house.circle.fill")
                                            .foregroundColor(.blue)
                                            .frame(width: 24)
                                        Text("Enable HomeKit")
                                    }
                                }
                                .padding()
                                
                                if homeKitIntegration.isEnabled {
                                    Divider()
                                        .padding(.leading, 60)
                                    
                                    HStack {
                                        Image(systemName: "house")
                                            .foregroundColor(.blue)
                                            .frame(width: 24)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Current Home")
                                                .font(.system(size: 16))
                                            Text(homeKitIntegration.currentHome?.name ?? "No home configured")
                                                .font(.system(size: 13))
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                    }
                                    .padding()
                                }
                                
                                Divider()
                                    .padding(.leading, 60)
                                
                                Button(action: { showHomeKitInfo = true }) {
                                    HStack {
                                        Image(systemName: "info.circle")
                                            .foregroundColor(.blue)
                                            .frame(width: 24)
                                        Text("How to Use")
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.secondary)
                                            .font(.system(size: 14))
                                    }
                                    .padding()
                                }
                            }
                            .background(Color.platformSecondaryBackground)
                            .cornerRadius(12)
                        }
                        
                        // Home Assistant Section
                        SettingsSection(title: "Home Assistant", icon: "server.rack") {
                            VStack(spacing: 0) {
                                Toggle(isOn: Binding(
                                    get: { homeAssistantIntegration.isEnabled },
                                    set: { enabled in
                                        if enabled {
                                            homeAssistantIntegration.enable()
                                        } else {
                                            homeAssistantIntegration.disable()
                                        }
                                    }
                                )) {
                                    HStack {
                                        Image(systemName: "server.rack")
                                            .foregroundColor(.blue)
                                            .frame(width: 24)
                                        Text("Enable Integration")
                                    }
                                }
                                .padding()
                                
                                if homeAssistantIntegration.isEnabled {
                                    Divider()
                                        .padding(.leading, 60)
                                    
                                    VStack(spacing: 12) {
                                        CustomTextField(
                                            icon: "link",
                                            placeholder: "Webhook URL",
                                            text: Binding(
                                                get: { homeAssistantIntegration.webhookURL },
                                                set: { homeAssistantIntegration.webhookURL = $0 }
                                            )
                                        )
                                        
                                        CustomTextField(
                                            icon: "key.fill",
                                            placeholder: "API Token (Optional)",
                                            text: Binding(
                                                get: { homeAssistantIntegration.apiToken },
                                                set: { homeAssistantIntegration.apiToken = $0 }
                                            )
                                        )
                                    }
                                    .padding()
                                }
                                
                                Divider()
                                    .padding(.leading, 60)
                                
                                Button(action: { showHomeAssistantInfo = true }) {
                                    HStack {
                                        Image(systemName: "info.circle")
                                            .foregroundColor(.blue)
                                            .frame(width: 24)
                                        Text("Setup Guide")
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.secondary)
                                            .font(.system(size: 14))
                                    }
                                    .padding()
                                }
                            }
                            .background(Color.platformSecondaryBackground)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Integrations")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showHomeKitInfo) {
                HomeKitInfoView()
            }
            .sheet(isPresented: $showHomeAssistantInfo) {
                HomeAssistantInfoView()
            }
            .sheet(isPresented: $showWatchInfo) {
                WatchInfoView()
            }
        }
    }
    
    private var watchStatusText: String {
        if watchConnectivity.isWatchReachable {
            return "Connected and reachable"
        } else if watchConnectivity.isWatchAppInstalled {
            return "Installed but not reachable"
        } else {
            return "Watch app not installed"
        }
    }
}

// MARK: - Info Views

struct HomeKitInfoView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    InfoSection(title: "What is HomeKit Integration?") {
                        Text("HomeKit integration allows you to trigger calls through Siri, automations, and scenes.")
                    }
                    
                    InfoSection(title: "How to Set Up") {
                        VStack(alignment: .leading, spacing: 12) {
                            StepView(number: 1, text: "Enable HomeKit integration in settings")
                            StepView(number: 2, text: "Open the Home app on your iPhone")
                            StepView(number: 3, text: "Create a new scene (e.g., 'Call Mom')")
                            StepView(number: 4, text: "Add actions to trigger calls")
                            StepView(number: 5, text: "Use Siri: 'Hey Siri, activate Call Mom'")
                        }
                    }
                    
                    InfoSection(title: "Use Cases") {
                        VStack(alignment: .leading, spacing: 8) {
                            BulletPoint(text: "Emergency calls triggered by a button")
                            BulletPoint(text: "Automated calls when you arrive home")
                            BulletPoint(text: "Quick dial with Siri voice commands")
                            BulletPoint(text: "Integration with other smart home devices")
                        }
                    }
                    
                    InfoSection(title: "Note") {
                        Text("HomeKit requires iOS 13.0 or later and proper network configuration.")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("HomeKit Guide")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct HomeAssistantInfoView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    InfoSection(title: "What is Home Assistant?") {
                        Text("Home Assistant is an open-source home automation platform. This integration allows you to trigger calls and receive call status updates.")
                    }
                    
                    InfoSection(title: "Setup Instructions") {
                        VStack(alignment: .leading, spacing: 12) {
                            StepView(number: 1, text: "Install Home Assistant")
                            StepView(number: 2, text: "Create a webhook automation")
                            StepView(number: 3, text: "Copy the webhook URL")
                            StepView(number: 4, text: "Paste the URL in this app's settings")
                            StepView(number: 5, text: "Optional: Add API token for authentication")
                        }
                    }
                    
                    InfoSection(title: "Example Automation") {
                        CodeBlockView(code: """
                        automation:
                          - alias: "Call when button pressed"
                            trigger:
                              platform: state
                              entity_id: input_button.emergency
                            action:
                              service: webhook
                              data:
                                url: "your-webhook-url"
                                method: POST
                                payload:
                                  phone_number: "911"
                                  account_id: 1
                        """)
                    }
                    
                    InfoSection(title: "Features") {
                        VStack(alignment: .leading, spacing: 8) {
                            BulletPoint(text: "Trigger calls from automations")
                            BulletPoint(text: "Receive call status updates")
                            BulletPoint(text: "Integration with sensors and buttons")
                            BulletPoint(text: "Custom dashboards showing call status")
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Home Assistant Guide")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct WatchInfoView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    InfoSection(title: "Apple Watch Companion App") {
                        Text("Control your SIP calls directly from your Apple Watch. View active calls, call history, and manage SIP accounts.")
                    }
                    
                    InfoSection(title: "Features") {
                        VStack(alignment: .leading, spacing: 8) {
                            BulletPoint(text: "View and control active calls")
                            BulletPoint(text: "Answer/reject incoming calls")
                            BulletPoint(text: "Hold, mute, and end calls")
                            BulletPoint(text: "Quick access to call history")
                            BulletPoint(text: "View SIP account status")
                            BulletPoint(text: "Watch face complications")
                        }
                    }
                    
                    InfoSection(title: "Setup") {
                        VStack(alignment: .leading, spacing: 12) {
                            StepView(number: 1, text: "Install the companion app on your Apple Watch")
                            StepView(number: 2, text: "Open the app on your watch")
                            StepView(number: 3, text: "Data will sync automatically when reachable")
                            StepView(number: 4, text: "Add complications to your watch face (optional)")
                        }
                    }
                    
                    InfoSection(title: "Note") {
                        Text("The Apple Watch app requires watchOS 7.0 or later. Some features may require the watch to be within Bluetooth or Wi-Fi range of your iPhone.")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    InfoSection(title: "To Add Watch Target") {
                        Text("This requires adding a watchOS target in Xcode:\n\n1. Open project in Xcode\n2. File > New > Target\n3. Select 'Watch App for iOS App'\n4. Follow the configuration wizard")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("Watch App Guide")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Helper Views

struct InfoSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            content
                .font(.system(size: 15))
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color.platformSecondaryBackground)
        .cornerRadius(12)
    }
}

struct StepView: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 24, height: 24)
                Text("\(number)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
            }
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.primary)
            Spacer()
        }
    }
}

struct BulletPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.blue)
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.primary)
        }
    }
}

struct CodeBlockView: View {
    let code: String
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            Text(code)
                .font(.system(size: 12, design: .monospaced))
                .padding()
                .background(Color.platformSystemFill)
                .cornerRadius(8)
        }
    }
}
