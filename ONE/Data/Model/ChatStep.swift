//
//  ChatStep.swift
//  ONE
//
//  Created by Michael Fleps on 04.11.25.
//

import Foundation

/// Ein einzelner Benutzer-Schritt innerhalb einer Runde.
/// Beziehung:
/// - Entsteht, wenn der Nutzer eine Eingabe tätigt.
/// - Die drei Nicht-ChatGPT-Agenten antworten separat (Map).
/// - ChatGPT liefert danach eine finale, geprüfte Antwort.
struct ChatStep: Codable, Identifiable {
    let id: String
    let userPrompt: String
    private(set) var agentReplies: [AgentType: String]  // Agent → Antwort (3 Stück)
    private(set) var finalReply: String?                // ChatGPT-Überprüfung

    init(userPrompt: String) {
        self.id = UUID().uuidString
        self.userPrompt = userPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.agentReplies = [:]
        self.finalReply = nil
    }

    // MARK: - Schreiben (mutating, da Struct-Wert geändert wird)
    /// Setzt oder ersetzt die Antwort eines Nicht-ChatGPT-Agenten.
    mutating func setAgentReply(agent: AgentType, text: String) {
        guard agent != .chatgpt else { return } // ChatGPT gehört in `finalReply`
        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return }  // leere Antworten ignorieren
        agentReplies[agent] = cleaned
    }

    /// Setzt die finale Antwort (ChatGPT prüft die drei Agenten + Prompt).
    mutating func setFinalReply(text: String) {
        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return }
        finalReply = cleaned
    }

    // MARK: - Lesen (UI-Bequemlichkeit)
    /// Holt optional die Antwort eines Agenten.
    func reply(for agent: AgentType) -> String? { agentReplies[agent] }

    /// True, wenn alle drei Agenten geantwortet haben.
    var allAgentsReplied: Bool {
        [.gemini, .claude, .mistral].allSatisfy { agentReplies[$0] != nil }
    }
}
