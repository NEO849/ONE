//
//  AgentCardView.swift
//  ONE
//
//  Created by Michael Fleps on 04.11.25.
//

import SwiftUI

/// Einzelne Agenten-Karte mit eigenem Hintergrund, Rahmen & Glas.
/// Beziehung: Wird im StackedAgentCardsView eingesetzt.
/// 
struct AgentCardView: View {
    let agent: AgentType
    let bodyText: String

    var body: some View {
        let theme = agent.theme

        ZStack {
            Image(theme.backgroundAssetName)
                .resizable().scaledToFill()
                .overlay(Color.black.opacity(0.10))
                .clipped()

            RoundedRectangle(cornerRadius: theme.cornerRadius, style: .continuous)
                .stroke(theme.accentColor.opacity(0.85), lineWidth: theme.strokeWidth)
                .shadow(color: theme.accentColor.opacity(0.45), radius: 14, x: 0, y: 6)

            VStack(spacing: 12) {
                Text(agent.displayName)
                    .font(.headline)
                    .foregroundStyle(theme.accentColor)

                Text(bodyText.isEmpty ? "… wartet auf Antwort …" : bodyText)
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.92))
                    .padding(.horizontal, 12)
            }
            .padding(18)
        }
        .frame(width: 260, height: 320)
        .glassCard(cornerRadius: theme.cornerRadius)
        .accessibilityLabel(Text("\(agent.displayName) Karte"))
    }
}
