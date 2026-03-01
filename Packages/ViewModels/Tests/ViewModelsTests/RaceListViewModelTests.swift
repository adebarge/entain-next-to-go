import Testing
import Foundation
@testable import ViewModels
import Model

// MARK: - Mock

@MainActor
final class MockRaceService: RaceService {
    var racesToReturn: [Race] = []
    var shouldThrow: Bool = false
    var fetchCount: Int = 0

    func fetchNextRaces(count: Int) async throws -> [Race] {
        fetchCount += 1
        if shouldThrow { throw URLError(.notConnectedToInternet) }
        return racesToReturn
    }
}

actor BlockingRaceService: RaceService {
    private var started = false

    func fetchNextRaces(count: Int) async throws -> [Race] {
        started = true
        try await Task.sleep(for: .seconds(5))
        return []
    }

    func waitUntilStarted(timeout: Duration = .seconds(2)) async throws {
        let deadline = ContinuousClock.now.advanced(by: timeout)
        while !started {
            guard ContinuousClock.now < deadline else {
                throw TimeoutError()
            }
            await Task.yield()
        }
    }

    private struct TimeoutError: Error {}
}

// MARK: - Helpers

extension Race {
    static func make(
        id: String = UUID().uuidString,
        meetingName: String = "Test Meeting",
        raceNumber: Int = 1,
        start: Date = Date.now.addingTimeInterval(300),
        category: RaceCategory = .horse
    ) -> Race {
        Race(id: id, meetingName: meetingName, raceNumber: raceNumber,
             advertisedStart: start, category: category)
    }
}

// MARK: - Tests

@Suite("RaceListViewModel")
@MainActor
struct RaceListViewModelTests {

    @Test("Fetches races and shows up to 5")
    func fetchesAndShowsFiveRaces() async throws {
        let mock = MockRaceService()
        mock.racesToReturn = (1...7).map { Race.make(id: "race-\($0)", raceNumber: $0) }
        let testSubject = RaceListViewModel(service: mock)
        defer { testSubject.stop() }

        testSubject.start()
        try await waitUntil { testSubject.visibleRaces.count == 5 }

        #expect(testSubject.visibleRaces.count == 5)
        #expect(testSubject.error == nil)
        #expect(!testSubject.isLoading)
    }

    @Test("Filters to selected category")
    func filtersByCategory() async throws {
        let mock = MockRaceService()
        mock.racesToReturn = [
            Race.make(id: "h1", category: .horse),
            Race.make(id: "g1", category: .greyhound),
            Race.make(id: "h2", category: .horse),
            Race.make(id: "r1", category: .harness),
            Race.make(id: "h3", category: .horse)
        ]
        let testSubject = RaceListViewModel(service: mock)
        defer { testSubject.stop() }
        testSubject.start()
        try await waitUntil { testSubject.visibleRaces.count == 5 }

        testSubject.toggleCategory(.horse)

        #expect(testSubject.visibleRaces.allSatisfy { $0.category == .horse })
        #expect(testSubject.visibleRaces.count == 3)
    }

    @Test("Deselecting all categories shows all races")
    func deselectAllShowsAll() async throws {
        let mock = MockRaceService()
        mock.racesToReturn = [
            Race.make(id: "h1", category: .horse),
            Race.make(id: "g1", category: .greyhound),
            Race.make(id: "r1", category: .harness)
        ]
        let testSubject = RaceListViewModel(service: mock)
        defer { testSubject.stop() }
        testSubject.start()
        try await waitUntil { testSubject.visibleRaces.count == 3 }

        testSubject.toggleCategory(.horse)
        #expect(testSubject.visibleRaces.count == 1)

        testSubject.toggleCategory(.horse) // deselect
        #expect(testSubject.visibleRaces.count == 3)
    }

    @Test("Expired races (older than 60s) are pruned from visible list")
    func expiredRacesArePruned() async throws {
        let mock = MockRaceService()
        let expired = Race.make(id: "expired", start: Date.now.addingTimeInterval(-90))
        let future = Race.make(id: "future", start: Date.now.addingTimeInterval(300))
        mock.racesToReturn = [expired, future]

        let testSubject = RaceListViewModel(service: mock)
        defer { testSubject.stop() }
        testSubject.start()
        try await waitUntil { !testSubject.visibleRaces.isEmpty }

        // applyFilter is called during fetchRaces and excludes races past the 60s expiry window
        let visible = testSubject.visibleRaces
        #expect(!visible.contains(where: { $0.id == "expired" }))
        #expect(visible.contains(where: { $0.id == "future" }))
    }

    @Test("Throttles refetches when visible races stay below 5")
    func throttlesRefetchWhenBelowFive() async throws {
        let mock = MockRaceService()
        // First fetch: 3 races (below threshold of 5)
        mock.racesToReturn = (1...3).map { Race.make(id: "r\($0)", raceNumber: $0) }
        let testSubject = RaceListViewModel(service: mock, configuration: RaceListConfiguration(minimumFetchInterval: 2))
        defer { testSubject.stop() }

        testSubject.start()
        try await waitUntil { mock.fetchCount >= 1 && testSubject.visibleRaces.count == 3 }
        let firstFetchCount = mock.fetchCount

        // Wait less than throttle interval; should not fetch yet.
        try await Task.sleep(for: .milliseconds(900))
        #expect(mock.fetchCount == firstFetchCount)

        // After interval elapses, next tick should trigger refetch.
        mock.racesToReturn = (4...8).map { Race.make(id: "r\($0)", raceNumber: $0) }
        try await waitUntil(timeout: .seconds(4)) {
            mock.fetchCount > firstFetchCount && testSubject.visibleRaces.count == 5
        }

        #expect(mock.fetchCount > firstFetchCount)
        #expect(testSubject.visibleRaces.count == 5)
    }

