//
//  ONEApp.swift
//  ONE
//
//  Created by Michael Fleps on 04.10.25.
//

import SwiftUI

/// App-Einstieg.
/// Ablauf beim Start:
///   1. DEBUG: DeveloperKeyInjector füllt Keychain aus Scheme-Env-Vars (einmalig)
///   2. SecureKeyManager prüft ob alle 4 Keys vorhanden sind
///   3. Keys vorhanden → RealConversationService
///      Keys fehlen   → MockConversationService + OnboardingView als fullScreenCover
@main
struct OneApp: App {

    @StateObject private var conversationViewModel: ConversationViewModel
    @State private var showOnboarding: Bool

    init() {
        // Entwickler-Keys aus Xcode Scheme → Keychain (nur DEBUG, nie RELEASE)
        #if DEBUG
        DeveloperKeyInjector.injectIfNeeded()
        #endif

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
                    OnboardingView {
                        // Mock-Daten verwerfen, dann echten Service starten
                        PersistenceManager.clearRounds()
                        conversationViewModel.updateService(RealConversationService())
                        showOnboarding = false
                    }
                }
        }
    }
}
