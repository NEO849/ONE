//
//  ChatMessageListView.swift
//  ONE
//
//  Created by Michael Fleps on 27.11.25.
//

import SwiftUI

/// Reine Chatliste:
/// - Kümmert sich NUR um ScrollView + Auto-Scroll.
/// - Leerzustand: Welcome-Screen wenn steps leer sind.
/// - Schaltet zwischen Grid- und Stacked-Ansicht anhand layoutMode.
/// - Kennt keine Services, kein ViewModel.
struct ChatMessageListView: View {

    let steps: [ChatStep]
    let isInputFocused: Bool
    let bottomScrollTriggerValue: Int
    let layoutMode: LayoutMode

    private let bottomAnchorIdentifier: String = "bottomAnchorIdentifier"

    var body: some View {
        Group {
            if steps.isEmpty {
                welcomeStateView
            } else {
                chatScrollView
            }
        }
    }

    // MARK: - Leerzustand

    /// Wird beim ersten Öffnen oder nach 'New Chat' gezeigt.
    private var welcomeStateView: some View {
        VStack(spacing: 20) {
            Spacer()

            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            Text("Stell deine erste Frage")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)

            Text("Gemini, Claude, Mistral und ChatGPT\nantworten parallel – du siehst alle vier.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.55))
                .multilineTextAlignment(.center)

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Chatliste

    private var chatScrollView: some View {
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

#Preview("ChatMessageList – Leerzustand") {
    ChatMessageListView(
        steps: [],
        isInputFocused: false,
        bottomScrollTriggerValue: 0,
        layoutMode: .grid
    )
    .background(Image("background").resizable().scaledToFill().ignoresSafeArea())
    .environment(\.colorScheme, .dark)
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
