//
//  ContentView.swift
//  VideoChat
//
//  Created by Aziz Bibitov on 27.02.2024.
//

import SwiftUI

struct ContentView: View {
    
    @State var showMakeVideoCall: Bool = false
    @State var showAcceptVideoCallScreen: Bool = false
    @EnvironmentObject var callManager: CallManager
    @ObservedObject var appState = AppState.shared
    let acceptPublishser = NotificationCenter.default
        .publisher(for: Notification.Name.DidCallAccepted)
    
    var body: some View {
        VStack {
            Button {
                print("video call")
                Task {
                    await sendVoip()
                }
                self.startCall()
            } label: {
                Text("Call")
                    .foregroundStyle(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(5)
            }
            
          
            
        }
        .onReceive(self.acceptPublishser) { _ in
            self.showAcceptVideoCallScreen = true
        }
        .fullScreenCover(isPresented: $showAcceptVideoCallScreen) {
            VideoRoomView(roomCode: AppState.shared.roomId ?? "", showMakeVideoCall: $showAcceptVideoCallScreen)
        }
        .fullScreenCover(isPresented: $showMakeVideoCall) {
            VideoCallView(showVideoCallView: $showMakeVideoCall)
        }
    }
    
    
    func sendVoip() async {
        do {
            // Step 1: Generate JWT token
            let jwtToken = try createJWT()

            // Step 2: Send VoIP push notification
            try await sendVoIPPush(to: "4cecbb6cec902e88054f1fba6a71d176e0d8ffae9dacf4d1e5215d0ed57b2517", jwtToken: jwtToken)
        } catch {
            print("Error: \(error)")
        }

    }
    
    func startCall() {
        self.showMakeVideoCall = true
    }
    
}

struct VideoCallView: View {
    
    @ObservedObject var videoCallVM = VideoCallVM()
    @Binding var showVideoCallView: Bool
    
    var body: some View {
        ZStack {
            
            switch videoCallVM.callState {
            case .inMeeting:
                VideoRoomView(roomCode: videoCallVM.roomId, showMakeVideoCall: $showVideoCallView)
            case .outgoing:
                OutgoingCallView(showVideoCallView: $showVideoCallView)
            }
            
            
        }
        .onAppear {
            videoCallVM.getRoomId()
        }
    }
}

extension Notification.Name {
    static let DidCallEnd = Notification.Name("DidCallEnd")
    
    static let DidCallAccepted = Notification.Name("DidCallAccepted")
}

class NavigationController: ObservableObject {
    @Published var path: [NavigationType] = []
}

/// - Note: (doni) This can be used for other views where programmatic navigation is needed
enum NavigationType: Hashable {
    case editProfileView
}


