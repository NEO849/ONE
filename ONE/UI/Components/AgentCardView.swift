//
//  AgentCardView.swift
//  ONE
//
//  Created by Michael Fleps on 04.11.25.
//

import SwiftUI

/// Einzelne Agenten-Karte mit eigenem Hintergrund, Rahmen & Glas.
/// Beziehung: Wird im StackedAgentCardsView eingesetzt.
struct AgentCardView: View {
    let agent: AgentType
    let bodyText: String

    var body: some View {
        let theme = agent.theme

        ZStack {
            Image(theme.backgroundAssetName)
                .resizable().scaledToFill()

            RoundedRectangle(cornerRadius: theme.cornerRadius)
                .stroke(theme.accentColor.opacity(0.85))
             

            VStack(spacing: 2) {
                Text(agent.displayName)
                    .font(.headline)
                    .foregroundStyle(theme.accentColor)

                Text(bodyText.isEmpty ? "… wartet auf Antwort …" : bodyText)
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.82))
                    .padding(.horizontal, 42)
            }
        }
        .frame(width: 260, height: 320)
        .glassCard(cornerRadius: theme.cornerRadius)
//        .accessibilityLabel(Text("\(agent.displayName) Karte"))
        .padding(.leading, 22)
    }
}

#Preview("AgentCard – alle vier") {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 16) {
            AgentCardView(agent: .chatgpt, bodyText: "Final check: Plausibel, klar strukturiert.")
            AgentCardView(agent: .gemini,  bodyText: "Research: Quellen X/Y/Z, Fakten geprüft.")
            AgentCardView(agent: .claude,  bodyText: "Structure: Schritt 1–3 mit Klarheit.")
            AgentCardView(agent: .mistral, bodyText: "Concise: Kernaussagen in 3 Sätzen.")
        }
        .padding(20)
    }
    .background(
        Image("background").resizable().scaledToFill()
    )
    .environment(\.colorScheme, .dark)
}

#Preview("AgentCard – Leerzustand") {
    // Zweiter Preview zur Überprüfung des Zustands, wenn die Antwort noch aussteht.
    AgentCardView(agent: .claude, bodyText: "")
        .padding(24)
        .background(Color.black.opacity(0.8))
        .environment(\.colorScheme, .dark)
}
