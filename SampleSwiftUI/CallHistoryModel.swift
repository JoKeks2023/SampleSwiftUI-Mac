//
//  CallHistoryModel.swift
//  SampleSwiftUI
//
//  Created by Copilot
//

import Foundation
import SwiftUI

///////////////////////////////////////////////////////////////////////////////////////////////////
///UserDefaults Keys

private enum UserDefaultsKeys {
    static let callHistory = "callHistory"
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///CallHistoryItem

/// Represents a single call in the call history.
struct CallHistoryItem: Identifiable, Codable {
    let id: UUID
    let remoteSide: String
    let localSide: String
    let isIncoming: Bool
    let startTime: Date
    let duration: TimeInterval
    let outcome: CallOutcome
    let withVideo: Bool
    
    /// Possible outcomes for a call.
    enum CallOutcome: String, Codable {
        case answered   // Call was successfully connected
        case missed     // Incoming call was not answered
        case rejected   // Call was explicitly rejected
        case failed     // Call failed to connect
    }
    
    init(remoteSide: String, localSide: String, isIncoming: Bool, startTime: Date, duration: TimeInterval, outcome: CallOutcome, withVideo: Bool) {
        self.id = UUID()
        self.remoteSide = remoteSide
        self.localSide = localSide
        self.isIncoming = isIncoming
        self.startTime = startTime
        self.duration = duration
        self.outcome = outcome
        self.withVideo = withVideo
    }
    
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: startTime)
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///CallHistoryModel

/// Manages the call history for the application, storing up to 100 recent calls.
/// Call history is automatically persisted to UserDefaults.
class CallHistoryModel: ObservableObject {
    @Published private(set) var history: [CallHistoryItem] = []
    private let maxHistoryItems = 100
    
    init() {
        loadHistory()
    }
    
    /// Adds a new call to the history.
    /// - Parameter item: The call history item to add
    /// - Note: The call is inserted at the beginning of the list (most recent first)
    ///         and the history is automatically saved to UserDefaults
    func addCall(_ item: CallHistoryItem) {
        history.insert(item, at: 0)
        
        // Keep only the most recent items
        if history.count > maxHistoryItems {
            history = Array(history.prefix(maxHistoryItems))
        }
        
        saveHistory()
    }
    
    /// Removes all call history items.
    func clearHistory() {
        history.removeAll()
        saveHistory()
    }
    
    /// Deletes specific calls from history.
    /// - Parameter indexSet: The indices of calls to delete
    func deleteCall(at indexSet: IndexSet) {
        history.remove(atOffsets: indexSet)
        saveHistory()
    }
    
    // MARK: - Persistence
    
    private func saveHistory() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(history)
            UserDefaults.standard.set(data, forKey: UserDefaultsKeys.callHistory)
        } catch {
            print("Error saving call history: \(error)")
        }
    }
    
    private func loadHistory() {
        guard let data = UserDefaults.standard.data(forKey: UserDefaultsKeys.callHistory) else { return }
        
        do {
            let decoder = JSONDecoder()
            history = try decoder.decode([CallHistoryItem].self, from: data)
        } catch {
            print("Error loading call history: \(error)")
        }
    }
}
