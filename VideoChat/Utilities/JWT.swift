import Foundation
import JWTKit
import JWTDecode

struct APNsPayload: JWTPayload {
    var iss: String
    var iat: Int
    
    func verify(using signer: JWTSigner) throws {
        
    }
}

func createJWT() throws -> String {
    
    
    /// extract pricateKey from .p8 file. For this use below command in terminal from your .p8 file directory to make it pem file:
    /// openssl pkcs8 -nocrypt -in AuthKey_6XG6X83U7H.p8 -out AuthKey.pem
    /// And open AuthKey.pem file with any Text Editing app
    
    let privateKey = """
        -----BEGIN PRIVATE KEY-----
        MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgzS6QSZJQcCdIg3Si
        2z2BRoNjzl2xUiwmcJlh+aZTTbqhRANCAASZ1jIgd8Iq7sCTXIyuoja2yxOnfL83
        yXNTLJ6pxnkNlXoJejSn6lV35Th+vFRGVFO3WUBP7OKB8lUxK2z6luhA
        -----END PRIVATE KEY-----
        """
    
    /// alg for Apple APNS should be ES256
    
    do {
        let signer = try JWTSigner.es256(key: .private(pem: privateKey))
        
        /// iss = teamId
        /// kid = p8 file key id
        let payload = APNsPayload(iss: "UUP4J7FZT4", iat: Int(Date().timeIntervalSince1970))
        let jwt = try signer.sign(payload, kid: JWKIdentifier(string: "6XG6X83U7H"))
        
        print("returnung created JWT:", jwt)
        return jwt
    } catch {
        print("Error creating JWT:", error)
        throw error
    }
    
}

func sendVoIPPush(to deviceToken: String, jwtToken: String) async throws {
    let configuration = URLSessionConfiguration.default
    let session = URLSession(configuration: configuration)
    
    /// device token is obtained in the pushRegistry method in the AppDelegate
    let url = URL(string: "https://api.development.push.apple.com/3/device/\(deviceToken)")!
    var request = URLRequest(url: url)
    
    request.httpMethod = "POST"
    request.addValue("bearer \(jwtToken)", forHTTPHeaderField: "authorization")
    /// .voip suffix should be added to the app's Bundle Id for apns-topic field
    request.addValue("com.goodground.datingApp.voip", forHTTPHeaderField: "apns-topic")
    request.addValue("10", forHTTPHeaderField: "apns-priority")
    request.addValue("voip", forHTTPHeaderField: "apns-push-type")
    
    let payload = ["aps": ["alert": "You have a call", "sound": "default"]]
    let jsonData = try JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted)
    request.httpBody = jsonData
    
    do {
        let (data, response) = try await session.data(for: request)
        debugPrint(response)
        print("utf8", String(data: data, encoding: .utf8) ?? "")
        if let httpResponse = response as? HTTPURLResponse {
            print("Status code: \(httpResponse.statusCode)")
        }
    } catch {
        print("Error: \(error)")
    }
}
