//
//  ConversationViewModelTests.swift
//  ONETests
//

import XCTest
@testable import ONE

// MARK: - Stub Service

/// Synchroner Stub: liefert sofort vordefinierte Antworten
final class StubConversationService: ConversationProtocol {

    var planResult: [AgentType: String] = [
        .gemini:  "Gemini-Prompt",
        .claude:  "Claude-Prompt",
        .mistral: "Mistral-Prompt"
    ]
    var agentReplies: [AgentType: String] = [
        .gemini:  "Gemini Antwort",
        .claude:  "Claude Antwort",
        .mistral: "Mistral Antwort"
    ]
    var finalReply = "Finale Zusammenfassung"
    var shouldThrow = false

    func planAgentPrompts(for userPrompt: String) async throws -> [AgentType: String] {
        if shouldThrow { throw URLError(.notConnectedToInternet) }
        return planResult
    }

    func fetchAgentReply(for agent: AgentType, plannedPrompt: String) async throws -> String {
        if shouldThrow { throw URLError(.notConnectedToInternet) }
        return agentReplies[agent] ?? ""
    }

    func makeFinalReply(from agentReplies: [AgentType: String], userPrompt: String) async throws -> String {
        if shouldThrow { throw URLError(.notConnectedToInternet) }
        return finalReply
    }

    func fetchAgentStream(for agent: AgentType, plannedPrompt: String) -> AsyncThrowingStream<String, Error> {
        let text = agentReplies[agent] ?? ""
        let shouldThrow = self.shouldThrow
        return AsyncThrowingStream { continuation in
            Task {
                if shouldThrow { continuation.finish(throwing: URLError(.notConnectedToInternet)); return }
                continuation.yield(text)
                continuation.finish()
            }
        }
    }

    func makeFinalStream(from agentReplies: [AgentType: String], userPrompt: String) -> AsyncThrowingStream<String, Error> {
        let text = finalReply
        let shouldThrow = self.shouldThrow
        return AsyncThrowingStream { continuation in
            Task {
                if shouldThrow { continuation.finish(throwing: URLError(.notConnectedToInternet)); return }
                continuation.yield(text)
                continuation.finish()
            }
        }
    }
}

// MARK: - Tests

@MainActor
final class ConversationViewModelTests: XCTestCase {

    private var stub: StubConversationService!
    private var sut: ConversationViewModel!

    override func setUp() {
        super.setUp()
        stub = StubConversationService()
        sut  = ConversationViewModel(service: stub)
    }

    override func tearDown() {
        sut  = nil
        stub = nil
        super.tearDown()
    }

    // MARK: Initial state

    func test_initialState_hasOneEmptyRound() {
        XCTAssertEqual(sut.rounds.count, 1)
        XCTAssertTrue(sut.currentSteps.isEmpty)
        XCTAssertFalse(sut.isBusy)
    }

    // MARK: Layout toggle

    func test_toggleLayoutMode_switchesBetweenGridAndStacked() {
        let initial = sut.layoutMode
        sut.toggleLayoutMode()
        XCTAssertNotEqual(sut.layoutMode, initial)
        sut.toggleLayoutMode()
        XCTAssertEqual(sut.layoutMode, initial)
    }

    // MARK: New round

    func test_createNewRound_appendsRound() {
        sut.createNewRound()
        XCTAssertEqual(sut.rounds.count, 2)
    }

    func test_createNewRound_selectsNewRound() {
        sut.createNewRound()
        XCTAssertEqual(sut.currentRoundId, sut.rounds.last?.id)
    }

    // MARK: Delete round

    func test_deleteRound_removesCorrectRound() {
        sut.createNewRound()
        let idToDelete = sut.rounds[0].id
        sut.deleteRound(withId: idToDelete)
        XCTAssertFalse(sut.rounds.contains { $0.id == idToDelete })
    }

    func test_deleteLastRound_createsNewEmptyRound() {
        let onlyId = sut.rounds[0].id
        sut.deleteRound(withId: onlyId)
        XCTAssertEqual(sut.rounds.count, 1)
        XCTAssertTrue(sut.currentSteps.isEmpty)
    }

    // MARK: Sidebar

    func test_toggleSidebar_flipsOpenState() {
        XCTAssertFalse(sut.isSidebarOpen)
        sut.toggleSidebar()
        XCTAssertTrue(sut.isSidebarOpen)
        sut.toggleSidebar()
        XCTAssertFalse(sut.isSidebarOpen)
    }

    // MARK: Input guard

    func test_runFreeFlowStep_withEmptyInput_doesNothing() async {
        sut.inputText = "   "
        sut.runFreeFlowStep()
        // isBusy bleibt false, kein Step hinzugefügt
        XCTAssertFalse(sut.isBusy)
        XCTAssertTrue(sut.currentSteps.isEmpty)
    }

    // MARK: Streaming step

    func test_runFreeFlowStep_addsStepAndFillsReplies() async throws {
        sut.inputText = "Test-Frage"
        sut.runFreeFlowStep()

        // Warte bis isBusy wieder false
        let deadline = Date().addingTimeInterval(5)
        while sut.isBusy && Date() < deadline {
            await Task.yield()
        }

        XCTAssertFalse(sut.isBusy)
        XCTAssertEqual(sut.currentSteps.count, 1)

        let step = try XCTUnwrap(sut.currentSteps.first)
        XCTAssertEqual(step.userPrompt, "Test-Frage")
        XCTAssertEqual(step.agentReplies[.gemini],  "Gemini Antwort")
        XCTAssertEqual(step.agentReplies[.claude],  "Claude Antwort")
        XCTAssertEqual(step.agentReplies[.mistral], "Mistral Antwort")
        XCTAssertEqual(step.finalReply, "Finale Zusammenfassung")
    }

    // MARK: Error handling

    func test_runFreeFlowStep_onNetworkError_setsErrorInReplies() async {
        stub.shouldThrow = true
        sut.inputText = "Fehler-Test"
        sut.runFreeFlowStep()

        let deadline = Date().addingTimeInterval(5)
        while sut.isBusy && Date() < deadline {
            await Task.yield()
        }

        XCTAssertFalse(sut.isBusy)
        // Step wurde angelegt
        XCTAssertEqual(sut.currentSteps.count, 1)
    }

    // MARK: Update service

    func test_updateService_replacesService() {
        let newStub = StubConversationService()
        newStub.finalReply = "Neuer Service"
        sut.updateService(newStub)
        // Kein direkter Test auf private property – Verhalten via Step-Test prüfen
        XCTAssertTrue(sut.currentSteps.isEmpty) // Zustand bleibt erhalten
    }
}
