//
//  RealConversationService.swift
//  ONE
//
//  Created by Michael Fleps.
//

import Foundation

/// Echte Implementierung des ConversationProtocol.
/// Orchestriert alle vier KI-APIs: Gemini, Claude, Mistral, ChatGPT.
/// Liest API-Keys sicher über den SecureKeyManager aus dem Keychain.
struct RealConversationService: ConversationProtocol {

    // MARK: - API-Clients (zustandslos, sicher mehrfach verwendbar)

    private let geminiClient  = GeminiAPIClient()
    private let claudeClient  = ClaudeAPIClient()
    private let mistralClient = MistralAPIClient()
    private let chatGPTClient = ChatGPTAPIClient()

    // MARK: - System-Prompts: jeder Agent hat eine klar definierte Rolle

    private enum AgentSystemPrompt {
        static let gemini  = "Du bist ein faktenbasierter Recherche-Assistent. Liefere sachliche, gut begründete Informationen zur Anfrage auf Deutsch."
        static let claude  = "Du bist ein strukturierter Analyst. Gliedere deine Antwort in klare, logische Schritte auf Deutsch."
        static let mistral = "Du bist ein prägnanter Zusammenfasser. Gib kurze, auf den Punkt gebrachte Kernaussagen auf Deutsch."
        static let chatgpt = "Du bist ein kritischer Prüfer. Die anderen drei KI-Agenten haben bereits geantwortet. Fasse ihre Kernaussagen zusammen, erkenne Widersprüche und liefere eine finale, ausgewogene Antwort auf Deutsch."
    }

    // MARK: - ConversationProtocol

    /// Bereitet agentenspezifische Prompts vor.
    /// Jeder Agent erhält denselben Nutzer-Prompt – der System-Kontext gibt die Rolle vor.
    func planAgentPrompts(for userPrompt: String) async throws -> [AgentType: String] {
        return [
            .gemini:  userPrompt,
            .claude:  userPrompt,
            .mistral: userPrompt
        ]
    }

    /// Ruft die Antwort eines einzelnen Agenten ab.
    /// Fehler werden als typisierten ONEAPIError weitergereicht.
    func fetchAgentReply(for agent: AgentType, plannedPrompt: String) async throws -> String {
        switch agent {
        case .gemini:
            guard let apiKey = SecureKeyManager.load(key: .gemini) else {
                throw ONEAPIError.missingAPIKey(.gemini)
            }
            return try await geminiClient.fetchReply(
                prompt: plannedPrompt,
                systemInstruction: AgentSystemPrompt.gemini,
                apiKey: apiKey
            )

        case .claude:
            guard let apiKey = SecureKeyManager.load(key: .claude) else {
                throw ONEAPIError.missingAPIKey(.claude)
            }
            return try await claudeClient.fetchReply(
                prompt: plannedPrompt,
                systemInstruction: AgentSystemPrompt.claude,
                apiKey: apiKey
            )

        case .mistral:
            guard let apiKey = SecureKeyManager.load(key: .mistral) else {
                throw ONEAPIError.missingAPIKey(.mistral)
            }
            return try await mistralClient.fetchReply(
                prompt: plannedPrompt,
                systemInstruction: AgentSystemPrompt.mistral,
                apiKey: apiKey
            )

        case .chatgpt:
            guard let apiKey = SecureKeyManager.load(key: .chatGPT) else {
                throw ONEAPIError.missingAPIKey(.chatgpt)
            }
            return try await chatGPTClient.fetchReply(
                prompt: plannedPrompt,
                systemInstruction: AgentSystemPrompt.chatgpt,
                apiKey: apiKey
            )
        }
    }

    /// Generiert die finale ChatGPT-Antwort basierend auf den drei Agenten-Antworten.
    /// Alle Antworten werden als Kontext gebundelt und zur Synthese an ChatGPT gesendet.
    func makeFinalReply(from agentReplies: [AgentType: String], userPrompt: String) async throws -> String {
        guard let apiKey = SecureKeyManager.load(key: .chatGPT) else {
            throw ONEAPIError.missingAPIKey(.chatgpt)
        }

        // Kontext-Prompt mit allen drei Agenten-Antworten aufbauen
        var parts: [String] = [
            "Nutzerfrage: \(userPrompt)",
            "",
            "[Gemini – Recherche]: \(agentReplies[.gemini] ?? "Keine Antwort")",
            "",
            "[Claude – Struktur]: \(agentReplies[.claude] ?? "Keine Antwort")",
            "",
            "[Mistral – Kompakt]: \(agentReplies[.mistral] ?? "Keine Antwort")",
            "",
            "Prüfe die drei Antworten, erkenne Gemeinsamkeiten und Widersprüche, und liefere eine präzise, ausgewogene Zusammenfassung auf Deutsch."
        ]

        return try await chatGPTClient.fetchReply(
            prompt: parts.joined(separator: "\n"),
            systemInstruction: AgentSystemPrompt.chatgpt,
            apiKey: apiKey
        )
    }
}
