//
//  CallHistoryView.swift
//  SampleSwiftUI
//
//  Created by Copilot
//

import SwiftUI

struct CallHistoryView: View {
    @StateObject private var historyModel = SiprixModel.shared.callHistory
    @State private var showClearAlert = false
    @State private var searchText = ""
    
    var filteredHistory: [CallHistoryItem] {
        if searchText.isEmpty {
            return historyModel.history
        }
        return historyModel.history.filter { item in
            item.remoteSide.localizedCaseInsensitiveContains(searchText) ||
            item.localSide.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    if historyModel.history.isEmpty {
                        // Empty State
                        VStack(spacing: 20) {
                            Spacer()
                            
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(
                                        gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.blue.opacity(0.1)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: "clock.arrow.circlepath")
                                    .font(.system(size: 50))
                                    .foregroundColor(.blue)
                            }
                            
                            VStack(spacing: 8) {
                                Text("No Call History")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.primary)
                                
                                Text("Your call history will appear here")
                                    .font(.system(size: 16))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("No call history available")
                    } else {
                        // Search Bar
                        SearchBar(text: $searchText)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                        
                        // Call History List
                        List {
                            ForEach(filteredHistory) { item in
                                CallHistoryRow(item: item)
                                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                    .listRowBackground(Color.clear)
                                    .accessibilityElement(children: .combine)
                                    .accessibilityLabel("\(item.isIncoming ? "Incoming" : "Outgoing") call \(item.outcome.rawValue) with \(item.remoteSide) at \(item.formattedTime), duration \(item.formattedDuration)")
                            }
                            .onDelete { indexSet in
                                historyModel.deleteCall(at: indexSet)
                            }
                        }
                        .listStyle(.plain)
                        .background(Color(UIColor.systemGroupedBackground))
                    }
                }
            }
            .navigationTitle("Call History")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if !historyModel.history.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showClearAlert = true }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        .accessibilityLabel("Clear all call history")
                    }
                }
            }
            .alert("Clear All History", isPresented: $showClearAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    historyModel.clearHistory()
                }
            } message: {
                Text("Are you sure you want to clear all call history? This action cannot be undone.")
            }
        }
    }
}

struct CallHistoryRow: View {
    let item: CallHistoryItem
    
    var body: some View {
        HStack(spacing: 16) {
            // Call Direction & Outcome Icon
            ZStack {
                Circle()
                    .fill(iconBackgroundColor.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: iconName)
                    .font(.system(size: 22))
                    .foregroundColor(iconColor)
            }
            
            // Call Info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(item.remoteSide)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    if item.withVideo {
                        Image(systemName: "video.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.blue)
                    }
                }
                
                HStack(spacing: 4) {
                    Text(outcomeText)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    Text("•")
                        .foregroundColor(.secondary.opacity(0.5))
                    Text(item.formattedTime)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Duration
            if item.outcome == .answered {
                VStack(alignment: .trailing, spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    Text(item.formattedDuration)
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
    }
    
    private var iconName: String {
        switch item.outcome {
        case .answered:
            return item.isIncoming ? "phone.arrow.down.left.fill" : "phone.arrow.up.right.fill"
        case .missed:
            return "phone.down.fill"
        case .rejected:
            return "phone.down.fill"
        case .failed:
            return "exclamationmark.triangle.fill"
        }
    }
    
    private var iconColor: Color {
        switch item.outcome {
        case .answered:
            return item.isIncoming ? .green : .blue
        case .missed:
            return .red
        case .rejected:
            return .orange
        case .failed:
            return .red
        }
    }
    
    private var iconBackgroundColor: Color {
        switch item.outcome {
        case .answered:
            return item.isIncoming ? .green : .blue
        case .missed, .rejected, .failed:
            return .red
        }
    }
    
    private var outcomeText: String {
        switch item.outcome {
        case .answered:
            return item.isIncoming ? "Incoming" : "Outgoing"
        case .missed:
            return "Missed"
        case .rejected:
            return "Rejected"
        case .failed:
            return "Failed"
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search call history", text: $text)
                .textFieldStyle(.plain)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(10)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Search call history")
    }
}
