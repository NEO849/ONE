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
        HStack(spacing: 8) {

            // Sidebar-Trigger: Logo-Taste links
            Button(action: onToggleSidebar) {
                Image(appLogoAsset)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
            }
            .buttonStyle(.plain)
            .frame(width: 40, height: 40)
            .accessibilityLabel("Gesprächsverlauf")
            .accessibilityHint("Öffnet oder schließt die Verlauf-Sidebar")

            // App-Name
            Image(appNameAsset)
                .resizable()
                .scaledToFit()
                .frame(height: 20)
                .accessibilityHidden(true)

            Spacer(minLength: 0)

            // Rechte Aktions-Gruppe
            HStack(spacing: 4) {
                topBarIconButton(
                    systemImage: layoutMode.systemIcon,
                    accessibilityLabel: layoutMode == .grid
                        ? "Zu gestapelt wechseln"
                        : "Zu Raster wechseln",
                    action: onToggleLayout
                )

                topBarIconButton(
                    systemImage: "gearshape",
                    accessibilityLabel: "Einstellungen öffnen",
                    action: onSettings
                )

                // Primärer CTA
                Button(action: onNewRound) {
                    HStack(spacing: 5) {
                        Image(systemName: "plus")
                            .font(.caption.weight(.bold))
                            .accessibilityHidden(true)
                        Text("New Chat")
                            .font(.footnote.weight(.semibold))
                            .lineLimit(1)
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(Color.blue))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Neues Gespräch starten")
            }
        }
        .frame(height: 52)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func topBarIconButton(
        systemImage: String,
        accessibilityLabel: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.body)
                .foregroundStyle(.white.opacity(0.75))
                .frame(width: 36, height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
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
            .padding(.horizontal, 20)
            Spacer()
        }
    }
    .environment(\.colorScheme, .dark)
}
