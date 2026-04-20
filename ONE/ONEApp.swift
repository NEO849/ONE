//
//  ONEApp.swift
//  ONE
//
//  Created by Michael Fleps on 04.10.25.
//

import SwiftUI

/// App-Einstieg.
/// DEBUG:   Immer MockConversationService – Simulator zeigt sofort Mockdaten.
/// RELEASE: Keys prüfen → Real- oder MockService + ggf. Onboarding.
@main
struct OneApp: App {

    @StateObject private var conversationViewModel: ConversationViewModel
    @State private var showOnboarding: Bool

    init() {
        #if DEBUG
        DeveloperKeyInjector.injectIfNeeded()
        _conversationViewModel = StateObject(
            wrappedValue: ConversationViewModel(service: MockConversationService())
        )
        _showOnboarding = State(initialValue: false)
        #else
        let keysPresent = SecureKeyManager.allKeysPresent()
        let initialService: ConversationProtocol = keysPresent
            ? RealConversationService()
            : MockConversationService()
        _conversationViewModel = StateObject(
            wrappedValue: ConversationViewModel(service: initialService)
        )
        _showOnboarding = State(initialValue: !keysPresent)
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(conversationViewModel)
                .fullScreenCover(isPresented: $showOnboarding) {
                    OnboardingView {
                        PersistenceManager.clearRounds()
                        conversationViewModel.updateService(RealConversationService())
                        showOnboarding = false
                    }
                }
        }
    }
}
