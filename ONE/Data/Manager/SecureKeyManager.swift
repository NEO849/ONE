//
//  SecureKeyManager.swift
//  ONE
//
//  Created by Michael Fleps.
//

import Foundation
import Security

/// Sicherer Speicher für API-Keys – ausschließlich iOS Keychain.
///
/// Sicherheitsgarantien:
///   • kSecAttrAccessibleWhenUnlockedThisDeviceOnly:
///       Keys sind nur bei entsperrtem Gerät lesbar, werden NICHT in iCloud gesichert
///       und können nicht auf ein anderes Gerät übertragen werden.
///   • kSecAttrService: Namespace-Isolation – verhindert Kollisionen mit anderen Apps,
///       die denselben kSecAttrAccount-Wert verwenden könnten.
///   • Kein UserDefaults, kein Klartext, keine Datei auf Disk.
struct SecureKeyManager {

    // MARK: - Konfiguration

    private static let keychainService = "com.NEO849.ONE"

    // MARK: - API-Key Bezeichner

    /// Typsichere Bezeichner für die vier KI-API-Keys.
    enum APIKey: String, CaseIterable {
        case gemini  = "one.apikey.gemini"
        case claude  = "one.apikey.claude"
        case mistral = "one.apikey.mistral"
        case chatGPT = "one.apikey.chatgpt"

        var displayName: String {
            switch self {
            case .gemini:  return "Gemini (Google AI Studio)"
            case .claude:  return "Claude (Anthropic)"
            case .mistral: return "Mistral AI"
            case .chatGPT: return "ChatGPT (OpenAI)"
            }
        }

        var placeholder: String {
            switch self {
            case .gemini:  return "AIza..."
            case .claude:  return "sk-ant-..."
            case .mistral: return "..."
            case .chatGPT: return "sk-..."
            }
        }

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

    /// Speichert einen API-Key sicher im Keychain.
    /// Überschreibt vorhandene Einträge atomisch (delete → add).
    /// Nie iCloud-gesichert, nicht auf andere Geräte übertragbar.
    @discardableResult
    static func save(key: APIKey, value: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        delete(key: key)
        let query: [CFString: Any] = [
            kSecClass:          kSecClassGenericPassword,
            kSecAttrService:    keychainService,
            kSecAttrAccount:    key.rawValue,
            kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            kSecValueData:      data
        ]
        return SecItemAdd(query as CFDictionary, nil) == errSecSuccess
    }

    /// Liest einen API-Key aus dem Keychain. Gibt nil zurück wenn nicht vorhanden.
    static func load(key: APIKey) -> String? {
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrService: keychainService,
            kSecAttrAccount: key.rawValue,
            kSecReturnData:  true,
            kSecMatchLimit:  kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data
        else { return nil }
        return String(data: data, encoding: .utf8)
    }

    /// Löscht einen Key aus dem Keychain.
    /// Idempotent – gibt true zurück auch wenn der Key nicht vorhanden war.
    @discardableResult
    static func delete(key: APIKey) -> Bool {
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrService: keychainService,
            kSecAttrAccount: key.rawValue
        ]
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }

    /// Löscht alle vier API-Keys (z. B. für Reset oder Logout).
    static func deleteAll() {
        APIKey.allCases.forEach { delete(key: $0) }
    }

    /// True wenn alle vier Keys vorhanden und nicht leer sind.
    /// Wird beim App-Start genutzt um zu entscheiden ob Onboarding nötig ist.
    static func allKeysPresent() -> Bool {
        APIKey.allCases.allSatisfy { key in
            guard let value = load(key: key) else { return false }
            return !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
}
