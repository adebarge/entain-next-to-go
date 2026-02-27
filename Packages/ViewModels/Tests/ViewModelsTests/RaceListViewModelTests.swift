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
        start: Date = Date().addingTimeInterval(300),
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
        let vm = RaceListViewModel(service: mock)
        defer { vm.stop() }

        vm.start()
        try await waitUntil { vm.visibleRaces.count == 5 }

        #expect(vm.visibleRaces.count == 5)
        #expect(vm.error == nil)
        #expect(!vm.isLoading)
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
        let vm = RaceListViewModel(service: mock)
        defer { vm.stop() }
        vm.start()
        try await waitUntil { vm.visibleRaces.count == 5 }

        vm.toggleCategory(.horse)

        #expect(vm.visibleRaces.allSatisfy { $0.category == .horse })
        #expect(vm.visibleRaces.count == 3)
    }

    @Test("Deselecting all categories shows all races")
    func deselectAllShowsAll() async throws {
        let mock = MockRaceService()
        mock.racesToReturn = [
            Race.make(id: "h1", category: .horse),
            Race.make(id: "g1", category: .greyhound),
            Race.make(id: "r1", category: .harness)
        ]
        let vm = RaceListViewModel(service: mock)
        defer { vm.stop() }
        vm.start()
        try await waitUntil { vm.visibleRaces.count == 3 }

        vm.toggleCategory(.horse)
        #expect(vm.visibleRaces.count == 1)

        vm.toggleCategory(.horse) // deselect
        #expect(vm.visibleRaces.count == 3)
    }

    @Test("Expired races (older than 60s) are pruned from visible list")
    func expiredRacesArePruned() async throws {
        let mock = MockRaceService()
        let expired = Race.make(id: "expired", start: Date().addingTimeInterval(-90))
        let future = Race.make(id: "future", start: Date().addingTimeInterval(300))
        mock.racesToReturn = [expired, future]

        let vm = RaceListViewModel(service: mock)
        defer { vm.stop() }
        vm.start()
        try await waitUntil { !vm.visibleRaces.isEmpty }

        // applyFilter is called during fetchRaces and excludes races past the 60s expiry window
        let visible = vm.visibleRaces
        #expect(!visible.contains(where: { $0.id == "expired" }))
        #expect(visible.contains(where: { $0.id == "future" }))
    }

    @Test("Throttles refetches when visible races stay below 5")
    func throttlesRefetchWhenBelowFive() async throws {
        let mock = MockRaceService()
        // First fetch: 3 races (below threshold of 5)
        mock.racesToReturn = (1...3).map { Race.make(id: "r\($0)", raceNumber: $0) }
        let vm = RaceListViewModel(service: mock, configuration: RaceListConfiguration(minimumFetchInterval: 2))
        defer { vm.stop() }

        vm.start()
        try await waitUntil { mock.fetchCount >= 1 && vm.visibleRaces.count == 3 }
        let firstFetchCount = mock.fetchCount

        // Wait less than throttle interval; should not fetch yet.
        try await Task.sleep(for: .milliseconds(900))
        #expect(mock.fetchCount == firstFetchCount)

        // After interval elapses, next tick should trigger refetch.
        mock.racesToReturn = (4...8).map { Race.make(id: "r\($0)", raceNumber: $0) }
        try await waitUntil(timeout: .seconds(4)) {
            mock.fetchCount > firstFetchCount && vm.visibleRaces.count == 5
        }

        #expect(mock.fetchCount > firstFetchCount)
        #expect(vm.visibleRaces.count == 5)
    }

    @Test("Error is surfaced when fetch fails")
    func surfacesError() async throws {
        let mock = MockRaceService()
        mock.shouldThrow = true
        let vm = RaceListViewModel(service: mock)
        defer { vm.stop() }

        vm.start()
        try await waitUntil { vm.error != nil }

        #expect(vm.error != nil)
        #expect(vm.visibleRaces.isEmpty)
    }

    @Test("Retry clears error and re-fetches")
    func retryClears() async throws {
        let mock = MockRaceService()
        mock.shouldThrow = true
        let vm = RaceListViewModel(service: mock)
        defer { vm.stop() }
        vm.start()
        try await waitUntil { vm.error != nil }
        #expect(vm.error != nil)

        mock.shouldThrow = false
        mock.racesToReturn = [Race.make(id: "r1")]
        vm.retry()
        try await waitUntil { vm.error == nil && !vm.visibleRaces.isEmpty }

        #expect(vm.error == nil)
        #expect(!vm.visibleRaces.isEmpty)
    }

    @Test("Error stops the tick loop; retry restarts it")
    func errorStopsTickLoopAndRetryRestarts() async throws {
        let mock = MockRaceService()
        mock.shouldThrow = true
        let vm = RaceListViewModel(service: mock)
        defer { vm.stop() }

        vm.start()
        try await waitUntil { vm.error != nil }

        #expect(vm.error != nil)
        let fetchCountAfterError = mock.fetchCount

        // Wait longer than one tick interval — no additional fetches should occur
        try await Task.sleep(for: .milliseconds(1_200))
        #expect(mock.fetchCount == fetchCountAfterError)

        // Retry should clear the error and trigger a new fetch
        mock.shouldThrow = false
        mock.racesToReturn = (1...5).map { Race.make(id: "r\($0)", raceNumber: $0) }
        vm.retry()
        try await waitUntil { vm.error == nil && !vm.visibleRaces.isEmpty }

        #expect(vm.error == nil)
        #expect(!vm.visibleRaces.isEmpty)
    }

    @Test("Stop during in-flight fetch does not surface cancellation as error")
    func stopDoesNotSurfaceCancellation() async throws {
        let service = BlockingRaceService()
        let vm = RaceListViewModel(service: service)

        vm.start()
        try await service.waitUntilStarted()
        vm.stop()
        try await Task.sleep(for: .milliseconds(200))

        #expect(vm.error == nil)
    }

    @Test("Upserts existing race when API returns same id with updated values")
    func upsertsExistingRace() async throws {
        let mock = MockRaceService()
        let now = Date.now
        mock.racesToReturn = [
            Race.make(id: "same-id", meetingName: "Old Meeting", raceNumber: 1, start: now.addingTimeInterval(300))
        ]

        let vm = RaceListViewModel(service: mock, configuration: RaceListConfiguration(minimumFetchInterval: 0))
        defer { vm.stop() }

        vm.start()
        try await waitUntil { vm.visibleRaces.first?.meetingName == "Old Meeting" }

        mock.racesToReturn = [
            Race.make(id: "same-id", meetingName: "Updated Meeting", raceNumber: 7, start: Date.now.addingTimeInterval(120))
        ]

        try await waitUntil(timeout: .seconds(4)) {
            vm.visibleRaces.first?.meetingName == "Updated Meeting"
        }

        #expect(vm.visibleRaces.first?.meetingName == "Updated Meeting")
        #expect(vm.visibleRaces.first?.raceNumberText == "Race 7")
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
    }
}
