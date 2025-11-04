//
//  TopBarView.swift
//  ONE
//
//  Created by Michael Fleps on 04.11.25.
//

import SwiftUI

/// Deutsch: Obere Leiste – links Sidebar-Toggle, dann Logo-Bild, Name-Bild, rechts „New Chat“.
/// Beziehung: Reine Darstellung; Callbacks werden von ContentView geliefert.
struct TopBarView: View {
    let appLogoAsset: String
    let appNameAsset: String
    let onToggleSidebar: () -> Void
    let onNewRound: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggleSidebar) {
                Image(systemName: "sidebar.leading").imageScale(.large)
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)

            Image(appLogoAsset)
                .resizable().scaledToFit()
                .frame(width: 24, height: 24)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))

            Image(appNameAsset)
                .resizable().scaledToFit()
                .frame(height: 22)

            Spacer()

            Button(action: onNewRound) {
                HStack(spacing: 6) {
                    Image(systemName: "plus.bubble").imageScale(.medium)
                    Text("New Chat").font(.subheadline.weight(.semibold))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }
}

#Preview("TopBar – dunkel") {
    TopBarView(
        appLogoAsset: "onetext",
        appNameAsset: "onetext",
        onToggleSidebar: {},
        onNewRound: {}
    )
    .background(
        Image("background").resizable().scaledToFill()
    )
    .environment(\.colorScheme, .dark) // Glass wirkt im Dark Mode am besten
}
