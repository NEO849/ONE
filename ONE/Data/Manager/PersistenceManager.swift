//
//  PersistenceManager.swift
//  ONE
//
//  Created by Michael Fleps.
//

import Foundation

/// Speichert und lädt Gesprächsrunden lokal als JSON in UserDefaults.
/// Wird vom ConversationViewModel nach jeder Änderung aufgerufen.
/// Fehler beim Speichern/Laden sind nicht kritisch – die App läuft weiter.
struct PersistenceManager {

    private static let roundsKey = "one.persisted.rounds"

    /// Serialisiert alle Runden als JSON und legt sie in UserDefaults ab.
    static func saveRounds(_ rounds: [ConversationRound]) {
        do {
            let data = try JSONEncoder().encode(rounds)
            UserDefaults.standard.set(data, forKey: roundsKey)
        } catch {
            // Kein Assert – Persistenzfehler darf die App nicht crashen
            print("[PersistenceManager] Speichern fehlgeschlagen: \(error)")
        }
    }

    /// Deserialisiert gespeicherte Runden aus UserDefaults.
    /// Gibt ein leeres Array zurück wenn keine Daten oder Fehler beim Decodieren.
    static func loadRounds() -> [ConversationRound] {
        guard let data = UserDefaults.standard.data(forKey: roundsKey) else { return [] }
        do {
            return try JSONDecoder().decode([ConversationRound].self, from: data)
        } catch {
            print("[PersistenceManager] Laden fehlgeschlagen: \(error)")
            return []
        }
    }

    /// Löscht alle gespeicherten Runden.
    /// Wird nach dem Onboarding aufgerufen um Mock-Daten zu verwerfen.
    static func clearRounds() {
        UserDefaults.standard.removeObject(forKey: roundsKey)
    }
}
