//
//  ConversationsRound.swift
//  ONE
//
//  Created by Michael Fleps on 04.11.25.
//

import Foundation

/// Eine Gesprächsrunde (History-Eintrag).
/// Beziehung:
/// - Enthält die Steps chronologisch.
/// - Der Rundentitel entsteht automatisch aus der ersten Benutzer-Eingabe.
struct ConversationRound: Codable, Identifiable {
    let id: String
    private(set) var title: String
    private(set) var steps: [ChatStep]

    init(title: String = "") {
        self.id = UUID().uuidString
        self.title = title
        self.steps = []
    }

    // MARK: - Schritte verwalten
    /// Hängt einen neuen Step an und setzt den Titel, falls leer.
    mutating func addStep(userPrompt: String) -> String {
        let cleaned = userPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return "" }
        let step = ChatStep(userPrompt: cleaned)
        steps.append(step)
        if title.isEmpty { title = cleaned } // Titel nur beim allerersten Step ableiten
        return step.id
    }

    /// Kern-Helfer – finde einen Step per id und ändert hn.
    /// Vorteil:
    /// - Kein „finden → kopieren → ersetzen“ Boilerplate mehr.
    /// - Wertsemantik bleibt korrekt (Structs bleiben Value-Typen).
    mutating func applyToStep(id stepId: String, _ mutate: (inout ChatStep) -> Void) {
        guard let indexValue = steps.firstIndex(where: { $0.id == stepId }) else { return }
        mutate(&steps[indexValue]) // direkt das Arrayelement mutieren
    }

    /// Der letzte Step (häufig für UI).
    var lastStep: ChatStep? { steps.last }
}
