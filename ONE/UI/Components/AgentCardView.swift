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
    
    // NEU: State-Variable für das Sheet
    @State private var showingSheet: Bool = false
    
    private var theme: AgentTheme { agent.theme }
    private var placeholder: String {
        agentResponse.isEmpty ? "… wartet auf Antwort …" : agentResponse
    }
    
    // ... Layout Konstanten bleiben gleich ...
    static let cardWidthValue: CGFloat = 260
    static let cardHeightValue: CGFloat = 140
    static let nameRailWidthValue: CGFloat = 100
    private let contentLeadingPaddingValue: CGFloat = 24
    private let contentTrailingPaddingValue: CGFloat = 34
    private let contentBottomPaddingValue: CGFloat = 14
    private let maxLines: Int = 4
    
    var body: some View {
        ZStack {
            Image(theme.backgroundAssetName)
                .resizable()
                .scaledToFill()
                .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius))
            
            RoundedRectangle(cornerRadius: theme.cornerRadius)
                .stroke(theme.accentColor.opacity(0.85), lineWidth: theme.strokeWidth)
            
            HStack(spacing: 0) {
                LeftAgentNameRailView(
                    agentNameAssetName: theme.verticalAgentName,
                    accentColor: theme.accentColor,
                )
                
                GlassVerticalDivider()
                
                VStack(alignment: .leading, spacing: 0) {
                    Spacer().frame(height: 24)
                    
                    // 1. Gekürzter Text
                    Text(placeholder)
                        .font(.callout)
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.white.opacity(0.86))
                        .lineLimit(maxLines) // Beschränkung auf 4 Zeilen
                        .truncationMode(.tail)
                        .padding(.leading, contentLeadingPaddingValue)
                        .padding(.trailing, contentTrailingPaddingValue)
                        .padding(.bottom, 6) // Abstand zum Button reduzieren

                         Button("Mehr anzeigen") {
                             showingSheet = true // Sheet öffnen
                         }
                         .font(.caption.weight(.semibold))
                         .foregroundStyle(theme.accentColor) // Akzentfarbe für den Link
                         .padding(.leading, contentLeadingPaddingValue)
                         .padding(.trailing, contentTrailingPaddingValue)
                         .padding(.bottom, contentBottomPaddingValue)
                    }

                    Spacer()
                }
            }
        
        .frame(width: Self.cardWidthValue, height: Self.cardHeightValue)
        .glassCard(cornerRadius: theme.cornerRadius)
        .clipped()
        .sheet(isPresented: $showingSheet) {
            FullAnswerAgentSheet(agent: agent, fullResponse: agentResponse)
                .presentationDragIndicator(.visible)
                .presentationDetents([.large]) // Sheet füllt den ganzen Bildschirm
        }
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
