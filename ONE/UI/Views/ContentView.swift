//
//  ContentView.swift
//  ONE
//
//  Created by Michael Fleps on 04.10.25.
//

import SwiftUI

/// Hauptansicht des ONE-Chats – verbindet Menüleiste, Gesprächsverlauf und Eingabefeld.
/// MVVM: ViewModel ist die Source of Truth, die View reagiert nur auf Zustandsänderungen.
struct ContentView: View {
    
    @FocusState private var isInputFocused: Bool              // Fokus für Tastatursteuerung
    @StateObject private var viewModel: ConversationViewModel // Source of Truth
    
    init() {
        _viewModel = StateObject(
            wrappedValue: ConversationViewModel(service: MockConversationService())
        )
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) { // Oben/links verankern
            Image("background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(spacing: 14) {
                TopBarView(
                    appLogoAsset: "logo",
                    appNameAsset: "onetext",
                    onToggleSidebar: { viewModel.toggleSidebar() },
                    onNewRound: { viewModel.createNewRound() }
                )
           
                ScrollViewReader { scrollProxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 20) { // ✅ LazyVStack performanter
                            ForEach(viewModel.currentSteps, id: \.id) { step in
                                VStack(alignment: .leading, spacing: 12) {
                                    UserPromptBubbleView(promptText: step.userPrompt)
                                        .frame( // ✅ Bubble darf NICHT die Gesamtbreite schrumpfen
                                            maxWidth: .infinity,
                                            alignment: .leading
                                        )
                                    
                                    StackedAgentCardsView(step: step)
                                        .frame( // ✅ Cards ebenfalls volle Breite erlauben
                                            maxWidth: .infinity,
                                            alignment: .leading
                                        )
                                }
                                .padding(.bottom, 164)
                                .id(step.id)
                                .frame( // ✅ jeder Step nimmt volle Breite ein
                                    maxWidth: .infinity,
                                    alignment: .leading
                                )
                            }
                        }
                        .frame( // ✅ ganzes Scroll-Content nimmt volle Breite ein
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        .padding(.horizontal, 12)
                        .padding(.top, 6)
                    }
                    .onChange(of: viewModel.currentLastStepId) {
                        if let stepId = viewModel.currentLastStepId {
                            withAnimation(.easeInOut) {
                                scrollProxy.scrollTo(stepId, anchor: .bottom)
                            }
                        }
                    }
                    .keyboardDismissable($isInputFocused) // nur Tap-Dismiss, kein Layout-Einfluss
                }
            }
            .frame( // ✅ Root-VStack zwingend auf Display-Breite/Höhe
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .topLeading
            )
            
            HistorySidebarView(
                rounds: viewModel.rounds,
                isOpen: $viewModel.isSidebarOpen,
                onSelect: { index in viewModel.selectRound(at: index) }
            )
        }
        .safeAreaInset(edge: .bottom) { // ✅ Eingabe sauber an Tastatur koppeln
            GlassCardInputField(
                text: $viewModel.inputText,
                isBusy: viewModel.isBusy,
                onSend: {
                    guard !viewModel.inputText
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                        .isEmpty
                    else { return }
                    
                    viewModel.runFreeFlowStep()
                    isInputFocused = true
                },
                isInputFocused: $isInputFocused
            )
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
        }
    }
}

#Preview("Content – Mockdaten, versetzte Agenten-Karten") {
    ContentView()
        .environment(\.colorScheme, .dark)
        .border(Color.red)
}
