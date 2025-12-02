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
/// Stapel aus Agenten-Karten.
/// Wichtig:
/// - offset(...) verändert NICHT die Layout-Größe.
/// - Deshalb bekommt der Stapel eine berechnete Frame-Größe, damit ScrollView stabil bleibt.
struct StackedAgentCardsView: View {
    
    let step: ChatStep
    
    @State private var frontIndex: Int = AgentType.allCases.count - 1                   // welche Karte oben ist
    
    private let offsetXValue: CGFloat = 36                                              // horizontaler Versatz
    private let offsetYValue: CGFloat = 54                                              // vertikaler Versatz
    
    var body: some View {
        let agentsList = AgentType.allCases                                            // Agenten-Reihenfolge
        
        ZStack(alignment: .topLeading) {
            ForEach(agentsList.indices, id: \.self) { indexValue in
                let agentValue = agentsList[indexValue]
                
                let replyTextValue: String = {                                         // Antwort je Agent
                    if agentValue == .chatgpt { return step.finalReply ?? "" }
                    return step.reply(for: agentValue) ?? ""
                }()
                
                AgentCardView(agent: agentValue, agentResponse: replyTextValue)
                    .offset(x: CGFloat(indexValue) * offsetXValue, y: CGFloat(indexValue) * offsetYValue)
                    .scaleEffect(frontIndex == indexValue ? 1.0 : 0.94)
                    .shadow(radius: frontIndex == indexValue ? 18 : 8)
                    .zIndex(frontIndex == indexValue ? 1 : 0) // Kartenreihenfolge
                    .onTapGesture {
                        // 👉 Bei Klick: Karte nach vorne holen
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            frontIndex = indexValue
                        }
                    }
            }
        }
        .frame(maxWidth: .infinity) // ⬅️ Karten nach links anordnen
        .padding(.leading, 12) // 📏 Konsistenter linker Abstand
        .padding(.top, 8)      // 🧩 Etwas Luft zur UserBubble
        .padding(.bottom, 160)
    }
}
#Preview("StackedAgentCards – versetzt & klickbar") {
    // Step mit drei Agentenantworten + finaler ChatGPT-Antwort.
    var step = ChatStep(userPrompt: "Wie gliedere ich ein SwiftUI-Projekt?")
    step.setAgentReply(agent: .gemini,  text: "Feature-Gruppierung: Features/<Name>/{Model,VM,View}.")
    step.setAgentReply(agent: .claude,  text: "Shared-Layer: Services/Repositories zentralisieren.")
    step.setAgentReply(agent: .mistral, text: "Einfach starten, später skalieren.")
    step.setFinalReply(text: "Vernünftig: Feature-Ordner plus zentrale Shared-Komponenten.")

    return ZStack {
        Image("background")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()

        StackedAgentCardsView(step: step)
    }
        .environment(\.colorScheme, .dark)
}
