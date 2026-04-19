//
//  AgentCardView.swift
//  ONE
//
//  Created by Michael Fleps on 04.11.25.
//

import SwiftUI

/// Einzelne Agenten-Karte mit eigenem Hintergrund, Rahmen & Glas.
/// Zustände:
///   • Leer  → Skeleton-Shimmer (agentResponse.isEmpty)
///   • Fehler → Orange Stroke + Fehlertext (agentResponse beginnt mit "[AgentName]")
///   • Normal → Antworttext + 'Mehr anzeigen'-Button
struct AgentCardView: View {

    let agent: AgentType
    let agentResponse: String
    let userPrompt: String
    var isGridLayout: Bool = false

    @State private var showingSheet: Bool = false
    @State private var shimmerOpacity: Double = 1.0

    private var theme: AgentTheme { agent.theme }

    private var isLoading: Bool { agentResponse.isEmpty }
    private var isErrorResponse: Bool {
        agentResponse.hasPrefix("[\(agent.displayName)]")
    }
    private var displayedErrorMessage: String {
        let prefix = "[\(agent.displayName)] "
        return agentResponse.hasPrefix(prefix)
            ? String(agentResponse.dropFirst(prefix.count))
            : agentResponse
    }

    static let cardWidthValue:     CGFloat = 260
    static let cardHeightValue:    CGFloat = 140
    static let nameRailWidthValue: CGFloat = 100
    private let contentLeadingPaddingValue:  CGFloat = 24
    private let contentTrailingPaddingValue: CGFloat = 34
    private let contentBottomPaddingValue:   CGFloat = 14
    private let maxLines: Int = 4

    private var cardHeight: CGFloat { isGridLayout ? 170 : Self.cardHeightValue }
    private var borderColor: Color {
        isErrorResponse ? .orange : theme.accentColor
    }

    var body: some View {
        ZStack {
            Image(theme.backgroundAssetName)
                .resizable()
                .scaledToFill()
                .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius))
                .accessibilityHidden(true)

            RoundedRectangle(cornerRadius: theme.cornerRadius)
                .stroke(borderColor.opacity(0.85), lineWidth: theme.strokeWidth)
                .accessibilityHidden(true)

            HStack(spacing: 0) {
                LeftAgentNameRailView(
                    agentNameAssetName: theme.verticalAgentName,
                    accentColor: theme.accentColor
                )
                .accessibilityHidden(true)

                GlassVerticalDivider()
                    .accessibilityHidden(true)

                if isLoading {
                    skeletonContent
                } else if isErrorResponse {
                    errorContent
                } else {
                    realContent
                }

                Spacer()
            }
        }
        .frame(width: isGridLayout ? nil : Self.cardWidthValue, height: cardHeight)
        .frame(maxWidth: isGridLayout ? .infinity : nil)
        .glassCard(cornerRadius: theme.cornerRadius)
        .clipped()
        .animation(.easeInOut(duration: 0.25), value: isLoading)
        .animation(.easeInOut(duration: 0.2), value: isErrorResponse)
        .sheet(isPresented: $showingSheet) {
            FullAnswerAgentSheet(
                agent: agent,
                fullResponse: agentResponse,
                userPrompt: userPrompt
            )
            .presentationDragIndicator(.visible)
            .presentationDetents([.large])
        }
    }

    // MARK: - Echte Antwort

    private var realContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer().frame(height: 24)

            Text(agentResponse)
                .font(.callout)
                .multilineTextAlignment(.leading)
                .foregroundStyle(.white.opacity(0.86))
                .lineLimit(maxLines)
                .truncationMode(.tail)
                .padding(.leading, contentLeadingPaddingValue)
                .padding(.trailing, contentTrailingPaddingValue)
                .padding(.bottom, 6)
                .accessibilityLabel("\(agent.displayName): \(agentResponse)")
                .accessibilityAddTraits(.updatesFrequently)

            Button("Mehr anzeigen") { showingSheet = true }
                .font(.caption.weight(.semibold))
                .foregroundStyle(theme.accentColor)
                .padding(.leading, contentLeadingPaddingValue)
                .padding(.trailing, contentTrailingPaddingValue)
                .padding(.bottom, contentBottomPaddingValue)
                .accessibilityLabel("Vollständige Antwort von \(agent.displayName) lesen")
                .accessibilityHint("Öffnet ein Detail-Sheet mit der vollständigen Antwort")
        }
    }

    // MARK: - Fehlerzustand

    private var errorContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer().frame(height: 18)

            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.orange)
                    .accessibilityHidden(true)
                Text("API-Fehler")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.orange)
            }
            .padding(.leading, contentLeadingPaddingValue)
            .padding(.bottom, 6)

            Text(displayedErrorMessage)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.65))
                .lineLimit(3)
                .padding(.leading, contentLeadingPaddingValue)
                .padding(.trailing, contentTrailingPaddingValue)

            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(agent.displayName), Fehler: \(displayedErrorMessage)")
    }

    // MARK: - Skeleton / Ladezustand

    private var skeletonContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            Spacer().frame(height: 24)
            skeletonLine(trailingExtra: 0)
            skeletonLine(trailingExtra: 36)
            skeletonLine(trailingExtra: 72)
            Spacer()
        }
        .padding(.leading, contentLeadingPaddingValue)
        .opacity(shimmerOpacity)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.75).repeatForever(autoreverses: true)) {
                shimmerOpacity = 0.3
            }
        }
        .onDisappear { shimmerOpacity = 1.0 }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(agent.displayName), lädt")
        .accessibilityHint("Antwort wird generiert")
    }

    private func skeletonLine(trailingExtra: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(Color.white.opacity(0.22))
            .frame(height: 11)
            .padding(.trailing, contentTrailingPaddingValue + trailingExtra)
            .accessibilityHidden(true)
    }
}

#Preview("AgentCard – Stack-Modus") {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 16) {
            AgentCardView(agent: .claude,  agentResponse: "Strukturiert: MVVM trennt Darstellung und Logik.", userPrompt: "Wie funktioniert MVVM?")
            AgentCardView(agent: .gemini,  agentResponse: "Fakten: ViewModel ist @MainActor und @ObservableObject.", userPrompt: "Wie funktioniert MVVM?")
            AgentCardView(agent: .mistral, agentResponse: "Prägnant: View = UI, VM = State+Logik.", userPrompt: "Wie funktioniert MVVM?")
        }
        .padding(20)
    }
    .background(Image("background").resizable().scaledToFill().ignoresSafeArea())
    .environment(\.colorScheme, .dark)
}

#Preview("AgentCard – Ladezustand (Shimmer)") {
    HStack(spacing: 16) {
        AgentCardView(agent: .claude,  agentResponse: "", userPrompt: "Test")
        AgentCardView(agent: .gemini,  agentResponse: "", userPrompt: "Test")
    }
    .padding(20)
    .background(Image("background").resizable().scaledToFill().ignoresSafeArea())
    .environment(\.colorScheme, .dark)
}

#Preview("AgentCard – Fehlerzustand") {
    HStack(spacing: 16) {
        AgentCardView(agent: .claude, agentResponse: "[Claude] HTTP 401 – ungültiger API-Key.", userPrompt: "Test")
        AgentCardView(agent: .gemini, agentResponse: "[Gemini] Netzwerkfehler: kein Internet.", userPrompt: "Test")
    }
    .padding(20)
    .background(Image("background").resizable().scaledToFill().ignoresSafeArea())
    .environment(\.colorScheme, .dark)
}
