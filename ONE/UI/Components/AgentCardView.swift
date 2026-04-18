//
//  AgentCardView.swift
//  ONE
//
//  Created by Michael Fleps on 04.11.25.
//

import SwiftUI

/// Einzelne Agenten-Karte mit eigenem Hintergrund, Rahmen & Glas.
/// Wird in StackedAgentCardsView (isGridLayout = false)
/// und GridAgentCardsView (isGridLayout = true) eingesetzt.
struct AgentCardView: View {

    let agent: AgentType
    let agentResponse: String
    var isGridLayout: Bool = false

    @State private var showingSheet: Bool = false

    private var theme: AgentTheme { agent.theme }
    private var placeholder: String {
        agentResponse.isEmpty ? "… wartet auf Antwort …" : agentResponse
    }

    static let cardWidthValue: CGFloat  = 260
    static let cardHeightValue: CGFloat = 140
    static let nameRailWidthValue: CGFloat = 100
    private let contentLeadingPaddingValue: CGFloat  = 24
    private let contentTrailingPaddingValue: CGFloat = 34
    private let contentBottomPaddingValue: CGFloat   = 14
    private let maxLines: Int = 4

    private var cardHeight: CGFloat { isGridLayout ? 170 : Self.cardHeightValue }

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
                    accentColor: theme.accentColor
                )

                GlassVerticalDivider()

                VStack(alignment: .leading, spacing: 0) {
                    Spacer().frame(height: 24)

                    Text(placeholder)
                        .font(.callout)
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.white.opacity(0.86))
                        .lineLimit(maxLines)
                        .truncationMode(.tail)
                        .padding(.leading, contentLeadingPaddingValue)
                        .padding(.trailing, contentTrailingPaddingValue)
                        .padding(.bottom, 6)

                    Button("Mehr anzeigen") {
                        showingSheet = true
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(theme.accentColor)
                    .padding(.leading, contentLeadingPaddingValue)
                    .padding(.trailing, contentTrailingPaddingValue)
                    .padding(.bottom, contentBottomPaddingValue)
                }

                Spacer()
            }
        }
        .frame(width: isGridLayout ? nil : Self.cardWidthValue, height: cardHeight)
        .frame(maxWidth: isGridLayout ? .infinity : nil)
        .glassCard(cornerRadius: theme.cornerRadius)
        .clipped()
        .sheet(isPresented: $showingSheet) {
            FullAnswerAgentSheet(agent: agent, fullResponse: agentResponse)
                .presentationDragIndicator(.visible)
                .presentationDetents([.large])
        }
    }
}

#Preview("AgentCard – Stack-Modus") {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 16) {
            AgentCardView(agent: .claude,   agentResponse: "Den kompletten Inhalt durch die neue AgentCardView ersetzen")
            AgentCardView(agent: .gemini,   agentResponse: "Bei versetzten Karten ist ein vertikaler Agenten-Name links perfekt, weil er immer sichtbar bleibt.")
            AgentCardView(agent: .mistral,  agentResponse: "Innen-Einzug der Texte erhöhen – Padding nur bei den Zeilen, nicht bei der ganzen Sidebar.")
        }
        .padding(20)
    }
    .background(Image("background").resizable().scaledToFill().ignoresSafeArea())
    .environment(\.colorScheme, .dark)
}

#Preview("AgentCard – Grid-Modus") {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
        AgentCardView(agent: .claude,   agentResponse: "MVVM trennt View, ViewModel und Model klar.",          isGridLayout: true)
        AgentCardView(agent: .gemini,   agentResponse: "Nutze @StateObject für das ViewModel in der Root-View.", isGridLayout: true)
        AgentCardView(agent: .mistral,  agentResponse: "Kurz: ViewModel = State + Logik. View = nur Rendering.", isGridLayout: true)
        AgentCardView(agent: .chatgpt,  agentResponse: "MVVM ist der empfohlene Ansatz in SwiftUI.",            isGridLayout: true)
    }
    .padding(16)
    .background(Image("background").resizable().scaledToFill().ignoresSafeArea())
    .environment(\.colorScheme, .dark)
}

#Preview("AgentCard – Leerzustand") {
    HStack(spacing: 16) {
        AgentCardView(agent: .claude,  agentResponse: "")
        AgentCardView(agent: .gemini,  agentResponse: "")
    }
    .padding(20)
    .background(Image("background").resizable().scaledToFill().ignoresSafeArea())
    .environment(\.colorScheme, .dark)
}
