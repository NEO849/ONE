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
    
    // Fokus für das Eingabefeld (steuert Tastatur)
    @FocusState private var isInputFocused: Bool
    
    // ViewModel bleibt in der obersten View als Source of Truth
    @StateObject private var viewModel: ConversationViewModel
    
    init() {
        _viewModel = StateObject(
            wrappedValue: ConversationViewModel(service: MockConversationService())
        )
    }
    
    var body: some View {
        GeometryReader { geometryProxy in // geometryProxy statt "geo", damit Name >= 4 Zeichen
            ZStack(alignment: .top) { // 🔹 Wichtig: ZStack oben ausrichten, nicht zentrieren
                Image("background")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea() // Background darf komplett hinter alles
                
                VStack(spacing: 0) {
                    // Menüleiste oben
                    TopBarView(
                        appLogoAsset: "logo",
                        appNameAsset: "onetext",
                        onToggleSidebar: { viewModel.toggleSidebar() },
                        onNewRound: { viewModel.createNewRound() }
                    )
                    .padding(.top, geometryProxy.safeAreaInsets.top) // 🔹 Safe-Area oben sauber berücksichtigen
                    .padding(.bottom, 14)
                    
                    // Scrollbarer Gesprächsverlauf
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
                        }
                        .onChange(of: viewModel.currentLastStepId) {
                            if let stepId = viewModel.currentLastStepId {
                                withAnimation(.easeInOut) {
                                    proxy.scrollTo(stepId, anchor: .bottom)
                                }
                            }
                        }
                        .keyboardDismissable($isInputFocused) // ✅ Nur Tap zum Schließen, beeinflusst Layout nicht
                    }
                    
                    // Eingabefeld unten – wird über safeAreaInset sauber an Tastatur gekoppelt
                }
                .frame( // 🔹 EXTREM wichtig: VStack auf volle Breite/Höhe zwingen
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .top
                )
            }
            // Eingabefeld als Safe-Area-Inset → bleibt automatisch über Tastatur
            .safeAreaInset(edge: .bottom) {
                GlassCardInputField(
                    text: $viewModel.inputText,
                    isBusy: viewModel.isBusy,
                    onSend: {
                        // Guard verhindert leere Nachrichten
                        guard !viewModel.inputText
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                            .isEmpty
                        else { return }
                        
                        viewModel.runFreeFlowStep() // VM macht Logik
                        isInputFocused = true       // Fokus bleibt für schnelle Folgeeingabe
                    },
                    isInputFocused: $isInputFocused
                )
                .padding(.horizontal, 12) // 🔹 Gleichmäßige Seitenabstände
                .padding(.bottom, 8)
                .background(.clear)
            }
        }
    }
}
#Preview("Content – Mockdaten, versetzte Agenten-Karten") {
    ContentView()
        .environment(\.colorScheme, .dark)
}
