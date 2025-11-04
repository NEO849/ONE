//
//  ContentView.swift
//  ONE
//
//  Created by Michael Fleps on 04.10.25.
//

import SwiftUI

///  Screen-Composer – verbindet TopBar, Sidebar, Steps (mit Karten) & Eingabe.
/// Beziehungen:
/// - Hält "ConversationViewModel" als @StateObject (eine Quelle der Wahrheit).
/// - Vertikales Scrollen mit stabilen IDs + optionalem Auto-Scroll zum letzten Step.
struct ContentView: View {
    
    @StateObject private var viewModel: ConversationViewModel
    
    init() {
        _viewModel = StateObject(wrappedValue: ConversationViewModel(service: MockConversationService()))
    }
    
    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // TOP: Menüleiste
                TopBarView(
                    appLogoAsset: "logo",
                    appNameAsset: "onetext",
                    onToggleSidebar: { viewModel.toggleSidebar() },
                    onNewRound: { viewModel.createNewRound() }
                )
                
                // MITTE: Steps der aktuellen Runde – stabil & auto-scrollbar
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Helper "currentSteps"
                            ForEach(viewModel.currentSteps, id: \.id) { (step: ChatStep) in
                                VStack(alignment: .leading, spacing: 12) {
                                    UserPromptBubbleView(promptText: step.userPrompt)
                                    StackedAgentCardsView(step: step)
                                }
                                .padding(.horizontal, 12)
                                .id(step.id) // stabile ID für Scroll-Anchor
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    // Auto-Scroll auf Basis der ID des letzten Steps
                    .onChange(of: viewModel.currentLastStepId) {
                        if let stepId = viewModel.currentLastStepId {
                               withAnimation(.easeInOut) {
                                   proxy.scrollTo(stepId, anchor: .bottom)
                               }
                           }
                       }
                }
                
                // UNTEN: Eingabe (Free-Flow)
                HStack(spacing: 12) {
                    TextField("User prompt …", text: $viewModel.inputText, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                    
                    Button(action: { viewModel.runFreeFlowStep() }) {
                        Text(viewModel.isBusy ? "Running…" : "Send")
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.isBusy || viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(12)
                .glassCard(cornerRadius: 16)
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
            }
            
            // LINKER OVERLAY: Sidebar mit History
            HistorySidebarView(
                rounds: viewModel.rounds,
                isOpen: $viewModel.isSidebarOpen,
                onSelect: { indexValue in viewModel.selectRound(at: indexValue) }
            )
        }
        .ignoresSafeArea(.keyboard)
    }
}

#Preview("Content – Mockdaten, versetzte Agenten-Karten") {
    ContentView()
        .environment(\.colorScheme, .dark)
}
