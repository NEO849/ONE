//
//  ContentView.swift
//  ONE
//
//  Created by Michael Fleps on 04.10.25.
//

import SwiftUI

/// Hauptansicht des ONE-Chats – verbindet Menüleiste, Verlauf (Steps) und Eingabefeld.
struct ContentView: View {
    
    // Fokus für das Eingabefeld (steuert Tastatur)
    @FocusState private var isInputFocused: Bool
    @StateObject private var viewModel: ConversationViewModel
    
    init() {
        _viewModel = StateObject(
            wrappedValue: ConversationViewModel(service: MockConversationService())
        )
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image("background")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Menüleiste (bleibt immer sichtbar)
                    TopBarView(
                        appLogoAsset: "logo",
                        appNameAsset: "onetext",
                        onToggleSidebar: { viewModel.toggleSidebar() },
                        onNewRound: { viewModel.createNewRound() }
                    )
                    //                    .padding(.top, geo.safeAreaInsets.top + 8)
                    .padding(.bottom, 14)
                    
                    //                    Divider().background(Color.white)
                    // Scrollbarer Gesprächsverlauf (Steps)
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(alignment: .leading, spacing: 20) {
                                ForEach(viewModel.currentSteps, id: \.id) { step in
                                    VStack(alignment: .leading, spacing: 12) {
                                        UserPromptBubbleView(promptText: step.userPrompt)
                                        StackedAgentCardsView(step: step)
                                    }
                                    .padding(.bottom, 164)
                                    .id(step.id)
                                }
                            }
                            //    .padding(.bottom, 16)
                        }
                        .onChange(of: viewModel.currentLastStepId) {
                            if let stepId = viewModel.currentLastStepId {
                                withAnimation(.easeInOut) {
                                    proxy.scrollTo(stepId, anchor: .bottom)
                                }
                            }
                        }
                        .keyboardDismissable($isInputFocused) // ✅ Modifier zum Schließen
                    }
                    
                    // Eingabefeld – immer ganz unten über der Tastatur sichtbar
                    GlassCardInputField(
                        text: $viewModel.inputText,
                        isBusy: viewModel.isBusy,
                        onSend: {
                            guard !viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                            viewModel.runFreeFlowStep()
                            isInputFocused = false
                        },
                        isInputFocused: $isInputFocused
                    )
                    .padding(.bottom, 8)
                }
                .padding(.horizontal, 16) // Zentrales  Padding
                .padding(.trailing, 114)
                
                // Sidebar als Overlay
                HistorySidebarView(
                    rounds: viewModel.rounds,
                    isOpen: $viewModel.isSidebarOpen,
                    onSelect: { index in viewModel.selectRound(at: index) }
                )
            }
            .ignoresSafeArea(.keyboard) // Verhindert verschieben
        }
    }
}

#Preview("Content – Mockdaten, versetzte Agenten-Karten") {
    ContentView()
        .environment(\.colorScheme, .dark)
}
