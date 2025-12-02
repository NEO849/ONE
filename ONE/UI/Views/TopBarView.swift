//
//  TopBarView.swift
//  ONE
//
//  Created by Michael Fleps on 04.11.25.
//


import SwiftUI

/// Obere Leiste – links App-Logo (als Button für Sidebar), dann App-Name, rechts Button „New Chat“.
/// Wichtig: Kein eigenes Padding! Das wird in der ContentView zentral gesetzt.
struct TopBarView: View {

    let appLogoAsset: String                                                                         // Asset-Name Logo
    let appNameAsset: String                                                                         // Asset-Name Schriftzug
    let onToggleSidebar: () -> Void                                                                  // Aktion: Sidebar öffnen
    let onNewRound: () -> Void                                                                       // Aktion: neuen Chat starten

    var body: some View {
        HStack(spacing: 14) {                                                                        // Grundlayout der TopBar
            HStack(spacing: 12) {                                                                    // Linke Gruppe: Logo + Name
                Button(action: onToggleSidebar) {                                                     // Logo ist Button
                    Image(appLogoAsset)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 32)                                                           // Fixe Höhe -> stabile TopBar
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)

                Image(appNameAsset)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 48)                                                               // Fixe Höhe -> verhindert Springen
            }
            .layoutPriority(0)                                                                        // Links darf notfalls eher schrumpfen

            Spacer(minLength: 12)                                                                     // Trennung + flexible Mitte

            Button(action: onNewRound) {                                                              // Rechter Button
                HStack(spacing: 6) {
                    Image(systemName: "plus.bubble.fill")
                        .imageScale(.medium)

                    Text("New Chat")
                        .font(.footnote.weight(.semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }
                .padding(.all, 10)                                                                    // Touch-Ziel + Optik
                .glassCard(cornerRadius: 12, borderColor: .blue)                                      // Dein Glass-Design
            }
            .buttonStyle(.plain)
            .layoutPriority(1)                                                                        // Rechts bevorzugt Platz bekommen
        }
        .frame(maxWidth: .infinity)                                                                   // Wichtig: Spacer kann nur so „schieben“
    }
}

#Preview("TopBar – Live App Appearance") {
    ZStack {
        // Gleicher Hintergrund wie in der Haupt-App
        Image("background")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()

        VStack {
            // TopBar mit gleichen Abständen wie in ContentView
            TopBarView(
                appLogoAsset: "logo",
                appNameAsset: "onetext",
                onToggleSidebar: { print("Toggle Sidebar") },
                onNewRound: { print("New Chat") }
            )
            
            Spacer()
        }
    }
    .environment(\.colorScheme, .dark)
}

