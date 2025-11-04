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
}
extension AgentType {
    var theme: AgentTheme {
        switch self {
        case .chatgpt: return .init(backgroundAssetName: "bg_gpt",     accentColor: .blue,      cornerRadius: 24, strokeWidth: 1)
        case .gemini:  return .init(backgroundAssetName: "bg_gemini",  accentColor: .teal,      cornerRadius: 24, strokeWidth: 1)
        case .claude:  return .init(backgroundAssetName: "bg_claude",  accentColor: .secondary, cornerRadius: 24, strokeWidth: 1)
        case .mistral: return .init(backgroundAssetName: "bg_mistral", accentColor: .gray,      cornerRadius: 24, strokeWidth: 1)
        }
    }
}
