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
            // Linker Bereich: Logo + Name
            HStack(spacing: 10) {
                Button(action: onToggleSidebar) {
                    Image(appLogoAsset)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 32)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
                
                Image(appNameAsset)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 56)
            }
          //  .padding(.horizontal, 28) // 🔹 vertikales Padding für bessere Klickfläche
            
            Spacer() // 🔹 drückt rechten Bereich zuverlässig nach rechts
            
            // Rechter Bereich: New Chat
            Button(action: onNewRound) {
                HStack(spacing: 6) {
                    Image(systemName: "plus.bubble.fill")
                        .imageScale(.medium)
                    Text("New Chat")
                        .font(.footnote.weight(.semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .padding(.all, 8)
                .glassCard(cornerRadius: 10, borderColor: .blue)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.gray)
        }
        .padding(.horizontal, 42)
    }
}

#Preview("TopBar – dunkel") {
    ZStack {
        Image("background")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()

        TopBarView(
            appLogoAsset: "logo",
            appNameAsset: "onetext",
            onToggleSidebar: {},
            onNewRound: {}
        )
    }
    .environment(\.colorScheme, .dark)
}


