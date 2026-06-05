//
//  AgentTheme.swift
//  ONE
//
//  Created by Michael Fleps on 04.11.25.
//

import SwiftUI

/// UI-Theme pro Agent. Trennt Darstellung vom Model.
/// Nach der Vereinheitlichung bleibt agentspezifisch nur ein dezenter
/// Akzentton plus der vertikale Namens-Schriftzug. Flaeche, Material,
/// Radius und Rahmen sind fuer alle Agenten identisch (siehe DesignSystem).
struct AgentTheme: Equatable {
    let accentColor: Color
    let cornerRadius: CGFloat
    let verticalAgentName: String

    init(
        accentColor: Color,
        cornerRadius: CGFloat = DesignSystem.Radius.card,
        verticalAgentName: String
    ) {
        self.accentColor = accentColor
        self.cornerRadius = cornerRadius
        self.verticalAgentName = verticalAgentName
    }
}

extension AgentType {
    /// Theme wird zentral aus dem DesignSystem gespeist (eine Quelle der Wahrheit).
    var theme: AgentTheme {
        AgentTheme(
            accentColor: DesignSystem.agentAccent(for: self),
            verticalAgentName: verticalImageName
        )
    }

    /// Asset-Name des vertikalen Schriftzugs pro Agent.
    private var verticalImageName: String {
        switch self {
        case .chatgpt: return "gpt_vertical"
        case .gemini:  return "gemini_vertical"
        case .claude:  return "claude_vertical"
        case .mistral: return "mistral_vertical"
        }
    }
}
