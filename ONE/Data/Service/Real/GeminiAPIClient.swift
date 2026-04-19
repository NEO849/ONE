//
//  GeminiAPIClient.swift
//  ONE
//
//  Created by Michael Fleps.
//

import Foundation

/// REST-Client für die Google Gemini 1.5 Flash API.
/// Doku: https://ai.google.dev/api/generate-content
struct GeminiAPIClient {

    // MARK: - Private Request/Response-Modelle

    private struct RequestBody: Encodable {
        let contents: [Content]
        let systemInstruction: SystemInstruction

        struct Content: Encodable {
            let parts: [Part]
        }
        struct SystemInstruction: Encodable {
            let parts: [Part]
        }
        struct Part: Encodable {
            let text: String
        }
    }

    private struct ResponseBody: Decodable {
        let candidates: [Candidate]
        struct Candidate: Decodable {
            let content: Content
        }
        struct Content: Decodable {
            let parts: [Part]
        }
        struct Part: Decodable {
            let text: String
        }
    }

    // MARK: - Batch-Anfrage

    func fetchReply(prompt: String, systemInstruction: String, apiKey: String) async throws -> String {
        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw ONEAPIError.invalidResponse(.gemini)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = RequestBody(
            contents: [.init(parts: [.init(text: prompt)])],
            systemInstruction: .init(parts: [.init(text: systemInstruction)])
        )
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ONEAPIError.invalidResponse(.gemini)
        }

        switch httpResponse.statusCode {
        case 200:   break
        case 401, 403: throw ONEAPIError.authenticationFailed(.gemini)
        case 429:   throw ONEAPIError.rateLimitExceeded(.gemini)
        default:
            let message = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
            throw ONEAPIError.modelError(.gemini, message)
        }

        guard
            let decoded = try? JSONDecoder().decode(ResponseBody.self, from: data),
            let text = decoded.candidates.first?.content.parts.first?.text
        else {
            throw ONEAPIError.decodingFailed(.gemini)
        }

        return text
    }

    // MARK: - Streaming-Anfrage (SSE)

    /// Streamt Token-für-Token via streamGenerateContent?alt=sse.
    /// Jedes SSE-Event enthält ein JSON-Objekt mit dem nächsten Text-Delta.
    func fetchReplyStream(prompt: String, systemInstruction: String, apiKey: String) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:streamGenerateContent?alt=sse&key=\(apiKey)"
                    guard let url = URL(string: urlString) else {
                        continuation.finish(throwing: ONEAPIError.invalidResponse(.gemini))
                        return
                    }

                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                    let body = RequestBody(
                        contents: [.init(parts: [.init(text: prompt)])],
                        systemInstruction: .init(parts: [.init(text: systemInstruction)])
                    )
                    request.httpBody = try JSONEncoder().encode(body)

                    let (asyncBytes, response) = try await URLSession.shared.bytes(for: request)

                    guard let httpResponse = response as? HTTPURLResponse else {
                        continuation.finish(throwing: ONEAPIError.invalidResponse(.gemini))
                        return
                    }

                    switch httpResponse.statusCode {
                    case 200: break
                    case 401, 403:
                        continuation.finish(throwing: ONEAPIError.authenticationFailed(.gemini))
                        return
                    case 429:
                        continuation.finish(throwing: ONEAPIError.rateLimitExceeded(.gemini))
                        return
                    default:
                        let msg = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                        continuation.finish(throwing: ONEAPIError.modelError(.gemini, msg))
                        return
                    }

                    for try await line in asyncBytes.lines {
                        guard line.hasPrefix("data: ") else { continue }
                        let jsonString = String(line.dropFirst(6))
                        guard !jsonString.isEmpty,
                              let data = jsonString.data(using: .utf8),
                              let decoded = try? JSONDecoder().decode(ResponseBody.self, from: data),
                              let text = decoded.candidates.first?.content.parts.first?.text
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
