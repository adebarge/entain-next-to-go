import Foundation

public struct RaceListConfiguration: Sendable {
    public let expiryInterval: TimeInterval
    public let visibleCount: Int
    public let fetchCount: Int
    public let minimumFetchInterval: TimeInterval

    public static let `default` = RaceListConfiguration()

    public init(
        expiryInterval: TimeInterval = 60,
        visibleCount: Int = 5,
        fetchCount: Int = 10,
        minimumFetchInterval: TimeInterval = 20
    ) {
        self.expiryInterval = expiryInterval
        self.visibleCount = visibleCount
        self.fetchCount = fetchCount
        self.minimumFetchInterval = minimumFetchInterval
    }
}
