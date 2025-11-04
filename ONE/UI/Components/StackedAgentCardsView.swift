//
//  StackedAgentCardsView.swift
//  ONE
//
//  Created by Michael Fleps on 04.11.25.
//

import SwiftUI

/// Versetzter, klickbarer Kartenstapel (oben links → unten rechts).
/// Logik:
/// - Reihenfolge folgt "AgentType.allCases".
/// - Tippen bringt die Karte nach vorn (Fokus).
struct StackedAgentCardsView: View {
    let step: ChatStep

    @State private var frontIndex: Int = AgentType.allCases.count - 1
    private let offsetX: CGFloat = 36
    private let offsetY: CGFloat = 44

    var body: some View {
        let agents = AgentType.allCases

        ZStack(alignment: .topLeading) {
            ForEach(agents.indices, id: \.self) { indexValue in
                let agent = agents[indexValue]
                let textValue: String = {
                    if agent == .chatgpt { return step.finalReply ?? "" }
                    return step.reply(for: agent) ?? ""
                }()

                AgentCardView(agent: agent, bodyText: textValue)
                    .offset(x: CGFloat(indexValue) * offsetX, y: CGFloat(indexValue) * offsetY)
                    .scaleEffect(frontIndex == indexValue ? 1.0 : 0.94)
                    .shadow(radius: frontIndex == indexValue ? 18 : 8)
                    .zIndex(frontIndex == indexValue ? 1 : 0)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            frontIndex = indexValue
                        }
                    }
            }
        }
        .padding(.top, offsetY * CGFloat(agents.count))
        .padding(.leading, offsetX * CGFloat(agents.count))
        .frame(maxWidth: .infinity, minHeight: 560, alignment: .topLeading)
    }
}

#Preview("StackedAgentCards – versetzt & klickbar") {
    // Deutsch: Step mit drei Agentenantworten + finaler ChatGPT-Antwort.
    var step = ChatStep(userPrompt: "Wie gliedere ich ein SwiftUI-Projekt?")
    step.setAgentReply(agent: .gemini,  text: "Feature-Gruppierung: Features/<Name>/{Model,VM,View}.")
    step.setAgentReply(agent: .claude,  text: "Shared-Layer: Services/Repositories zentralisieren.")
    step.setAgentReply(agent: .mistral, text: "Einfach starten, später skalieren.")
    step.setFinalReply(text: "Vernünftig: Feature-Ordner plus zentrale Shared-Komponenten.")

    return StackedAgentCardsView(step: step)
        .padding(24)
        .background(
            Image("background").resizable().scaledToFill()
        )
        .environment(\.colorScheme, .dark)
}
