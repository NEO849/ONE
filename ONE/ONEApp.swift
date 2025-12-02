//
//  ONEApp.swift
//  ONE
//
//  Created by Michael Fleps on 04.10.25.
//

import SwiftUI

@main
struct OneApp: App {

    @StateObject private var conversationViewModel = ConversationViewModel(service: MockConversationService()) // Source of Truth

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(conversationViewModel)                                              // Alle Views greifen auf gleiche VM zu
        }
    }
}
