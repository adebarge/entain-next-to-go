import Foundation

/// Abstraction over the race data source, enabling dependency injection and testing.
public protocol RaceService: Sendable {
    /// Fetch the next `count` races from the data source, ordered by advertised start time.
    func fetchNextRaces(count: Int) async throws -> [Race]
}
