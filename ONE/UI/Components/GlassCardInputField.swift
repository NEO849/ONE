//
//  GlassCardInputField.swift
//  ONE
//
//  Created by Michael Fleps on 06.11.25.
//

import SwiftUI

/// Eingabefeld mit Glaseffekt – konsistent zum Design der Chat-Ansicht.
/// Beziehung:
/// - Wird in der ContentView unten als Eingabe für neue Prompts eingebunden.
/// - Nutzt Binding für den Text und eine Callback-Funktion beim Absenden.
struct GlassCardInputField: View {

    @Binding var text: String                      // Zwei-Wege-Bindung zum Eingabetext
    var isBusy: Bool = false                       // Zeigt Ladezustand (z. B. während KI antwortet)
    var onSend: () -> Void                         // Aktion beim Absenden

    @FocusState.Binding var isInputFocused: Bool   // Fokusbindung (öffnet/schließt Tastatur)

    private let accentBlue: Color = .blue          // Designfarbe für Senden-Knopf

    var body: some View {
        // Text leer prüfen (leer nach Trimmen?)
        let isTextEmpty = text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        HStack(spacing: 14) {
            // Textfeld – kann ein- oder mehrzeilig sein
            TextField("Schreibe etwas für ONE …", text: $text, axis: .vertical)
                .textFieldStyle(.plain)
                .foregroundColor(.white.opacity(0.9))        // Textfarbe
                .padding(12)
                .background(.ultraThinMaterial)              // Blur-Hintergrund
                .cornerRadius(18)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(accentBlue.opacity(0.45), lineWidth: 1)
                        .shadow(color: accentBlue.opacity(0.3), radius: 6)
                )
                .focused($isInputFocused)                    // Fokussteuerung
                .submitLabel(.send)                          // Tastatur-Taste zeigt „Senden“
                .onSubmit {
                    guard !isTextEmpty, !isBusy else { return }
                    onSend()
                    isInputFocused = false                   // Fokus schließen = Tastatur zu
                }

            // Senden-Knopf (rechts)
            Button {
                guard !isTextEmpty, !isBusy else { return }
                onSend()
                isInputFocused = false
            } label: {
                Image(systemName: isBusy ? "hourglass" : "paperplane.fill")
                    .font(.title2)
                    .foregroundColor(accentBlue)
                    .rotationEffect(.degrees(isBusy ? 180 : 0)) // Animation bei Busy
                    .animation(.easeInOut(duration: 0.3), value: isBusy)
            }
            .disabled(isBusy || isTextEmpty)
            .opacity(isBusy || isTextEmpty ? 0.4 : 1.0)        // Button ausgrauen
        }
        .padding(.horizontal, 12)           // Innerer Abstand links/rechts
        .padding(.vertical, 10)            // Innerer Abstand oben/unten
        .background(.ultraThinMaterial)    // Gesamter Hintergrund (Blur)
        .cornerRadius(22)
        .shadow(radius: 3)
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
