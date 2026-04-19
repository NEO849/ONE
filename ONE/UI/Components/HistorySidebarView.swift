//
//  HistorySidebarView.swift
//  ONE
//
//  Created by Michael Fleps on 04.11.25.
//

import SwiftUI

/// Einfahrende Sidebar links – listet Rundentitel (History) auf.
/// Beziehungen:
/// - ContentView hält isOpen & Callbacks.
/// - onDelete: Runde per ID löschen → ConversationViewModel.deleteRound(withId:).
/// - selectedRoundId: aktive Runde wird optisch hervorgehoben.
struct HistorySidebarView: View {

    let rounds: [ConversationRound]
    @Binding var isOpen: Bool
    let selectedRoundId: String?
    let onSelect: (Int) -> Void
    let onDelete: (String) -> Void

    private let sidebarBreitenFaktor: CGFloat = 0.72

    var body: some View {
        GeometryReader { geometryProxy in
            let drawerWidth = geometryProxy.size.width * sidebarBreitenFaktor

            ZStack(alignment: .leading) {

                // Dunkler Overlay – Tap außerhalb schließt Sidebar
                if isOpen {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.25)) { isOpen = false }
                        }
                }

                VStack(alignment: .leading, spacing: 0) {
                    sidebarHeader
                    roundsList
                }
                .frame(width: drawerWidth, height: geometryProxy.size.height)
                .background(Color.black.opacity(0.65))
                .glassCard(cornerRadius: 0)
                .offset(x: isOpen ? 0 : -drawerWidth)
                .animation(.spring(response: 0.3, dampingFraction: 0.85), value: isOpen)
                .ignoresSafeArea(edges: .vertical)
            }
        }
    }

    // MARK: - Subviews

    private var sidebarHeader: some View {
        HStack {
            Text("Verlauf")
                .font(.headline)
                .foregroundStyle(.white)

            Spacer()

            Button {
                withAnimation(.easeInOut(duration: 0.25)) { isOpen = false }
            } label: {
                Image(systemName: "xmark")
                    .imageScale(.medium)
                    .foregroundStyle(.white.opacity(0.8))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 24)
        .padding(.top, 72)
        .padding(.bottom, 16)
    }

    private var roundsList: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 8) {
                if rounds.isEmpty {
                    Text("Noch keine Gespräche")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.45))
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                } else {
                    // ID-basiertes ForEach – stabil auch bei Neuordnung und Löschung
                    ForEach(Array(rounds.enumerated()), id: \.element.id) { indexValue, round in
                        roundRow(round: round, indexValue: indexValue)
                    }
                }
            }
            .padding(.bottom, 40)
        }
    }

    private func roundRow(round: ConversationRound, indexValue: Int) -> some View {
        let isActive = round.id == selectedRoundId

        return Button {
            onSelect(indexValue)
            withAnimation(.easeInOut(duration: 0.25)) { isOpen = false }
        } label: {
            HStack(spacing: 10) {
                // Aktiv-Indikator
                RoundedRectangle(cornerRadius: 2)
                    .fill(isActive ? Color.blue : Color.clear)
                    .frame(width: 3, height: 32)

                Text(round.title.isEmpty ? "Neues Gespräch" : round.title)
                    .font(isActive ? .subheadline.weight(.semibold) : .subheadline)
                    .foregroundStyle(isActive ? .white : .white.opacity(0.75))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 10)
            .padding(.leading, 16)
            .padding(.trailing, 20)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isActive ? Color.white.opacity(0.12) : Color.clear)
            )
            .padding(.horizontal, 12)
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                onDelete(round.id)
            } label: {
                Label("Löschen", systemImage: "trash")
            }
        }
    }
}

#Preview("Sidebar – geöffnet") {
    var r1 = ConversationRound(title: "SwiftUI & MVVM Basics")
    var r2 = ConversationRound(title: "KI-Agenten – Zusammenarbeit")
    let rounds = [r1, r2]

    return HistorySidebarView(
        rounds: rounds,
        isOpen: .constant(true),
        selectedRoundId: rounds.first?.id,
        onSelect: { _ in },
        onDelete: { _ in }
    )
    .background(Image("background").resizable().scaledToFill())
    .environment(\.colorScheme, .dark)
}
