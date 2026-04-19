//
//  ContentView.swift
//  ONE
//
//  Created by Michael Fleps on 04.10.25.
//

import SwiftUI

/// Hauptansicht des ONE-Chats – verbindet TopBar, Gesprächsverlauf, InputBar und Sidebar.
/// MVVM: ViewModel ist die Source of Truth, die View reagiert nur auf Zustandsänderungen.
struct ContentView: View {

    @FocusState private var isInputFocused: Bool
    @EnvironmentObject private var conversationViewModel: ConversationViewModel
    @State private var isSettingsPresented: Bool = false

    private let layoutPaddingHorizontal: CGFloat = 32
    private let topbarPaddingVertical: CGFloat   = 12
    private let inputbarPaddingVertical: CGFloat  = 10

    var body: some View {
        ZStack(alignment: .leading) {
            Image("background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            ChatMessageListView(
                steps: conversationViewModel.currentSteps,
                isInputFocused: isInputFocused,
                bottomScrollTriggerValue: conversationViewModel.currentSteps.count,
                layoutMode: conversationViewModel.layoutMode
            )
            .padding(.horizontal, layoutPaddingHorizontal)
        }
        .keyboardDismissable($isInputFocused)

        .safeAreaInset(edge: .top, spacing: 0) {
            TopBarView(
                appLogoAsset: "logo",
                appNameAsset: "onetext",
                layoutMode: conversationViewModel.layoutMode,
                onToggleSidebar: { conversationViewModel.toggleSidebar() },
                onToggleLayout:  { conversationViewModel.toggleLayoutMode() },
                onSettings:      { isSettingsPresented = true },
                onNewRound:      { conversationViewModel.createNewRound() }
            )
            .padding(.horizontal, layoutPaddingHorizontal)
            .padding(.vertical, topbarPaddingVertical)
        }

        .safeAreaInset(edge: .bottom, spacing: 0) {
            GlassCardInputField(
                text: $conversationViewModel.inputText,
                isBusy: conversationViewModel.isBusy,
                onSend: {
                    let trimmed = conversationViewModel.inputText
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return }
                    conversationViewModel.runFreeFlowStep()
                    isInputFocused = false
                },
                isInputFocused: $isInputFocused
            )
            .padding(.horizontal, layoutPaddingHorizontal)
            .padding(.vertical, inputbarPaddingVertical)
        }

        // Sidebar – ID-basiert, aktive Runde hervorgehoben, swipe-to-delete
        .overlay {
            HistorySidebarView(
                rounds: conversationViewModel.rounds,
                isOpen: Binding(
                    get: { conversationViewModel.isSidebarOpen },
                    set: { conversationViewModel.isSidebarOpen = $0 }
                ),
                selectedRoundId: conversationViewModel.currentRoundId,
                onSelect: { conversationViewModel.selectRound(at: $0) },
                onDelete: { conversationViewModel.deleteRound(withId: $0) }
            )
            .allowsHitTesting(conversationViewModel.isSidebarOpen)
        }

        // Settings-Sheet: API-Keys bearbeiten
        .sheet(isPresented: $isSettingsPresented) {
            SettingsView {
                conversationViewModel.updateService(RealConversationService())
            }
        }
    }
}

#Preview("Content – Mockdaten") {
    ContentView()
        .environmentObject(ConversationViewModel(service: MockConversationService()))
        .environment(\.colorScheme, .dark)
}
