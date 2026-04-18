//
//  MockConversationService.swift
//  ONE
//
//  Created by Michael Fleps on 04.11.25.
//

import Foundation

/// Schein-Implementierung – schnell, stabil, #Preview-tauglich.
/// Realistische async-Delays sorgen dafür, dass der Shimmer-Ladezustand
/// in Previews und auf dem Simulator sichtbar ist.
struct MockConversationService: ConversationProtocol {

    func planAgentPrompts(for userPrompt: String) async throws -> [AgentType: String] {
        // Kurze Planungsphase simulieren
        try await Task.sleep(for: .milliseconds(300))
        let base = userPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
        return [
            .gemini:  "[Research] \(base)",
            .claude:  "[Structure] \(base)",
            .mistral: "[Concise] \(base)"
        ]
    }

    func fetchAgentReply(for agent: AgentType, plannedPrompt: String) async throws -> String {
        // Versetzt: Mistral antwortet zuerst, dann Gemini, zuletzt Claude –
        // so ist das progressive Update der Karten gut sichtbar.
        let delayMs: Int
        switch agent {
        case .gemini:  delayMs = 1_400
        case .claude:  delayMs = 2_100
        case .mistral: delayMs =   900
        case .chatgpt: delayMs =     0
        }
        if delayMs > 0 {
            try await Task.sleep(for: .milliseconds(delayMs))
        }
        switch agent {
        case .gemini:  return "[Gemini] Fakten & Quellen: \(plannedPrompt.prefix(80))…"
        case .claude:  return "[Claude] Strukturiert: \(plannedPrompt.prefix(80))…"
        case .mistral: return "[Mistral] Prägnant: \(plannedPrompt.prefix(80))…"
        case .chatgpt: return ""
        }
    }

    func makeFinalReply(from agentReplies: [AgentType: String], userPrompt: String) async throws -> String {
        try await Task.sleep(for: .milliseconds(1_500))
        return """
        ✅ Finale Prüfung (ChatGPT):
        • Gemini: \(agentReplies[.gemini]  ?? "–")
        • Claude: \(agentReplies[.claude]  ?? "–")
        • Mistral: \(agentReplies[.mistral] ?? "–")
        """
    }
}
