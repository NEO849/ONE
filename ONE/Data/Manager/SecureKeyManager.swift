//
//  SecureKeyManager.swift
//  ONE
//
//  Created by Michael Fleps.
//

import Foundation
import Security

/// Sicherer Speicher für API-Keys – alle Keys landen im iOS Keychain.
/// Kein UserDefaults, kein Klartext. Wird von RealConversationService
/// und den Settings-/Onboarding-Views genutzt.
struct SecureKeyManager {

    // MARK: - API-Key Bezeichner

    /// Typsichere Bezeichner für die vier KI-API-Keys.
    enum APIKey: String, CaseIterable {
        case gemini  = "one.apikey.gemini"
        case claude  = "one.apikey.claude"
        case mistral = "one.apikey.mistral"
        case chatGPT = "one.apikey.chatgpt"

        /// Lesbarer Name für UI-Labels.
        var displayName: String {
            switch self {
            case .gemini:  return "Gemini (Google AI Studio)"
            case .claude:  return "Claude (Anthropic)"
            case .mistral: return "Mistral AI"
            case .chatGPT: return "ChatGPT (OpenAI)"
            }
        }

        /// Platzhalter-Text für das Eingabefeld.
        var placeholder: String {
            switch self {
            case .gemini:  return "AIza..."
            case .claude:  return "sk-ant-..."
            case .mistral: return "..."
            case .chatGPT: return "sk-..."
            }
        }

        /// Passender AgentType für den Key.
        var agentType: AgentType {
            switch self {
            case .gemini:  return .gemini
            case .claude:  return .claude
            case .mistral: return .mistral
            case .chatGPT: return .chatgpt
            }
        }
    }

    // MARK: - Keychain Operationen

    /// Speichert einen API-Key sicher im iOS Keychain.
    /// Löscht einen vorhandenen Eintrag vor dem Neuschreiben (kein Update-Path nötig).
    @discardableResult
    static func save(key: APIKey, value: String) -> Bool {
        let data = Data(value.utf8)
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue,
            kSecValueData as String:   data
        ]
        // Bestehenden Eintrag entfernen bevor neu geschrieben wird
        SecItemDelete(query as CFDictionary)
        return SecItemAdd(query as CFDictionary, nil) == errSecSuccess
    }

    /// Liest einen API-Key aus dem Keychain. Gibt nil zurück wenn nicht vorhanden.
    static func load(key: APIKey) -> String? {
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue,
            kSecReturnData as String:  true,
            kSecMatchLimit as String:  kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    /// Löscht einen API-Key aus dem Keychain.
    @discardableResult
    static func delete(key: APIKey) -> Bool {
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue
        ]
        return SecItemDelete(query as CFDictionary) == errSecSuccess
    }

    /// True wenn alle vier API-Keys vorhanden und nicht leer sind.
    /// Wird beim App-Start genutzt um zu entscheiden ob Onboarding nötig ist.
    static func allKeysPresent() -> Bool {
        APIKey.allCases.allSatisfy { key in
            guard let value = load(key: key) else { return false }
            return !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
}
