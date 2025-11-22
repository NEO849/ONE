//
//  UserPromptBubbleView.swift
//  ONE
//
//  Created by Michael Fleps on 04.11.25.
//

import SwiftUI

///  Darstellung der Eingabe des Nutzers als Bubble.
struct UserPromptBubbleView: View {
    let promptText: String
    
    var body: some View {
        HStack(alignment: .bottom) {
            Text(promptText)
                .font(.callout)
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            Spacer(minLength: 0) // ✅ HStack nimmt volle Breite ein
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
