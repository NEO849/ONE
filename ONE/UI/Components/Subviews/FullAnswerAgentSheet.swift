//
//  FullAnswerAgentSheet.swift
//  ONE
//
//  Created by Michael Fleps on 27.11.25.
//

import SwiftUI
import UIKit

/// Zeigt die vollständige Antwort eines Agenten in einem Sheet.
/// Features: Nutzerprompt als Kontext, Copy-Button mit Bestätigungsfeedback.
struct FullAnswerAgentSheet: View {

    let agent: AgentType
    let fullResponse: String
    let userPrompt: String

    @State private var showCopied: Bool = false

    var body: some View {
        ZStack {
            Image(agent.theme.backgroundAssetName)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                headerBar
                    .padding(.top, 40)
                    .padding(.bottom, 16)

                // Nutzerprompt als Kontext
                Text(userPrompt)
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.55))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .glassCard(cornerRadius: 10, borderColor: .white.opacity(0.15))
                    .padding(.bottom, 20)

                GlassDivider()
                    .padding(.bottom, 20)

                // Vollständige Antwort
                ScrollView(showsIndicators: false) {
                    Text(fullResponse)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.white.opacity(0.92))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 40)
                }
            }
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack(spacing: 12) {
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(height: 28)
                .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))

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
                Text(showCopied ? "Kopiert" : "Kopieren")
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(showCopied ? Color.green : Color.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .glassCard(
                cornerRadius: 10,
                borderColor: showCopied ? Color.green : Color.white.opacity(0.35)
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: showCopied)
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

#Preview("FullAnswerSheet – Gemini") {
    FullAnswerAgentSheet(
        agent: .gemini,
        fullResponse: "MVVM (Model-View-ViewModel) ist ein Architekturmuster, das Darstellung (View) von Logik (ViewModel) und Datenzugriff (Model/Repository) trennt. In SwiftUI wird das ViewModel typischerweise als @MainActor-Klasse mit @Published-Properties implementiert. Die View abonniert diese Properties über @EnvironmentObject oder @StateObject und rendert sich automatisch neu bei Änderungen. Vorteile: einfaches Testen der Logik ohne UI, klare Zuständigkeiten, weniger Boilerplate gegenüber UIKit.",
        userPrompt: "Erkläre MVVM in SwiftUI"
    )
    .environment(\.colorScheme, .dark)
}
