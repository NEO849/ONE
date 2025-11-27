//
//  ContentView.swift
//  ONE
//
//  Created by Michael Fleps on 04.10.25.
//

import SwiftUI

/// Hauptansicht des ONE-Chats – verbindet Menüleiste, Gesprächsverlauf und Eingabefeld.
/// MVVM: ViewModel ist die Source of Truth, die View reagiert nur auf Zustandsänderungen.
import SwiftUI

/// Klassischer Chat-Screen wie WhatsApp/ChatGPT.
/// Konzept (Profi-Standard):
/// 1) TopBar oben fix.
/// 2) ScrollView darunter.
/// 3) InputBar unten als safeAreaInset (folgt Tastatur).
/// 4) In der ScrollView gibt es einen Bottom-Anker + Platz in Höhe der InputBar,
///    damit die letzte Bubble niemals „hinter“ InputBar/Tastatur verschwindet.
struct ContentView: View {
    
    @FocusState private var isInputFocused: Bool                                       // Tastatur Fokus
    @StateObject private var viewModel: ConversationViewModel                          // Source of Truth
    
    // Wenige, klare Abstände (kein Padding-Chaos)
    private let layoutPaddingHorizontalValue: CGFloat = 42                             // TopBar + Chat Kante
    private let inputPaddingHorizontalValue: CGFloat = 12                              // InputBar Kante
    private let bottomGapExtraValue: CGFloat = 12                                      // kleine Luft über InputBar
    
    // InputBar-Höhe (messen wir), damit ScrollView unten Platz bekommt
    @State private var inputBarHeightValue: CGFloat = 0                                // dynamische Höhe der InputBar
    
    // Feste ID für den unteren Scroll-Anker (immer vorhanden, nie nil)
    private let bottomAnchorIdentifier: String = "bottomAnchorIdentifier"              // stabile ScrollTo-ID
    
    init() {
        _viewModel = StateObject(
            wrappedValue: ConversationViewModel(service: MockConversationService())    // Service-Injektion
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
                    onToggleSidebar: { viewModel.toggleSidebar() },                    // Logik im VM
                    onNewRound: { viewModel.createNewRound() }                         // Logik im VM
                )
                .padding(.horizontal, layoutPaddingHorizontalValue)                    // einheitliche Kante
                .padding(.top, 8)
                .padding(.bottom, 14)
                .frame(maxWidth: .infinity, alignment: .leading)                       // verhindert Zentrier-Sprünge
                
                ScrollViewReader { scrollProxy in                                      // ScrollController
                    ScrollView(showsIndicators: false) {
                        LazyVStack(alignment: .leading, spacing: 20) {
                            
                            // Chat-Inhalt
                            ForEach(viewModel.currentSteps, id: \.id) { stepValue in
                                VStack(alignment: .leading, spacing: 12) {
                                    UserPromptBubbleView(promptText: stepValue.userPrompt)
                                    StackedAgentCardsView(step: stepValue)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)      // stabil links
                            }
                            
                            // ✅ Bottom-Anker + Platz für InputBar
                            Color.clear
                                .frame(height: inputBarHeightValue + bottomGapExtraValue) // Platz reservieren
                                .id(bottomAnchorIdentifier)                               // fester Anker
                        }
                        .padding(.horizontal, layoutPaddingHorizontalValue)            // gleiche Kante wie TopBar
                        .padding(.top, 6)
                    }
                    .scrollDismissesKeyboard(.immediately)                              // Scroll -> Tastatur schließen
                    
                    // Wenn neue Nachricht kommt -> ans Ende
                    .onChange(of: viewModel.currentSteps.count) { _ in
                        scrollToBottom(scrollProxy: scrollProxy)                        // zuverlässig zum Anker
                    }
                    
                    // Wenn Tastatur aufgeht -> ans Ende (damit Bubble sichtbar bleibt)
                    .onChange(of: isInputFocused) { isFocusedValue in
                        guard isFocusedValue else { return }                            // nur beim Öffnen
                        DispatchQueue.main.async {                                      // nach Layout-Update scrollen
                            scrollToBottom(scrollProxy: scrollProxy)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .keyboardDismissable($isInputFocused)                                       // Tippen außerhalb -> Tastatur zu
            
            HistorySidebarView(
                rounds: viewModel.rounds,
                isOpen: $viewModel.isSidebarOpen,
                onSelect: { indexValue in viewModel.selectRound(at: indexValue) }
            )
        }
        .safeAreaInset(edge: .bottom) {
            GlassCardInputField(
                text: $viewModel.inputText,
                isBusy: viewModel.isBusy,
                onSend: {
                    let trimmedTextValue = viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmedTextValue.isEmpty else { return }
                    
                    viewModel.runFreeFlowStep()
                    isInputFocused = false                                              // Tastatur schließen
                },
                isInputFocused: $isInputFocused
            )
            .padding(.horizontal, inputPaddingHorizontalValue)
            .padding(.bottom, 8)
            .background(
                GeometryReader { geometryProxy in
                    Color.clear
                        .preference(key: InputBarHeightPreferenceKey.self, value: geometryProxy.size.height) // Höhe messen
                }
            )
        }
        .onPreferenceChange(InputBarHeightPreferenceKey.self) { newHeightValue in
            // Nur aktualisieren, wenn sinnvoll (verhindert Flackern)
            if newHeightValue > 0, abs(newHeightValue - inputBarHeightValue) > 0.5 {
                inputBarHeightValue = newHeightValue
            }
        }
    }
    
    /// Scrollt immer sicher zum unteren Anker.
    private func scrollToBottom(scrollProxy: ScrollViewProxy) {
        withAnimation(.easeInOut) {
            scrollProxy.scrollTo(bottomAnchorIdentifier, anchor: .bottom)              // fester Anker -> stabil
        }
    }
}

/// PreferenceKey zum Messen der InputBar-Höhe.
/// Dadurch bekommt die ScrollView unten IMMER genug Platz.
private struct InputBarHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        let nextHeightValue = nextValue()
        if nextHeightValue > 0 { value = nextHeightValue }
    }
}

#Preview("Content – Mockdaten, versetzte Agenten-Karten") {
    ContentView()
        .environment(\.colorScheme, .dark)
        .border(Color.red)
}
