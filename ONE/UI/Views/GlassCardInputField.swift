//
//  GlassCardInputField.swift
//  ONE
//
//  Created by Michael Fleps on 06.11.25.
//

import SwiftUI

/// Eingabefeld mit Glaseffekt – optisch passend zum UI.
/// Beziehung:
/// - Wird in ContentView als unterer Eingabebereich verwendet.
/// - Nutzt Binding für Text, Busy-Status und Fokus.
/// - Sendet bei Return-Taste oder Senden-Button die Eingabe nach außen.
struct GlassCardInputField: View {

    @Binding var text: String
    var isBusy: Bool = false
    var onSend: () -> Void

    @FocusState.Binding var isInputFocused: Bool

    private let accentBlue: Color = .blue

    var body: some View {
        HStack(spacing: 14) {
            TextField("Schreibe etwas für ONE …", text: $text, axis: .vertical)
                .textFieldStyle(.plain)
                .foregroundColor(.white.opacity(0.92))
                .lineLimit(1...4)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(accentBlue.opacity(0.45), lineWidth: 1)
                        .shadow(color: accentBlue.opacity(0.25), radius: 6)
                )
                .focused($isInputFocused)
                .submitLabel(.send)
                .onSubmit {
                    sendInputText()
                }
                .accessibilityLabel("Nachricht eingeben")
                .accessibilityHint("Deine Frage wird an alle vier KI-Agenten gesendet")

            Button {
                sendInputText()
            } label: {
                Image(systemName: isBusy ? "hourglass" : "paperplane.fill")
                    .font(.title2)
                    .foregroundColor(accentBlue)
                    .rotationEffect(.degrees(isBusy ? 180 : 0))
                    .animation(.easeInOut(duration: 0.3), value: isBusy)
                    .frame(width: 44, height: 44)
            }
            .disabled(isBusy || isTrimmedTextEmpty)
            .opacity(isBusy || isTrimmedTextEmpty ? 0.4 : 1.0)
            .accessibilityLabel(isBusy ? "Anfrage wird verarbeitet" : "Senden")
            .accessibilityHint(isBusy ? "" : "Sendet die Nachricht an alle KI-Agenten")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(accentBlue.opacity(0.22), lineWidth: 1)
        )
        .shadow(radius: 3)
    }

    private var isTrimmedTextEmpty: Bool {
        text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func sendInputText() {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        guard !isBusy else { return }
        onSend()
        isInputFocused = false
    }
}

#Preview("GlassCardInputField – Vorschau") {
    @Previewable @State var previewText: String = "Schreibe etwas für ONE …"
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
            .padding(.bottom, 8)
        }
    }
    .environment(\.colorScheme, .dark)
}
