//
//  GlassLightSweepModifier.swift
//  ONE
//
//  Created by Michael Fleps on 28.11.25.
//

import SwiftUI

/// Animierter Licht-Sweep, der über die Glasfläche läuft.                                     // Was der Modifier macht
/// Der Sweep ist sehr subtil, wirkt aber extrem hochwertig im UI.                             // Warum subtil: Premium-Look
struct GlassLightSweepModifier: ViewModifier {
    
    var cornerRadius: CGFloat = 22                                                           // Muss zur Karte passen
    var animationDuration: Double = 2.8                                                      // Geschwindigkeit des Sweeps
    var sweepOpacity: Double = 0.35                                                          // Sichtbarkeit des Lichtstreifens
    
    @State private var sweepOffset: CGFloat = -1                                             // Start links außerhalb
    
    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { geometryProxy in                                            // Wir brauchen die Breite für die Animation
                    let viewWidth = geometryProxy.size.width                                 // Breite der Karte
                    
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    .clear,
                                    .white.opacity(sweepOpacity),                            // Hell in der Mitte
                                    .clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .rotationEffect(.degrees(18))                                        // Schräge Lichtreflex-Optik
                        .offset(x: sweepOffset * viewWidth)                                  // Sweep bewegt sich horizontal
                        .blendMode(.screen)                                                  // Sweep addiert Licht statt zu übermalen
                        .onAppear {
                            sweepOffset = 1.2                                                // Damit er komplett rechts rausläuft
                        }
                        .animation(
                            .easeInOut(duration: animationDuration)                          // Sanfte Premium-Bewegung
                            .repeatForever(autoreverses: false),                             // Endlos nach rechts
                            value: sweepOffset
                        )
                }
                .allowsHitTesting(false)                                                     // Sweep ist nur Optik
            }
    }
}

extension View {
    /// Einfache Nutzung in Views.                                                             // Komfort-API
    func glassLightSweep(
        cornerRadius: CGFloat = 22,
        animationDuration: Double = 2.8,
        sweepOpacity: Double = 0.35
    ) -> some View {
        modifier(
            GlassLightSweepModifier(
                cornerRadius: cornerRadius,
                animationDuration: animationDuration,
                sweepOpacity: sweepOpacity
            )
        )
    }
}
