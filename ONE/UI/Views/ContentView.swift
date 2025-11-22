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
    
    @FocusState private var isInputFocused: Bool
    @StateObject private var viewModel: ConversationViewModel
    
    init() {
        _viewModel = StateObject(
            wrappedValue: ConversationViewModel(service: MockConversationService())
        )
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            
            Image("background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                TopBarView(
                    appLogoAsset: "logo",
                    appNameAsset: "onetext",
                    onToggleSidebar: { viewModel.toggleSidebar() },
                    onNewRound: { viewModel.createNewRound() }
                )
                .padding(.horizontal, 42)
                .padding(.top, 8)
                .padding(.bottom, 14)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Chat-Verlauf
                ScrollViewReader { scrollProxy in
                    ScrollView(showsIndicators: false) {
                        LazyVStack(alignment: .leading, spacing: 20) {
                            ForEach(viewModel.currentSteps, id: \.id) { step in
                                VStack(alignment: .leading, spacing: 12) {
                                    UserPromptBubbleView(promptText: step.userPrompt)
                                    StackedAgentCardsView(step: step)
                                }
                                .padding(.bottom, 164)
                                .id(step.id)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding(.horizontal, 42)
                        .padding(.top, 6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .onChange(of: viewModel.currentLastStepId) {
                        if let stepId = viewModel.currentLastStepId {
                            withAnimation(.easeInOut) {
                                scrollProxy.scrollTo(stepId, anchor: .bottom)
                            }
                        }
                    }
                    .scrollDismissesKeyboard(.immediately)
                    .ignoresSafeArea(.keyboard)              // ScrollView ignoriert Keyboard
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .keyboardDismissable($isInputFocused)           // Tap außerhalb -> Tastatur zu
            
            // Sidebar als Overlay
            HistorySidebarView(
                rounds: viewModel.rounds,
                isOpen: $viewModel.isSidebarOpen,
                onSelect: { index in viewModel.selectRound(at: index) }
            )
        }
        .safeAreaInset(edge: .bottom) {
            GlassCardInputField(
                text: $viewModel.inputText,
                isBusy: viewModel.isBusy,
                onSend: {
                    guard !viewModel.inputText
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                        .isEmpty
                    else { return }
                    
                    viewModel.runFreeFlowStep()
                    isInputFocused = false // ✅ Send-Button schließt Tastatur
                },
                isInputFocused: $isInputFocused
            )
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
            .background(.clear)
        }
    }
}

#Preview("Content – Mockdaten, versetzte Agenten-Karten") {
    ContentView()
        .environment(\.colorScheme, .dark)
        .border(Color.red)
}
