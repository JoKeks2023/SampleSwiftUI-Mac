//
//  ContentView.swift
//  SampleSwiftUI
//
//  Created by Siprix Team.
//

import SwiftUI
import siprix

///////////////////////////////////////////////////////////////////////////////////////////////////
///AccountView
///
struct AccountRowView: View {
    private var accList : AccountsListModel
    @StateObject private var acc : AccountModel
    @State private var delAccAlert = false
    
    init(_ acc: AccountModel, accList: AccountsListModel) {
        self._acc = StateObject(wrappedValue: acc)
        self.accList = accList
    }
    
    private var regStateImgName: String {
        get {
            switch acc.regState{
                case .success: return "checkmark.circle.fill"
                case .failed:  return "xmark.circle.fill"
                case .removed: return "minus.circle.fill"
                default: return "arrow.clockwise.circle.fill"
            }
        }
    }
    
    private var regStateImgColor : Color {
        get {
            switch acc.regState {
                case .success: return .green
                case .failed:  return .red
                default: return .orange
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                // Status Indicator
                ZStack {
                    Circle()
                        .fill(regStateImgColor.opacity(0.15))
                        .frame(width: 56, height: 56)
                    
                    if(acc.regState == RegState.inProgress) {
                        ProgressView()
                            .scaleEffect(1.2)
                    } else {
                        Image(systemName: regStateImgName)
                            .foregroundColor(regStateImgColor)
                            .font(.system(size: 28))
                    }
                }
                
                // Account Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(acc.name)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                    
                    HStack(spacing: 4) {
                        Text("ID: \(acc.id)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                        Text("•")
                            .foregroundColor(.secondary.opacity(0.5))
                        Text(acc.regText)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                    }
                }
                
                Spacer()
                
                // Action Menu
                Menu {
                    Button {
                        accList.reg(acc.id)
                    } label: {
                        Label("Register", systemImage: "arrow.up.circle")
                    }
                    
                    Button {
                        accList.unReg(acc.id)
                    } label: {
                        Label("Unregister", systemImage: "arrow.down.circle")
                    }
                    
                    Divider()
                    
                    Button(role: .destructive) {
                        delAccAlert = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                        .frame(minWidth: 44, minHeight: 44)
                }
                .accessibilityLabel("Account actions menu")
                .alert(isPresented: $delAccAlert) {
                    Alert(
                        title: Text("Delete Account"),
                        message: Text("Are you sure you want to delete '\(acc.name)'? This action cannot be undone."),
                        primaryButton: .destructive(Text("Delete")) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                accList.del(acc.id)
                            }
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(accList.isSelectedAcc(acc.id) ? Color.blue : Color.clear, lineWidth: 2)
            )
            .scaleEffect(accList.isSelectedAcc(acc.id) ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: accList.isSelectedAcc(acc.id))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Account \(acc.name), \(acc.regText)")
        .accessibilityHint("Tap to select, or use the menu for more actions")
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///AccountsListView

struct AccountsListView: View {
    @StateObject private var accList : AccountsListModel
    @State private var addAccNavTag = false
    @State private var addAccSheet = false
    @State private var isRefreshing = false
    @State private var lastRefreshTime: Date?
            
    init(_ accList: AccountsListModel) {
        self._accList = StateObject(wrappedValue: accList)
    }
    
    private func refreshAccounts() {
        guard !isRefreshing else { return }
        isRefreshing = true
        lastRefreshTime = Date()
        
        // Re-register all accounts to check status
        let accountsToRefresh = accList.accounts.filter { $0.regState == .success || $0.regState == .failed }
        
        if accountsToRefresh.isEmpty {
            isRefreshing = false
            return
        }
        
        for account in accountsToRefresh {
            accList.reg(account.id)
        }
        
        // Complete refresh after a reasonable delay to allow network operations
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.isRefreshing = false
        }
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(UIColor.systemGroupedBackground),
                    Color(UIColor.systemGroupedBackground).opacity(0.95)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("SIP Accounts")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.primary)
                            .accessibilityAddTraits(.isHeader)
                        
                        if !accList.accounts.isEmpty {
                            HStack(spacing: 4) {
                                Text("\(accList.accounts.count) account\(accList.accounts.count == 1 ? "" : "s")")
                                    .font(.system(size: 15))
                                    .foregroundColor(.secondary)
                                
                                if let lastRefresh = lastRefreshTime {
                                    Text("•")
                                        .foregroundColor(.secondary.opacity(0.5))
                                    Text("Updated \(timeAgo(lastRefresh))")
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    if !accList.accounts.isEmpty {
                        Button(action: refreshAccounts) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 20))
                                .foregroundColor(.blue)
                                .rotationEffect(.degrees(isRefreshing ? 360 : 0))
                                .animation(isRefreshing ? Animation.linear(duration: 1).repeatForever(autoreverses: false) : .default, value: isRefreshing)
                        }
                        .disabled(isRefreshing)
                        .accessibilityLabel("Refresh account status")
                        .frame(minWidth: 44, minHeight: 44)
                    }
                    
                    Button(action: { addAccSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.blue)
                    }
                    .accessibilityLabel("Add new account")
                    .frame(minWidth: 44, minHeight: 44)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                if(accList.accounts.isEmpty) {
                    // Empty State
                    Spacer()
                    VStack(spacing: 20) {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .font(.system(size: 70))
                            .foregroundColor(.blue.opacity(0.5))
                        
                        VStack(spacing: 8) {
                            Text("No Accounts Yet")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("Add your first SIP account to start making calls")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        
                        Button(action: { addAccSheet = true }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Account")
                                    .fontWeight(.semibold)
                            }
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                            .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.top, 8)
                    }
                    Spacer()
                } else {
                    // Accounts List
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(accList.accounts) { acc in
                                AccountRowView(acc, accList:accList)
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            accList.selectAcc(acc.id)
                                        }
                                        // Haptic feedback
                                        #if os(iOS)
                                        let generator = UIImpactFeedbackGenerator(style: .light)
                                        generator.impactOccurred()
                                        #endif
                                    }
                                    .transition(.asymmetric(
                                        insertion: .scale.combined(with: .opacity),
                                        removal: .opacity
                                    ))
                            }
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 16)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: accList.accounts.count)
                    }
                    .refreshable {
                        await refreshAccountsAsync()
                    }
                }
            }
        }
        .sheet(isPresented: $addAccSheet) {
            AccountAddView(accList)
        }
    }
    
    private func refreshAccountsAsync() async {
        refreshAccounts()
        // Wait for refresh to complete
        while isRefreshing {
            try? await Task.sleep(nanoseconds: 100_000_000) // Check every 100ms
        }
    }
    
    private func timeAgo(_ date: Date) -> String {
        let seconds = Int(Date().timeIntervalSince(date))
        if seconds < 60 {
            return "just now"
        } else if seconds < 3600 {
            let minutes = seconds / 60
            return "\(minutes)m ago"
        } else if seconds < 86400 {
            let hours = seconds / 3600
            return "\(hours)h ago"
        } else {
            let days = seconds / 86400
            return "\(days)d ago"
        }
    }
}//AccountsListView


