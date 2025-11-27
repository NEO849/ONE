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
    
    let agentNameAssetName: String                                                           // Asset-Name vom Schriftzug (z.B. "gpt_vertical")
      let accentColor: Color                                                                    // Akzentfarbe vom Agenten (Glow/Farbfilm)
      let railWidthValue: CGFloat                                                               // Breite der Rail (kommt von der Card)
      let cornerRadiusValue: CGFloat                                                            // Damit die Rundung zur Card passt (links)

      var body: some View {
          ZStack {

              Rectangle()                                                                       // Basisfläche der Rail
                  .fill(.ultraThinMaterial)                                                     // Glas-Material = iOS Blur + Tiefe
                  .overlay(                                                                     // Farbfilm für Agenten-Identität (subtil)
                      Rectangle()
                          .fill(accentColor.opacity(0.12))                                      // Kleiner Farbanteil, damit es nicht “billig” wirkt
                  )
                  .overlay(                                                                     // Optionales Light-Gradient für Premium-Look
                      LinearGradient(
                          colors: [
                              .white.opacity(0.10),                                              // Oben etwas heller
                              .white.opacity(0.02),                                              // Mitte fast neutral
                              .black.opacity(0.08)                                               // Unten leicht dunkler für Tiefenwirkung
                          ],
                          startPoint: .top,
                          endPoint: .bottom
                      )
                  )

              Image(agentNameAssetName)                                                          // ✅ Dein Schriftzug-Asset (pro Agent unterschiedlich)
                  .resizable()                                                                   // Muss skalierbar sein, damit es in die Rail passt
                  .scaledToFit()                                                                 // Bewahrt Seitenverhältnis (kein Verzerren)
                  .padding(.vertical, 18)                                                        // Luft oben/unten, damit es nicht “klebt”
                  .padding(.horizontal, 10)                                                      // Luft links/rechts, damit nichts abgeschnitten wird
           
          
          }
          .frame(width: railWidthValue)                                                          // Rail bekommt fixe Breite von der Card

 
      }
  }

  #Preview {
      LeftAgentNameRailView(
          agentNameAssetName: "gpt_vertical",
          accentColor: .blue,
          railWidthValue: 66,
          cornerRadiusValue: 12
      )
      .frame(height: 200)
      .environment(\.colorScheme, .dark)
      .border(Color.red)
  }
