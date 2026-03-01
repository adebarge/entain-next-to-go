import Foundation
import Model
import Observation

/// The view-model for the "Next to Go" race list.
///
/// - Owns a 1-second tick loop that:
///   1. Prunes races that started more than `configuration.expiryInterval` seconds ago.
///   2. Applies the selected category filter (empty set = all categories).
///   3. Exposes the first `configuration.visibleCount` matching races as `visibleRaces`.
///   4. Triggers a network refresh when fewer than `configuration.visibleCount` races are visible.
///
/// - Countdown rendering is a View concern: use `CountdownLabel` (wrapping
///   `TimelineView(.everySecond)`) — no timer lives here for display purposes.
@Observable
@MainActor
public final class RaceListViewModel {

    // MARK: - Public state (automatically observed via @Observable)

    public private(set) var visibleRaces: [RaceRowViewModel] = []
    public private(set) var selectedCategories: Set<RaceCategory> = []
    public private(set) var isLoading: Bool = false
    public private(set) var error: Error?

    public var isFilterBarDisabled: Bool {
        visibleRaces.isEmpty && (isLoading || error != nil)
    }

    // MARK: - Private state

    private var allRaces: [Race] = []
    private var tickTask: Task<Void, Never>?
    private let service: any RaceService
    private let configuration: RaceListConfiguration
    private var lastFetchAt: Date?

    // MARK: - Static localised strings (view-level labels)

    // MARK: - Init

    public init(service: any RaceService, configuration: RaceListConfiguration = .default) {
        self.service = service
        self.configuration = configuration
    }

    // MARK: - Lifecycle

    /// Starts the tick loop and triggers an initial fetch.
    /// Call from `.onAppear`.
    public func start() {
        guard tickTask == nil else { return }
        tickTask = Task { [weak self] in
            await self?.fetchRaces(force: true)
            await self?.runTickLoop()
        }
    }

    /// Stops the tick loop. Call from `.onDisappear`.
    public func stop() {
        tickTask?.cancel()
        tickTask = nil
    }

    /// Retries after an error.
    public func retry() {
        error = nil
        lastFetchAt = nil
        start()
    }

    // MARK: - Category filtering

    /// Toggles a category on/off in the active filter set.
    public func toggleCategory(_ category: RaceCategory) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
        applyFilter(since: .now)
    }
}

extension RaceListViewModel {
    
    public var listTitle: String {
        NSLocalizedString("race.list.title", bundle: .module, comment: "")
    }
    
    public var emptyTitle: String {
        NSLocalizedString("race.list.empty.title", bundle: .module, comment: "")
    }

    public var emptyImageName: String {
        "flag.checkered"
    }
    
    public var filterBarAccessibilityLabel: String {
        NSLocalizedString("filter.bar.accessibility", bundle: .module, comment: "")
    }

    public var loadingMessage: String {
        NSLocalizedString("loading.message", bundle: .module, comment: "")
    }

    public var loadingAccessibilityLabel: String {
        NSLocalizedString("loading.accessibility", bundle: .module, comment: "")
    }

    public var errorTitle: String {
        NSLocalizedString("error.title", bundle: .module, comment: "")
    }

    public var errorMessage: String {
        NSLocalizedString("error.message.generic", bundle: .module, comment: "")
    }

    public var errorRetryButtonText: String {
        NSLocalizedString("error.retry.button", bundle: .module, comment: "")
    }
}

private extension RaceListViewModel {

    // MARK: - Private helpers

    func runTickLoop() async {
        while !Task.isCancelled {
            do {
                try await Task.sleep(for: .seconds(1))
            } catch {
                break
            }
            let now = Date.now
            pruneExpired(since: now)
            applyFilter(since: now)
            if shouldFetch(since: now) {
                await fetchRaces()
            }
        }
    }

    /// Remove races that started more than `configuration.expiryInterval` seconds ago.
    func pruneExpired(since date: Date) {
        allRaces = allRaces.filter { race in
            race.advertisedStart.timeIntervalSince(date) > -configuration.expiryInterval
        }
    }

    /// Apply expiry + category filter and pick the first `configuration.visibleCount` races.
    func applyFilter(since date: Date) {
        // Always exclude races past the expiry window for the visible list
        let active = allRaces.filter {
            $0.advertisedStart.timeIntervalSince(date) > -configuration.expiryInterval
        }
        let filtered: [Race]
        if selectedCategories.isEmpty {
            filtered = active
        } else {
            filtered = active.filter { selectedCategories.contains($0.category) }
        }
        visibleRaces = Array(filtered.prefix(configuration.visibleCount)).map { RaceRowViewModel(race: $0) }
    }

    func shouldFetch(since date: Date) -> Bool {
        guard visibleRaces.count < configuration.visibleCount else { return false }
        guard let lastFetchAt else { return true }
        return date.timeIntervalSince(lastFetchAt) >= configuration.minimumFetchInterval
    }

    func fetchRaces(force: Bool = false) async {
        guard !isLoading else { return }
        let now = Date.now
        guard force || shouldFetch(since: now) else { return }
        lastFetchAt = now
        isLoading = true
        defer { isLoading = false }
        do {
            let fetched = try await service.fetchNextRaces(count: configuration.fetchCount)
            // Prune stale races before merging to avoid surfacing expired entries
            pruneExpired(since: .now)
            // Upsert by ID so existing races are refreshed when API data changes.
            var racesById = Dictionary(uniqueKeysWithValues: allRaces.map { ($0.id, $0) })
            for race in fetched {
                racesById[race.id] = race
            }
            allRaces = racesById.values.sorted { $0.advertisedStart < $1.advertisedStart }
            error = nil
            applyFilter(since: .now)
        } catch is CancellationError {
            return
        } catch {
            self.error = error
            stop()
        }
    }
}
