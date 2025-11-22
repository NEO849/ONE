//
//  AgentTheme.swift
//  ONE
//
//  Created by Michael Fleps on 04.11.25.
//

import SwiftUI

/// UI-Theme pro Agent – hält Darstellung getrennt vom Model.
struct AgentTheme: Equatable {
    let backgroundAssetName: String
    let accentColor: Color
    let cornerRadius: CGFloat
    let strokeWidth: CGFloat
    
    /// Zentraler Init mit Default-Werten für alle Agenten
    init(
        backgroundAssetName: String,
        accentColor: Color,
        cornerRadius: CGFloat = 12,
        strokeWidth: CGFloat = 1
    ) {
        self.backgroundAssetName = backgroundAssetName
        self.accentColor = accentColor
        self.cornerRadius = cornerRadius
        self.strokeWidth = strokeWidth
    }
}

extension AgentType {
    var theme: AgentTheme {
        switch self {
        case .chatgpt: return AgentTheme(backgroundAssetName: "bg_gpt",     accentColor: .blue)
        case .gemini:  return AgentTheme(backgroundAssetName: "bg_gemini",  accentColor: .teal)
        case .claude:  return AgentTheme(backgroundAssetName: "bg_claude",  accentColor: .secondary)
        case .mistral: return AgentTheme(backgroundAssetName: "bg_mistral", accentColor: .gray)
        }
    }
}
