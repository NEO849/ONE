//
//  MistralAPIClient.swift
//  ONE
//
//  Created by Michael Fleps.
//

import Foundation

/// REST-Client für die Mistral AI API (mistral-small-latest).
/// Doku: https://docs.mistral.ai/api/
struct MistralAPIClient {

    // MARK: - Private Request/Response-Modelle

    private struct RequestBody: Encodable {
        let model: String
        let messages: [Message]
        struct Message: Encodable {
            let role: String
            let content: String
        }
    }

    private struct StreamRequestBody: Encodable {
        let model: String
        let stream: Bool
        let messages: [Message]
        struct Message: Encodable {
            let role: String
            let content: String
        }
    }

    private struct ResponseBody: Decodable {
        let choices: [Choice]
        struct Choice: Decodable {
            let message: Message
        }
        struct Message: Decodable {
            let content: String
        }
    }

    private struct StreamChunk: Decodable {
        let choices: [Choice]
        struct Choice: Decodable {
            let delta: Delta
        }
        struct Delta: Decodable {
            let content: String?
        }
    }

    // MARK: - Batch-Anfrage

    func fetchReply(prompt: String, systemInstruction: String, apiKey: String) async throws -> String {
        guard let url = URL(string: "https://api.mistral.ai/v1/chat/completions") else {
            throw ONEAPIError.invalidResponse(.mistral)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json",    forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)",   forHTTPHeaderField: "Authorization")

        let body = RequestBody(
            model: "mistral-small-latest",
            messages: [
                .init(role: "system", content: systemInstruction),
                .init(role: "user",   content: prompt)
            ]
        )
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ONEAPIError.invalidResponse(.mistral)
        }

        switch httpResponse.statusCode {
        case 200:   break
        case 401, 403: throw ONEAPIError.authenticationFailed(.mistral)
        case 429:   throw ONEAPIError.rateLimitExceeded(.mistral)
        default:
            let message = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
            throw ONEAPIError.modelError(.mistral, message)
        }

        guard
            let decoded = try? JSONDecoder().decode(ResponseBody.self, from: data),
            let text = decoded.choices.first?.message.content
        else {
            throw ONEAPIError.decodingFailed(.mistral)
        }

        return text
    }

    // MARK: - Streaming-Anfrage (SSE)

    /// Streamt Token-für-Token via OpenAI-kompatibler SSE.
    /// Format: data: {"choices":[{"delta":{"content":"..."}}]} / data: [DONE]
    func fetchReplyStream(prompt: String, systemInstruction: String, apiKey: String) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    guard let url = URL(string: "https://api.mistral.ai/v1/chat/completions") else {
                        continuation.finish(throwing: ONEAPIError.invalidResponse(.mistral))
                        return
                    }

                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

                    let body = StreamRequestBody(
                        model: "mistral-small-latest",
                        stream: true,
                        messages: [
                            .init(role: "system", content: systemInstruction),
                            .init(role: "user",   content: prompt)
                        ]
                    )
                    request.httpBody = try JSONEncoder().encode(body)

                    let (asyncBytes, response) = try await URLSession.shared.bytes(for: request)

                    guard let httpResponse = response as? HTTPURLResponse else {
                        continuation.finish(throwing: ONEAPIError.invalidResponse(.mistral))
                        return
                    }

                    switch httpResponse.statusCode {
                    case 200: break
                    case 401, 403:
                        continuation.finish(throwing: ONEAPIError.authenticationFailed(.mistral))
                        return
                    case 429:
                        continuation.finish(throwing: ONEAPIError.rateLimitExceeded(.mistral))
                        return
                    default:
                        let msg = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                        continuation.finish(throwing: ONEAPIError.modelError(.mistral, msg))
                        return
                    }

                    for try await line in asyncBytes.lines {
                        guard line.hasPrefix("data: ") else { continue }
                        let jsonString = String(line.dropFirst(6))
                        guard jsonString != "[DONE]",
                              !jsonString.isEmpty,
                              let data = jsonString.data(using: .utf8),
                              let chunk = try? JSONDecoder().decode(StreamChunk.self, from: data),
                              let text = chunk.choices.first?.delta.content
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
