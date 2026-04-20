//
//  OnboardingView.swift
//  ONE
//
//  Created by Michael Fleps on 18.04.26.
//

import SwiftUI

/// Erster Start: Nutzer gibt alle vier API-Keys ein.
/// Nach dem Speichern in die Keychain ruft die View `onComplete` auf.
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

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    headerSection
                        .padding(.top, 72)
                        .padding(.bottom, 44)

                    keyInputSection
                        .padding(.bottom, 28)

                    continueButton
                        .padding(.bottom, 56)
                }
                .padding(.horizontal, 24)
                .frame(maxWidth: 440)
                .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 20) {
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: .black.opacity(0.45), radius: 20, y: 10)
                .accessibilityHidden(true)

            VStack(spacing: 8) {
                Text("Willkommen bei ONE")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)

                Text("Verbinde deine KI-Dienste.\nDie Keys werden sicher in der Keychain gespeichert.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.55))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: - Key Inputs

    private var keyInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("API-KEYS")
                .font(.caption2.weight(.bold))
                .foregroundStyle(.white.opacity(0.35))
                .tracking(1.5)
                .padding(.leading, 4)

            VStack(spacing: 8) {
                ForEach(SecureKeyManager.APIKey.allCases, id: \.self) { apiKey in
                    APIKeyInputRow(
                        label: apiKey.displayName,
                        placeholder: apiKey.placeholder,
                        accentColor: brandColor(for: apiKey),
                        text: Binding(
                            get: { keyValues[apiKey] ?? "" },
                            set: { keyValues[apiKey] = $0 }
                        )
                    )
                }
            }
        }
    }

    // MARK: - CTA

    private var continueButton: some View {
        Button(action: saveAndContinue) {
            HStack(spacing: 8) {
                Text("Loslegen")
                    .font(.body.weight(.semibold))
                Image(systemName: "arrow.right")
                    .font(.footnote.weight(.bold))
                    .accessibilityHidden(true)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(allFilled ? Color.blue : Color.white.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(
                        allFilled ? Color.clear : Color.white.opacity(0.12),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(!allFilled)
        .animation(.easeInOut(duration: 0.2), value: allFilled)
        .accessibilityLabel("Einrichtung abschließen")
        .accessibilityHint(allFilled
            ? "Speichert alle API-Keys und startet die App"
            : "Bitte alle vier API-Keys ausfüllen"
        )
    }

    // MARK: - Helpers

    private func brandColor(for key: SecureKeyManager.APIKey) -> Color {
        let name = key.displayName.lowercased()
        if name.contains("gemini")  { return Color(red: 0.26, green: 0.52, blue: 0.98) }
        if name.contains("claude")  { return Color(red: 0.88, green: 0.55, blue: 0.28) }
        if name.contains("mistral") { return Color(red: 0.95, green: 0.36, blue: 0.24) }
        if name.contains("chatgpt") || name.contains("openai") { return Color(red: 0.11, green: 0.73, blue: 0.57) }
        return .blue
    }

    private func saveAndContinue() {
        for apiKey in SecureKeyManager.APIKey.allCases {
            let value = (keyValues[apiKey] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            SecureKeyManager.save(key: apiKey, value: value)
        }
        onComplete()
    }
}

// MARK: - APIKeyInputRow (auch in SettingsView genutzt)

struct APIKeyInputRow: View {

    let label: String
    let placeholder: String
    var accentColor: Color = .blue
    @Binding var text: String
    @State private var isRevealed: Bool = false
    @FocusState private var isFocused: Bool

    private var isFilled: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 7) {
                Circle()
                    .fill(accentColor)
                    .frame(width: 6, height: 6)

                Text(label)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.7))

                Spacer()

                if isFilled {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(Color.green.opacity(0.85))
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 11)
            .padding(.bottom, 7)

            Rectangle()
                .fill(Color.white.opacity(0.07))
                .frame(height: 1)

            HStack(spacing: 0) {
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
                .focused($isFocused)
                .padding(.leading, 14)
                .padding(.vertical, 11)
                .accessibilityLabel("\(label) API-Key")

                Button {
                    isRevealed.toggle()
                } label: {
                    Image(systemName: isRevealed ? "eye.slash" : "eye")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.35))
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isRevealed ? "\(label) Key verbergen" : "\(label) Key anzeigen")
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .fill(Color.white.opacity(isFocused ? 0.09 : 0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .strokeBorder(
                    isFocused
                        ? accentColor.opacity(0.55)
                        : (isFilled ? Color.white.opacity(0.18) : Color.white.opacity(0.09)),
                    lineWidth: 1
                )
        )
        .animation(.easeInOut(duration: 0.15), value: isFocused)
        .animation(.easeInOut(duration: 0.2), value: isFilled)
    }
}

#Preview("Onboarding – Leere Keys") {
    OnboardingView(onComplete: {})
        .environment(\.colorScheme, .dark)
}
