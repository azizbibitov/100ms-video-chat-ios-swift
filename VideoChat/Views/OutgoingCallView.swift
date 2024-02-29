import SwiftUI
import HMSRoomModels

struct OutgoingCallView: View {
    
    @StateObject private var model = DataModel()
    @Binding var showVideoCallView: Bool
//    @EnvironmentObject var roomModel: HMSRoomModel
    
    var body: some View {
        ZStack {
            
            Image("video_ui")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
          
            bottomRightCameraPreview
            
            VStack(alignment: .center){
                
                Text("Caller Name")
                    .foregroundStyle(.white)
                    .font(.title)
                
                Spacer()
                
                HStack {
                    Button(action: {
                        model.camera.switchCaptureDevice()
                    }) {
                        Image("flip_camera")
                            .resizable()
                            .frame(width: 55, height: 55)
                            .foregroundColor(.red)
                        
                    }
                    
                    Button(action: self.endCall) {
                        Image("Reject")
                            .resizable()
                            .frame(width: 55, height: 55)
                            .foregroundColor(.red)
                        
                    }
                }
            }
            .padding(.top, 30)
            .padding(.bottom, 50)
            
           
            
        }
        .task {
            await model.camera.start()
        }
    }
    
    var bottomRightCameraPreview: some View {
        VStack(content: {
            Spacer()
            HStack {
                Spacer()
                ViewfinderView(image:  $model.viewfinderImage )
                    .frame(width: 100, height: 150)
                    .cornerRadius(10, corners: .allCorners)
            }
        })
        .padding(.horizontal)
        .padding(.vertical, 30)
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .onAppear {
            model.camera.switchCaptureDevice()
        }
    }
    
    func endCall() {
//        Task {
//            
//            switch roomModel.roomState {
//            case .notJoined:
//                print("")
//            case .inMeeting:
//                try await roomModel.leaveSession()
//            case .leftMeeting:
//                print("")
//            }
//        }
        self.showVideoCallView = false
    }
    
}
