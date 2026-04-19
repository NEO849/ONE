//
//  ConversationViewModelTests.swift
//  ONETests
//
//  To run: add a test target in Xcode (File → New → Target → Unit Testing Bundle),
//  set Host Application to ONE, then include this file.
//

import XCTest
@testable import ONE

// MARK: - Stub

/// Synchroner Stub: liefert sofort vordefinierte Antworten, kein Netz, kein Delay.
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
        let throws = self.shouldThrow
        return AsyncThrowingStream { continuation in
            Task {
                if throws { continuation.finish(throwing: URLError(.notConnectedToInternet)); return }
                continuation.yield(text)
                continuation.finish()
            }
        }
    }

    func makeFinalStream(from agentReplies: [AgentType: String], userPrompt: String) -> AsyncThrowingStream<String, Error> {
        let text = finalReply
        let throws = self.shouldThrow
        return AsyncThrowingStream { continuation in
            Task {
                if throws { continuation.finish(throwing: URLError(.notConnectedToInternet)); return }
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
        // Clear any leftover persistence from a previous test run
        PersistenceManager.clearRounds()
        stub = StubConversationService()
        sut  = ConversationViewModel(service: stub)
    }

    override func tearDown() {
        PersistenceManager.clearRounds()
        sut  = nil
        stub = nil
        super.tearDown()
    }

    // MARK: – Initial state

    /// With StubConversationService + empty persistence → rounds starts empty.
    func test_initialState_isEmpty() {
        XCTAssertTrue(sut.rounds.isEmpty)
        XCTAssertTrue(sut.currentSteps.isEmpty)
        XCTAssertFalse(sut.isBusy)
    }

    func test_initialState_defaultLayoutIsGrid() {
        XCTAssertEqual(sut.layoutMode, .grid)
    }

    // MARK: – Layout toggle

    func test_toggleLayoutMode_switchesMode() {
        sut.toggleLayoutMode()
        XCTAssertEqual(sut.layoutMode, .stacked)
        sut.toggleLayoutMode()
        XCTAssertEqual(sut.layoutMode, .grid)
    }

    // MARK: – New round

    func test_createNewRound_appendsRound() {
        sut.createNewRound()
        XCTAssertEqual(sut.rounds.count, 1)
    }

    func test_createNewRound_insertsAtFront() {
        sut.createNewRound()
        let first = sut.rounds[0].id
        sut.createNewRound()
        // New round inserted at index 0
        XCTAssertNotEqual(sut.rounds[0].id, first)
        XCTAssertEqual(sut.rounds.count, 2)
    }

    func test_createNewRound_selectedIndexIsZero() {
        sut.createNewRound()
        XCTAssertEqual(sut.selectedRoundIndex, 0)
    }

    func test_createNewRound_currentRoundIdMatchesFirstRound() {
        sut.createNewRound()
        XCTAssertEqual(sut.currentRoundId, sut.rounds[0].id)
    }

    // MARK: – Delete round

    func test_deleteRound_removesCorrectRound() {
        sut.createNewRound()
        sut.createNewRound()
        let idToDelete = sut.rounds[0].id
        sut.deleteRound(withId: idToDelete)
        XCTAssertFalse(sut.rounds.contains { $0.id == idToDelete })
    }

    func test_deleteOnlyRound_leavesEmptyState() {
        sut.createNewRound()
        let onlyId = sut.rounds[0].id
        sut.deleteRound(withId: onlyId)
        XCTAssertTrue(sut.rounds.isEmpty)
        XCTAssertTrue(sut.currentSteps.isEmpty)
    }

    func test_deleteRoundWithInvalidId_doesNothing() {
        sut.createNewRound()
        let countBefore = sut.rounds.count
        sut.deleteRound(withId: "non-existent-id")
        XCTAssertEqual(sut.rounds.count, countBefore)
    }

    // MARK: – Sidebar

    func test_toggleSidebar_flipsState() {
        XCTAssertFalse(sut.isSidebarOpen)
        sut.toggleSidebar()
        XCTAssertTrue(sut.isSidebarOpen)
        sut.toggleSidebar()
        XCTAssertFalse(sut.isSidebarOpen)
    }

    // MARK: – Input guard

    func test_runFreeFlowStep_withBlankInput_doesNotAddStep() {
        sut.inputText = "   "
        sut.runFreeFlowStep()
        XCTAssertFalse(sut.isBusy)
        XCTAssertTrue(sut.currentSteps.isEmpty)
    }

    func test_runFreeFlowStep_withEmptyString_doesNotAddStep() {
        sut.inputText = ""
        sut.runFreeFlowStep()
        XCTAssertFalse(sut.isBusy)
    }

    // MARK: – Streaming step (happy path)

    func test_runFreeFlowStep_completesAndFillsAllReplies() async throws {
        sut.inputText = "Test-Frage"
        sut.runFreeFlowStep()

        let deadline = Date().addingTimeInterval(5)
        while sut.isBusy, Date() < deadline {
            await Task.yield()
        }

        XCTAssertFalse(sut.isBusy, "isBusy should be false after completion")
        XCTAssertEqual(sut.currentSteps.count, 1)

        let step = try XCTUnwrap(sut.currentSteps.first)
        XCTAssertEqual(step.userPrompt, "Test-Frage")
        XCTAssertEqual(step.agentReplies[.gemini],  "Gemini Antwort")
        XCTAssertEqual(step.agentReplies[.claude],  "Claude Antwort")
        XCTAssertEqual(step.agentReplies[.mistral], "Mistral Antwort")
        XCTAssertEqual(step.finalReply, "Finale Zusammenfassung")
    }

    func test_runFreeFlowStep_clearsInputText() async {
        sut.inputText = "Hallo"
        sut.runFreeFlowStep()
        XCTAssertTrue(sut.inputText.isEmpty)
    }

    func test_runFreeFlowStep_createsRoundIfNoneExists() async {
        XCTAssertTrue(sut.rounds.isEmpty)
        sut.inputText = "Frage ohne Runde"
        sut.runFreeFlowStep()

        let deadline = Date().addingTimeInterval(5)
        while sut.isBusy, Date() < deadline { await Task.yield() }

        XCTAssertFalse(sut.rounds.isEmpty, "runFreeFlowStep should create a round when none exists")
    }

    // MARK: – Error path

    func test_runFreeFlowStep_onPlanError_setsNotBusy() async {
        stub.shouldThrow = true
        sut.inputText = "Fehler-Test"
        sut.runFreeFlowStep()

        let deadline = Date().addingTimeInterval(5)
        while sut.isBusy, Date() < deadline { await Task.yield() }

        XCTAssertFalse(sut.isBusy)
        // Step was created before the throw, final reply holds error message
        XCTAssertEqual(sut.currentSteps.count, 1)
    }

    // MARK: – Update service

    func test_updateService_doesNotCrash() {
        let newStub = StubConversationService()
        sut.updateService(newStub)
        // State is valid after service swap
        XCTAssertEqual(sut.selectedRoundIndex, 0)
    }
}
