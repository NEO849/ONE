//
//  UserPromptBubbleView.swift
//  ONE
//
//  Created by Michael Fleps on 04.11.25.
//

import SwiftUI

/// Gläserne Bubble für die Benutzer-Eingabe eines Steps.
struct UserPromptBubbleView: View {
    let promptText: String
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "person.fill")
                .imageScale(.large)
                .foregroundStyle(.gray.opacity(0.9))
                .frame(width: 24)
            Text(promptText)
                .font(.body)
                .foregroundStyle(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .glassCard(cornerRadius: 22, borderColor: .blue)    }
}

#Preview("UserPromptBubble – Beispiel") {
    UserPromptBubbleView(promptText: "Erkläre mir MVVM in SwiftUI mit einem kleinen Beispiel.")
        .padding(20)
        .background(
            Image("background").resizable().scaledToFill()
        )
        .environment(\.colorScheme, .dark)
}
