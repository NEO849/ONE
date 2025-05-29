//
//  ClaudeCardMessage.swift
//  ONE
//
//  Created by Michael Fleps on 29.05.25.
//

import SwiftUI

/// Nachrichten-Blase im eleganten Card-Design mit Glanzkante
struct ClaudeCardMessage: View {
    let message: ClaudeMessage

    var isUser: Bool {
        message.role == .user
    }

    var body: some View {
        HStack {
            if isUser { Spacer() }

            VStack(alignment: .leading, spacing: 6) {
                Text(message.role == .user ? "Du:" : "Claude:")
                    .font(.caption)
                    .foregroundColor(.gray)

                Text(message.content)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .cornerRadius(18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .strokeBorder(isUser ? Color.blue : Color.gray.opacity(0.6), lineWidth: 1)
                            .shadow(color: isUser ? .blue.opacity(0.3) : .gray.opacity(0.3), radius: 6)
                    )
            }
            .frame(maxWidth: 280, alignment: isUser ? .trailing : .leading)

            if !isUser { Spacer() }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

#Preview {
    ClaudeCardMessage(message: ClaudeMessage(role: .user, content: "Hallo Claude!"))
}
