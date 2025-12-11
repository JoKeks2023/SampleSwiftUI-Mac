//
//  WatchConnectivity.swift
//  SampleSwiftUI
//
//  Created by Copilot - Apple Watch Integration
//

import Foundation
import WatchConnectivity

///////////////////////////////////////////////////////////////////////////////////////////////////
/// WatchConnectivityManager
///
/// Manages communication between the iOS app and Apple Watch companion app
///
/// Features:
/// - Sync SIP accounts to Apple Watch
/// - View active calls on Apple Watch
/// - Control calls from Apple Watch (answer, reject, hold, hangup)
/// - View call history on Apple Watch
/// - Quick dial favorite contacts from Apple Watch
///
/// The Apple Watch app provides:
/// - Call status at a glance
/// - One-tap call controls
/// - Complication support showing active call count
/// - Force Touch menu for quick actions
/// - Digital Crown for volume control

class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()
    
    // MARK: - Properties
    
    @Published private(set) var isWatchAppInstalled = false
    @Published private(set) var isWatchReachable = false
    
    private let logs: LogsModel?
    private var session: WCSession?
    
    // MARK: - Initialization
    
    private override init() {
        self.logs = SiprixModel.shared.logs
        super.init()
        
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
            logs?.printl("Watch Connectivity: Session activated")
        } else {
            logs?.printl("Watch Connectivity: Not supported on this device")
        }
    }
    
    // MARK: - Data Sync Methods
    
    /// Syncs all SIP accounts to the Apple Watch
    func syncAccounts() {
        guard let session = session, session.isReachable else {
            logs?.printl("Watch Connectivity: Watch not reachable, accounts not synced")
            return
        }
        
        let accounts = SiprixModel.shared.accountsListModel.accounts
        let accountsData: [[String: Any]] = accounts.map { account in
            [
                "id": account.id,
                "name": account.name,
                "regState": account.regState.rawValue,
                "regText": account.regText
            ]
        }
        
        let message: [String: Any] = [
            "type": "accounts_update",
            "accounts": accountsData
        ]
        
        session.sendMessage(message, replyHandler: { reply in
            self.logs?.printl("Watch Connectivity: Accounts synced successfully")
        }, errorHandler: { error in
            self.logs?.printl("Watch Connectivity: Error syncing accounts - \(error.localizedDescription)")
        })
    }
    
    /// Syncs active calls to the Apple Watch
    func syncActiveCalls() {
        guard let session = session, session.isReachable else {
            logs?.printl("Watch Connectivity: Watch not reachable, calls not synced")
            return
        }
        
        let calls = SiprixModel.shared.callsListModel.calls
        let callsData: [[String: Any]] = calls.map { call in
            [
                "id": call.id,
                "remoteSide": call.remoteSide,
                "localSide": call.localSide,
                "isIncoming": call.isIncoming,
                "callState": call.callState.rawValue,
                "stateStr": call.stateStr,
                "durationStr": call.durationStr,
                "isMicMuted": call.isMicMuted,
                "isLocalHold": call.isLocalHold
            ]
        }
        
        let message: [String: Any] = [
            "type": "calls_update",
            "calls": callsData
        ]
        
        session.sendMessage(message, replyHandler: nil, errorHandler: { error in
            self.logs?.printl("Watch Connectivity: Error syncing calls - \(error.localizedDescription)")
        })
    }
    
    /// Syncs call history to the Apple Watch (limited to most recent 20 calls)
    func syncCallHistory() {
        guard let session = session else { return }
        
        let history = SiprixModel.shared.callHistory.history.prefix(20)
        let historyData: [[String: Any]] = history.map { item in
            [
                "id": item.id.uuidString,
                "remoteSide": item.remoteSide,
                "isIncoming": item.isIncoming,
                "startTime": item.startTime.timeIntervalSince1970,
                "duration": item.duration,
                "outcome": item.outcome.rawValue,
                "withVideo": item.withVideo
            ]
        }
        
        do {
            try session.updateApplicationContext([
                "type": "history_update",
                "history": historyData
            ])
            logs?.printl("Watch Connectivity: Call history synced to watch")
        } catch {
            logs?.printl("Watch Connectivity: Error syncing history - \(error.localizedDescription)")
        }
    }
    
    // MARK: - Call Control Methods
    
    /// Handles call control commands from the Apple Watch
    /// - Parameters:
    ///   - action: The action to perform (answer, reject, hold, hangup, mute)
    ///   - callId: The ID of the call to control
    private func handleCallAction(action: String, callId: Int) {
        logs?.printl("Watch Connectivity: Handling action '\(action)' for call \(callId)")
        
        guard let call = SiprixModel.shared.callsListModel.calls.first(where: { $0.id == callId }) else {
            logs?.printl("Watch Connectivity: Call \(callId) not found")
            return
        }
        
        DispatchQueue.main.async {
            switch action {
            case "answer":
                call.accept()
            case "reject":
                call.reject()
            case "hold":
                call.hold()
            case "hangup":
                call.bye()
            case "mute":
                call.muteMic(!call.isMicMuted)
            case "speaker":
                #if os(iOS)
                call.switchSpeaker(!call.isSpeakerOn)
                #endif
            default:
                self.logs?.printl("Watch Connectivity: Unknown action '\(action)'")
            }
        }
    }
    
    /// Initiates a call from the Apple Watch
    /// - Parameters:
    ///   - phoneNumber: The phone number to call
    ///   - accountId: The SIP account to use
    private func handleMakeCall(phoneNumber: String, accountId: Int) {
        logs?.printl("Watch Connectivity: Making call to \(phoneNumber) from account \(accountId)")
        
        DispatchQueue.main.async {
            let destData = SiprixDestData()
            destData.toExt = phoneNumber
            destData.fromAccId = Int32(accountId)
            destData.withVideo = NSNumber(value: false)
            
            let errCode = SiprixModel.shared.callsListModel.invite(destData)
            if errCode != kErrorCodeEOK {
                self.logs?.printl("Watch Connectivity: Error making call - \(SiprixModel.shared.getErrorText(errCode))")
            }
        }
    }
}

