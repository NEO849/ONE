//
//  MockConversationService.swift
//  ONE
//
//  Created by Michael Fleps on 04.11.25.
//

import Foundation

/// Schein-Implementierung (schnell, stabil, #Preview-tauglich).
/// Free-Flow:
/// - Alle drei Agenten antworten auf den gleichen Prompt (mit Rollenmarkierung).
/// - ChatGPT prüft und liefert eine finale Antwort.
struct MockConversationService: ConversationProtocol {

    func planAgentPrompts(for userPrompt: String) async throws -> [AgentType: String] {
        let base = userPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
        return [
            .gemini:  "[Research] \(base)",
            .claude:  "[Structure] \(base)",
            .mistral: "[Concise] \(base)"
        ]
    }

    func fetchAgentReply(for agent: AgentType, plannedPrompt: String) async throws -> String {
        switch agent {
        case .gemini:  return "Research → \(plannedPrompt.prefix(64))…"
        case .claude:  return "Structure → \(plannedPrompt.prefix(64))…"
        case .mistral: return "Concise → \(plannedPrompt.prefix(64))…"
        case .chatgpt: return "" // ChatGPT antwortet hier erst als Final-Reply
        }
    }

    func makeFinalReply(from agentReplies: [AgentType: String], userPrompt: String) async throws -> String {
        """
        Final check:
        • Prompt: \(userPrompt.prefix(80))…
        • Gemini: \(agentReplies[.gemini]  ?? "")
        • Claude: \(agentReplies[.claude]  ?? "")
        • Mistral: \(agentReplies[.mistral] ?? "")
        """
    }
}
