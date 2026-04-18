//
//  SettingsView.swift
//  ONE
//
//  Created by Michael Fleps on 18.04.26.
//

import SwiftUI

/// Einstellungen: API-Keys nachträglich bearbeiten.
/// Wird aus ContentView als Sheet gezeigt.
/// Nach dem Speichern wird `onSave` aufgerufen –
/// ContentView wechselt den Service auf RealConversationService.
struct SettingsView: View {

    let onSave: () -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var keyValues: [SecureKeyManager.APIKey: String] = Dictionary(
        uniqueKeysWithValues: SecureKeyManager.APIKey.allCases.map { ($0, "") }
    )

    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                headerBar

                ScrollView {
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

                        saveButton
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .padding(.bottom, 48)
                }
            }
        }
        .onAppear(perform: loadExistingKeys)
    }

    // MARK: - Subviews

    private var headerBar: some View {
        HStack {
            Text("API-Keys")
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)

            Spacer()

            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.7))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 20)
    }

    private var saveButton: some View {
        Button(action: saveAndDismiss) {
            Text("Speichern")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .glassCard(cornerRadius: 16, borderColor: .blue)
        }
        .buttonStyle(.plain)
        .padding(.top, 8)
    }

    // MARK: - Logik

    private func loadExistingKeys() {
        for apiKey in SecureKeyManager.APIKey.allCases {
            keyValues[apiKey] = SecureKeyManager.load(key: apiKey) ?? ""
        }
    }

    private func saveAndDismiss() {
        for apiKey in SecureKeyManager.APIKey.allCases {
            let value = (keyValues[apiKey] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            SecureKeyManager.save(key: apiKey, value: value)
        }
        onSave()
        dismiss()
    }
}

#Preview("Settings – Leere Keys") {
    SettingsView(onSave: {})
        .environment(\.colorScheme, .dark)
}
