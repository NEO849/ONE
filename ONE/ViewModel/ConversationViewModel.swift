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
            // Gespeicherte Runden haben Vorrang
            self.rounds = persistedRounds
        } else if service is MockConversationService {
            // Mock-Daten nur als Fallback für Previews / ersten Start ohne Keys
            self.rounds = Self.makeMockRounds()
        }
        // Echter Service + keine Persistenz → leere Liste (Nutzer startet frisch)
    }

    // MARK: - Service-Wechsel

    /// Tauscht den aktiven Service aus (z.B. nach Onboarding oder Settings-Änderung).
    /// Lädt bestehende Persistenz neu; bei leerer Persistenz startet die Liste frisch.
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

    // MARK: - Free-Flow-Schritt

    /// Nutzerprompt → drei Agenten antworten progressiv → ChatGPT prüft final.
    /// Jede Agentenkarte aktualisiert sich, sobald ihre Antwort eintrifft (kein Warten auf alle).
    func runFreeFlowStep() {
        let prompt = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty else { return }

        // Neue Runde anlegen, falls keine vorhanden oder Index ungültig
        if rounds.isEmpty || !rounds.indices.contains(selectedRoundIndex) {
            createNewRound()
        }

        isBusy = true
        inputText = ""

        Task {
            // Index einfrieren – der Nutzer könnte während des Requests die Runde wechseln
            let roundIndex = selectedRoundIndex
            guard rounds.indices.contains(roundIndex) else { isBusy = false; return }

            let stepId = rounds[roundIndex].addStep(userPrompt: prompt)
            // addStep setzt den Rundentitel automatisch beim ersten Step
            // @Published löst hier bereits einen UI-Redraw aus (leere Karten = Ladezustand)

            do {
                // 1) Planung – Service gibt pro Agent einen optimierten Teilprompt zurück
                let plannedPrompts = try await service.planAgentPrompts(for: prompt)

                // 2) Drei Agenten parallel starten – UI-Update sobald jede Antwort eintrifft
                await withTaskGroup(of: (AgentType, String).self) { group in
                    for agent in [AgentType.gemini, .claude, .mistral] {
                        let agentPrompt = plannedPrompts[agent] ?? prompt
                        group.addTask {
                            let reply = await self.safeAgentReply(for: agent,
                                                                  plannedPrompt: agentPrompt)
                            return (agent, reply)
                        }
                    }
                    // Progressives UI-Update: sofort wenn ein Agent antwortet
                    for await (agent, reply) in group {
                        rounds[roundIndex].applyToStep(id: stepId) { step in
                            step.setAgentReply(agent: agent, text: reply)
                        }
                    }
                }

                // 3) Gesammelte Antworten für ChatGPT-Finalprüfung
                let agentReplies = rounds[roundIndex].steps
                    .first { $0.id == stepId }?.agentReplies ?? [:]

                // 4) ChatGPT prüft und fasst alle drei Perspektiven zusammen
                let finalText = try await service.makeFinalReply(from: agentReplies,
                                                                 userPrompt: prompt)
                rounds[roundIndex].applyToStep(id: stepId) { step in
                    step.setFinalReply(text: finalText)
                }

            } catch {
                // Fehler als lesbarer Text – kein Crash, kein Datenverlust
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

    var currentSteps: [ChatStep] { currentRound?.steps ?? [] }

    var currentLastStepId: String? { currentRound?.lastStep?.id }

    // MARK: - Private Helfer

    /// Ruft einen Agenten auf und fängt Fehler als Anzeigetext ab (wirft nie).
    private func safeAgentReply(for agent: AgentType, plannedPrompt: String) async -> String {
        do {
            return try await service.fetchAgentReply(for: agent, plannedPrompt: plannedPrompt)
        } catch let error as ONEAPIError {
            return "[\(agent.displayName)] \(error.localizedDescription)"
        } catch {
            return "[\(agent.displayName)] Fehler: \(error.localizedDescription)"
        }
    }

    /// Statische Mock-Daten – nur beim MockConversationService und leerer Persistenz.
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
