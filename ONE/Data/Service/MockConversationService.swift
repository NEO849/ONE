//
//  MockConversationService.swift
//  ONE
//
//  Created by Michael Fleps on 04.11.25.
//

import Foundation

/// Schein-Implementierung – schnell, stabil, #Preview-tauglich.
/// fetchAgentStream / makeFinalStream liefern einen realistischen Wort-für-Wort
/// Tipp-Effekt (60 ms/Wort), damit Skeleton-Shimmer und Streaming-UI
/// im Simulator und in Previews sichtbar sind.
struct MockConversationService: ConversationProtocol {

    // MARK: - Batch (Fallback)

    func planAgentPrompts(for userPrompt: String) async throws -> [AgentType: String] {
        try await Task.sleep(for: .milliseconds(300))
        let base = userPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
        return [
            .gemini:  "[Research] \(base)",
            .claude:  "[Structure] \(base)",
            .mistral: "[Concise] \(base)"
        ]
    }

    func fetchAgentReply(for agent: AgentType, plannedPrompt: String) async throws -> String {
        let delayMs: Int
        switch agent {
        case .gemini:  delayMs = 1_400
        case .claude:  delayMs = 2_100
        case .mistral: delayMs =   900
        case .chatgpt: delayMs =     0
        }
        if delayMs > 0 { try await Task.sleep(for: .milliseconds(delayMs)) }
        return mockText(for: agent, prompt: plannedPrompt)
    }

    func makeFinalReply(from agentReplies: [AgentType: String], userPrompt: String) async throws -> String {
        try await Task.sleep(for: .milliseconds(1_500))
        return finalText(from: agentReplies)
    }

    // MARK: - Streaming (Wort-für-Wort Tipp-Effekt)

    func fetchAgentStream(for agent: AgentType, plannedPrompt: String) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                // Kurze Initialverzögerung pro Agent, damit die Karten versetzt zu tippen beginnen
                let initialDelayMs: Int
                switch agent {
                case .gemini:  initialDelayMs = 700
                case .claude:  initialDelayMs = 1_050
                case .mistral: initialDelayMs = 450
                case .chatgpt: continuation.finish(); return
                }
                try? await Task.sleep(for: .milliseconds(initialDelayMs))

                let words = mockText(for: agent, prompt: plannedPrompt).components(separatedBy: " ")
                for word in words {
                    try? await Task.sleep(for: .milliseconds(60))
                    continuation.yield(word + " ")
                }
                continuation.finish()
            }
        }
    }

    func makeFinalStream(from agentReplies: [AgentType: String], userPrompt: String) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                try? await Task.sleep(for: .milliseconds(300))
                let words = finalText(from: agentReplies).components(separatedBy: " ")
                for word in words {
                    try? await Task.sleep(for: .milliseconds(60))
                    continuation.yield(word + " ")
                }
                continuation.finish()
            }
        }
    }

    // MARK: - Private Helfer

    private func mockText(for agent: AgentType, prompt: String) -> String {
        let prefix = String(prompt.prefix(80))
        switch agent {
        case .gemini:  return "[Gemini] Fakten & Quellen: \(prefix)…"
        case .claude:  return "[Claude] Strukturiert: \(prefix)…"
        case .mistral: return "[Mistral] Prägnant: \(prefix)…"
        case .chatgpt: return ""
        }
    }

    private func finalText(from agentReplies: [AgentType: String]) -> String {
        """
        ✅ Finale Prüfung (ChatGPT):
        • Gemini: \(agentReplies[.gemini]  ?? "–")
        • Claude: \(agentReplies[.claude]  ?? "–")
        • Mistral: \(agentReplies[.mistral] ?? "–")
        """
    }
}
