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

    private let drawerWidth: CGFloat = 290

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {

                if isOpen {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                                isOpen = false
                            }
                        }
                        .transition(.opacity)
                }

                VStack(alignment: .leading, spacing: 0) {
                    sidebarHeader

                    if rounds.isEmpty {
                        emptyState
                    } else {
                        roundsList
                    }
                }
                .frame(width: drawerWidth, height: proxy.size.height)
                .background(.ultraThinMaterial)
                .background(Color.black.opacity(0.55))
                .overlay(alignment: .trailing) {
                    Rectangle()
                        .fill(Color.white.opacity(0.07))
                        .frame(width: 1)
                }
                .offset(x: isOpen ? 0 : -drawerWidth)
                .animation(.spring(response: 0.3, dampingFraction: 0.88), value: isOpen)
                .ignoresSafeArea(edges: .vertical)
            }
        }
    }

    // MARK: - Header

    private var sidebarHeader: some View {
        HStack(alignment: .center) {
            Text("Verlauf")
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)

            Spacer()

            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                    isOpen = false
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.5))
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(Color.white.opacity(0.08)))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Sidebar schließen")
        }
        .padding(.horizontal, 20)
        .padding(.top, 64)
        .padding(.bottom, 16)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 36))
                .foregroundStyle(.white.opacity(0.12))
            Text("Noch keine Gespräche")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.28))
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Kein Gesprächsverlauf vorhanden")
    }

    // MARK: - Rounds List

    private var roundsList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(alignment: .leading, spacing: 2) {
                ForEach(Array(rounds.enumerated()), id: \.element.id) { index, round in
                    roundRow(round: round, index: index)
                }
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 40)
        }
    }

    private func roundRow(round: ConversationRound, index: Int) -> some View {
        let isActive = round.id == selectedRoundId

        return Button {
            onSelect(index)
            withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                isOpen = false
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: isActive ? "bubble.left.fill" : "bubble.left")
                    .font(.caption)
                    .foregroundStyle(isActive ? Color.blue : .white.opacity(0.3))
                    .frame(width: 16)

                Text(round.title.isEmpty ? "Neues Gespräch" : round.title)
                    .font(.subheadline.weight(isActive ? .medium : .regular))
                    .foregroundStyle(isActive ? .white : .white.opacity(0.62))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(isActive ? Color.white.opacity(0.1) : Color.clear)
            )
            .contentShape(Rectangle())
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
    let r1 = ConversationRound(title: "SwiftUI & MVVM Basics")
    let r2 = ConversationRound(title: "KI-Agenten – Zusammenarbeit")
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
