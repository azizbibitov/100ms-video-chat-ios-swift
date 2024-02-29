import UIKit
import PushKit
import CallKit

class AppDelegate: UIResponder, UIApplicationDelegate, PKPushRegistryDelegate {
    
    /// Controls calls using CXCallController, handling start/end, hold/unhold, mute/unmute, and transaction requests. Tracks active calls with call UUIDs
    let callManager = CallManager()
    
    /// Manages CallKit events and actions for incoming/outgoing calls, audio session, and error handling.
    var providerDelegate: ProviderDelegate?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let voipRegistry = PKPushRegistry(queue: DispatchQueue.main)
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [PKPushType.voIP]
        
        providerDelegate = ProviderDelegate(callManager: callManager)
        
        
        return true
    }
    

    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        let callUUID = UUID()
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload.dictionaryPayload, options: .prettyPrinted)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("didReceiveIncomingPushWith JSON:", jsonString)
            }
        } catch {
            print("Error converting payload to JSON:", error)
        }
        UserDefaults.standard.set(callUUID.uuidString, forKey: "SavedCallUUID")
        self.providerDelegate?.reportIncomingCall(with: callUUID, remoteUserID: "Aziz Bibitov", hasVideo: true, roomId: "dzu-pwri-uox")
        
    }




    
    /// This method is called when the push credentials are updated
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        let deviceToken = pushCredentials.token.map { String(format: "%02x", $0) }.joined()
        print("deviceToken===", deviceToken)
    }
    
    
    func providerDidReset(_ provider: CXProvider) {
        
    }
    
}




/// Helps Navigate to Call UI and return back when Incoming Call is received
class AppState: ObservableObject {
    static let shared = AppState()
    @Published var pageToNavigationTo : String?
    @Published var roomId : String?
}
