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
                .focused($isInputFocused)    // Fokussteuerung
                .submitLabel(.continue)          // Tastatur zeigt „Enter“

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
        .padding(.trailing, 120)           // Innerer Abstand links/rechts
        .padding(.leading, 22)
        .padding(.vertical, 14)            // Innerer Abstand oben/unten
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
