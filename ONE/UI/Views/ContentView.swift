//
//  ContentView.swift
//  ONE
//
//  Created by Michael Fleps on 04.10.25.
//

import SwiftUI
import Combine

/// Hauptansicht des ONE-Chats – verbindet Menüleiste, Gesprächsverlauf und Eingabefeld.
/// MVVM: ViewModel ist die Source of Truth, die View reagiert nur auf Zustandsänderungen.


struct ContentView: View {

    @FocusState private var isInputFocused: Bool                                                       // Fokus steuert Tastatur

    @EnvironmentObject private var conversationViewModel: ConversationViewModel                        // Source of Truth zentral

    private let layoutPaddingHorizontal: CGFloat = 32                                                  // Einheitlicher Seitenabstand
    private let topbarPaddingVertical: CGFloat = 12                                                    // Vertikaler Abstand TopBar
    private let inputbarPaddingVertical: CGFloat = 10                                                  // Vertikaler Abstand InputBar

    var body: some View {
        ZStack(alignment: .leading) {
            Image("background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()                                                                     // Background darf full-screen sein

            ChatMessageListView(
                steps: conversationViewModel.currentSteps,
                isInputFocused: isInputFocused,
                bottomScrollTriggerValue: conversationViewModel.currentSteps.count
            )
            .padding(.horizontal, layoutPaddingHorizontal)                                              // Ein Ort für horizontales Layout
        }
        .keyboardDismissable($isInputFocused)                                                           // Tap -> Tastatur schließen

        // ✅ TopBar sitzt im SafeArea-Top und wird NICHT vom Keyboard beeinflusst
        .safeAreaInset(edge: .top, spacing: 0) {
            TopBarView(
                appLogoAsset: "logo",
                appNameAsset: "onetext",
                onToggleSidebar: { conversationViewModel.toggleSidebar() },
                onNewRound: { conversationViewModel.createNewRound() }
            )
            .padding(.horizontal, layoutPaddingHorizontal)                                              // Gleiche Kante wie Content
            .padding(.vertical, topbarPaddingVertical)
        }

        // ✅ InputBar sitzt automatisch DIREKT über dem Keyboard (ohne Observer!)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            GlassCardInputField(
                text: $conversationViewModel.inputText,
                isBusy: conversationViewModel.isBusy,
                onSend: {
                    let trimmedTextValue = conversationViewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines) // Input bereinigen
                    guard !trimmedTextValue.isEmpty else { return }                                       // Guard: nicht leer senden
                    conversationViewModel.runFreeFlowStep()                                               // VM macht die Logik
                    isInputFocused = false                                                                 // Tastatur zu nach Senden
                },
                isInputFocused: $isInputFocused
            )
            .padding(.horizontal, layoutPaddingHorizontal)                                             // gleiche Kante wie Topbar
            .padding(.vertical, inputbarPaddingVertical)                                               // kleiner Abstand – sitzt nah am Keyboard
        }
    }
}


#Preview("Content – Mockdaten, versetzte Agenten-Karten") {
    ContentView()
        .environmentObject(ConversationViewModel(service: MockConversationService()))
        .environment(\.colorScheme, .dark)
        .border(Color.red)
}
