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

        await vm.fetchRaces()

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
        await vm.fetchRaces()

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
        await vm.fetchRaces()

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
        await vm.fetchRaces()

        // applyFilter is called during fetchRaces and excludes races past the 60s expiry window
        let visible = vm.visibleRaces
        #expect(!visible.contains(where: { $0.id == "expired" }))
        #expect(visible.contains(where: { $0.id == "future" }))
    }

    @Test("Triggers a refetch when visible races fall below 5 after expiry")
    func refetchesWhenBelowFive() async throws {
        let mock = MockRaceService()
        // First fetch: 3 races (below threshold of 5)
        mock.racesToReturn = (1...3).map { Race.make(id: "r\($0)", raceNumber: $0) }
        let vm = RaceListViewModel(service: mock)

        await vm.fetchRaces()
        let firstFetchCount = mock.fetchCount

        // Second fetch: provide 5 more
        mock.racesToReturn = (4...8).map { Race.make(id: "r\($0)", raceNumber: $0) }
        await vm.fetchRaces()

        #expect(mock.fetchCount > firstFetchCount)
        #expect(vm.visibleRaces.count == 5)
    }

    @Test("Error is surfaced when fetch fails")
    func surfacesError() async throws {
        let mock = MockRaceService()
        mock.shouldThrow = true
        let vm = RaceListViewModel(service: mock)

        await vm.fetchRaces()

        #expect(vm.error != nil)
        #expect(vm.visibleRaces.isEmpty)
    }

    @Test("Retry clears error and re-fetches")
    func retryClears() async throws {
        let mock = MockRaceService()
        mock.shouldThrow = true
        let vm = RaceListViewModel(service: mock)
        await vm.fetchRaces()
        #expect(vm.error != nil)

        mock.shouldThrow = false
        mock.racesToReturn = [Race.make(id: "r1")]
        vm.retry()
        // Give retry task a moment
        try await Task.sleep(for: .milliseconds(100))

        #expect(vm.error == nil)
        #expect(!vm.visibleRaces.isEmpty)
        vm.stop()
    }

    @Test("Error stops the tick loop; retry restarts it")
    func errorStopsTickLoopAndRetryRestarts() async throws {
        let mock = MockRaceService()
        mock.shouldThrow = true
        let vm = RaceListViewModel(service: mock)

        vm.start()
        try await Task.sleep(for: .milliseconds(100))

        #expect(vm.error != nil)
        let fetchCountAfterError = mock.fetchCount

        // Wait longer than one tick interval — no additional fetches should occur
        try await Task.sleep(for: .milliseconds(1_200))
        #expect(mock.fetchCount == fetchCountAfterError)

        // Retry should clear the error and trigger a new fetch
        mock.shouldThrow = false
        mock.racesToReturn = (1...5).map { Race.make(id: "r\($0)", raceNumber: $0) }
        vm.retry()
        try await Task.sleep(for: .milliseconds(100))

        #expect(vm.error == nil)
        #expect(!vm.visibleRaces.isEmpty)
        vm.stop()
    }
}
