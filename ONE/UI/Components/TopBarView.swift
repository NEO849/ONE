//
//  TopBarView.swift
//  ONE
//
//  Created by Michael Fleps on 04.11.25.
//


import SwiftUI

/// Obere Leiste – links App-Logo (als Button für Sidebar), dann Name-Bild, rechts „New Chat“.
/// Beziehung:
/// - Reine Darstellung; Logik (Sidebar öffnen, neue Runde) kommt aus ContentView.
struct TopBarView: View {
    let appLogoAsset: String
    let appNameAsset: String
    let onToggleSidebar: () -> Void
    let onNewRound: () -> Void

    var body: some View {
        HStack {
            // 🔹 Linker Bereich: Logo + App Name
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

            Spacer()

            // 🔹 Rechter Bereich: New Chat Button
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
        .padding(.horizontal, 78) // 🔹 Konsistenter 32dp Abstand links und rechts
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

