import AVFoundation
import UIKit
import CallKit

typealias ErrorHandler = ((NSError?) -> ())

class ProviderDelegate: NSObject, CXProviderDelegate {
    
    let callManager: CallManager
    private let provider: CXProvider
    private(set) var roomId: String = ""
    
    init(callManager: CallManager) {
        self.callManager = callManager
        provider = CXProvider.custom
        super.init()
        provider.setDelegate(self, queue: nil)
    }
    
    func reportIncomingCall(with uuid: UUID, remoteUserID: String, hasVideo: Bool, completionHandler: ErrorHandler? = nil, roomId: String) {
        
        let update = CXCallUpdate()
        update.update(with: remoteUserID, hasVideo: hasVideo, incoming: true)
       
        provider.reportNewIncomingCall(with: uuid, update: update) { error in
            guard error == nil else {
                completionHandler?(error as NSError?)
                return
            }
            
            if error == nil {
                /// Save UUID in UserDefaults for further removing from CallManager when Ending Call
                UserDefaults.standard.set(uuid.uuidString, forKey: "SavedCallUUID")
            }
            self.roomId = roomId
            self.callManager.addCall(uuid: uuid)
        }
    }
    
    func reportIncomingCall(with uuid: UUID) {
        // Update call based on DirectCall object
        let update = CXCallUpdate()
        update.onFailed(with: uuid)
        
        provider.reportNewIncomingCall(with: uuid, update: update) { error in
            self.provider.reportCall(with: uuid, endedAt: Date(), reason: .failed)
        }
    }
    
    func endCall(with uuid: UUID, endedAt: Date, reason: CXCallEndedReason) {
        self.provider.reportCall(with: uuid, endedAt: endedAt, reason: reason)
    }
    
    func connectedCall(with uuid: UUID) {
        self.provider.reportOutgoingCall(with: uuid, connectedAt: Date())
    }
    
    
    
    func providerDidReset(_ provider: CXProvider) {
        self.callManager.removeAllCalls()
    }
    
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        self.callManager.addCall(uuid: action.callUUID)
        self.connectedCall(with: action.callUUID)
        
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        
        action.fulfill()
        
        print("CXAnswerCallAction====")
        AppState.shared.roomId = self.roomId
        NotificationCenter.default.post(name: NSNotification.Name.DidCallAccepted, object: nil)
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        
        action.fulfill()
        print("CXEndCallAction====")
        self.callManager.removeAllCalls()
        provider.reportCall(with: action.uuid, endedAt: nil, reason: CXCallEndedReason.remoteEnded)
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        // update holding state
        switch action.isOnHold {
        case true:
            // Stop audio
            // Stop video
            action.fulfill()
        case false:
            // Play audio
            // Play video
            action.fulfill()
        }
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {

        // Stop / start audio by using `action.isMuted`
        
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        // Start audio
    }
    
    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        // Restart any non-call related audio now that the app's audio session has been
        // de-activated after having its priority restored to normal.
    }
}


extension CXProvider {
    // To ensure initializing only at once. Lazy stored property doesn't ensure it.
    static var custom: CXProvider {
        
        // Configure provider with sendbird's customzied configuration.
        let configuration = CXProviderConfiguration.custom
        let provider = CXProvider(configuration: configuration)
        
        return provider
    }
}

extension CXProviderConfiguration {
    
    static var custom: CXProviderConfiguration {
        let configuration = CXProviderConfiguration()
    
        configuration.supportsVideo = true
        configuration.maximumCallsPerCallGroup = 1
        
        configuration.supportedHandleTypes = [.generic]
        
        if let iconImage = UIImage(named: "AppIcon") {
            configuration.iconTemplateImageData = iconImage.pngData()
        }
        
        return configuration
    }
}


extension CXCallUpdate {
    func update(with username: String, hasVideo: Bool, incoming: Bool) {
        let remoteHandle = CXHandle(type: .generic, value: username)
        self.remoteHandle = remoteHandle
        self.localizedCallerName = username
        self.hasVideo = hasVideo
    }
    
    func onFailed(with uuid: UUID) {
        let remoteHandle = CXHandle(type: .generic, value: "Unknown")
        self.remoteHandle = remoteHandle
        self.localizedCallerName = "Unknown"
        self.hasVideo = false
    }
}
