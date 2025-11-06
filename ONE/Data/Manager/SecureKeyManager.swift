//
//  SecureKeyManager.swift
//  ONE
//
//  Created by Michael Fleps on 06.11.25.
//

import Foundation

enum SecureKeyManagerError {
    static var claudeKey: String {
        ProcessInfo.processInfo.environment["CLAUDE_API_KEY"] ?? ""
    }
    static var gptKey: String {
        ProcessInfo.processInfo.environment["GPT_API_KEY"] ?? ""
    }
    static var geminiKey: String {
        ProcessInfo.processInfo.environment["GEMINI_API_KEY"] ?? ""
    }
    static var mistralKey: String {
        ProcessInfo.processInfo.environment["MISTRAL_API_KEY"] ?? ""
    }
}
