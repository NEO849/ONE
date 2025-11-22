//
//  UserPromptBubbleView.swift
//  ONE
//
//  Created by Michael Fleps on 04.11.25.
//

import SwiftUI

/// 🗣 Darstellung der Eingabe des Nutzers als Bubble.
/// Wird immer vor den Antworten der Agenten dargestellt.
struct UserPromptBubbleView: View {
    let promptText: String  // 💬 Inhalt der Nutzereingabe

    var body: some View {
        HStack(alignment: .bottom) {
            // 👤 Icon links neben dem Text
            Image(systemName: "person.fill")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .padding(6)
                .background(Color.white.opacity(0.15))
                .clipShape(Circle())

            Text(promptText)
                .font(.callout)
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
//        .padding(.horizontal, 12)          // ⬅️ neuer Rahmen
//        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)       // ⬅️ zentriert sich automatisch
    }
}

#Preview("UserPromptBubble – Beispiel") {
    UserPromptBubbleView(promptText: "Erkläre mir MVVM in SwiftUI mit einem kleinen Beispiel.")
        .padding(20)
        .background(
            Image("background").resizable().scaledToFill()
        )
        .environment(\.colorScheme, .dark)
}
