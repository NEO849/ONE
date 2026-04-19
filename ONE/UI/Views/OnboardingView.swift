//
//  OnboardingView.swift
//  ONE
//
//  Created by Michael Fleps on 18.04.26.
//

import SwiftUI

/// Erster Start: Nutzer gibt alle vier API-Keys ein.
/// Nach dem Speichern in die Keychain ruft die View `onComplete` auf –
/// ONEApp wechselt dann auf den RealConversationService.
struct OnboardingView: View {

    let onComplete: () -> Void

    @State private var keyValues: [SecureKeyManager.APIKey: String] = Dictionary(
        uniqueKeysWithValues: SecureKeyManager.APIKey.allCases.map { ($0, "") }
    )

    private var allFilled: Bool {
        SecureKeyManager.APIKey.allCases.allSatisfy {
            !(keyValues[$0] ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .accessibilityHidden(true)

            ScrollView {
                VStack(spacing: 32) {
                    headerSection
                    keyInputSection
                    continueButton
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
            }
        }
    }

    // MARK: - Subviews

    private var headerSection: some View {
        VStack(spacing: 16) {
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .padding(.top, 64)
                .accessibilityHidden(true)

            Text("API-Keys einrichten")
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)

            Text("Hinterlege deine persönlichen API-Keys.\nSie werden sicher in der Keychain gespeichert.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
    }

    private var keyInputSection: some View {
        VStack(spacing: 16) {
            ForEach(SecureKeyManager.APIKey.allCases, id: \.self) { apiKey in
                APIKeyInputRow(
                    label: apiKey.displayName,
                    placeholder: apiKey.placeholder,
                    text: Binding(
                        get: { keyValues[apiKey] ?? "" },
                        set: { keyValues[apiKey] = $0 }
                    )
                )
            }
        }
    }

    private var continueButton: some View {
        Button(action: saveAndContinue) {
            Text("Loslegen")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .glassCard(
                    cornerRadius: 16,
                    borderColor: allFilled ? Color.blue : Color.white.opacity(0.3)
                )
        }
        .buttonStyle(.plain)
        .disabled(!allFilled)
        .opacity(allFilled ? 1.0 : 0.5)
        .animation(.easeInOut(duration: 0.2), value: allFilled)
        .accessibilityLabel("Einrichtung abschließen")
        .accessibilityHint(allFilled
            ? "Speichert alle API-Keys und startet die App"
            : "Bitte alle vier API-Keys ausfüllen"
        )
    }

    // MARK: - Logik

    private func saveAndContinue() {
        for apiKey in SecureKeyManager.APIKey.allCases {
            let value = (keyValues[apiKey] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            SecureKeyManager.save(key: apiKey, value: value)
        }
        onComplete()
    }
}

// MARK: - Wiederverwendbares Eingabefeld (auch in SettingsView genutzt)

/// Einzelnes API-Key-Eingabefeld mit Sichtbarkeits-Toggle.
struct APIKeyInputRow: View {

    let label: String
    let placeholder: String
    @Binding var text: String
    @State private var isRevealed: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.8))

            HStack(spacing: 12) {
                Group {
                    if isRevealed {
                        TextField(placeholder, text: $text)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    } else {
                        SecureField(placeholder, text: $text)
                    }
                }
                .font(.subheadline)
                .foregroundStyle(.white)
                .accessibilityLabel("\(label) API-Key")

                Button {
                    isRevealed.toggle()
                } label: {
                    Image(systemName: isRevealed ? "eye.slash" : "eye")
                        .foregroundStyle(.white.opacity(0.6))
                        .frame(width: 24, height: 24)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isRevealed
                    ? "\(label) Key verbergen"
                    : "\(label) Key anzeigen"
                )
            }
            .padding(14)
            .glassCard(cornerRadius: 12, borderColor: .white.opacity(0.3))
        }
    }
}

#Preview("Onboarding – Leere Keys") {
    OnboardingView(onComplete: {})
        .environment(\.colorScheme, .dark)
}
