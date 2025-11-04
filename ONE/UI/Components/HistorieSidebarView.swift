//
//  HistorieSidebarView.swift
//  ONE
//
//  Created by Michael Fleps on 04.11.25.
//

import SwiftUI

/// Einfahrende Sidebar links – listet Rundentitel (History) auf.
/// Beziehung: ContentView hält "isOpen" & Auswahl-Callback.
/// 
struct HistorySidebarView: View {
    let rounds: [ConversationRound]
    @Binding var isOpen: Bool
    let onSelect: (Int) -> Void

    private let widthFactor: CGFloat = 0.52

    var body: some View {
        GeometryReader { geo in
            let drawerWidth = geo.size.width * widthFactor

            ZStack(alignment: .leading) {
                if isOpen {
                    Color.black.opacity(0.25)
                        .ignoresSafeArea()
                        .onTapGesture { withAnimation(.easeInOut) { isOpen = false } }
                }

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("History").font(.headline).foregroundStyle(.white)
                        Spacer()
                        Button(action: { withAnimation(.easeInOut) { isOpen = false } }) {
                            Image(systemName: "xmark").imageScale(.medium)
                        }
                        .buttonStyle(.plain).foregroundStyle(.white)
                    }

                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(Array(rounds.enumerated()), id: \.offset) { indexValue, round in
                                Button {
                                    onSelect(indexValue)
                                    withAnimation(.easeInOut) { isOpen = false }
                                } label: {
                                    Text(round.title.isEmpty ? "Untitled Round" : round.title)
                                        .foregroundStyle(.white)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 12)
                                        .glassCard(cornerRadius: 12)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    Spacer()
                }
                .padding(16)
                .frame(width: drawerWidth, height: geo.size.height)
                .background(.regularMaterial)
                .offset(x: isOpen ? 0 : -drawerWidth)
                .animation(.easeInOut, value: isOpen)
                .ignoresSafeArea(edges: .vertical)
            }
        }
    }
}
