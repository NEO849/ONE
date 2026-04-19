//
//  ConversationViewModel.swift
//  ONE
//
//  Created by Michael Fleps on 04.11.25.
//

import Foundation

/// Zentrale Steuereinheit (MVVM).
/// Beziehungen:
/// - Hält den gesamten Screen-State (Source of Truth).
/// - Orchestriert Gesprächsschritte via DI-Service.
/// - Keine UI-Elemente – nur Daten und Logik.
/// - Persistiert Runden nach jeder Änderung via PersistenceManager.
@MainActor
final class ConversationViewModel: ObservableObject {

    // DI – var erlaubt Wechsel nach Onboarding auf RealConversationService
    private var service: ConversationProtocol

    // UI-State
    @Published private(set) var rounds: [ConversationRound] = []
    @Published var selectedRoundIndex: Int = 0
    @Published var isSidebarOpen: Bool = false
    @Published var inputText: String = ""
    @Published var isBusy: Bool = false
    @Published var layoutMode: LayoutMode = .grid

    init(service: ConversationProtocol) {
        self.service = service
        let persistedRounds = PersistenceManager.loadRounds()
        if !persistedRounds.isEmpty {
            self.rounds = persistedRounds
        } else if service is MockConversationService {
            self.rounds = Self.makeMockRounds()
        }
    }

    // MARK: - Service-Wechsel

    func updateService(_ newService: ConversationProtocol) {
        service = newService
        rounds = PersistenceManager.loadRounds()
        selectedRoundIndex = 0
    }

    // MARK: - UI-Aktionen

    func toggleSidebar() { isSidebarOpen.toggle() }
    func toggleLayoutMode() { layoutMode = layoutMode.toggled }

    func selectRound(at indexValue: Int) {
        guard rounds.indices.contains(indexValue) else { return }
        selectedRoundIndex = indexValue
        isSidebarOpen = false
    }

    func createNewRound() {
        rounds.insert(ConversationRound(title: ""), at: 0)
        selectedRoundIndex = 0
        inputText = ""
        PersistenceManager.saveRounds(rounds)
    }

    func deleteRound(withId roundId: String) {
        guard let indexValue = rounds.firstIndex(where: { $0.id == roundId }) else { return }
        rounds.remove(at: indexValue)
        if rounds.isEmpty {
            selectedRoundIndex = 0
        } else {
            selectedRoundIndex = min(selectedRoundIndex, rounds.count - 1)
        }
        PersistenceManager.saveRounds(rounds)
    }

    // MARK: - Free-Flow-Schritt (Streaming)

    /// Nutzerprompt → drei Agenten streamen parallel Token für Token → ChatGPT prüft final.
    func runFreeFlowStep() {
        let prompt = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty else { return }

        if rounds.isEmpty || !rounds.indices.contains(selectedRoundIndex) {
            createNewRound()
        }

        isBusy = true
        inputText = ""

        Task {
            let roundIndex = selectedRoundIndex
            guard rounds.indices.contains(roundIndex) else { isBusy = false; return }

            let stepId = rounds[roundIndex].addStep(userPrompt: prompt)

            do {
                let plannedPrompts = try await service.planAgentPrompts(for: prompt)

                // Alle drei Agenten streamen parallel – jede Task aktualisiert die UI pro Token.
                await withTaskGroup(of: Void.self) { group in
                    for agent in [AgentType.gemini, .claude, .mistral] {
                        let agentPrompt = plannedPrompts[agent] ?? prompt
                        group.addTask {
                            await self.streamAgentReply(
                                agent: agent,
                                plannedPrompt: agentPrompt,
                                into: roundIndex,
                                stepId: stepId
                            )
                        }
                    }
                    for await _ in group { }
                }

                // Finale ChatGPT-Synthese ebenfalls streaming
                let agentReplies = rounds[roundIndex].steps
                    .first { $0.id == stepId }?.agentReplies ?? [:]

                var finalAccumulated = ""
                for try await token in service.makeFinalStream(from: agentReplies, userPrompt: prompt) {
                    finalAccumulated += token
                    rounds[roundIndex].applyToStep(id: stepId) { step in
                        step.setFinalReply(text: finalAccumulated)
                    }
                }

            } catch {
                rounds[roundIndex].applyToStep(id: stepId) { step in
                    step.setFinalReply(text: "Fehler: \(error.localizedDescription)")
                }
            }

            PersistenceManager.saveRounds(rounds)
            isBusy = false
        }
    }

    // MARK: - Computed Properties

    var currentRound: ConversationRound? {
        guard rounds.indices.contains(selectedRoundIndex) else { return nil }
        return rounds[selectedRoundIndex]
    }

    var currentRoundId: String? { currentRound?.id }
    var currentSteps: [ChatStep] { currentRound?.steps ?? [] }
    var currentLastStepId: String? { currentRound?.lastStep?.id }

    // MARK: - Private Helfer

    /// Iteriert einen AsyncThrowingStream und schreibt jeden Token direkt in die Karte.
    private func streamAgentReply(
        agent: AgentType,
        plannedPrompt: String,
        into roundIndex: Int,
        stepId: String
    ) async {
        var accumulated = ""
        do {
            for try await token in service.fetchAgentStream(for: agent, plannedPrompt: plannedPrompt) {
                accumulated += token
                rounds[roundIndex].applyToStep(id: stepId) { step in
                    step.setAgentReply(agent: agent, text: accumulated)
                }
            }
        } catch let error as ONEAPIError {
            let errorText = accumulated.isEmpty
                ? "[\(agent.displayName)] \(error.localizedDescription)"
                : accumulated
            rounds[roundIndex].applyToStep(id: stepId) { step in
                step.setAgentReply(agent: agent, text: errorText)
            }
        } catch {
            rounds[roundIndex].applyToStep(id: stepId) { step in
                step.setAgentReply(agent: agent, text: "[\(agent.displayName)] Fehler: \(error.localizedDescription)")
            }
        }
    }

    private static func makeMockRounds() -> [ConversationRound] {
        var roundOne = ConversationRound(title: "SwiftUI & MVVM Basics")
        let stepOneId = roundOne.addStep(userPrompt: "Wie setze ich MVVM pragmatisch in SwiftUI um?")
        roundOne.applyToStep(id: stepOneId) { step in
            step.setAgentReply(agent: .gemini,  text: "MVVM trennt Daten, Logik und Darstellung klar voneinander.")
            step.setAgentReply(agent: .claude,  text: "Nutze Models, ViewModels (@Published) und Views (@StateObject).")
            step.setAgentReply(agent: .mistral, text: "Ergebnis: besser testbar und gut wartbar.")
            step.setFinalReply(text: "Insgesamt sinnvoll: VM als Source of Truth, Views bleiben schlank.")
        }
        var roundTwo = ConversationRound(title: "KI-Agenten – Zusammenarbeit")
        let stepTwoId = roundTwo.addStep(userPrompt: "Wie können mehrere KIs sinnvoll zusammenarbeiten?")
        roundTwo.applyToStep(id: stepTwoId) { step in
            step.setAgentReply(agent: .gemini,  text: "Gemini liefert Fakten und Quellen zur Anfrage.")
            step.setAgentReply(agent: .claude,  text: "Claude strukturiert diese Fakten in nachvollziehbare Schritte.")
            step.setAgentReply(agent: .mistral, text: "Mistral destilliert kurze, prägnante Kernaussagen.")
            step.setFinalReply(text: "ChatGPT prüft, ob alles konsistent zur Benutzereingabe passt.")
        }
        return [roundOne, roundTwo]
    }
}
