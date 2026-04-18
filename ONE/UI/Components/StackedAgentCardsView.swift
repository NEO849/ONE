//
//  StackedAgentCardsView.swift
//  ONE
//
//  Created by Michael Fleps on 04.11.25.
//

import SwiftUI

/// Ansicht 2: Versetzter, klickbarer Kartenstapel (oben links → unten rechts).
/// Alle Karten gleich groß; Gesamthöhe kürzer als eine Bildschirmhöhe.
/// Tippen bringt die gewählte Karte nach vorne.
struct StackedAgentCardsView: View {

    let step: ChatStep

    @State private var frontIndex: Int = AgentType.allCases.count - 1

    private let offsetXValue: CGFloat = 36
    private let offsetYValue: CGFloat = 54

    var body: some View {
        let agentsList  = AgentType.allCases
        let agentCount  = CGFloat(agentsList.count)
        let stackHeight = AgentCardView.cardHeightValue + (agentCount - 1) * offsetYValue  // 140 + 3*54 = 302

        ZStack(alignment: .topLeading) {
            ForEach(agentsList.indices, id: \.self) { indexValue in
                let agentValue = agentsList[indexValue]

                let replyTextValue: String = {
                    if agentValue == .chatgpt { return step.finalReply ?? "" }
                    return step.reply(for: agentValue) ?? ""
                }()

                AgentCardView(agent: agentValue, agentResponse: replyTextValue)
                    .offset(x: CGFloat(indexValue) * offsetXValue, y: CGFloat(indexValue) * offsetYValue)
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: stackHeight)
        .padding(.leading, 12)
        .padding(.top, 8)
        .padding(.bottom, 16)
    }
}

#Preview("StackedAgentCards – versetzt & klickbar") {
    var step = ChatStep(userPrompt: "Wie gliedere ich ein SwiftUI-Projekt?")
    step.setAgentReply(agent: .gemini,  text: "Feature-Gruppierung: Features/<Name>/{Model,VM,View}.")
    step.setAgentReply(agent: .claude,  text: "Shared-Layer: Services/Repositories zentralisieren.")
    step.setAgentReply(agent: .mistral, text: "Einfach starten, später skalieren.")
    step.setFinalReply(text: "Vernünftig: Feature-Ordner plus zentrale Shared-Komponenten.")

    return ZStack {
        Image("background").resizable().scaledToFill().ignoresSafeArea()
        StackedAgentCardsView(step: step)
    }
    .environment(\.colorScheme, .dark)
}
