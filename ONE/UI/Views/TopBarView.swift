//
//  TopBarView.swift
//  ONE
//
//  Created by Michael Fleps on 04.11.25.
//

import SwiftUI

/// Obere Leiste – Logo (Sidebar), App-Name, Layout-Toggle, Settings und New-Chat.
/// Kein eigenes Padding – wird zentral in ContentView gesetzt.
struct TopBarView: View {

    let appLogoAsset: String
    let appNameAsset: String
    let layoutMode: LayoutMode
    let onToggleSidebar: () -> Void
    let onToggleLayout: () -> Void
    let onSettings: () -> Void
    let onNewRound: () -> Void

    var body: some View {
        HStack(spacing: 14) {

            // Linke Gruppe: Logo (Sidebar-Trigger) + App-Name
            HStack(spacing: 12) {
                Button(action: onToggleSidebar) {
                    Image(appLogoAsset)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 32)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Gesprächsverlauf")
                .accessibilityHint("Öffnet oder schließt die Verlauf-Sidebar")

                Image(appNameAsset)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 48)
                    .accessibilityHidden(true)
            }
            .layoutPriority(0)

            Spacer(minLength: 12)

            // Layout-Toggle: wechselt zwischen Grid und Stacked
            Button(action: onToggleLayout) {
                Image(systemName: layoutMode.systemIcon)
                    .font(.title3)
                    .foregroundStyle(.white)
                    .padding(10)
                    .glassCard(cornerRadius: 12, borderColor: .white)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(layoutMode == .grid
                ? "Layout zu gestapelt wechseln"
                : "Layout zu Raster wechseln"
            )
            .accessibilityHint(layoutMode == .grid
                ? "Zeigt Agenten-Karten übereinander versetzt"
                : "Zeigt Agenten-Karten als 2x2 Raster"
            )

            // Settings: API-Keys bearbeiten
            Button(action: onSettings) {
                Image(systemName: "gearshape")
                    .font(.title3)
                    .foregroundStyle(.white)
                    .padding(10)
                    .glassCard(cornerRadius: 12, borderColor: .white)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Einstellungen")
            .accessibilityHint("Öffnet API-Key-Verwaltung")

            // New Chat
            Button(action: onNewRound) {
                HStack(spacing: 6) {
                    Image(systemName: "plus.bubble.fill")
                        .imageScale(.medium)
                        .accessibilityHidden(true)
                    Text("New Chat")
                        .font(.footnote.weight(.semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }
                .padding(.all, 10)
                .glassCard(cornerRadius: 12, borderColor: .blue)
            }
            .buttonStyle(.plain)
            .layoutPriority(1)
            .accessibilityLabel("Neues Gespräch starten")
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview("TopBar – Live App Appearance") {
    ZStack {
        Image("background")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()

        VStack {
            TopBarView(
                appLogoAsset: "logo",
                appNameAsset: "onetext",
                layoutMode: .grid,
                onToggleSidebar: {},
                onToggleLayout: {},
                onSettings: {},
                onNewRound: {}
            )
            Spacer()
        }
    }
    .environment(\.colorScheme, .dark)
}
