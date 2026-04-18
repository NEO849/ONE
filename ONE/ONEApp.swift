//
//  ONEApp.swift
//  ONE
//
//  Created by Michael Fleps on 04.10.25.
//

import SwiftUI

/// App-Einstieg.
/// Entscheidet beim Start:
/// - Alle vier API-Keys im Keychain → RealConversationService
/// - Fehlende Keys → MockConversationService + OnboardingView als fullScreenCover
@main
struct OneApp: App {

    @StateObject private var conversationViewModel: ConversationViewModel
    @State private var showOnboarding: Bool

    init() {
        let keysPresent = SecureKeyManager.allKeysPresent()
        let initialService: ConversationProtocol = keysPresent
            ? RealConversationService()
            : MockConversationService()
        _conversationViewModel = StateObject(
            wrappedValue: ConversationViewModel(service: initialService)
        )
        _showOnboarding = State(initialValue: !keysPresent)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(conversationViewModel)
                .fullScreenCover(isPresented: $showOnboarding) {
                    // Nach erfolgreichem Onboarding: auf echten Service wechseln
                    OnboardingView {
                        conversationViewModel.updateService(RealConversationService())
                        showOnboarding = false
                    }
                }
        }
    }
}