    @Test("Error is surfaced when fetch fails")
    func surfacesError() async throws {
        let mock = MockRaceService()
        mock.shouldThrow = true
        let testSubject = RaceListViewModel(service: mock)
        defer { testSubject.stop() }

        testSubject.start()
        try await waitUntil { testSubject.error != nil }

        #expect(testSubject.error != nil)
        #expect(testSubject.visibleRaces.isEmpty)
    }

    @Test("Error copy is generic and user-friendly")
    func usesGenericErrorMessage() {
        let mock = MockRaceService()
        let testSubject = RaceListViewModel(service: mock)
        #expect(testSubject.errorMessage == "We couldn't load races right now. Please try again.")
        #expect(!testSubject.errorMessage.contains("NSURLErrorDomain"))
    }

    @Test("Error accessibility label is non-technical")
    func usesErrorScreenLabel() {
        let mock = MockRaceService()
        let testSubject = RaceListViewModel(service: mock)
        #expect(testSubject.errorScreenLabel == "Unable to load races. Tap 'Try Again' to retry.")
        #expect(!testSubject.errorScreenLabel.contains("%@"))
    }

    @Test("Retry clears error and re-fetches")
    func retryClears() async throws {
        let mock = MockRaceService()
        mock.shouldThrow = true
        let testSubject = RaceListViewModel(service: mock)
        defer { testSubject.stop() }
        testSubject.start()
        try await waitUntil { testSubject.error != nil }
        #expect(testSubject.error != nil)

        mock.shouldThrow = false
        mock.racesToReturn = [Race.make(id: "r1")]
        testSubject.retry()
        try await waitUntil { testSubject.error == nil && !testSubject.visibleRaces.isEmpty }

        #expect(testSubject.error == nil)
        #expect(!testSubject.visibleRaces.isEmpty)
    }

    @Test("Error stops the tick loop; retry restarts it")
    func errorStopsTickLoopAndRetryRestarts() async throws {
        let mock = MockRaceService()
        mock.shouldThrow = true
        let testSubject = RaceListViewModel(service: mock)
        defer { testSubject.stop() }

        testSubject.start()
        try await waitUntil { testSubject.error != nil }

        #expect(testSubject.error != nil)
        let fetchCountAfterError = mock.fetchCount

        // Wait longer than one tick interval — no additional fetches should occur
        try await Task.sleep(for: .milliseconds(1_200))
        #expect(mock.fetchCount == fetchCountAfterError)

        // Retry should clear the error and trigger a new fetch
        mock.shouldThrow = false
        mock.racesToReturn = (1...5).map { Race.make(id: "r\($0)", raceNumber: $0) }
        testSubject.retry()
        try await waitUntil { testSubject.error == nil && !testSubject.visibleRaces.isEmpty }

        #expect(testSubject.error == nil)
        #expect(!testSubject.visibleRaces.isEmpty)
    }

    @Test("Stop during in-flight fetch does not surface cancellation as error")
    func stopDoesNotSurfaceCancellation() async throws {
        let service = BlockingRaceService()
        let testSubject = RaceListViewModel(service: service)

        testSubject.start()
        try await service.waitUntilStarted()
        testSubject.stop()
        try await Task.sleep(for: .milliseconds(200))

        #expect(testSubject.error == nil)
    }

    @Test("Upserts existing race when API returns same id with updated values")
    func upsertsExistingRace() async throws {
        let mock = MockRaceService()
        let now = Date.now
        mock.racesToReturn = [
            Race.make(id: "same-id", meetingName: "Old Meeting", raceNumber: 1, start: now.addingTimeInterval(300))
        ]

        let testSubject = RaceListViewModel(service: mock, configuration: RaceListConfiguration(minimumFetchInterval: 0))
        defer { testSubject.stop() }

        testSubject.start()
        try await waitUntil { testSubject.visibleRaces.first?.meetingName == "Old Meeting" }

        mock.racesToReturn = [
            Race.make(id: "same-id", meetingName: "Updated Meeting", raceNumber: 7, start: Date.now.addingTimeInterval(120))
        ]

        try await waitUntil(timeout: .seconds(4)) {
            testSubject.visibleRaces.first?.meetingName == "Updated Meeting"
        }

        #expect(testSubject.visibleRaces.first?.meetingName == "Updated Meeting")
        #expect(testSubject.visibleRaces.first?.raceNumberText == "Race 7")
    }
}

private extension RaceListViewModelTests {
    func waitUntil(
        timeout: Duration = .seconds(2),
        pollInterval: Duration = .milliseconds(20),
        _ condition: @escaping @MainActor () -> Bool
    ) async throws {
        let clock = ContinuousClock()
        let deadline = clock.now.advanced(by: timeout)
        while clock.now < deadline {
            if condition() {
                return
            }
            try await Task.sleep(for: pollInterval)
        }
        Issue.record("Timed out waiting for async condition.")
        throw WaitTimeoutError()
    }
    
    struct WaitTimeoutError: Error {}
}
