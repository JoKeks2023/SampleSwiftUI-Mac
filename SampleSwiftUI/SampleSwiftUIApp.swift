//
//  SampleSwiftUIApp.swift
//  SampleSwiftUI
//
//  Created by Siprix Team.
//

import SwiftUI
import Intents


@main
struct SampleSwiftUIApp: App {
    
    init() {
        SiprixModel.shared.initialize()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        .commands {
            CommandGroup(after: .appInfo) {
                Button("Check Registration Status") {
                    // Check SIP account registration status
                }
                .keyboardShortcut("r", modifiers: [.command, .shift])
            }
            
            CommandGroup(replacing: .newItem) {
                Button("New Call...") {
                    // Trigger new call sheet
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }
        
        Settings {
            SettingsView()
        }
        #endif
    }    
   
    #if os(iOS)
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        let interaction = userActivity.interaction
        let startCallIntent = interaction?.intent as? INStartCallIntent
        
        let contact = startCallIntent?.contacts?[0]
        let contactHandle = contact?.personHandle
        if let phoneNumber = contactHandle?.value {
           print(phoneNumber)
        }
        return true
    }
    
    func handleStartCall(_ userActivity: NSUserActivity) {
        let interaction = userActivity.interaction
        let startCallIntent = interaction?.intent as? INStartCallIntent
        
        let contact = startCallIntent?.contacts?[0]
        let contactHandle = contact?.personHandle
        if let phoneNumber = contactHandle?.value {
           print(phoneNumber)
        }
    }
    #endif
}
