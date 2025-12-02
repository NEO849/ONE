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

    @Binding var text: String                                                                          // Source of Truth kommt von außen
    var isBusy: Bool = false                                                                           // Busy: sperrt Senden
    var onSend: () -> Void                                                                             // Callback nach außen

    @FocusState.Binding var isInputFocused: Bool                                                       // Fokus-Binding für Keyboard

    private let accentBlue: Color = .blue                                                              // Akzentfarbe

    var body: some View {
        HStack(spacing: 14) {
            TextField("Schreibe etwas für ONE …", text: $text, axis: .vertical)                         // Mehrzeilig möglich
                .textFieldStyle(.plain)
                .foregroundColor(.white.opacity(0.92))
                .lineLimit(1...4)                                                                      // Max 4 Zeilen -> UI bleibt stabil
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)                                                        // Feld-Glas
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(accentBlue.opacity(0.45), lineWidth: 1)
                        .shadow(color: accentBlue.opacity(0.25), radius: 6)
                )
                .focused($isInputFocused)                                                              // Fokus steuert Tastatur
                .submitLabel(.send)                                                                    // „Senden“ auf der Tastatur
                .onSubmit {                                                                            // Return-Taste sendet
                    sendInputText()                                                                    // Gleiche Logik wie Button
                }

            Button {
                sendInputText()                                                                        // Senden über Button
            } label: {
                Image(systemName: isBusy ? "hourglass" : "paperplane.fill")
                    .font(.title2)
                    .foregroundColor(accentBlue)
                    .rotationEffect(.degrees(isBusy ? 180 : 0))
                    .animation(.easeInOut(duration: 0.3), value: isBusy)
                    .frame(width: 44, height: 44)                                                      // Fixe Touch-Fläche
            }
            .disabled(isBusy || isTrimmedTextEmpty)                                                    // Guard via UI
            .opacity(isBusy || isTrimmedTextEmpty ? 0.4 : 1.0)
        }
        .padding(.horizontal, 14)                                                                      // Außen-Padding der gesamten Bar
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)                                                                // Bar-Glas (einmal!)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(accentBlue.opacity(0.22), lineWidth: 1)
        )
        .shadow(radius: 3)
    }

    private var isTrimmedTextEmpty: Bool {                                                             // Hilfswert für Guard-Logik
        text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty                                   // Leer nach Trimmen?
    }

    private func sendInputText() {                                                                     // Zentrale Sende-Funktion
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)                         // Input bereinigen
        guard !trimmedText.isEmpty else { return }                                                     // Guard: nichts senden
        guard !isBusy else { return }                                                                  // Guard: nicht doppelt senden
        onSend()                                                                                       // Callback nach außen (VM macht Request)
        isInputFocused = false                                                                         // Tastatur schließen nach Senden
    }
}

#Preview("GlassCardInputField – Vorschau") {
    // Hilfs-Wrapper für Preview mit Fokussteuerung
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
                    isPreviewFocused = false // Tastatur schließen
                },
                isInputFocused: $isPreviewFocused // Fokus-Binding für Preview
            )
            .padding(.bottom, 8)
        }
    }
    .environment(\.colorScheme, .dark)
}
