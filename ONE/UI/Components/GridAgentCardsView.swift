//
//  GridAgentCardsView.swift
//  ONE
//

import SwiftUI

/// Ansicht 1: Alle 4 Agenten-Karten gleichgroß in einem 2×2-Raster.
/// Jede Karte zeigt gekürzten Text + "Mehr anzeigen" → FullAnswerAgentSheet bei Klick.
struct GridAgentCardsView: View {

    let step: ChatStep

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(AgentType.allCases, id: \.self) { agent in
                let reply: String = {
                    if agent == .chatgpt { return step.finalReply ?? "" }
                    return step.reply(for: agent) ?? ""
                }()
                AgentCardView(
                    agent: agent,
                    agentResponse: reply,
                    userPrompt: step.userPrompt,
                    isGridLayout: true
                )
            }
        }
        .padding(.horizontal, 4)
        .padding(.top, 8)
        .padding(.bottom, 16)
    }
}

#Preview("GridAgentCardsView – Beispiel") {
    var step = ChatStep(userPrompt: "Wie setze ich MVVM in SwiftUI um?")
    step.setAgentReply(agent: .gemini,  text: "MVVM trennt View, ViewModel und Model klar voneinander.")
    step.setAgentReply(agent: .claude,  text: "Nutze @StateObject für das ViewModel in der Root-View.")
    step.setAgentReply(agent: .mistral, text: "Kurz: ViewModel = State + Logik. View = nur Rendering.")
    step.setFinalReply(text: "MVVM ist der empfohlene Ansatz in SwiftUI. ViewModel als @MainActor markieren.")

    return ZStack {
        Image("background").resizable().scaledToFill().ignoresSafeArea()
        ScrollView {
            GridAgentCardsView(step: step)
                .padding(.horizontal, 16)
        }
    }
    .environment(\.colorScheme, .dark)
}
