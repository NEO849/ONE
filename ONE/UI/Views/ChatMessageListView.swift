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
/// - schaltet zwischen Grid- und Stacked-Ansicht anhand layoutMode
struct ChatMessageListView: View {

    let steps: [ChatStep]
    let isInputFocused: Bool
    let bottomScrollTriggerValue: Int
    let layoutMode: LayoutMode

    private let bottomAnchorIdentifier: String = "bottomAnchorIdentifier"

    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView(showsIndicators: false) {
                LazyVStack(alignment: .leading) {
                    ForEach(steps, id: \.id) { stepValue in
                        VStack {
                            UserPromptBubbleView(promptText: stepValue.userPrompt)

                            if layoutMode == .grid {
                                GridAgentCardsView(step: stepValue)
                            } else {
                                StackedAgentCardsView(step: stepValue)
                            }
                        }
                    }

                    Color.clear
                        .frame(height: 22)
                        .id(bottomAnchorIdentifier)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 6)
            }

            .onChange(of: bottomScrollTriggerValue) {
                scrollToBottom(scrollProxy: scrollProxy)
            }

            .onChange(of: isInputFocused) {
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

#Preview("ChatMessageList – Grid-Ansicht") {
    let steps = ChatMessageListViewPreviewFactory.erstelleBeispielSteps()
    return ChatMessageListView(
        steps: steps,
        isInputFocused: false,
        bottomScrollTriggerValue: steps.count,
        layoutMode: .grid
    )
    .background(Color.black.opacity(0.001))
}

#Preview("ChatMessageList – Stacked-Ansicht") {
    let steps = ChatMessageListViewPreviewFactory.erstelleBeispielSteps()
    return ChatMessageListView(
        steps: steps,
        isInputFocused: false,
        bottomScrollTriggerValue: steps.count,
        layoutMode: .stacked
    )
    .background(Color.black.opacity(0.001))
}

// MARK: - Preview Factory
private enum ChatMessageListViewPreviewFactory {

    static func erstelleBeispielSteps() -> [ChatStep] {
        var ergebnisSteps: [ChatStep] = []

        var ersterStep = ChatStep(userPrompt: "Erkläre MVVM in SwiftUI ganz kurz.")
        ersterStep.setAgentReply(agent: .gemini,  text: "MVVM trennt View (UI) von Logik (ViewModel) und Datenzugriff (Repository).")
        ersterStep.setAgentReply(agent: .mistral, text: "View zeigt State, ViewModel hält State und ruft Services/Repos auf.")
        ersterStep.setAgentReply(agent: .claude,  text: "Durch Bindings bleibt die UI automatisch aktuell, weil das ViewModel publishen kann.")
        ersterStep.setFinalReply(text: "Kurz: View rendert, ViewModel steuert State/Logik, Repository kapselt Datenzugriff.")
        ergebnisSteps.append(ersterStep)

        var zweiterStep = ChatStep(userPrompt: "Warum ScrollViewReader + Bottom-Anker?")
        zweiterStep.setAgentReply(agent: .gemini,  text: "Damit du zuverlässig ans Ende scrollen kannst – ohne Timing-Probleme.")
        zweiterStep.setAgentReply(agent: .mistral, text: "Ein fester .id-Anker ist stabiler als 'last message id', wenn UI noch rendert.")
        zweiterStep.setAgentReply(agent: .claude,  text: "Auto-Scroll ist so entkoppelt: Liste kennt kein ViewModel, nur Trigger-Werte.")
        ergebnisSteps.append(zweiterStep)

        return ergebnisSteps
    }
}