///////////////////////////////////////////////////////////////////////////////////////////////////
///AccountAddView

struct AccountAddView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    private var accList : AccountsListModel
    
    @State private var sipServer = ""
    @State private var sipExtension = ""
    @State private var sipPassword = ""
    @State private var transport = SipTransport.udp
    
    @State private var addAccAlert = false
    @State private var addAccErr = ""
    
    init(_ accList: AccountsListModel) {
        self.accList = accList
    }
        
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header Icon
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.blue.opacity(0.1)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "person.crop.circle.badge.plus")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                        }
                        .padding(.top, 20)
                        
                        // Credentials Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Account Credentials")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 12) {
                                CustomTextField(
                                    icon: "server.rack",
                                    placeholder: "SIP Server / Domain",
                                    text: $sipServer
                                )
                                
                                CustomTextField(
                                    icon: "person.fill",
                                    placeholder: "Extension / Username",
                                    text: $sipExtension
                                )
                                
                                CustomSecureField(
                                    icon: "lock.fill",
                                    placeholder: "Password",
                                    text: $sipPassword
                                )
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Transport Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Connection Settings")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 0) {
                                ForEach([SipTransport.udp, SipTransport.tcp, SipTransport.tls], id: \.self) { proto in
                                    Button(action: { transport = proto }) {
                                        HStack {
                                            Image(systemName: proto == transport ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(proto == transport ? .blue : .gray)
                                                .font(.system(size: 22))
                                            
                                            Text(getTransportName(proto))
                                                .font(.system(size: 16, weight: proto == transport ? .semibold : .regular))
                                                .foregroundColor(.primary)
                                            
                                            Spacer()
                                            
                                            if proto == .tls {
                                                Image(systemName: "lock.shield.fill")
                                                    .font(.system(size: 16))
                                                    .foregroundColor(.green)
                                            }
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 14)
                                        .background(Color(UIColor.secondarySystemGroupedBackground))
                                    }
                                    
                                    if proto != .tls {
                                        Divider()
                                            .padding(.leading, 60)
                                    }
                                }
                            }
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                        }
                        
                        // Add Account Button
                        Button(action: addAcc) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Add Account")
                                    .fontWeight(.semibold)
                            }
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: isFormValid ? 
                                        [Color.blue, Color.blue.opacity(0.8)] : 
                                        [Color.gray.opacity(0.5), Color.gray.opacity(0.4)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                            .shadow(color: isFormValid ? Color.blue.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
                        }
                        .disabled(!isFormValid)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .alert("Can't add account", isPresented: $addAccAlert) {}
                            message: { Text(addAccErr) }
                        
                        Spacer(minLength: 20)
                    }
                }
            }
            .navigationTitle("Add SIP Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !sipServer.isEmpty && !sipExtension.isEmpty && !sipPassword.isEmpty
    }
    
    private func getTransportName(_ transport: SipTransport) -> String {
        switch transport {
        case .udp: return "UDP (User Datagram Protocol)"
        case .tcp: return "TCP (Transmission Control Protocol)"
        case .tls: return "TLS (Secure Transport)"
        default: return "Unknown"
        }
    }
    
    private func addAcc() {
        let accData = SiprixAccData()
        accData.sipServer = sipServer
        accData.sipExtension = sipExtension
        accData.sipPassword = sipPassword
        accData.transport = transport
        accData.keepAliveTime = 0
        accData.expireTime=300
        //Use this line when TLS transport required and certificate of SIP server signed by Let's Encrypt CA
        //accData.tlsCaCertPath = Bundle.main.path(forResource: "isrg_root_x1", ofType: "pem")
        
        let errCode = accList.add(accData)
        if(errCode == kErrorCodeEOK) {
            self.dismiss()
        } else {
            addAccErr = SiprixModel.shared.getErrorText(errCode)
            addAccAlert = true
        }
    }
}

