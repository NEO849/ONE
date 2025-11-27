//
//  HistorySidebarView.swift
//  ONE
//
//  Created by Michael Fleps on 04.11.25.
//

import SwiftUI

/// Einfahrende Sidebar links – listet Rundentitel (History) auf.
/// Beziehung: ContentView hält "isOpen" & Auswahl-Callback.
struct HistorySidebarView: View {
    let rounds: [ConversationRound]
    @Binding var isOpen: Bool
    let onSelect: (Int) -> Void

    private let sidebarBreitenFaktor: CGFloat = 0.68

    var body: some View {
        GeometryReader { geometryProxy in                     // geometryProxy >= 4 Zeichen
            let drawerWidth = geometryProxy.size.width * sidebarBreitenFaktor // Breite berechnen

            ZStack(alignment: .leading) {
                
                // ✅ Dunkler Overlay-Hintergrund wenn offen
                if isOpen {
                    Color.black.opacity(0.25)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                isOpen = false               // Tap außerhalb schließt Sidebar
                            }
                        }
                }

                VStack {
                    // Header
                    HStack {
                        Text("History")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.leading, 48)               // ✅ Header-Text weiter links
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.easeInOut) {
                                isOpen = false               // X schließt Sidebar
                            }
                        }) {
                            Image(systemName: "xmark")
                                .imageScale(.medium)
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.white)
                    }
                    .padding(.top, 100)                        // ✅ statt riesigem vertical Padding
                    .padding(.bottom, 12)
                    .padding(.trailing, 32) // ✅ Header-Text weiter rechts
                    
                    // Liste
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(Array(rounds.enumerated()), id: \.offset) { indexValue, round in
                                Button {
                                    onSelect(indexValue)
                                    withAnimation(.easeInOut) {
                                        isOpen = false
                                    }
                                } label: {
                                    Text(round.title.isEmpty ? "Untitled Round" : round.title)
                                        .foregroundStyle(.white)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 12)
                                        .glassCard(cornerRadius: 12)
                                        .padding(.leading, 48)
                                        .padding(.trailing, 28)                       // ✅ rechts weniger Abstand
                                }
                                .buttonStyle(.plain)
                            }
                        }                    }
                }
                .frame(width: drawerWidth, height: geometryProxy.size.height)
                .background(.regularMaterial)     .glassCard()                            // Glas-Hintergrund
                .offset(x: isOpen ? 0 : -drawerWidth)                         // Slide rein/raus
                .animation(.easeInOut, value: isOpen)
                .ignoresSafeArea(edges: .vertical)
            }
        }
    }
}

#Preview("Sidebar – geöffnet") {
    let sampleRounds: [ConversationRound] = {
        var r1 = ConversationRound(title: "SwiftUI & MVVM Basics")
        var r2 = ConversationRound(title: "KI-Agenten – Zusammenarbeit")

        return [r1, r2]
    }()

    // Fix geöffnetem Zustand (.constant(true)).
    return HistorySidebarView(
        rounds: sampleRounds,
        isOpen: .constant(true),
        onSelect: { _ in }
    )
    .background(
        Image("background").resizable().scaledToFill()
    )
    .environment(\.colorScheme, .dark)
}
