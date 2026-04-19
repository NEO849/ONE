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
    let verticalAgentName: String
    
    init(
        backgroundAssetName: String,
        accentColor: Color,
        cornerRadius: CGFloat = 12,
        strokeWidth: CGFloat = 1,
        verticalAgentName: String
    ) {
        self.backgroundAssetName = backgroundAssetName
        self.accentColor = accentColor
        self.cornerRadius = cornerRadius
        self.strokeWidth = strokeWidth
        self.verticalAgentName = verticalAgentName
    }
}

extension AgentType {
    var theme: AgentTheme {
        switch self {
        case .chatgpt: return AgentTheme(backgroundAssetName: "bg_gpt",     accentColor: .blue,                            verticalAgentName: "gpt_vertical")
        case .gemini:  return AgentTheme(backgroundAssetName: "bg_gemini",  accentColor: .teal,                            verticalAgentName: "gemini_vertical")
        case .claude:  return AgentTheme(backgroundAssetName: "bg_claude",  accentColor: Color(red: 0.9, green: 0.5, blue: 0.2), verticalAgentName: "claude_vertical")
        case .mistral: return AgentTheme(backgroundAssetName: "bg_mistral", accentColor: Color(red: 0.6, green: 0.3, blue: 0.9), verticalAgentName: "mistral_vertical")
        }
    }
}
