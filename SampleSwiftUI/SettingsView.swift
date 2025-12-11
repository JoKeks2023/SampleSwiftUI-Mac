//
//  SettingsView.swift
//  SampleSwiftUI
//
//  Created by Copilot
//

import SwiftUI
import siprix

struct SettingsView: View {
    @StateObject private var settingsModel = SettingsModel.shared
    @State private var showAbout = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Audio Settings
                        SettingsSection(title: "Audio Settings", icon: "speaker.wave.2.fill") {
                            VStack(spacing: 0) {
                                Toggle(isOn: $settingsModel.speakerByDefault) {
                                    HStack {
                                        Image(systemName: "speaker.fill")
                                            .foregroundColor(.blue)
                                            .frame(width: 24)
                                        Text("Speaker by Default")
                                    }
                                }
                                .padding()
                                .accessibilityLabel("Enable speaker by default for calls")
                                
                                Divider()
                                    .padding(.leading, 60)
                                
                                Toggle(isOn: $settingsModel.autoAnswer) {
                                    HStack {
                                        Image(systemName: "phone.fill.arrow.down.left")
                                            .foregroundColor(.green)
                                            .frame(width: 24)
                                        Text("Auto Answer")
                                    }
                                }
                                .padding()
                                .accessibilityLabel("Automatically answer incoming calls")
                            }
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                        }
                        
                        // Notification Settings
                        SettingsSection(title: "Notifications", icon: "bell.fill") {
                            VStack(spacing: 0) {
                                Toggle(isOn: $settingsModel.callNotifications) {
                                    HStack {
                                        Image(systemName: "phone.badge")
                                            .foregroundColor(.blue)
                                            .frame(width: 24)
                                        Text("Call Notifications")
                                    }
                                }
                                .padding()
                                .accessibilityLabel("Enable notifications for incoming calls")
                                
                                Divider()
                                    .padding(.leading, 60)
                                
                                Toggle(isOn: $settingsModel.messageNotifications) {
                                    HStack {
                                        Image(systemName: "message.badge")
                                            .foregroundColor(.blue)
                                            .frame(width: 24)
                                        Text("Message Notifications")
                                    }
                                }
                                .padding()
                                .accessibilityLabel("Enable notifications for messages")
                            }
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                        }
                        
                        // Display Settings
                        SettingsSection(title: "Display", icon: "eye.fill") {
                            VStack(spacing: 0) {
                                Toggle(isOn: $settingsModel.showCallDuration) {
                                    HStack {
                                        Image(systemName: "timer")
                                            .foregroundColor(.blue)
                                            .frame(width: 24)
                                        Text("Show Call Duration")
                                    }
                                }
                                .padding()
                                .accessibilityLabel("Display call duration during calls")
                            }
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                        }
                        
                        // About Section
                        SettingsSection(title: "About", icon: "info.circle.fill") {
                            VStack(spacing: 0) {
                                Button(action: { showAbout = true }) {
                                    HStack {
                                        Image(systemName: "info.circle")
                                            .foregroundColor(.blue)
                                            .frame(width: 24)
                                        Text("App Information")
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.secondary)
                                            .font(.system(size: 14))
                                    }
                                    .padding()
                                }
                                .accessibilityLabel("View app information")
                                
                                Divider()
                                    .padding(.leading, 60)
                                
                                HStack {
                                    Image(systemName: "gearshape.2")
                                        .foregroundColor(.blue)
                                        .frame(width: 24)
                                    Text("SDK Version")
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text(SiprixModel.shared.siprixModule_.version())
                                        .foregroundColor(.secondary)
                                        .font(.system(size: 14))
                                }
                                .padding()
                                .accessibilityLabel("Siprix SDK version \(SiprixModel.shared.siprixModule_.version())")
                            }
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showAbout) {
                AboutView()
            }
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .font(.system(size: 16))
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 20)
            
            content
        }
    }
}

struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // App Icon
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.blue.opacity(0.1)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "phone.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.blue)
                        }
                        .padding(.top, 40)
                        
                        VStack(spacing: 8) {
                            Text("Siprix VoIP Client")
                                .font(.system(size: 24, weight: .bold))
                            
                            Text("Version 1.0")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(spacing: 16) {
                            InfoRow(label: "SDK Version", value: SiprixModel.shared.siprixModule_.version())
                            InfoRow(label: "Platform", value: "iOS/macOS")
                            InfoRow(label: "License", value: "Trial Mode (60s limit)")
                        }
                        .padding(.horizontal, 20)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Features")
                                .font(.system(size: 18, weight: .semibold))
                                .padding(.horizontal, 20)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                FeatureItem(text: "Multiple SIP accounts")
                                FeatureItem(text: "Audio & Video calls")
                                FeatureItem(text: "Call hold & transfer")
                                FeatureItem(text: "DTMF support")
                                FeatureItem(text: "CallKit integration")
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        Text("For more information, visit siprix-voip.com")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.top, 20)
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .foregroundColor(.primary)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(10)
    }
}

struct FeatureItem: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.system(size: 16))
            Text(text)
                .font(.system(size: 15))
        }
    }
}

class SettingsModel: ObservableObject {
    static let shared = SettingsModel()
    
    @Published var speakerByDefault: Bool {
        didSet { UserDefaults.standard.set(speakerByDefault, forKey: "speakerByDefault") }
    }
    
    @Published var autoAnswer: Bool {
        didSet { UserDefaults.standard.set(autoAnswer, forKey: "autoAnswer") }
    }
    
    @Published var callNotifications: Bool {
        didSet { UserDefaults.standard.set(callNotifications, forKey: "callNotifications") }
    }
    
    @Published var messageNotifications: Bool {
        didSet { UserDefaults.standard.set(messageNotifications, forKey: "messageNotifications") }
    }
    
    @Published var showCallDuration: Bool {
        didSet { UserDefaults.standard.set(showCallDuration, forKey: "showCallDuration") }
    }
    
    private init() {
        self.speakerByDefault = UserDefaults.standard.bool(forKey: "speakerByDefault")
        self.autoAnswer = UserDefaults.standard.bool(forKey: "autoAnswer")
        self.callNotifications = UserDefaults.standard.bool(forKey: "callNotifications")
        self.messageNotifications = UserDefaults.standard.bool(forKey: "messageNotifications")
        self.showCallDuration = UserDefaults.standard.bool(forKey: "showCallDuration")
    }
}
