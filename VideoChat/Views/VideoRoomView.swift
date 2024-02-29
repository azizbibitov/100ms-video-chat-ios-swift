import SwiftUI
import HMSRoomModels

struct VideoRoomView: View {
    
    @ObservedObject var roomModel: HMSRoomModel
    @EnvironmentObject var callManager: CallManager
    @Binding var showMakeVideoCall: Bool
    @State var localPeerInFullScreen = false
    @State var onlyOneParticipant: Bool = true
    
    init(roomCode: String, showMakeVideoCall: Binding<Bool>) {
        self._roomModel = ObservedObject(wrappedValue: HMSRoomModel(roomCode: roomCode))
        self._showMakeVideoCall = showMakeVideoCall
    }
    
    
    var body: some View {
        ZStack {
            
            switch roomModel.roomState {
            case .notJoined, .leftMeeting:
                
                Color("AppThemeColorTeal")
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    .edgesIgnoringSafeArea(.all)
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .foregroundColor(.white)
                
                controlBtns
                
            case .inMeeting:
                if !onlyOneParticipant {
                    ForEach(Array(roomModel.peerModels.enumerated()), id: \.element.id) { index, _ in
                        ZStack {
                            
                            if localPeerInFullScreen {
                                
                                if let localPeer = roomModel.peerModels.first(where: { $0.isLocal == true }) {
                                    if roomModel.isCameraMute {
                                        Image("profileUser")
                                            .resizable()
                                            .scaledToFill()
                                            .edgesIgnoringSafeArea(.all)
                                    }else{
                                        HMSVideoTrackView(peer: localPeer)
                                            .edgesIgnoringSafeArea(.all)
                                    }
                                    
                                }
                                
                                if let notLocalPeer = roomModel.peerModels.first(where: { $0.isLocal == false }) {
                                    VStack(content: {
                                        HStack {
                                            Spacer()
                                            HMSVideoTrackView(peer: notLocalPeer)
                                                .frame(width: 150, height: 230)
                                                .cornerRadius(10, corners: .allCorners)
                                                .onTapGesture {
                                                    localPeerInFullScreen.toggle()
                                                }
                                        }
                                        Spacer()
                                    })
                                    .padding(.horizontal)
                                    .padding(.vertical, 30)
                                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                                }
                                
                            }else{
                                if let notLocalPeer = roomModel.peerModels.first(where: { $0.isLocal == false }) {
                                    HMSVideoTrackView(peer: notLocalPeer)
                                        .edgesIgnoringSafeArea(.all)
                                }
                                
                                if let localPeer = roomModel.peerModels.first(where: { $0.isLocal == true }) {
                                    VStack(content: {
                                        HStack {
                                            Spacer()
                                            if roomModel.isCameraMute {
                                                Image("profileUser")
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 150, height: 230)
                                                    .clipped()
                                                    .cornerRadius(10, corners: .allCorners)
                                                    .onTapGesture {
                                                        localPeerInFullScreen.toggle()
                                                    }
                                            }else{
                                                HMSVideoTrackView(peer: localPeer)
                                                    .frame(width: 150, height: 230)
                                                    .cornerRadius(10, corners: .allCorners)
                                                    .onTapGesture {
                                                        localPeerInFullScreen.toggle()
                                                    }
                                            }
                                            
                                            
                                        }
                                        Spacer()
                                    })
                                    .padding(.horizontal)
                                    .padding(.vertical, 30)
                                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                                }
                            }
                            
                        }
                    }
                    
                    controlBtns
                }else{
                    Color("AppThemeColorTeal")
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                        .edgesIgnoringSafeArea(.all)
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .foregroundColor(.white)
                    
                    controlBtns
                }
                
                
                
            }
            
            
        }
        .onChange(of: roomModel.peerModels, perform: { newValue in
            print("peerModelsXXX", roomModel.peerModels)
            
            if onlyOneParticipant == false && roomModel.peerModels.count == 1 {
                leaveCall()
            }
            
            if roomModel.peerModels.count < 2 {
                self.onlyOneParticipant = true
            }else{
                self.onlyOneParticipant = false
            }
            
        })
        .navigationBarBackButtonHidden()
        .onAppear {
            Task {
                try await roomModel.joinSession(userName: "Aziz room iPhone 11")
                roomModel.toggleCamera()
                DispatchQueue.main.asyncAfter(deadline: .now() + 60 + 10) {
                    if roomModel.peerModels.count == 1 {
                        leaveCall()
                    }
                }
            }
        }
    }
    
    
    var controlBtns: some View {
        VStack {
            Spacer()
            
            HStack(spacing: 15) {
                Button {
                    roomModel.toggleMic()
                } label: {
                    ZStack {
                        Circle()
                            .foregroundColor(.blue)
                            .frame(width: 55, height: 55)
                        
                        Image(systemName: roomModel.isMicMute ? "mic.slash" : "mic")
                            .foregroundColor(.white)
                    }
                }
                
                Button {
                    roomModel.toggleCamera()
                } label: {
                    ZStack {
                        Circle()
                            .foregroundColor(.blue)
                            .frame(width: 55, height: 55)
                        
                        Image(systemName: roomModel.isCameraMute ? "video.slash" : "video")
                            .foregroundColor(.white)
                    }
                }
                
                Button(action: {
                    Task {
                        if !roomModel.isCameraMute {
                            try await roomModel.switchCamera()
                        }
                    }
                }) {
                    Image("flip_camera")
                        .resizable()
                        .frame(width: 55, height: 55)
                        .foregroundColor(.red)
                    
                }
                
                Button {
                    leaveCall()
                } label: {
                    ZStack {
                        Circle()
                            .foregroundColor(.blue)
                            .frame(width: 55, height: 55)
                        
                        Image(systemName: "phone.down.fill")
                            .foregroundColor(.red)
                    }
                }
            }
            
        }
        .padding(.bottom, 50)
    }
    
    func leaveCall() {
        Task {
            
            switch roomModel.roomState {
            case .notJoined:
                print("")
            case .inMeeting:
                try await roomModel.leaveSession()
            case .leftMeeting:
                print("")
            }
            self.endCall()
        }
    }
    
    func endCall() {
        if AppState.shared.pageToNavigationTo == "Incoming" {
            AppState.shared.pageToNavigationTo = nil
        }else{
            self.showMakeVideoCall = false
        }
        if let savedCallUUIDString = UserDefaults.standard.string(forKey: "SavedCallUUID"),
           let savedCallUUID = UUID(uuidString: savedCallUUIDString) {
            // Do something with the savedCallUUID
            print(savedCallUUID)
            UserDefaults.standard.removeObject(forKey: "SavedCallUUID")
            self.callManager.endCall(with: savedCallUUID) { error in
                if let error = error { print(error.localizedDescription) }
                else {
                    //                    self.hasActivateCall = false
                }
            }
        }
        
    }
    
}
