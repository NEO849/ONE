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
    let appLogoAsset: String                // Bildname für App-Logo
    let appNameAsset: String                // Bildname für App-Schriftzug
    let onToggleSidebar: () -> Void         // Aktion beim Tippen auf das Logo
    let onNewRound: () -> Void              // Aktion beim Tippen auf „New Chat“

    var body: some View {
        HStack {
            // ⬅️ Linker Bereich (Logo + App-Name)
            HStack(spacing: 12) {
                Button(action: onToggleSidebar) {
                    Image(appLogoAsset)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 32)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)

                Image(appNameAsset)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 48)
            }

            Spacer() // ➖ Abstand in der Mitte

            // ➡️ Rechter Bereich (Neuer Chat)
            Button(action: onNewRound) {
                HStack(spacing: 6) {
                    Image(systemName: "plus.bubble.fill")
                        .imageScale(.medium)

                    Text("New Chat")
                        .font(.footnote.weight(.semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .padding(.all, 10)
                .glassCard(cornerRadius: 12, borderColor: .blue)
            }
            .buttonStyle(.plain)
        }
        // Kein .padding() hier – äußere View (ContentView) gibt das vor!
        .frame(maxWidth: .infinity, alignment: .leading)
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

