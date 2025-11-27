//
//  ConversationViewModel.swift
//  ONE
//
//  Created by Michael Fleps on 04.11.25.
//

import Foundation

/// Zentrale Steuereinheit (MVVM).
/// Beziehungen:
/// - Hält State für den Screen.
/// - Orchestriert einen Step via Service.
/// - Keine UI-Elemente (nur Daten/Logik).
@MainActor
final class ConversationViewModel: ObservableObject {
    
    // Abhängigkeit (DI)
    private let service: ConversationProtocol
    
    // UI-State (Source of Truth)
    @Published private(set) var rounds: [ConversationRound] = []
    @Published var selectedRoundIndex: Int = 0
    @Published var isSidebarOpen: Bool = false
    @Published var inputText: String = ""
    @Published var isBusy: Bool = false
    
    init(service: ConversationProtocol) {
        self.service = service
        // Start mit Demo-Daten
        self.rounds = Self.makeInitialRounds()
    }
    
    // MARK: - UI-Aktionen
    func toggleSidebar() { isSidebarOpen.toggle() }
    
    func selectRound(at indexValue: Int) {
        guard rounds.indices.contains(indexValue) else { return }
        selectedRoundIndex = indexValue
    }
    
    func createNewRound() {
        rounds.insert(ConversationRound(title: ""), at: 0)
        selectedRoundIndex = 0
        inputText = ""
    }
    
    /// Free-Flow – Nutzerprompt → drei Agenten antworten → ChatGPT prüft final.
    func runFreeFlowStep() {
        let prompt = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !prompt.isEmpty, rounds.indices.contains(selectedRoundIndex) else { return }
        
        isBusy = true
        inputText = ""
        
        Task {
            var round = rounds[selectedRoundIndex]
            let stepId = round.addStep(userPrompt: prompt)
            
            do {
                // 1) Planung
                let planned = try await service.planAgentPrompts(for: prompt)
                
                // 2) Antworten parallel
                async let gem = service.fetchAgentReply(for: .gemini,  plannedPrompt: planned[.gemini]  ?? "")
                async let cla = service.fetchAgentReply(for: .claude,  plannedPrompt: planned[.claude]  ?? "")
                async let mis = service.fetchAgentReply(for: .mistral, plannedPrompt: planned[.mistral] ?? "")
                
                let replies: [AgentType: String] = [
                    .gemini:  try await gem,
                    .claude:  try await cla,
                    .mistral: try await mis
                ]
                
                // 3) Finale Prüfung
                let final = try await service.makeFinalReply(from: replies, userPrompt: prompt)
                
                // 4) **in-place** aktualisieren (applyToStep)
                round.applyToStep(id: stepId) { step in
                    step.setAgentReply(agent: .gemini,  text: replies[.gemini]  ?? "")
                    step.setAgentReply(agent: .claude,  text: replies[.claude]  ?? "")
                    step.setAgentReply(agent: .mistral, text: replies[.mistral] ?? "")
                    step.setFinalReply(text: final)
                }
                
                rounds[selectedRoundIndex] = round
            } catch {
                // Fehler als finalReply eintragen (UI bleibt benutzbar)
                round.applyToStep(id: stepId) { step in
                    step.setFinalReply(text: "Fehler: \(error.localizedDescription)")
                }
                rounds[selectedRoundIndex] = round
            }
            
            isBusy = false
        }
    }
    
    // Helper
    var currentRound: ConversationRound? {
        guard rounds.indices.contains(selectedRoundIndex) else { return nil }
        return rounds[selectedRoundIndex]
    }

    /// Liefert alle Steps der aktuellen Runde als nicht-optionales Array.
    /// Vorteil: Die UI muss keine Nil-Coalescing-Magie (?? []) machen.
    var currentSteps: [ChatStep] {
        currentRound?.steps ?? []
    }

    /// ID des letzten Steps (falls vorhanden).
    /// Wird für das automatische Scrollen nach unten genutzt.
    var currentLastStepId: String? {
        currentRound?.lastStep?.id
    }
    
    /// Beispielrunden, damit #Preview sofort Inhalte zeigt.
    private static func makeInitialRounds() -> [ConversationRound] {
        // Runde 1
        var roundOne = ConversationRound(title: "SwiftUI & MVVM Basics")
        
        // Step 1
        let stepOneId = roundOne.addStep(userPrompt: "Wie setze ich MVVM pragmatisch in SwiftUI um?")
        roundOne.applyToStep(id: stepOneId) { step in
            step.setAgentReply(agent: .gemini,
                               text: "MVVM trennt Daten, Logik und Darstellung klar voneinander.")
            step.setAgentReply(agent: .claude,
                               text: "Nutze Models, ViewModels (@Published) und Views (@StateObject).")
            step.setAgentReply(agent: .mistral,
                               text: "Ergebnis: besser testbar und gut wartbar.")
            step.setFinalReply(text: "Insgesamt sinnvoll: VM als Source of Truth, Views bleiben schlank.")
        }
        let stepTwoId = roundOne.addStep(userPrompt: "Wie strukturiere ich meine Ordner sauber?")
        roundOne.applyToStep(id: stepTwoId) { step in
            step.setAgentReply(agent: .gemini,
                               text: "Empfehlung: Features/<Name>/{Model,ViewModel,View}.")
            step.setAgentReply(agent: .claude,
                               text: "Gemeinsame Services/Repositories in einen Shared-Bereich legen.")
            step.setAgentReply(agent: .mistral,
                               text: "Nicht übertreiben – klein starten, Struktur wächst mit dem Projekt.")
            step.setFinalReply(text: "Feature-Gruppierung plus Shared-Layer ist ein pragmatischer Start.")
        }
        // Runde 2
        var roundTwo = ConversationRound(title: "KI-Agenten – Zusammenarbeit")
        let stepThreeId = roundTwo.addStep(userPrompt: "Wie können mehrere KIs sinnvoll zusammenarbeiten?")
        roundTwo.applyToStep(id: stepThreeId) { step in
            step.setAgentReply(agent: .gemini,
                               text: "Gemini liefert Fakten und Quellen zur Anfrage.")
            step.setAgentReply(agent: .claude,
                               text: "Claude strukturiert diese Fakten in nachvollziehbare Schritte.")
            step.setAgentReply(agent: .mistral,
                               text: "Mistral destilliert kurze, prägnante Kernaussagen.")
            step.setFinalReply(text: "ChatGPT prüft, ob alles konsistent zur Benutzereingabe passt.")
        }
        
        return [roundOne, roundTwo]
    }
}
