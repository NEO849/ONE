//
//  ClaudeMessage.swift
//  ONE
//
//  Created by Michael Fleps on 29.05.25.
//

import Foundation

struct ClaudeMessage: Identifiable, Codable {
    let id: UUID
    let role: MessageRole
    let content: String

    /// NEU: Ob diese Nachricht markiert ist (z. B. für Timeline oder Filter)
    var isMarked: Bool = false

    init(id: UUID = UUID(), role: MessageRole, content: String, isMarked: Bool = false) {
        self.id = id
        self.role = role
        self.content = content
        self.isMarked = isMarked
    }
}

/// Enum für die Rolle der Nachricht, z. B. Nutzer oder Claude
enum MessageRole: String, Codable {
    case user       // Eingabe durch den Benutzer
    case assistant  // Antwort durch Claude
}
