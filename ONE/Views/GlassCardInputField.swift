//
//  GlassCardInputField.swift
//  ONE
//
//  Created by Michael Fleps on 29.05.25.
//

import SwiftUI

/// Eingabefeld im Glassmorphism-Stil mit leuchtendem Rand und Glaseffekt
struct GlassCardInputField: View {
    
    @Binding var text: String              // Bindung an das ViewModel
    var onSend: () -> Void                 // Aktion bei Button-Tap

    var body: some View {
        HStack(spacing: 12) {
            // Eingabe
            TextField("Schreibe etwas für Claude ...", text: $text)
                .foregroundColor(.white)
                .padding(14)
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.blue.opacity(0.5), lineWidth: 1)
                        .shadow(color: .blue.opacity(0.3), radius: 8)
                )

            // Senden-Button
            Button(action: onSend) {
                Image(systemName: "paperplane.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            .disabled(text.isEmpty)
            .opacity(text.isEmpty ? 0.5 : 1)
        }
        .padding(.horizontal)
    }
}

#Preview {
    GlassCardInputField(text: .constant(""), onSend: {})
        .padding()
}