// MARK: - WCSessionDelegate

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            logs?.printl("Watch Connectivity: Activation failed - \(error.localizedDescription)")
        } else {
            logs?.printl("Watch Connectivity: Session activated with state \(activationState.rawValue)")
            isWatchAppInstalled = session.isWatchAppInstalled
            isWatchReachable = session.isReachable
            
            // Sync initial data to watch
            if session.isReachable {
                syncAccounts()
                syncCallHistory()
            }
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        logs?.printl("Watch Connectivity: Session became inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        logs?.printl("Watch Connectivity: Session deactivated")
        session.activate()
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        isWatchReachable = session.isReachable
        logs?.printl("Watch Connectivity: Reachability changed - reachable: \(session.isReachable)")
        
        if session.isReachable {
            // Sync data when watch becomes reachable
            syncAccounts()
            syncActiveCalls()
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        logs?.printl("Watch Connectivity: Received message from watch")
        
        guard let type = message["type"] as? String else {
            replyHandler(["success": false, "error": "Missing message type"])
            return
        }
        
        switch type {
        case "call_action":
            guard let action = message["action"] as? String,
                  let callId = message["callId"] as? Int else {
                replyHandler(["success": false, "error": "Invalid call action parameters"])
                return
            }
            handleCallAction(action: action, callId: callId)
            replyHandler(["success": true])
            
        case "make_call":
            guard let phoneNumber = message["phoneNumber"] as? String,
                  let accountId = message["accountId"] as? Int else {
                replyHandler(["success": false, "error": "Invalid make call parameters"])
                return
            }
            handleMakeCall(phoneNumber: phoneNumber, accountId: accountId)
            replyHandler(["success": true])
            
        case "request_accounts":
            syncAccounts()
            replyHandler(["success": true])
            
        case "request_calls":
            syncActiveCalls()
            replyHandler(["success": true])
            
        default:
            logs?.printl("Watch Connectivity: Unknown message type '\(type)'")
            replyHandler(["success": false, "error": "Unknown message type"])
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
/// Apple Watch App Structure (Documentation)
///
/// To create the Apple Watch companion app, add a new watchOS target to the Xcode project:
///
/// 1. File > New > Target > watchOS > Watch App for iOS App
/// 2. Create the following views:
///
/// WatchContentView.swift:
/// - Main view with tabs: Calls, Accounts, History
/// - Shows active call count badge
///
/// WatchCallsView.swift:
/// - List of active calls
/// - Tap to show call controls
/// - Answer/Reject buttons for incoming calls
/// - Hold/Hangup buttons for active calls
///
/// WatchAccountsView.swift:
/// - List of SIP accounts with status indicators
/// - Shows registration state
///
/// WatchHistoryView.swift:
/// - Recent call history (last 20 calls)
/// - Shows call direction, duration, outcome
///
/// WatchCallDetailView.swift:
/// - Call control buttons (Hold, Mute, Speaker, Hangup)
/// - Call duration timer
/// - Remote party information
///
/// WatchComplication.swift:
/// - Show active call count on watch face
/// - Tap to open app to active calls view
///
/// Additional Features:
/// - VoIP notification support on watch
/// - Handoff support to continue call on iPhone/iPad
/// - Digital Crown volume control during calls
/// - Haptic feedback for call events
/// - Background VoIP updates
///
/// Required Capabilities (Info.plist):
/// - com.apple.developer.networking.wifi-info (for network status)
/// - Background Modes: VoIP
///
/// Required Entitlements:
/// - Push Notifications
/// - Background Modes (VoIP)
