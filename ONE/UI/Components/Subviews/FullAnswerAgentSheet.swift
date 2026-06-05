//
//  FullAnswerAgentSheet.swift
//  ONE
//
//  Created by Michael Fleps on 27.11.25.
//

import SwiftUI
import UIKit

/// Zeigt die vollstaendige Antwort eines Agenten in einem Sheet.
/// Features: Nutzerprompt als Kontext, Copy-Button mit Bestaetigungsfeedback.
/// Hintergrund ist jetzt einheitlich (App-Hintergrund) mit dezentem Agent-Akzent oben.
struct FullAnswerAgentSheet: View {

    let agent: AgentType
    let fullResponse: String
    let userPrompt: String

    @State private var showCopied: Bool = false

    private var accent: Color { agent.theme.accentColor }

    var body: some View {
        ZStack(alignment: .top) {
            // Einheitlicher App-Hintergrund (konsistent zur Hauptansicht)
            Image("background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .accessibilityHidden(true)

            // Dezenter Farb-Akzent oben in der Agentenfarbe
            LinearGradient(
                colors: [accent.opacity(0.22), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 170)
            .ignoresSafeArea()
            .allowsHitTesting(false)
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 0) {
                headerBar
                    .padding(.top, DesignSystem.Spacing.huge)
                    .padding(.bottom, DesignSystem.Spacing.large)

                // Nutzerprompt als Kontext
                Text(userPrompt)
                    .font(.footnote)
                    .foregroundStyle(DesignSystem.Surface.textSecondary)
                    .padding(.horizontal, DesignSystem.Spacing.medium)
                    .padding(.vertical, DesignSystem.Spacing.small + 2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .glassCard(cornerRadius: DesignSystem.Radius.small, borderColor: .white.opacity(0.15))
                    .padding(.bottom, DesignSystem.Spacing.large)
                    .accessibilityLabel("Deine Frage: \(userPrompt)")

                GlassDivider()
                    .padding(.bottom, DesignSystem.Spacing.large)
                    .accessibilityHidden(true)

                // Vollstaendige Antwort
                ScrollView(showsIndicators: false) {
                    Text(fullResponse)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(DesignSystem.Surface.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                        .padding(.bottom, DesignSystem.Spacing.huge)
                        .accessibilityLabel("Antwort von \(agent.displayName): \(fullResponse)")
                        .accessibilityAddTraits(.updatesFrequently)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.xlarge)
        }
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack(spacing: DesignSystem.Spacing.medium) {
            // Kleiner Agent-Akzentpunkt fuer dezente Identitaet
            Circle()
                .fill(accent)
                .frame(width: 9, height: 9)
                .accessibilityHidden(true)

            Text(agent.displayName)
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)

            Spacer()

            copyButton
        }
    }

    private var copyButton: some View {
        Button(action: copyToClipboard) {
            HStack(spacing: 5) {
                Image(systemName: showCopied ? "checkmark" : "doc.on.doc")
                    .font(.caption.weight(.semibold))
                    .accessibilityHidden(true)
                Text(showCopied ? "Kopiert" : "Kopieren")
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(showCopied ? Color.green : Color.white)
            .padding(.horizontal, DesignSystem.Spacing.medium)
            .padding(.vertical, DesignSystem.Spacing.small)
            .glassCard(
                cornerRadius: DesignSystem.Radius.small,
                borderColor: showCopied ? Color.green : Color.white.opacity(0.35)
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .sensoryFeedback(trigger: showCopied) { _, newValue in
            newValue ? .success : nil
        }
        .animation(DesignSystem.Motion.standard, value: showCopied)
        .accessibilityLabel(showCopied ? "In Zwischenablage kopiert" : "Antwort kopieren")
        .accessibilityHint(showCopied ? "" : "Kopiert die vollstaendige Antwort in die Zwischenablage")
    }

    // MARK: - Logik

    private func copyToClipboard() {
        UIPasteboard.general.string = fullResponse
        showCopied = true
        Task {
            try? await Task.sleep(for: .seconds(2))
            showCopied = false
        }
    }
}

#Preview("FullAnswerSheet - Gemini") {
    FullAnswerAgentSheet(
        agent: .gemini,
        fullResponse: "MVVM trennt Darstellung (View) von Logik (ViewModel) und Datenzugriff (Model). In SwiftUI ist das ViewModel meist eine @MainActor-Klasse mit @Published-Properties. Die View reagiert automatisch auf Aenderungen. Vorteile: einfaches Testen, klare Zustaendigkeiten, weniger Boilerplate.",
        userPrompt: "Erklaere MVVM in SwiftUI"
    )
    .environment(\.colorScheme, .dark)
}
