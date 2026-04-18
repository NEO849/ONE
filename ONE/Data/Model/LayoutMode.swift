//
//  LayoutMode.swift
//  ONE
//

import Foundation

/// Steuert die Darstellungsart der Agenten-Antworten pro ChatStep.
/// - grid:    Alle 4 Karten gleichgroß in einem 2×2-Raster (Ansicht 1).
/// - stacked: Karten versetzt gestapelt, gleiche Höhe, kürzer als Bildschirm (Ansicht 2).
enum LayoutMode {
    case grid
    case stacked

    /// SF-Symbol für den Toggle-Button in der TopBar.
    var systemIcon: String {
        switch self {
        case .grid:    return "square.grid.2x2.fill"
        case .stacked: return "square.stack.fill"
        }
    }

    /// Liefert den jeweils anderen Modus.
    var toggled: LayoutMode {
        self == .grid ? .stacked : .grid
    }
}
