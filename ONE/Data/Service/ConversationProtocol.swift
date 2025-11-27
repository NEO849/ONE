//
//  ConversationProtokol.swift
//  ONE
//
//  Created by Michael Fleps on 04.11.25.
//

import Foundation

/// Orchestrierungsschnittstelle (Free-Modus heute, Paid-Modus später).
/// Beziehung:
/// - ViewModel hängt nur an diesem Protokol.
protocol ConversationProtocol {
    func planAgentPrompts(for userPrompt: String) async throws -> [AgentType: String]
    func fetchAgentReply(for agent: AgentType, plannedPrompt: String) async throws -> String
    func makeFinalReply(from agentReplies: [AgentType: String], userPrompt: String) async throws -> String
}
