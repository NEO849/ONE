//
//  ConversationProtocol.swift
//  ONE
//
//  Created by Michael Fleps on 04.11.25.
//

import Foundation

/// Orchestrierungsschnittstelle (Free-Modus heute, Paid-Modus später).
/// Beziehung:
/// - ViewModel hängt nur an diesem Protokoll.
/// - fetchAgentStream / makeFinalStream liefern Token für Token (SSE).
/// - Default-Implementierungen in der Extension wrappen die Batch-Methoden
///   für Services, die kein echtes Streaming implementieren.
protocol ConversationProtocol {
    func planAgentPrompts(for userPrompt: String) async throws -> [AgentType: String]
    func fetchAgentReply(for agent: AgentType, plannedPrompt: String) async throws -> String
    func makeFinalReply(from agentReplies: [AgentType: String], userPrompt: String) async throws -> String

    func fetchAgentStream(for agent: AgentType, plannedPrompt: String) -> AsyncThrowingStream<String, Error>
    func makeFinalStream(from agentReplies: [AgentType: String], userPrompt: String) -> AsyncThrowingStream<String, Error>
}

extension ConversationProtocol {

    /// Fallback: wraps fetchAgentReply in a single-yield stream.
    func fetchAgentStream(for agent: AgentType, plannedPrompt: String) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let reply = try await fetchAgentReply(for: agent, plannedPrompt: plannedPrompt)
                    continuation.yield(reply)
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    /// Fallback: wraps makeFinalReply in a single-yield stream.
    func makeFinalStream(from agentReplies: [AgentType: String], userPrompt: String) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let reply = try await makeFinalReply(from: agentReplies, userPrompt: userPrompt)
                    continuation.yield(reply)
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}
