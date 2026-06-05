//
//  AgentCardView.swift
//  ONE
//
//  Created by Michael Fleps on 04.11.25.
//

import SwiftUI

/// Einzelne Agenten-Karte mit EINHEITLICHER Glas-Flaeche fuer alle Agenten.
/// Die Identitaet entsteht nur noch durch einen dezenten Farb-Akzent oben
/// und den vertikalen Namens-Schriftzug links.
/// Zustaende:
///   - Leer   -> Skeleton-Shimmer (agentResponse.isEmpty)
///   - Fehler -> Orange Akzent + Fehlertext
///   - Normal -> Antworttext + Mehr-anzeigen-Aktion
struct AgentCardView: View {

    let agent: AgentType
    let agentResponse: String
    let userPrompt: String
    var isGridLayout: Bool = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
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

    // Feste Kennzahlen (vom Stapel-Layout benoetigt) bleiben erhalten.
    static let cardWidthValue:     CGFloat = 260
    static let cardHeightValue:    CGFloat = 140
    static let nameRailWidthValue: CGFloat = 100

    private let maxLines: Int = 4
    private var cardHeight: CGFloat { isGridLayout ? 170 : Self.cardHeightValue }

    /// Akzentfarbe: im Fehlerfall warnendes Orange, sonst der dezente Agent-Ton.
    private var accent: Color {
        isErrorResponse ? .orange : theme.accentColor
    }

    var body: some View {
        cardContent
            .frame(width: isGridLayout ? nil : Self.cardWidthValue, height: cardHeight)
            .frame(maxWidth: isGridLayout ? .infinity : nil)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: theme.cornerRadius, style: .continuous))
            .overlay(borderOverlay)
            .depthShadow(.resting)
            .animation(DesignSystem.Motion.standard, value: isLoading)
            .animation(DesignSystem.Motion.standard, value: isErrorResponse)
            .sensoryFeedback(.selection, trigger: showingSheet)
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

    // MARK: - Aufbau der Karte

    private var cardContent: some View {
        HStack(spacing: 0) {
            LeftAgentNameRailView(
                agentNameAssetName: theme.verticalAgentName,
                accentColor: accent
            )
            .accessibilityHidden(true)

            GlassVerticalDivider()
                .accessibilityHidden(true)

            Group {
                if isLoading {
                    skeletonContent
                } else if isErrorResponse {
                    errorContent
                } else {
                    realContent
                }
            }

            Spacer(minLength: 0)
        }
    }

    // MARK: - Einheitliche Glas-Flaeche plus dezenter Top-Akzent (hinter dem Inhalt)

    private var cardBackground: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: theme.cornerRadius, style: .continuous)
                .fill(DesignSystem.Surface.cardFill)
                .background(.ultraThinMaterial)
            topAccent
        }
    }

    /// Dezenter Farb-Akzent oben: weicher Schein plus feine Linie.
    private var topAccent: some View {
        ZStack(alignment: .top) {
            LinearGradient(
                colors: [accent.opacity(0.16), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 60)
            .blur(radius: 6)

            LinearGradient(
                colors: [accent.opacity(0.0), accent.opacity(0.85), accent.opacity(0.0)],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 2.5)
            .padding(.horizontal, DesignSystem.Spacing.large)
        }
        .allowsHitTesting(false)
    }

    private var borderOverlay: some View {
        RoundedRectangle(cornerRadius: theme.cornerRadius, style: .continuous)
            .strokeBorder(
                isErrorResponse ? Color.orange.opacity(0.55) : DesignSystem.Surface.cardStroke,
                lineWidth: 1
            )
    }

    // MARK: - Echte Antwort

    private var realContent: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            Text(agentResponse)
                .font(.callout)
                .multilineTextAlignment(.leading)
                .foregroundStyle(DesignSystem.Surface.textPrimary)
                .lineLimit(maxLines)
                .truncationMode(.tail)
                .accessibilityLabel("\(agent.displayName): \(agentResponse)")
                .accessibilityAddTraits(.updatesFrequently)

            Button("Mehr anzeigen") { showingSheet = true }
                .font(.caption.weight(.semibold))
                .foregroundStyle(accent)
                .buttonStyle(ScaleButtonStyle())
                .accessibilityLabel("Vollstaendige Antwort von \(agent.displayName) lesen")
                .accessibilityHint("Oeffnet ein Detail-Sheet mit der vollstaendigen Antwort")
        }
        .padding(.top, DesignSystem.Spacing.large)
        .padding(.leading, DesignSystem.Spacing.large)
        .padding(.trailing, DesignSystem.Spacing.medium)
        .padding(.bottom, DesignSystem.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Fehlerzustand

    private var errorContent: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            HStack(spacing: DesignSystem.Spacing.tiny + 2) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.orange)
                    .accessibilityHidden(true)
                Text("API-Fehler")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.orange)
            }

            Text(displayedErrorMessage)
                .font(.caption)
                .foregroundStyle(DesignSystem.Surface.textSecondary)
                .lineLimit(3)

            Spacer(minLength: 0)
        }
        .padding(.top, DesignSystem.Spacing.large)
        .padding(.leading, DesignSystem.Spacing.large)
        .padding(.trailing, DesignSystem.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(agent.displayName), Fehler: \(displayedErrorMessage)")
    }

    // MARK: - Skeleton / Ladezustand (Reduce-Motion-fest)

    private var skeletonContent: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            skeletonLine(trailingExtra: 0)
            skeletonLine(trailingExtra: 36)
            skeletonLine(trailingExtra: 72)
            Spacer(minLength: 0)
        }
        .padding(.top, DesignSystem.Spacing.large)
        .padding(.leading, DesignSystem.Spacing.large)
        .frame(maxWidth: .infinity, alignment: .leading)
        .opacity(reduceMotion ? 0.6 : shimmerOpacity)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 0.75).repeatForever(autoreverses: true)) {
                shimmerOpacity = 0.3
            }
        }
        .onDisappear { shimmerOpacity = 1.0 }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(agent.displayName), laedt")
        .accessibilityHint("Antwort wird generiert")
    }

    private func skeletonLine(trailingExtra: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 4, style: .continuous)
            .fill(Color.white.opacity(0.22))
            .frame(height: 11)
            .padding(.trailing, DesignSystem.Spacing.medium + trailingExtra)
            .accessibilityHidden(true)
    }
}

