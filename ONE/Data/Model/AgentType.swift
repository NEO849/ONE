//
//  AgentType.swift
//  ONE
//
//  Created by Michael Fleps on 04.11.25.
//

import Foundation

/// KI-Agenten – typsicher & stabil.
/// Beziehung: Wird in "ChatStep" als Schlüssel genutzt; die UI mappt ihn auf Themes/Bilder.
enum AgentType: String, Codable, CaseIterable, Identifiable {
    case gemini  = "Gemini"
    case claude  = "Claude"
    case mistral = "Mistral"
    case chatgpt = "ChatGPT"    

    var id: String { rawValue }           // Identifiable → ForEach ohne Zusatz-ID
    var displayName: String { rawValue }  // Anzeigename (später leicht lokalisierbar)
}
