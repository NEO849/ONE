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

        // Snake_case-Mapping für die Anthropic API
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

    private struct ResponseBody: Decodable {
        let content: [ContentBlock]
        struct ContentBlock: Decodable {
            let text: String
        }
    }

    // MARK: - API-Anfrage

    /// Sendet einen Prompt an Claude Haiku und gibt die Textantwort zurück.
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
}
