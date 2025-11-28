//
//  GlassTiltModifier.swift
//  ONE
//
//  Created by Michael Fleps on 28.11.25.
//

import SwiftUI

/// Dieser Modifier erlaubt einen dezenten 3D-Tilt per Drag.                                   // Nutzer kann Karte leicht kippen
/// Dadurch wirkt das Glas noch realer (Parallax-Effekt).                                      // Warum das realer wirkt
struct GlassTiltModifier: ViewModifier {
    
    @State private var dragOffset: CGSize = .zero                                            // Speichert Drag-Bewegung
    var maximumAngle: Double = 8                                                             // Maximaler Kippwinkel
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(                                                               // Kippen nach oben/unten
                .degrees(currentAngleVertical),
                axis: (x: 1, y: 0, z: 0)
            )
            .rotation3DEffect(                                                               // Kippen nach links/rechts
                .degrees(currentAngleHorizontal),
                axis: (x: 0, y: 1, z: 0)
            )
            .gesture(
                DragGesture(minimumDistance: 0)                                              // Sofort reagieren
                    .onChanged { dragValue in
                        dragOffset = dragValue.translation                                   // Drag wird gespeichert
                    }
                    .onEnded { _ in
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {     // Federt schön zurück
                            dragOffset = .zero                                               // Reset
                        }
                    }
            )
    }
    
    private var currentAngleVertical: Double {                                               // Berechnet Vertikal-Winkel
        let normalizedValue = Double(dragOffset.height / 30)                                 // Normierung → nicht zu stark
        return clampAngle(value: -normalizedValue)                                           // Auf max Winkel begrenzen
    }
    
    private var currentAngleHorizontal: Double {                                             // Berechnet Horizontal-Winkel
        let normalizedValue = Double(dragOffset.width / 30)                                  // Normierung → nicht zu stark
        return clampAngle(value: normalizedValue)                                            // Begrenzen
    }
    
    private func clampAngle(value: Double) -> Double {                                       // Hilfsfunktion zum Begrenzen
        max(-maximumAngle, min(maximumAngle, value))                                         // Clamp zwischen -max und +max
    }
}

extension View {
    /// Public API für deine Views.                                                            // Komfort-API
    func glassTilt3D(maximumAngle: Double = 8) -> some View {
        modifier(GlassTiltModifier(maximumAngle: maximumAngle))
    }
}
