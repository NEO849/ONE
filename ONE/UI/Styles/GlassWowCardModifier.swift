//
//  GlassWowCardModifier.swift
//  ONE
//
//  Created by Michael Fleps on 28.11.25.
//

import SwiftUI

/// Dieser Modifier erstellt einen hochwertigen 3D-Glass-Effekt.                               // Grundidee der Datei
/// Er nutzt mehrere Layer: Glasbasis, Innen-Bevel, specular Highlights und Tiefenschatten.    // Warum mehrere Layer nötig sind
struct GlassWowCardModifier: ViewModifier {
    
    // MARK: - Konfiguration (alles bewusst sprechend benannt)                               // Bereich für Einstellungen
    
    var cornerRadius: CGFloat = 22                                                           // Rundung wie im Screenshot
    var backgroundOpacity: Double = 0.50                                                     // Stärke der dunklen Glasbasis
    var innerStrokeOpacity: Double = 0.35                                                    // Sichtbarkeit der inneren Kante
    var specularOpacity: Double = 0.70                                                       // Stärke der Lichtreflexe
    var depthShadowOpacity: Double = 0.75                                                    // Stärke der Tiefen-Schatten unten
    var blurRadius: CGFloat = 7                                                              // Weichheit für Glas
    var noiseOpacity: Double = 0.05                                                          // Dezentes Glas-Rauschen (macht es „echt“)
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 18)                                                        // Innenabstand links/rechts
            .padding(.vertical, 12)                                                          // Innenabstand oben/unten
            
            // MARK: 1) Glasbasis                                                             // Unterste Ebene
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)             // Gleiche Form wie später alle Overlays
                    .fill(.black.opacity(backgroundOpacity))                                 // Dunkle Grundfläche
                    .background(                                                              // Zweite Ebene → Materiallicht bricht im Glas
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(.ultraThinMaterial)                                        // System-Glas für natürliche Tiefe
                    )
                    .blur(radius: blurRadius)                                                // Leichter Blur → wirkt wie satiniertes Glas
            }
            
            // MARK: 2) Innen-Bevel / feine innere Kante                                      // Wichtig für 3D-Look
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(                                                                 // Nur Linie, kein Fill
                        LinearGradient(
                            colors: [
                                .white.opacity(innerStrokeOpacity),                          // Oben heller
                                .white.opacity(innerStrokeOpacity * 0.30),                   // Mitte schwächer
                                .black.opacity(innerStrokeOpacity * 0.40)                    // Unten leicht dunkler (Bevel)
                            ],
                            startPoint: .top,                                                // Licht kommt von oben
                            endPoint: .bottom
                        ),
                        lineWidth: 1.2                                                       // Dünn wie im Bild
                    )
                    .blendMode(.overlay)                                                     // Mischung → realistische Kantenwirkung
            }
            
            // MARK: 3) Specular Highlights (Lichtreflexe oben & links)                        // „Wow-Glanz“
            .overlay(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                .white.opacity(specularOpacity),                             // Starker Glanzstart
                                .white.opacity(specularOpacity * 0.20),                      // Schneller Abfall
                                .clear
                            ],
                            startPoint: .topLeading,                                         // Glanz sitzt oben links
                            endPoint: .center
                        )
                    )
                    .padding(2)                                                              // Minimaler Abstand zur Außenkante
                    .blur(radius: 2)                                                         // Glanz nicht zu hart
                    .allowsHitTesting(false)                                                 // Highlight soll keine Touches blockieren
            }
            
            // MARK: 4) Unteres Soft-Shadow-Plateau                                           // „Schwebend“ wie echtes Glas
            .shadow(
                color: .black.opacity(depthShadowOpacity),                                   // Dunkler Schatten
                radius: 18,                                                                  // Weicher Schatten
                x: 0,
                y: 12                                                                        // Nach unten versetzt → Tiefe
            )
            
            // MARK: 5) Bevel-Tiefe durch zwei entgegengesetzte Schatten                       // Simuliert eine 3D-Kante
            .shadow(color: .white.opacity(0.10), radius: 2, x: -1, y: -1)                    // Minimal hell oben links
            .shadow(color: .black.opacity(0.55), radius: 8, x: 3, y: 6)                      // Dunkel unten rechts
            
            // MARK: 6) Dezentes Glas-Rauschen                                                // Macht es „nicht künstlich“
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.white.opacity(noiseOpacity))                                      // Sehr transparentes Weiß
                    .blendMode(.softLight)                                                   // Mischt sich wie feine Struktur hinein
                    .opacity(noiseOpacity)                                                   // Doppelt abgesichert, damit es subtil bleibt
                    .allowsHitTesting(false)                                                 // Rein optisch
            }
    }
}

// MARK: - Komfort-API für saubere Views

extension View {
    
    /// `.glassWowCard()` ist die einfache Außen-API in deinen Views.                          // Warum Extension: kein Modifier-Chaos in Views
    func glassWowCard(
        cornerRadius: CGFloat = 22,
        backgroundOpacity: Double = 0.50,
        innerStrokeOpacity: Double = 0.35,
        specularOpacity: Double = 0.70,
        depthShadowOpacity: Double = 0.75,
        blurRadius: CGFloat = 7,
        noiseOpacity: Double = 0.05
    ) -> some View {
        modifier(
            GlassWowCardModifier(
                cornerRadius: cornerRadius,
                backgroundOpacity: backgroundOpacity,
                innerStrokeOpacity: innerStrokeOpacity,
                specularOpacity: specularOpacity,
                depthShadowOpacity: depthShadowOpacity,
                blurRadius: blurRadius,
                noiseOpacity: noiseOpacity
            )
        )
    }
}
