//
//  ClaudeAPIClient.swift
//  ONE
//
//  Created by Michael Fleps.
//

import Foundation

/// REST-Client für die Anthropic Claude API (claude-3-5-haiku).
/// Doku: https://docs.anthropic.com/en/api/messages
struct ClaudeAPIClient {

    // MARK: - Private Request/Response-Modelle

    private struct RequestBody: Encodable {
        let model: String
        let maxTokens: Int
        let system: String
        let messages: [Message]

        enum CodingKeys: String, CodingKey {
            case model
            case maxTokens = "max_tokens"
            case system
            case messages
        }

        struct Message: Encodable {
            let role: String
            let content: String
        }
    }

    private struct StreamRequestBody: Encodable {
        let model: String
        let maxTokens: Int
        let stream: Bool
        let system: String
        let messages: [Message]

        enum CodingKeys: String, CodingKey {
            case model
            case maxTokens = "max_tokens"
            case stream
            case system
            case messages
        }

        struct Message: Encodable {
            let role: String
            let content: String
        }
    }

    private struct ResponseBody: Decodable {
        let content: [ContentBlock]
        struct ContentBlock: Decodable {
            let text: String
        }
    }

    // MARK: - SSE Delta-Event

    private struct ContentBlockDelta: Decodable {
        let delta: Delta?
        struct Delta: Decodable {
            let type: String
            let text: String?
        }
    }

    // MARK: - Batch-Anfrage

    func fetchReply(prompt: String, systemInstruction: String, apiKey: String) async throws -> String {
        guard let url = URL(string: "https://api.anthropic.com/v1/messages") else {
            throw ONEAPIError.invalidResponse(.claude)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json",  forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey,               forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01",         forHTTPHeaderField: "anthropic-version")

        let body = RequestBody(
            model: "claude-3-5-haiku-20241022",
            maxTokens: 1024,
            system: systemInstruction,
            messages: [.init(role: "user", content: prompt)]
        )
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ONEAPIError.invalidResponse(.claude)
        }

        switch httpResponse.statusCode {
        case 200:   break
        case 401:   throw ONEAPIError.authenticationFailed(.claude)
        case 429:   throw ONEAPIError.rateLimitExceeded(.claude)
        default:
            let message = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
            throw ONEAPIError.modelError(.claude, message)
        }

        guard
            let decoded = try? JSONDecoder().decode(ResponseBody.self, from: data),
            let text = decoded.content.first?.text
        else {
            throw ONEAPIError.decodingFailed(.claude)
        }

        return text
    }

    // MARK: - Streaming-Anfrage (SSE)

    /// Streamt Token-für-Token via Anthropic SSE.
    /// Events vom Typ content_block_delta mit text_delta werden als Tokens geliefert.
    func fetchReplyStream(prompt: String, systemInstruction: String, apiKey: String) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    guard let url = URL(string: "https://api.anthropic.com/v1/messages") else {
                        continuation.finish(throwing: ONEAPIError.invalidResponse(.claude))
                        return
                    }

                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.setValue(apiKey,              forHTTPHeaderField: "x-api-key")
                    request.setValue("2023-06-01",        forHTTPHeaderField: "anthropic-version")

                    let body = StreamRequestBody(
                        model: "claude-3-5-haiku-20241022",
                        maxTokens: 1024,
                        stream: true,
                        system: systemInstruction,
                        messages: [.init(role: "user", content: prompt)]
                    )
                    request.httpBody = try JSONEncoder().encode(body)

                    let (asyncBytes, response) = try await URLSession.shared.bytes(for: request)

                    guard let httpResponse = response as? HTTPURLResponse else {
                        continuation.finish(throwing: ONEAPIError.invalidResponse(.claude))
                        return
                    }

                    switch httpResponse.statusCode {
                    case 200: break
                    case 401:
                        continuation.finish(throwing: ONEAPIError.authenticationFailed(.claude))
                        return
                    case 429:
                        continuation.finish(throwing: ONEAPIError.rateLimitExceeded(.claude))
                        return
                    default:
                        let msg = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                        continuation.finish(throwing: ONEAPIError.modelError(.claude, msg))
                        return
                    }

                    for try await line in asyncBytes.lines {
                        guard line.hasPrefix("data: ") else { continue }
                        let jsonString = String(line.dropFirst(6))
                        guard !jsonString.isEmpty,
                              let data = jsonString.data(using: .utf8),
                              let event = try? JSONDecoder().decode(ContentBlockDelta.self, from: data),
                              let delta = event.delta,
                              delta.type == "text_delta",
                              let text = delta.text
                        else { continue }
                        continuation.yield(text)
                    }

                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}
