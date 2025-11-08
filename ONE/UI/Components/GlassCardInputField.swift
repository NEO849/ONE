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
    @Binding var text: String
    var isBusy: Bool = false
    var onSend: () -> Void
    
    @FocusState.Binding var isInputFocused: Bool  // 🔹 Fokuszustand wird von außen gesetzt
    
    private let accentBlue: Color = .blue

    var body: some View {
        let isTextEmpty = text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        HStack(spacing: 22) {
            // Textfeld mit Fokusbindung
            TextField("Schreibe etwas für ONE …", text: $text, axis: .vertical)
                .textFieldStyle(.plain)
                .foregroundColor(.gray)
                .padding(12)
                .background(.ultraThinMaterial)
                .cornerRadius(18)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(accentBlue.opacity(0.45), lineWidth: 1)
                        .shadow(color: accentBlue.opacity(0.3), radius: 6)
                )
                .padding(.leading, 12)
                .submitLabel(.send)
                .focused($isInputFocused)  // 🔹 Fokusbindung
                .onSubmit {
                    guard !isTextEmpty, !isBusy else { return }
                    onSend()
                    isInputFocused = false // 🔹 Fokus entfernen → Tastatur schließen
                }

            Button {
                guard !isTextEmpty, !isBusy else { return }
                onSend()
                isInputFocused = false // 🔹 Fokus entfernen
            } label: {
                Image(systemName: isBusy ? "hourglass" : "paperplane.fill")
                    .font(.title2)
                    .foregroundColor(accentBlue)
                    .rotationEffect(.degrees(isBusy ? 180 : 0))
                    .animation(.easeInOut(duration: 0.3), value: isBusy)
            }
           
            .disabled(isBusy || isTextEmpty)
            .opacity(isBusy || isTextEmpty ? 0.5 : 1)
            .padding(.trailing, 12)
        }
//        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .glassCard(cornerRadius: 22, borderColor: accentBlue)
        .frame(maxWidth: .infinity)
        
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
          //  .padding(.horizontal, 32)
            .padding(.bottom, 8)
        }
    }
    .environment(\.colorScheme, .dark)
}
