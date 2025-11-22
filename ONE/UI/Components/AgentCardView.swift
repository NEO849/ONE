//
//  AgentCardView.swift
//  ONE
//
//  Created by Michael Fleps on 04.11.25.
//

import SwiftUI

/// Einzelne Agenten-Karte mit eigenem Hintergrund, Rahmen & Glas.
/// Beziehung: Wird im StackedAgentCardsView eingesetzt.
/// Keine Magic Numbers im Body (wartbar + konsistent).
struct AgentCardView: View {
    
    let agent: AgentType
    let agentResponse: String
    
    /// Theme des Agents (Farben, Radius, Stroke).
    private var theme: AgentTheme {
        agent.theme
    }
    
    /// Placeholder-Text falls Antwort leer ist.
    private var placeholder: String {
        agentResponse.isEmpty ? "… wartet auf Antwort …" : agentResponse
    }
    
    // MARK: - Layout Konfiguration (zentrale Werte, keine Redundanz)
    private let cardWidthValue: CGFloat = 260
    private let cardHeightValue: CGFloat = 320
    private let nameRailWidthValue: CGFloat = 66
    
    var body: some View {
        ZStack {
            // Hintergrundbild – skaliert und an Kartenradius geclippt
            Image(theme.backgroundAssetName)
                .resizable()
                .scaledToFill()
                .clipShape(
                    RoundedRectangle(cornerRadius: theme.cornerRadius)
                )
            
            // Rahmen passend zum Theme
            RoundedRectangle(cornerRadius: theme.cornerRadius)
                .stroke(
                    theme.accentColor.opacity(0.85),
                    lineWidth: theme.strokeWidth
                )
            
            // Rail links + Divider + Content rechts
            HStack(spacing: 0) {
                
                LeftAgentNameRailView(
                    agentName: agent.displayName,
                    accentColor: theme.accentColor,
                    railWidthValue: nameRailWidthValue
                )
                VStack() {
                    Spacer(minLength: 14)
                    ScrollView(showsIndicators: false) {
                        Text(placeholder)
                            .font(.callout)
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(.white.opacity(0.86))
                            .padding(.top, 24)
                            .padding(.horizontal, 28)
                            .padding(.trailing, 10)
                    }
                    Spacer(minLength: 20)
                }
            }
        }
        .frame(width: cardWidthValue, height: cardHeightValue)
        .glassCard(cornerRadius: theme.cornerRadius)
        .clipped()
    }
}

#Preview("AgentCard – ANtworten") {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 16) {
            AgentCardView(agent: .claude, agentResponse: "Den kompletten Inhalt durch die neue AgentCardView ersetzen")
            AgentCardView(agent: .gemini,  agentResponse: "bei versetzten Karten ist ein vertikaler Agenten-Name links perfekt, weil er immer sichtbar bleibt, selbst wenn Karten überlappen bei versetzten Karten ist ein vertikaler Agenten-Name links perfekt, weil er immer sichtbar bleibt, selbst wenn Karten überlappen bei versetzten Karten ist ein vertikaler Agenten-Name links perfekt, weil er immer sichtbar bleibt, selbst wenn Karten überlappen bei versetzten Karten ist ein vertikaler Agenten-Name links perfekt, weil er immer sichtbar bleibt, selbst wenn Karten überlappen")
            AgentCardView(agent: .claude,  agentResponse: "Das macht das Header-Layout unnötig groß und kann zu komischen Abständen führen.")
            AgentCardView(agent: .mistral, agentResponse: "Innen-Einzug der Texte erhöhen → Padding nur bei den Zeilen, nicht bei der ganzen Sidebar")
        }
        .padding(20)
    }
    .background(
        Image("background").resizable().scaledToFill().ignoresSafeArea()
    )
    .environment(\.colorScheme, .dark)
}

#Preview("AgentCard – Leerzustand") {
    // Wenn die Antwort noch aussteht.
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 16) {
            AgentCardView(agent: .claude, agentResponse: "")
            AgentCardView(agent: .gemini,  agentResponse: "")
            AgentCardView(agent: .claude,  agentResponse: "")
            AgentCardView(agent: .mistral, agentResponse: "")
        }
        .padding(20)
    }
    .background(
        Image("background").resizable().scaledToFill().ignoresSafeArea()
    )
    .environment(\.colorScheme, .dark)
}
