//
//  GlassStyles.swift
//  ONE
//
//  Created by Michael Fleps on 04.11.25.
//

import SwiftUI

/// Einheitlicher Glass-Look – ein Modifier für alle Cards/Container.
/// Beziehung:
/// - Hält den „Glass + Stroke“-Stil zentral.
struct GlassCardModifier: ViewModifier {
    let cornerRadius: CGFloat
    let borderColor: Color          // Rahmenfarbe für den Glas-Container
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.white.opacity(0.10))      // leichte Helligkeit
                    .background(.ultraThinMaterial)       // eigentlicher Glas-Effekt
            )  
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(borderColor.opacity(0.35), lineWidth: 1) // Rahmenfarbe
            )
    }
}

extension View {
    /// Einheitlicher Glasstil
    func glassCard(
        cornerRadius: CGFloat = 24,
        borderColor: Color = .white
    ) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius, borderColor: borderColor))
    }
}

/// Dünne Glass-Linie, z.B. als Divider
struct GlassDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.white.opacity(0.18))
            .frame(height: 1)
            .overlay(Rectangle().fill(Color.white.opacity(0.05)).frame(height: 0.5))
            .padding(.horizontal, 8)
    }
}
