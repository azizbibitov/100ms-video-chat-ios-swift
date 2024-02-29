import SwiftUI

class VideoCallVM: ObservableObject {
    
    
    @Published var callState: CallState = .outgoing
    @Published var roomId: String = ""
    
    func getRoomId() {
        /// Making request to server for creating room and responsing with roomID
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            self.roomId = "dzu-pwri-uox"
            self.callState = .inMeeting
        }
        
    }
    
}

enum CallState {
    case inMeeting
    case outgoing
}

enum CallParticipant {
    case caller
    case receiver
}
