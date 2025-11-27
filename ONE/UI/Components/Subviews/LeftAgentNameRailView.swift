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
    
    // cornerRadiusValue entfernt, da es im Body nicht verwendet wird
    let agentNameAssetName: String
    let accentColor: Color
    // Width of the left rail provided by the caller (keeps layout consistent)
    let railWidthValue: CGFloat

    var body: some View {
        ZStack {
            // Hintergrund-Logik (Glas-Effekt)
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(
                    Rectangle()
                        .fill(accentColor.opacity(0.12))
                )

            // Agenten-Schriftzug (Bildgröße optimiert)
            Image(agentNameAssetName)
                .resizable()
                .scaledToFit()
            
        }
        .frame(width: railWidthValue)
        .frame(maxHeight: .infinity)
     }
 }

   #Preview {
       LeftAgentNameRailView(
           agentNameAssetName: "gpt_vertical",
           accentColor: .blue,
           railWidthValue: 80
       )
       .frame(height: 200)
       .environment(\.colorScheme, .dark)
       .border(Color.red)
   }