#Preview("AgentCard - Stack-Modus") {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 16) {
            AgentCardView(agent: .claude,  agentResponse: "Strukturiert: MVVM trennt Darstellung und Logik.", userPrompt: "Wie funktioniert MVVM?")
            AgentCardView(agent: .gemini,  agentResponse: "Fakten: ViewModel ist @MainActor und @ObservableObject.", userPrompt: "Wie funktioniert MVVM?")
            AgentCardView(agent: .mistral, agentResponse: "Praegnant: View = UI, VM = State und Logik.", userPrompt: "Wie funktioniert MVVM?")
        }
        .padding(20)
    }
    .background(Image("background").resizable().scaledToFill().ignoresSafeArea())
    .environment(\.colorScheme, .dark)
}

#Preview("AgentCard - Ladezustand") {
    HStack(spacing: 16) {
        AgentCardView(agent: .claude, agentResponse: "", userPrompt: "Test")
        AgentCardView(agent: .gemini, agentResponse: "", userPrompt: "Test")
    }
    .padding(20)
    .background(Image("background").resizable().scaledToFill().ignoresSafeArea())
    .environment(\.colorScheme, .dark)
}

#Preview("AgentCard - Fehlerzustand") {
    HStack(spacing: 16) {
        AgentCardView(agent: .claude, agentResponse: "[Claude] HTTP 401 - ungueltiger API-Key.", userPrompt: "Test")
        AgentCardView(agent: .gemini, agentResponse: "[Gemini] Netzwerkfehler: kein Internet.", userPrompt: "Test")
    }
    .padding(20)
    .background(Image("background").resizable().scaledToFill().ignoresSafeArea())
    .environment(\.colorScheme, .dark)
}
