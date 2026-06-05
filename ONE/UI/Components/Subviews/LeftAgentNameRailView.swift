//
//  LeftAgentNameRailView.swift
//  ONE
//
//  Created by Michael Fleps on 22.11.25.
//

import SwiftUI

/// Linke Rail fuer den vertikalen Agentennamen.
/// Design: Die Rail hat KEINEN eigenen Hintergrund mehr, sondern verschmilzt
/// mit der einheitlichen Glas-Flaeche der Card. Identitaet entsteht nur durch
/// den Namen in der dezenten Agentenfarbe.
struct LeftAgentNameRailView: View {

    let agentNameAssetName: String
    let accentColor: Color
    let railImageWidthValue: CGFloat = 46

    var body: some View {
        ZStack {
            // Transparent -> die Rail zeigt die gemeinsame Card-Flaeche dahinter.
            Color.clear

            // Agenten-Schriftzug, dezent in der Agentenfarbe eingefaerbt.
            Image(agentNameAssetName)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundStyle(accentColor.opacity(0.85))
                .padding(.vertical, DesignSystem.Spacing.medium)
        }
        .frame(width: railImageWidthValue)
        .frame(maxHeight: .infinity)
    }
}

#Preview {
    HStack(spacing: 0) {
        LeftAgentNameRailView(agentNameAssetName: "gemini_vertical", accentColor: .blue)
        LeftAgentNameRailView(agentNameAssetName: "claude_vertical", accentColor: .orange)
    }
    .frame(height: 200)
    .background(Color.black)
    .environment(\.colorScheme, .dark)
}
