//
//  GlassCardInputField.swift
//  ONE
//
//  Created by Michael Fleps on 06.11.25.
//

import SwiftUI

/// Eingabefeld im Command-Bar-Stil – Text oben, Aktionsleiste unten.
/// Beziehung:
/// - Wird in ContentView als unterer Eingabebereich verwendet.
/// - Nutzt Binding für Text, Busy-Status und Fokus.
struct GlassCardInputField: View {

    @Binding var text: String
    var isBusy: Bool = false
    var onSend: () -> Void

    @FocusState.Binding var isInputFocused: Bool

    private var isTrimmedEmpty: Bool {
        text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var canSend: Bool { !isTrimmedEmpty && !isBusy }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Texteingabe
            TextField("Stell eine Frage an alle vier KI-Agenten …", text: $text, axis: .vertical)
                .textFieldStyle(.plain)
                .font(.body)
                .foregroundStyle(.white)
                .lineLimit(1...6)
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 10)
                .focused($isInputFocused)
                .submitLabel(.send)
                .onSubmit { handleSend() }
                .accessibilityLabel("Nachricht eingeben")
                .accessibilityHint("Deine Frage wird an alle vier KI-Agenten gesendet")

            // Aktionsleiste
            HStack(alignment: .center, spacing: 0) {
                Text(isBusy ? "Agenten antworten …" : "⏎  Senden")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.28))
                    .padding(.leading, 16)

                Spacer()

                Button(action: handleSend) {
                    ZStack {
                        Circle()
                            .fill(canSend ? Color.blue : Color.white.opacity(0.08))
                            .frame(width: 32, height: 32)

                        if isBusy {
                            ProgressView()
                                .tint(.white.opacity(0.6))
                                .scaleEffect(0.65)
                        } else {
                            Image(systemName: "arrow.up")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(canSend ? .white : .white.opacity(0.25))
                        }
                    }
                }
                .buttonStyle(.plain)
                .disabled(!canSend)
                .padding(.trailing, 10)
                .animation(.easeInOut(duration: 0.15), value: canSend)
                .accessibilityLabel(isBusy ? "Anfrage wird verarbeitet" : "Senden")
                .accessibilityHint(isBusy ? "" : "Sendet die Nachricht an alle KI-Agenten")
            }
            .frame(height: 48)
        }
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(
                    isInputFocused ? Color.blue.opacity(0.45) : Color.white.opacity(0.10),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.15), radius: 12, y: 4)
        .animation(.easeInOut(duration: 0.2), value: isInputFocused)
    }

    private func handleSend() {
        guard canSend else { return }
        onSend()
        isInputFocused = false
    }
}

#Preview("GlassCardInputField – Vorschau") {
    @Previewable @State var previewText: String = ""
    @FocusState var isPreviewFocused: Bool

    ZStack {
        Image("background")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()

        VStack {
            Spacer()
            GlassCardInputField(
                text: $previewText,
                isBusy: false,
                onSend: {
                    print("Gesendet: \(previewText)")
                    previewText = ""
                    isPreviewFocused = false
                },
                isInputFocused: $isPreviewFocused
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
    }
    .environment(\.colorScheme, .dark)
}