// Custom TextField Component
struct CustomTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.system(size: 18))
                .frame(width: 24)
            
            TextField(placeholder, text: $text)
                .font(.system(size: 16))
                .autocapitalization(.none)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(10)
    }
}

// Custom SecureField Component
struct CustomSecureField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.system(size: 18))
                .frame(width: 24)
            
            SecureField(placeholder, text: $text)
                .font(.system(size: 16))
                .autocapitalization(.none)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(10)
    }
}//AccountAddView




///////////////////////////////////////////////////////////////////////////////////////////////////
///CallRowView
///
struct CallRowView: View {
    private var callsList : CallsListModel
    @StateObject private var call : CallModel
    @State private var switchedCallId : Int
    
    init(_ call: CallModel, callsList : CallsListModel) {
        self._call = StateObject(wrappedValue: call)
        self._switchedCallId = State(wrappedValue: callsList.switchedCallId)
        self.callsList = callsList
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Call Direction Icon
            ZStack {
                Circle()
                    .fill(call.isIncoming ? Color.green.opacity(0.15) : Color.blue.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: call.isIncoming ? "phone.arrow.down.left" : "phone.arrow.up.right")
                    .font(.system(size: 22))
                    .foregroundColor(call.isIncoming ? .green : .blue)
            }
            
            // Call Info
            VStack(alignment: .leading, spacing: 4) {
                Text(call.remoteSide)
                    .font(.system(size: 17, weight: .semibold))
                    .lineLimit(1)
                    .foregroundColor(.primary)
                    .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                
                HStack(spacing: 6) {
                    // Status indicator
                    Circle()
                        .fill(getStatusColor())
                        .frame(width: 8, height: 8)
                        .animation(.easeInOut(duration: 0.3), value: call.callState)
                    
                    Text(call.stateStr)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                    
                    if call.isMicMuted {
                        Image(systemName: "mic.slash.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.red)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: call.isMicMuted)
            }
            
            Spacer()
            
            // Duration or Status
            if(call.callState != .connected) && (call.callState != .held) {
                ProgressView()
                    .scaleEffect(0.9)
            } else if(call.callState == .connected) {
                Text(call.durationStr)
                    .font(.system(size: 15, weight: .medium, design: .monospaced))
                    .foregroundColor(.blue)
            }
            
            // Quick Actions Menu
            if call.callState == .ringing {
                HStack(spacing: 12) {
                    Button(action: {
                        #if os(iOS)
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.warning)
                        #endif
                        call.reject()
                    }) {
                        Image(systemName: "phone.down.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.red)
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Reject call from \(call.remoteSide)")
                    
                    Button(action: {
                        #if os(iOS)
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        #endif
                        call.accept()
                    }) {
                        Image(systemName: "phone.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.green)
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Accept call from \(call.remoteSide)")
                }
                .transition(.scale.combined(with: .opacity))
            } else {
                getMenu()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(callsList.isSwitchedCall(call.id) ? 
                    Color.blue.opacity(0.1) : 
                    Color(UIColor.secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(callsList.isSwitchedCall(call.id) ? Color.blue : Color.clear, lineWidth: 2)
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
        .scaleEffect(callsList.isSwitchedCall(call.id) ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: callsList.isSwitchedCall(call.id))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(call.isIncoming ? "Incoming" : "Outgoing") call from \(call.remoteSide), \(call.stateStr)")
    }
    
    private func getStatusColor() -> Color {
        switch call.callState {
        case .connected: return .green
        case .held: return .orange
        case .ringing: return .blue
        default: return .gray
        }
    }

    func getMenu() -> some View {
        Menu {
            if(call.callState == .connected) {
                if(!callsList.isSwitchedCall(call.id)) {
                    Button(action: { callsList.switchToCall(call.id) }) {
                        Label("Switch To", systemImage: "arrow.triangle.swap")
                    }
                }
                Button(action: { call.hold() }) {
                    Label("Hold", systemImage: "pause.circle")
                }
            }
            
            if((call.holdState == .local)||(call.holdState == .localAndRemote)) {
                Button(action: { call.hold() }) {
                    Label("Resume", systemImage: "play.circle")
                }
            }
            
            Divider()
            
            Button(role: .destructive, action: { call.bye() }) {
                Label("Hang Up", systemImage: "phone.down")
            }
        } label: {
            Image(systemName: "ellipsis.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(.blue)
                .frame(minWidth: 44, minHeight: 44)
        }
        .disabled(callsList.isSwitchedCall(call.id))
        .accessibilityLabel("Call actions menu")
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///SiprixVideoView
///
struct SiprixVideoView: UIViewRepresentable {
    private var call : CallModel
    private let isPreview : Bool
    
    init(_ call: CallModel, isPreview : Bool) {
        self.call = call
        self.isPreview = isPreview
    }
    //deinit {
    //    call.setVideoView(nil, isPreview:isPreview)
    //}
    
    func makeUIView(context: Context) -> UIView {
        let view = SiprixModel.shared.createVideoView()
        call.setVideoView(view, isPreview:isPreview)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) { }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///CallSwitchedView
///
struct CallSwitchedView: View {
    @StateObject private var call : CallModel
    private let addCallAction: () -> Void
    
    @State var transferShow = false
    @State var transferExt = ""
    
    @State var dtmfShow = false
    @State var dtmfSent = ""
            
    init(_ call: CallModel, addCallAction: @escaping () -> Void) {
        self._call = StateObject(wrappedValue: call)
        self.addCallAction = addCallAction
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Video Views
            if(call.withVideo) {
                SiprixVideoView(call, isPreview:false)
                    .ignoresSafeArea()
                
                VStack {
                    HStack {
                        Spacer()
                        SiprixVideoView(call, isPreview:true)
                            .frame(width:140, height:180)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
                            )
                            .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                            .padding()
                    }
                    Spacer()
                }
                
                // Camera toggle button
                VStack {
                    HStack {
                        Button(action:{ call.muteCam(!call.isCamMuted) }) {
                            ZStack {
                                Circle()
                                    .fill(Color.black.opacity(0.5))
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: call.isCamMuted ? "video.slash.fill":"video.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                        Spacer()
                    }
                    Spacer()
                }
            }
            
            // Main Call Interface
            VStack(spacing: 0) {
                // Call Info Header
                VStack(spacing: 12) {
                    // Status Badge
                    Text(call.stateStr)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(getStatusColor().opacity(0.8))
                        )
                    
                    // Remote Party Info
                    VStack(spacing: 4) {
                        Text(call.remoteSide)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        Text(call.localSide)
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                    }
                    
                    // Duration / Hold Status
                    if(call.callState == .connected) {
                        Text(call.durationStr)
                            .font(.system(size: 32, weight: .medium, design: .monospaced))
                            .foregroundColor(.blue)
                    } else if(call.callState == .held) {
                        HStack(spacing: 8) {
                            Image(systemName: "pause.circle.fill")
                                .foregroundColor(.orange)
                            Text(call.holdStr)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.orange)
                        }
                    } else {
                        Text("--:--")
                            .font(.system(size: 32, weight: .medium, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                    
                    // DTMF Display
                    if !call.receivedDtmf.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "number.circle.fill")
                                .foregroundColor(.blue)
                            Text("DTMF: \(call.receivedDtmf)")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.blue.opacity(0.1))
                        )
                    }
                }
                .padding(.top, 30)
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Controls Section
                if((call.callState == .connected)||(call.callState == .held)) {
                    if(transferShow)  {   getTransView()  }
                    else if(dtmfShow) {   getDtmfView()   }
                    else              {   getCtrlsView()  }
                }
                
                // Action Buttons
                if(call.callState == .ringing) {
                    getAcceptRejectView()
                } else {
                    getHangupView()
                }
                
                Spacer(minLength: 30)
            }
            .background(
                call.withVideo ? Color.clear : 
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(UIColor.systemGroupedBackground),
                        Color(UIColor.systemGroupedBackground).opacity(0.95)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }
    
    private func getStatusColor() -> Color {
        switch call.callState {
        case .connected: return .green
        case .held: return .orange
        case .ringing: return .blue
        default: return .gray
        }
    }
    
    func getRoundBtn(iconName: String, action: @escaping () -> Void) -> some View {
        Button(action:action) {
            ZStack {
                Circle()
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
                    .frame(width: 60, height: 60)
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                Image(systemName: iconName)
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
            }
        }
    }
    
    func getFilledBtn(iconName: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 70, height: 70)
                    .shadow(color: color.opacity(0.4), radius: 8, x: 0, y: 4)
                
                Image(systemName: iconName)
                    .font(.system(size: 32))
                    .foregroundColor(.white)
            }
        }
    }
    
    func getDtmfBtn(_ tone: String) -> some View {
        Button(action: {
            if(call.sendDtmf(tone)) {  dtmfSent += tone }
        }) {
            ZStack {
                Text(tone).font(.title)//.foregroundColor(.blue)
                Circle().strokeBorder(.blue, lineWidth: 2)
            }.frame(width: 40, height: 40)
        }//.padding()
    }
    
    func getTransView() -> some View {
        HStack {
            TextField("Extension to transfer", text:$transferExt)
            .textFieldStyle(.roundedBorder)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
            
            Button(action: {
                transferShow = false
                call.transferBlind(toExt: transferExt)
            }) {
                Image(systemName: "checkmark.circle").font(.title).foregroundColor(.green)
            }
            .padding()
            .disabled(transferExt.isEmpty)
            
            Button(action: { transferShow = false }) {
                Image(systemName: "xmark.circle.fill").font(.title)
            }.padding()
        }
    }
       
    func getDtmfView() -> some View {
        VStack(spacing: 10) {
            Divider()
            HStack(spacing: 20) {
                Text(dtmfSent).underline().frame(maxWidth: .infinity, alignment: .center)
                Spacer()
                Button(action: { dtmfShow = false }) {
                    Image(systemName: "xmark.circle.fill").font(.title)
                }.padding(.trailing)
            }
            HStack(spacing: 20) { getDtmfBtn("1"); getDtmfBtn("2"); getDtmfBtn("3")  }
            HStack(spacing: 20) { getDtmfBtn("4"); getDtmfBtn("5"); getDtmfBtn("6")  }
            HStack(spacing: 20) { getDtmfBtn("7"); getDtmfBtn("8"); getDtmfBtn("9")  }
            HStack(spacing: 20) { getDtmfBtn("*"); getDtmfBtn("0"); getDtmfBtn("#")  }
            Divider()
        }
    }
    
    func getCtrlsView() -> some View {
        VStack(spacing: 24) {
            // Primary Controls
            HStack(spacing: 32) {
                VStack(spacing: 8) {
                    getRoundBtn(iconName: call.isMicMuted ? "mic.slash.fill":"mic.fill",
                                action: { call.muteMic(!call.isMicMuted) })
                    Text(call.isMicMuted ? "Unmute" : "Mute")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 8) {
                    getRoundBtn(iconName: "circle.grid.3x3.fill",
                                action: { dtmfShow = true; dtmfSent="" })
                    Text("Keypad")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 8) {
                    getRoundBtn(iconName: call.isSpeakerOn ? "speaker.wave.3.fill" : "speaker.wave.2.fill",
                                action: { call.switchSpeaker(!call.isSpeakerOn) })
                    Text("Speaker")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            
            // Secondary Controls
            HStack(spacing: 32) {
                VStack(spacing: 8) {
                    getRoundBtn(iconName: "plus.circle.fill",
                                action: addCallAction)
                    Text("Add Call")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 8) {
                    getRoundBtn(iconName: (call.isLocalHold) ? "play.fill" : "pause.fill",
                                action: { call.hold() })
                    Text(call.isLocalHold ? "Resume" : "Hold")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                Menu {
                    Button {
                        call.routeAudioToBluetoth()
                    } label: {
                        Label("Bluetooth Audio", systemImage: "airpodspro")
                    }
                    
                    Button {
                        call.routeAudioToBuiltIn()
                    } label: {
                        Label("Phone Speaker", systemImage: "iphone")
                    }
                    
                    Divider()
                    
                    Button {
                        transferShow = true
                    } label: {
                        Label("Transfer Call", systemImage: "arrow.triangle.branch")
                    }
                    
                    Button {
                        call.playFile()
                    } label: {
                        Label("Play Audio File", systemImage: "music.note")
                    }
                } label: {
                    VStack(spacing: 8) {
                        getRoundBtn(iconName: "ellipsis", action: {})
                        Text("More")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 20)
    }
    
    func getAcceptRejectView() -> some View {
        HStack(spacing: 60) {
            VStack(spacing: 8) {
                getFilledBtn(iconName:"phone.down.fill", color:.red, action: { call.reject() })
                Text("Decline")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
            }
            
            VStack(spacing: 8) {
                getFilledBtn(iconName:"phone.fill", color:.green, action: { call.accept() })
                Text("Accept")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
            }
        }
        .padding(.vertical, 20)
    }
    
    func getHangupView() -> some View {
        VStack(spacing: 8) {
            getFilledBtn(iconName:"phone.down.fill", color:.red, action:{ call.bye() })
            Text("End Call")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
        }
        .padding(.vertical, 20)
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///CallsListView

struct CallsListView: View {
    let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()
    @StateObject private var callsList : CallsListModel
    @State private var addCallSheet = false
        
    init(_ callsList: CallsListModel) {
        self._callsList = StateObject(wrappedValue: callsList)
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(UIColor.systemGroupedBackground),
                    Color(UIColor.systemGroupedBackground).opacity(0.95)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                if(callsList.calls.isEmpty) {
                    // Empty State
                    VStack(spacing: 20) {
                        Spacer()
                        
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [Color.green.opacity(0.2), Color.green.opacity(0.1)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: "phone.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.green)
                        }
                        
                        VStack(spacing: 8) {
                            Text("No Active Calls")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("Tap the button below to start a call")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                        }
                        
                        Button(action: addCallNav) {
                            HStack {
                                Image(systemName: "phone.badge.plus")
                                Text("Make Call")
                                    .fontWeight(.semibold)
                            }
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                            .shadow(color: Color.green.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.top, 8)
                        
                        Spacer()
                    }
                }
                else {
                    // Active Calls
                    VStack(spacing: 0) {
                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Active Calls")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.primary)
                                
                                Text("\(callsList.calls.count) call\(callsList.calls.count == 1 ? "" : "s")")
                                    .font(.system(size: 15))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(action: addCallNav) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.green)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        
                        // Calls List
                        ScrollView {
                            VStack(spacing: 8) {
                                ForEach(callsList.calls) { call in
                                    CallRowView(call, callsList:callsList)
                                }
                            }
                            .padding(.top, 4)
                        }
                        .frame(height: 200)
                        .onReceive(timer) { curTime in
                            callsList.updateDuration(curTime)
                        }
                        
                        // Active Call Details
                        if(callsList.switchedCallId != kInvalidId) {
                            CallSwitchedView(callsList.switchedCall!, addCallAction:addCallNav)
                                .id(callsList.switchedCall!.uuid)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $addCallSheet) {
            CallAddView()
        }
    }
    
    private func addCallNav() {
        addCallSheet = true
    }
    
}//CallsListView

///////////////////////////////////////////////////////////////////////////////////////////////////
///CallAddView

struct CallAddView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    let accList = SiprixModel.shared.accountsListModel
    @FocusState private var destInFocus: Bool
    
    @State private var addCallAlert = false
    @State private var addCallErr = ""
   
    @State private var ext = ""
    @State private var withVideo = false
    @State private var accId : Int
    
    init() {
        ext = ""
        accId = accList.selectedAccId
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header Icon
                        ZStack {
                            Circle()
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [Color.green.opacity(0.2), Color.green.opacity(0.1)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "phone.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.green)
                        }
                        .padding(.top, 20)
                        
                        if(accList.isEmpty) {
                            // No Account Warning
                            VStack(spacing: 16) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.orange)
                                
                                Text("No Account Available")
                                    .font(.system(size: 20, weight: .bold))
                                
                                Text("You need to add a SIP account before making calls")
                                    .font(.system(size: 16))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                            }
                            .padding(.vertical, 40)
                        } else {
                            // Destination Section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Call Destination")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 20)
                                
                                HStack(spacing: 12) {
                                    Image(systemName: "phone.fill")
                                        .foregroundColor(.green)
                                        .font(.system(size: 18))
                                        .frame(width: 24)
                                    
                                    TextField("Phone number or extension", text: $ext)
                                        .font(.system(size: 16))
                                        .keyboardType(.phonePad)
                                        .focused($destInFocus)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(Color(UIColor.secondarySystemGroupedBackground))
                                .cornerRadius(10)
                                .padding(.horizontal, 20)
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                                        self.destInFocus = true
                                    }
                                }
                            }
                            
                            // Account Selection
                            VStack(alignment: .leading, spacing: 16) {
                                Text("From Account")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 20)
                                
                                VStack(spacing: 0) {
                                    ForEach(accList.accounts) { acc in
                                        Button(action: { accId = acc.id }) {
                                            HStack {
                                                Image(systemName: accId == acc.id ? "checkmark.circle.fill" : "circle")
                                                    .foregroundColor(accId == acc.id ? .green : .gray)
                                                    .font(.system(size: 22))
                                                
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(acc.name)
                                                        .font(.system(size: 16, weight: accId == acc.id ? .semibold : .regular))
                                                        .foregroundColor(.primary)
                                                    
                                                    Text(acc.regText)
                                                        .font(.system(size: 13))
                                                        .foregroundColor(.secondary)
                                                }
                                                
                                                Spacer()
                                            }
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 12)
                                            .background(Color(UIColor.secondarySystemGroupedBackground))
                                        }
                                        
                                        if acc.id != accList.accounts.last?.id {
                                            Divider()
                                                .padding(.leading, 60)
                                        }
                                    }
                                }
                                .background(Color(UIColor.secondarySystemGroupedBackground))
                                .cornerRadius(12)
                                .padding(.horizontal, 20)
                            }
                            
                            // Video Toggle
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Call Options")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 20)
                                
                                Toggle(isOn: $withVideo) {
                                    HStack {
                                        Image(systemName: withVideo ? "video.fill" : "video.slash.fill")
                                            .foregroundColor(withVideo ? .blue : .gray)
                                            .font(.system(size: 18))
                                        
                                        Text("Enable Video")
                                            .font(.system(size: 16))
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 14)
                                .background(Color(UIColor.secondarySystemGroupedBackground))
                                .cornerRadius(10)
                                .padding(.horizontal, 20)
                            }
                            
                            // Call Button
                            Button(action: addCall) {
                                HStack {
                                    Image(systemName: "phone.fill")
                                    Text("Start Call")
                                        .fontWeight(.semibold)
                                }
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: isFormValid ?
                                            [Color.green, Color.green.opacity(0.8)] :
                                            [Color.gray.opacity(0.5), Color.gray.opacity(0.4)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                                .shadow(color: isFormValid ? Color.green.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
                            }
                            .disabled(!isFormValid)
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                            .alert("Can't add call", isPresented: $addCallAlert) {}
                                message: { Text(addCallErr) }
                        }
                        
                        Spacer(minLength: 20)
                    }
                }
            }
            .navigationTitle("New Call")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !ext.isEmpty && !accList.isEmpty
    }

    func addCall() {
        let dest = SiprixDestData()
        dest.toExt = ext
        dest.fromAccId = Int32(accId)
        dest.withVideo = NSNumber(value:withVideo)
        
        let errCode = SiprixModel.shared.callsListModel.invite(dest)
        
        if(errCode == kErrorCodeEOK) {
            self.presentationMode.wrappedValue.dismiss()
        } else {
            addCallErr = SiprixModel.shared.getErrorText(errCode)
            addCallAlert = true
        }
    }
    
}//CallAddView

///////////////////////////////////////////////////////////////////////////////////////////////////
///LogsListView

struct LogsListView: View {
    @StateObject private var logsModel : LogsModel
    
    init(_ model:LogsModel){
        self._logsModel = StateObject(wrappedValue: model)
    }
    
    var body: some View {
        TextEditor(text: .constant(logsModel.text))
            .textSelection(.enabled)
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
///ContentView

struct ContentView: View {
    @StateObject var accList = SiprixModel.shared.accountsListModel
    @StateObject var callsList = SiprixModel.shared.callsListModel
    @StateObject var networkModel = SiprixModel.shared.networkModel
    
    @State private var selectedTab = Tab.accounts
    enum Tab { case accounts, calls, history, settings, logs }
            
    var body: some View {
        TabView(selection: $selectedTab) {
            AccountsListView(accList)
                .tabItem {
                    Label("Accounts", systemImage: "person.crop.circle.fill")
                }
                .tag(Tab.accounts)
                .accessibilityLabel("Accounts tab")
            
            CallsListView(callsList)
                .tabItem {
                    Label("Calls", systemImage: "phone.fill")
                }
                .tag(Tab.calls)
                .badge(callsList.calls.count > 0 ? callsList.calls.count : nil)
                .accessibilityLabel("Calls tab\(callsList.calls.count > 0 ? ", \(callsList.calls.count) active calls" : "")")
            
            CallHistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
                .tag(Tab.history)
                .accessibilityLabel("Call history tab")
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(Tab.settings)
                .accessibilityLabel("Settings tab")
            
            LogsListView((SiprixModel.shared.logs==nil) ?
                         LogsModel() : SiprixModel.shared.logs!)
                .tabItem {
                    Label("Logs", systemImage: "doc.text.fill")
                }
                .tag(Tab.logs)
                .accessibilityLabel("Logs tab")
        }
        .onReceive(callsList.$switchedCallId, perform: { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedTab = .calls
            }
        })
        .overlay(alignment: .bottom) {
            if(networkModel.lost) {
                HStack(spacing: 8) {
                    Image(systemName: "wifi.slash")
                        .font(.system(size: 16))
                    Text("Network connection lost")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(Color.red)
                        .shadow(color: Color.red.opacity(0.3), radius: 8, x: 0, y: 4)
                )
                .padding(.bottom, 80)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: networkModel.lost)
                .accessibilityLabel("Network connection lost")
            }
        }
    }
    
}//ContentView


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

