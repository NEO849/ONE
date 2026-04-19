//
//  DeveloperKeyInjector.swift
//  ONE
//
//  Created by Michael Fleps.
//

import Foundation

/// Sicherheits-Helfer für Entwickler-Builds.
/// Liest API-Keys aus Xcode-Scheme-Environment-Variables und schreibt
/// sie einmalig in die Keychain – nur wenn dort noch kein Eintrag vorhanden ist.
///
/// EINRICHTUNG (einmalig in Xcode):
///   Product → Scheme → Edit Scheme → Run → Environment Variables
///   GEMINI_API_KEY, CLAUDE_API_KEY, MISTRAL_API_KEY, CHATGPT_API_KEY setzen.
///   (Alternativ: bash scripts/setup-secrets.sh für Anleitung ausführen)
///
/// PRODUKTION: In Release-Builds ist diese gesamte Datei durch #if DEBUG inaktiv.
#if DEBUG
enum DeveloperKeyInjector {

    /// Liest Keys aus ProcessInfo.environment und speichert fehlende Keys in der Keychain.
    /// Bestehende Keychain-Einträge werden NICHT überschrieben.
    static func injectIfNeeded() {
        let environment = ProcessInfo.processInfo.environment

        let keyMapping: [(SecureKeyManager.APIKey, String)] = [
            (.gemini,  "GEMINI_API_KEY"),
            (.claude,  "CLAUDE_API_KEY"),
            (.mistral, "MISTRAL_API_KEY"),
            (.chatGPT, "CHATGPT_API_KEY")
        ]

        for (apiKey, envVarName) in keyMapping {
            guard
                let rawValue = environment[envVarName],
                !rawValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            else { continue }

            // Vorhandenen Keychain-Eintrag nicht überschreiben – Nutzer-Keys bleiben erhalten
            guard SecureKeyManager.load(key: apiKey) == nil else { continue }

            let didSave = SecureKeyManager.save(key: apiKey, value: rawValue)
            print("[DeveloperKeyInjector] \(didSave ? "✅" : "❌") \(apiKey.displayName) gespeichert.")
        }
    }
}
#endif
