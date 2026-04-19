//
//  ChatGPTAPIClient.swift
//  ONE
//
//  Created by Michael Fleps.
//

import Foundation

/// REST-Client für die OpenAI ChatGPT API (gpt-4o-mini).
/// Doku: https://platform.openai.com/docs/api-reference/chat
struct ChatGPTAPIClient {

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
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            throw ONEAPIError.invalidResponse(.chatgpt)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json",  forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let body = RequestBody(
            model: "gpt-4o-mini",
            messages: [
                .init(role: "system", content: systemInstruction),
                .init(role: "user",   content: prompt)
            ]
        )
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ONEAPIError.invalidResponse(.chatgpt)
        }

        switch httpResponse.statusCode {
        case 200:   break
        case 401, 403: throw ONEAPIError.authenticationFailed(.chatgpt)
        case 429:   throw ONEAPIError.rateLimitExceeded(.chatgpt)
        default:
            let message = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
            throw ONEAPIError.modelError(.chatgpt, message)
        }

        guard
            let decoded = try? JSONDecoder().decode(ResponseBody.self, from: data),
            let text = decoded.choices.first?.message.content
        else {
            throw ONEAPIError.decodingFailed(.chatgpt)
        }

        return text
    }

    // MARK: - Streaming-Anfrage (SSE)

    /// Streamt Token-für-Token via OpenAI SSE.
    /// Format: data: {"choices":[{"delta":{"content":"..."}}]} / data: [DONE]
    func fetchReplyStream(prompt: String, systemInstruction: String, apiKey: String) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
                        continuation.finish(throwing: ONEAPIError.invalidResponse(.chatgpt))
                        return
                    }

                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

                    let body = StreamRequestBody(
                        model: "gpt-4o-mini",
                        stream: true,
                        messages: [
                            .init(role: "system", content: systemInstruction),
                            .init(role: "user",   content: prompt)
                        ]
                    )
                    request.httpBody = try JSONEncoder().encode(body)

                    let (asyncBytes, response) = try await URLSession.shared.bytes(for: request)

                    guard let httpResponse = response as? HTTPURLResponse else {
                        continuation.finish(throwing: ONEAPIError.invalidResponse(.chatgpt))
                        return
                    }

                    switch httpResponse.statusCode {
                    case 200: break
                    case 401, 403:
                        continuation.finish(throwing: ONEAPIError.authenticationFailed(.chatgpt))
                        return
                    case 429:
                        continuation.finish(throwing: ONEAPIError.rateLimitExceeded(.chatgpt))
                        return
                    default:
                        let msg = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                        continuation.finish(throwing: ONEAPIError.modelError(.chatgpt, msg))
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
