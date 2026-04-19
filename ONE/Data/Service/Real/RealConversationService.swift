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
        static var claude: String {
            let fmt = DateFormatter()
            fmt.locale = Locale(identifier: "de_DE")
            fmt.dateStyle = .long
            return "Du bist ein strukturierter Analyst. Das heutige Datum ist \(fmt.string(from: Date())). Gliedere deine Antwort in klare, logische Schritte auf Deutsch."
        }
        static let mistral = "Du bist ein prägnanter Zusammenfasser. Gib kurze, auf den Punkt gebrachte Kernaussagen auf Deutsch."
        static let chatgpt = "Du bist ein kritischer Prüfer. Die anderen drei KI-Agenten haben bereits geantwortet. Fasse ihre Kernaussagen zusammen, erkenne Widersprüche und liefere eine finale, ausgewogene Antwort auf Deutsch."
    }

    // MARK: - ConversationProtocol (Batch)

    func planAgentPrompts(for userPrompt: String) async throws -> [AgentType: String] {
        return [
            .gemini:  userPrompt,
            .claude:  userPrompt,
            .mistral: userPrompt
        ]
    }

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

    func makeFinalReply(from agentReplies: [AgentType: String], userPrompt: String) async throws -> String {
        guard let apiKey = SecureKeyManager.load(key: .chatGPT) else {
            throw ONEAPIError.missingAPIKey(.chatgpt)
        }
        let contextPrompt = buildFinalContextPrompt(agentReplies: agentReplies, userPrompt: userPrompt)
        return try await chatGPTClient.fetchReply(
            prompt: contextPrompt,
            systemInstruction: AgentSystemPrompt.chatgpt,
            apiKey: apiKey
        )
    }

    // MARK: - ConversationProtocol (Streaming)

    /// Überschreibt den Protocol-Extension-Fallback mit echter SSE-Anbindung.
    func fetchAgentStream(for agent: AgentType, plannedPrompt: String) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    switch agent {
                    case .gemini:
                        guard let apiKey = SecureKeyManager.load(key: .gemini) else {
                            continuation.finish(throwing: ONEAPIError.missingAPIKey(.gemini))
                            return
                        }
                        for try await token in geminiClient.fetchReplyStream(
                            prompt: plannedPrompt,
                            systemInstruction: AgentSystemPrompt.gemini,
                            apiKey: apiKey
                        ) { continuation.yield(token) }

                    case .claude:
                        guard let apiKey = SecureKeyManager.load(key: .claude) else {
                            continuation.finish(throwing: ONEAPIError.missingAPIKey(.claude))
                            return
                        }
                        for try await token in claudeClient.fetchReplyStream(
                            prompt: plannedPrompt,
                            systemInstruction: AgentSystemPrompt.claude,
                            apiKey: apiKey
                        ) { continuation.yield(token) }

                    case .mistral:
                        guard let apiKey = SecureKeyManager.load(key: .mistral) else {
                            continuation.finish(throwing: ONEAPIError.missingAPIKey(.mistral))
                            return
                        }
                        for try await token in mistralClient.fetchReplyStream(
                            prompt: plannedPrompt,
                            systemInstruction: AgentSystemPrompt.mistral,
                            apiKey: apiKey
                        ) { continuation.yield(token) }

                    case .chatgpt:
                        break
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    /// Überschreibt den Protocol-Extension-Fallback mit echtem ChatGPT-Streaming.
    func makeFinalStream(from agentReplies: [AgentType: String], userPrompt: String) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    guard let apiKey = SecureKeyManager.load(key: .chatGPT) else {
                        continuation.finish(throwing: ONEAPIError.missingAPIKey(.chatgpt))
                        return
                    }
                    let contextPrompt = buildFinalContextPrompt(agentReplies: agentReplies, userPrompt: userPrompt)
                    for try await token in chatGPTClient.fetchReplyStream(
                        prompt: contextPrompt,
                        systemInstruction: AgentSystemPrompt.chatgpt,
                        apiKey: apiKey
                    ) { continuation.yield(token) }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    // MARK: - Private Helfer

    private func buildFinalContextPrompt(agentReplies: [AgentType: String], userPrompt: String) -> String {
        [
            "Nutzerfrage: \(userPrompt)",
            "",
            "[Gemini – Recherche]: \(agentReplies[.gemini] ?? "Keine Antwort")",
            "",
            "[Claude – Struktur]: \(agentReplies[.claude] ?? "Keine Antwort")",
            "",
            "[Mistral – Kompakt]: \(agentReplies[.mistral] ?? "Keine Antwort")",
            "",
            "Prüfe die drei Antworten, erkenne Gemeinsamkeiten und Widersprüche, und liefere eine präzise, ausgewogene Zusammenfassung auf Deutsch."
        ].joined(separator: "\n")
    }
}
