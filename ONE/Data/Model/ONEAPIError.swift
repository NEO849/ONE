//
//  ONEAPIError.swift
//  ONE
//
//  Created by Michael Fleps.
//

import Foundation

/// Typsichere Fehler für alle KI-API-Aufrufe in der App.
/// Jeder Fehlerfall hat eine klare Ursache und einen nutzerfreundlichen Text.
/// Wird vom RealConversationService und vom ConversationViewModel genutzt.
enum ONEAPIError: Error, LocalizedError {

    case missingAPIKey(AgentType)
    case networkError(AgentType, Error)
    case invalidResponse(AgentType)
    case rateLimitExceeded(AgentType)
    case authenticationFailed(AgentType)
    case modelError(AgentType, String)
    case decodingFailed(AgentType)

    /// Nutzerfreundliche Fehlerbeschreibung – erscheint in der AgentCard.
    var errorDescription: String? {
        switch self {
        case .missingAPIKey(let agent):
            return "\(agent.displayName): API-Key fehlt. Bitte in den Einstellungen eintragen."
        case .networkError(let agent, let error):
            return "\(agent.displayName): Netzwerkfehler – \(error.localizedDescription)"
        case .invalidResponse(let agent):
            return "\(agent.displayName): Ungültige Antwort vom Server."
        case .rateLimitExceeded(let agent):
            return "\(agent.displayName): Rate-Limit überschritten. Bitte kurz warten."
        case .authenticationFailed(let agent):
            return "\(agent.displayName): API-Key ungültig oder abgelaufen."
        case .modelError(let agent, let message):
            return "\(agent.displayName): \(message)"
        case .decodingFailed(let agent):
            return "\(agent.displayName): Antwort konnte nicht verarbeitet werden."
        }
    }

    /// Der betroffene Agent – nützlich für gezieltes Retry.
    var affectedAgent: AgentType {
        switch self {
        case .missingAPIKey(let agent),
             .networkError(let agent, _),
             .invalidResponse(let agent),
             .rateLimitExceeded(let agent),
             .authenticationFailed(let agent),
             .modelError(let agent, _),
             .decodingFailed(let agent):
            return agent
        }
    }
}
