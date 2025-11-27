//
//  ChatMessageListView.swift
//  ONE
//
//  Created by Michael Fleps on 27.11.25.
//

import SwiftUI

/// Reine Chatliste:
/// - kümmert sich NUR um ScrollView + Auto-Scroll
/// - kennt keine Services, kein ViewModel
struct ChatMessageListView: View {
    
    let steps: [ChatStep]                                                               // Daten rein
    let isInputFocused: Bool                                                   // Fokus rein
    let bottomScrollTriggerValue: Int                                                   // Trigger: count
    
    private let bottomAnchorIdentifier: String = "bottomAnchorIdentifier"               // fester Anker
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView(showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 20) {
                    
                    ForEach(steps, id: \.id) { stepValue in
                        VStack(alignment: .leading, spacing: 12) {
                            UserPromptBubbleView(promptText: stepValue.userPrompt)
                            StackedAgentCardsView(step: stepValue)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // ✅ fester Bottom-Anker -> nie nil, nie Timing-Probleme
                    Color.clear
                        .frame(height: 12)
                        .id(bottomAnchorIdentifier)
                }
                .padding(.horizontal, 42)
                .padding(.top, 6)
            }
            .scrollDismissesKeyboard(.immediately)                                       // scroll -> Tastatur zu
            
            // neue Steps -> an das Ende
            .onChange(of: bottomScrollTriggerValue) { _ in
                scrollToBottom(scrollProxy: scrollProxy)
            }
            
            // Tastatur öffnet -> an das Ende
            .onChange(of: isInputFocused) { isFocusedValue in
                guard isFocusedValue else { return }
                DispatchQueue.main.async {
                    scrollToBottom(scrollProxy: scrollProxy)
                }
            }
        }
    }
    
    private func scrollToBottom(scrollProxy: ScrollViewProxy) {
        withAnimation(.easeInOut) {
            scrollProxy.scrollTo(bottomAnchorIdentifier, anchor: .bottom)
        }
    }
}
