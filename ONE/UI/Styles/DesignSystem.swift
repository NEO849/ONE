//
//  DesignSystem.swift
//  ONE
//
//  Zentrales Design-System (Design-Tokens) fuer die gesamte App.
//  Ein Ort fuer Abstaende, Radien, Flaechenfarben, Bewegung und Agent-Akzente.
//  So bleiben alle Screens visuell konsistent und ruhig.
//

import SwiftUI

/// Oberster Namensraum fuer alle Design-Tokens.
enum DesignSystem {

    // MARK: - Abstaende (8-pt-Raster fuer ruhige, konsistente Layouts)
    enum Spacing {
        static let tiny:   CGFloat = 4
        static let small:  CGFloat = 8
        static let medium: CGFloat = 12
        static let large:  CGFloat = 16
        static let xlarge: CGFloat = 24
        static let huge:   CGFloat = 32
    }

    // MARK: - Eckenradien (durchgaengig continuous / squircle)
    enum Radius {
        static let small:  CGFloat = 10
        static let medium: CGFloat = 14
        static let large:  CGFloat = 18
        static let card:   CGFloat = 20
    }

    // MARK: - Glas- und Flaechenfarben (einheitliche Tiefe fuer alle Cards)
    enum Surface {
        static let cardFill         = Color.white.opacity(0.06)
        static let cardFillRaised   = Color.white.opacity(0.10)
        static let cardStroke       = Color.white.opacity(0.12)
        static let cardStrokeStrong = Color.white.opacity(0.22)
        static let textPrimary      = Color.white.opacity(0.92)
        static let textSecondary    = Color.white.opacity(0.55)
        static let textTertiary     = Color.white.opacity(0.32)
    }

    // MARK: - Bewegung (zentrale, ruhige Animationskurven)
    enum Motion {
        static let quick    = Animation.easeInOut(duration: 0.18)
        static let standard = Animation.easeInOut(duration: 0.25)
        static let smooth   = Animation.spring(response: 0.38, dampingFraction: 0.86)
    }

    // MARK: - Schatten-Stufen (konsistente, glaubwuerdige Tiefe)
    struct ShadowStyle {
        let color: Color
        let radius: CGFloat
        let yOffset: CGFloat

        // Presets direkt am Typ -> ermoeglicht Leading-Dot: .depthShadow(.resting)
        static let resting = ShadowStyle(color: .black.opacity(0.22), radius: 10, yOffset: 6)
        static let raised  = ShadowStyle(color: .black.opacity(0.34), radius: 18, yOffset: 12)
    }
}

// MARK: - Agent-Akzente (dezenter Farbton pro Agent an EINEM Ort)

extension DesignSystem {
    /// Dezenter Akzentton pro Agent. Wird nur fuer feine Akzente genutzt
    /// (Top-Streifen, Name, Links) und NICHT mehr fuer die ganze Kartenflaeche.
    /// Dadurch wirken alle Cards einheitlich, behalten aber subtile Identitaet.
    static func agentAccent(for agent: AgentType) -> Color {
        switch agent {
        case .gemini:  return Color(red: 0.30, green: 0.56, blue: 0.98) // Blau
        case .claude:  return Color(red: 0.90, green: 0.55, blue: 0.28) // Warmes Orange
        case .mistral: return Color(red: 0.62, green: 0.36, blue: 0.92) // Violett
        case .chatgpt: return Color(red: 0.12, green: 0.74, blue: 0.58) // Gruen-Teal
        }
    }
}

// MARK: - Wiederverwendbare Stile

/// Button-Stil mit dezentem Druck-Feedback (leichtes Skalieren).
struct ScaleButtonStyle: ButtonStyle {
    var pressedScale: CGFloat = 0.96
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? pressedScale : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

extension View {
    /// Wendet eine zentrale Schatten-Stufe an.
    func depthShadow(_ style: DesignSystem.ShadowStyle) -> some View {
        shadow(color: style.color, radius: style.radius, x: 0, y: style.yOffset)
    }
}
