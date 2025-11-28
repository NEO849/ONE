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

/// Klassischer Chat-Screen wie WhatsApp/ChatGPT.
/// Konzept (Profi-Standard):
/// 1) TopBar oben fix.
/// 2) ScrollView darunter.
/// 3) InputBar unten als safeAreaInset (folgt Tastatur).
/// 4) In der ScrollView gibt es einen Bottom-Anker + Platz in Höhe der InputBar,
///    damit die letzte Bubble niemals „hinter“ InputBar/Tastatur verschwindet.
struct ContentView: View {
    
    // Tastatur-Fokus (öffnet/schließt Keyboard)
    @FocusState private var isInputFocused: Bool
    // ViewModel als @StateObject – bleibt über Rebuilds bestehen
    @StateObject private var viewModel: ConversationViewModel
    // Keyboard-Observer zur dynamischen Höhenanpassung
    @StateObject private var keyboard = KeyboardObserver()

    // Globale Layoutwerte für konsistentes Design
    private let layoutPaddingHorizontal: CGFloat = 32  // Horizontaler Rahmen für gesamte Ansicht
    private let inputPaddingHorizontal: CGFloat = 16   // Extra Rahmen für Eingabezeile

    init() {
        _viewModel = StateObject(
            wrappedValue: ConversationViewModel(service: MockConversationService())
        )
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                // Hintergrundbild – Fullscreen & Edge-to-Edge
                Image("background")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // 🔹 TopBar – feste obere Leiste
                    TopBarView(
                        appLogoAsset: "logo",
                        appNameAsset: "onetext",
                        onToggleSidebar: { viewModel.toggleSidebar() },
                        onNewRound: { viewModel.createNewRound() }
                    )
                    .padding(.top, 14) // Abstand zum Notch
                    .padding(.trailing, 130)
                    .padding(.leading, 28)
                    .padding(.bottom, 14)

                    // 🔹 Nachrichtenliste (extrahiert in separate View)
                    ChatMessageListView(
                        steps: viewModel.currentSteps,
                        isInputFocused: isInputFocused,
                        bottomScrollTriggerValue: viewModel.currentSteps.count
                    )
                    
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .keyboardDismissable($isInputFocused)

                // 🔹 Seitenleiste (Overlay)
                HistorySidebarView(
                    rounds: viewModel.rounds,
                    isOpen: $viewModel.isSidebarOpen,
                    onSelect: { index in viewModel.selectRound(at: index) }
                )
            }
            .ignoresSafeArea(.keyboard, edges: .bottom) // Tastatur darf nur unten überlagern
            .overlay(alignment: .bottom) {
                VStack(spacing: 0) {
                    GlassCardInputField(
                        text: $viewModel.inputText,
                        isBusy: viewModel.isBusy,
                        onSend: {
                            let trimmedText = viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !trimmedText.isEmpty else { return }
                            viewModel.runFreeFlowStep()
                            isInputFocused = false
                        },
                        isInputFocused: $isInputFocused
                    )
                }
                .padding(.bottom, keyboard.keyboardHeight)
                .animation(.easeOut(duration: keyboard.animationDuration), value: keyboard.keyboardHeight)
            }
            .onAppear { keyboard.startObserving() }
            .onDisappear { keyboard.stopObserving() }
        }
    }
}


#Preview("Content – Mockdaten, versetzte Agenten-Karten") {
    ContentView()
        .environment(\.colorScheme, .dark)
        .border(Color.red)
}
