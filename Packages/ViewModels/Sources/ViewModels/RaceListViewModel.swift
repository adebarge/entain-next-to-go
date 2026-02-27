import Foundation
import Model
import Observation

/// The view-model for the "Next to Go" race list.
///
/// - Owns a 1-second tick loop that:
///   1. Prunes races that started more than 60 seconds ago.
///   2. Applies the selected category filter (empty set = all categories).
///   3. Exposes the first 5 matching races as `visibleRaces`.
///   4. Triggers a network refresh when fewer than 5 races are visible.
///
/// - Countdown rendering is a View concern: use `CountdownLabel` (wrapping
///   `TimelineView(.everySecond)`) — no timer lives here for display purposes.
@Observable
@MainActor
public final class RaceListViewModel {

    // MARK: - Public state (automatically observed via @Observable)

    public var visibleRaces: [RaceRowViewModel] = []
    public var selectedCategories: Set<RaceCategory> = []
    public var isLoading: Bool = false
    public var error: Error?

    // MARK: - Private state

    private var allRaces: [Race] = []
    private var tickTask: Task<Void, Never>?
    private var retryTask: Task<Void, Never>?
    private let service: any RaceService

    private static let expiryInterval: TimeInterval = 60
    private static let visibleCount = 5
    private static let fetchCount = 10

    // MARK: - Static localised strings (view-level labels)

    public nonisolated static let listTitle = NSLocalizedString(
        "race.list.title", bundle: .module, comment: "")
    public nonisolated static let emptyTitle = NSLocalizedString(
        "race.list.empty.title", bundle: .module, comment: "")
    public nonisolated static let emptyDescription = NSLocalizedString(
        "race.list.empty.description", bundle: .module, comment: "")
    public nonisolated static let listAccessibilityLabel = NSLocalizedString(
        "race.list.accessibility", bundle: .module, comment: "")
    public nonisolated static let filterBarAccessibilityLabel = NSLocalizedString(
        "filter.bar.accessibility", bundle: .module, comment: "")
    public nonisolated static let loadingMessage = NSLocalizedString(
        "loading.message", bundle: .module, comment: "")
    public nonisolated static let loadingAccessibilityLabel = NSLocalizedString(
        "loading.accessibility", bundle: .module, comment: "")
    public nonisolated static let errorTitle = NSLocalizedString(
        "error.title", bundle: .module, comment: "")
    public nonisolated static let errorRetryButtonText = NSLocalizedString(
        "error.retry.button", bundle: .module, comment: "")
    public nonisolated static let errorRetryLabel = NSLocalizedString(
        "error.retry.label", bundle: .module, comment: "")
    public nonisolated static let errorRetryHint = NSLocalizedString(
        "error.retry.hint", bundle: .module, comment: "")

    public nonisolated static func errorScreenLabel(error: Error) -> String {
        String(
            format: NSLocalizedString("error.screen.label", bundle: .module, comment: ""),
            error.localizedDescription
        )
    }

    // MARK: - Init

    public init(service: any RaceService) {
        self.service = service
    }

    // MARK: - Lifecycle

    /// Starts the tick loop and triggers an initial fetch.
    /// Call from `.onAppear`.
    public func start() {
        guard tickTask == nil else { return }
        tickTask = Task { [weak self] in
            await self?.fetchRaces()
            await self?.runTickLoop()
        }
    }

    /// Stops the tick loop. Call from `.onDisappear`.
    public func stop() {
        tickTask?.cancel()
        tickTask = nil
        retryTask?.cancel()
        retryTask = nil
    }

    /// Retries after an error.
    public func retry() {
        error = nil
        retryTask = Task { await fetchRaces() }
    }

    // MARK: - Category filtering

    /// Toggles a category on/off in the active filter set.
    public func toggleCategory(_ category: RaceCategory) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
        applyFilter(now: Date())
    }

    // MARK: - Private helpers

    private func runTickLoop() async {
        while !Task.isCancelled {
            do {
                try await Task.sleep(for: .seconds(1))
            } catch {
                break
            }
            let now = Date()
            pruneExpired(now: now)
            applyFilter(now: now)
            if visibleRaces.count < Self.visibleCount {
                await fetchRaces()
            }
        }
    }

    /// Remove races that started more than 60 seconds ago.
    private func pruneExpired(now: Date) {
        allRaces = allRaces.filter { race in
            race.advertisedStart.timeIntervalSince(now) > -Self.expiryInterval
        }
    }

    /// Apply expiry + category filter and pick the first 5 races.
    private func applyFilter(now: Date) {
        // Always exclude races past the expiry window for the visible list
        let active = allRaces.filter {
            $0.advertisedStart.timeIntervalSince(now) > -Self.expiryInterval
        }
        let filtered: [Race]
        if selectedCategories.isEmpty {
            filtered = active
        } else {
            filtered = active.filter { selectedCategories.contains($0.category) }
        }
        visibleRaces = Array(filtered.prefix(Self.visibleCount)).map { RaceRowViewModel(race: $0) }
    }

    @discardableResult
    public func fetchRaces() async -> Bool {
        guard !isLoading else { return false }
        isLoading = true
        defer { isLoading = false }
        do {
            let fetched = try await service.fetchNextRaces(count: Self.fetchCount)
            // Prune stale races before merging to avoid surfacing expired entries
            pruneExpired(now: Date())
            // Merge without duplicates, keeping existing races and appending new ones
            let existingIds = Set(allRaces.map(\.id))
            let newRaces = fetched.filter { !existingIds.contains($0.id) }
            allRaces = (allRaces + newRaces).sorted { $0.advertisedStart < $1.advertisedStart }
            error = nil
            applyFilter(now: Date())
            return true
        } catch {
            self.error = error
            return false
        }
    }
}
