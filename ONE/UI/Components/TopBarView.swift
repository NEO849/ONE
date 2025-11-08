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
        HStack(spacing: 12) {
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
                .frame(height: 64)
                .layoutPriority(1)

            Spacer(minLength: 8)

            Button(action: onNewRound) {
                HStack(spacing: 6) {
                    Image(systemName: "plus.bubble.fill")
                        .imageScale(.medium)
                    Text("New Chat")
                        .font(.footnote.weight(.semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .glassCard(cornerRadius: 22, borderColor: .blue)
//                .background(
//                    RoundedRectangle(cornerRadius: 14, style: .continuous)
//                        .fill(.blue.opacity(0.25))
//                )
            }
            .buttonStyle(.plain)
            .foregroundStyle(.gray)
        }
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
      //  .padding(.horizontal, 76)
    }
    .environment(\.colorScheme, .dark)
}


