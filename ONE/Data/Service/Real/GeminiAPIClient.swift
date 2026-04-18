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

    // MARK: - API-Anfrage

    /// Sendet einen Prompt mit System-Kontext an Gemini 1.5 Flash und gibt die Textantwort zurück.
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
}
