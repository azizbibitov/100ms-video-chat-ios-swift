//
//  VideoChatApp.swift
//  VideoChat
//
//  Created by Aziz Bibitov on 27.02.2024.
//

import SwiftUI

@main
struct VideoChatApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(CallManager.shared)
        }
    }
}
