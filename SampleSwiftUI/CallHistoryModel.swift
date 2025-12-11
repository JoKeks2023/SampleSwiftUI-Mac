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

struct CallHistoryItem: Identifiable, Codable {
    let id: UUID
    let remoteSide: String
    let localSide: String
    let isIncoming: Bool
    let startTime: Date
    let duration: TimeInterval
    let outcome: CallOutcome
    let withVideo: Bool
    
    enum CallOutcome: String, Codable {
        case answered
        case missed
        case rejected
        case failed
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

class CallHistoryModel: ObservableObject {
    @Published private(set) var history: [CallHistoryItem] = []
    private let maxHistoryItems = 100
    
    init() {
        loadHistory()
    }
    
    func addCall(_ item: CallHistoryItem) {
        history.insert(item, at: 0)
        
        // Keep only the most recent items
        if history.count > maxHistoryItems {
            history = Array(history.prefix(maxHistoryItems))
        }
        
        saveHistory()
    }
    
    func clearHistory() {
        history.removeAll()
        saveHistory()
    }
    
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
