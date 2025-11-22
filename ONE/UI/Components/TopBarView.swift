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
            HStack(spacing: 10) {
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
                    .frame(height: 56)
            }
            
            Spacer()
            
            Button(action: onNewRound) {
                HStack(spacing: 6) {
                    Image(systemName: "plus.bubble.fill")
                        .imageScale(.medium)
                    Text("New Chat")
                        .font(.footnote.weight(.semibold))
                }
                .padding(.all, 8)
                .glassCard(cornerRadius: 10, borderColor: .blue)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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


