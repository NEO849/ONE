//
//  LeftAgentNameRailView.swift
//  ONE
//
//  Created by Michael Fleps on 22.11.25.
//

import SwiftUI

/// Linke Rail für vertikalen Agentennamen.
/// Design:
/// - Glasiger Hintergrund passend zu deinem Glass-Theme.
/// - Name steht vertikal und bleibt sichtbar auch bei Überlappung.
struct LeftAgentNameRailView: View {
    
    let agentName: String
    let accentColor: Color
    let railWidthValue: CGFloat  // Breite vom Parent
    
    var body: some View {
        ZStack {
            
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(                           // leichter Farb-Glow
                    Rectangle()
                        .fill(accentColor.opacity(0.10))
                )
            
            // Vertikaler Name,  zentriert
            VStack(spacing: 6) {
                ForEach(Array(agentName), id: \.self) { characterValue in
                    Text(String(characterValue))
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(accentColor.opacity(0.75))
                        .frame(
                            width: 30,
                            height: 30,
                            alignment: .trailing
                        )
                }
            }
        }
        .frame(width: railWidthValue)           // Parent-Breite wird genutzt
    }
}

#Preview {
    LeftAgentNameRailView(
        agentName: "ChatGPT",
        accentColor: .blue,
        railWidthValue: 66
    )
    .frame(height: 200)
    .environment(\.colorScheme, .dark)
    .border(Color.red)
}
