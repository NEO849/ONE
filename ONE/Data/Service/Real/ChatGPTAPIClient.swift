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

    private struct ResponseBody: Decodable {
        let choices: [Choice]
        struct Choice: Decodable {
            let message: Message
        }
        struct Message: Decodable {
            let content: String
        }
    }

    // MARK: - API-Anfrage

    /// Sendet einen Prompt an GPT-4o-mini und gibt die Textantwort zurück.
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
}
