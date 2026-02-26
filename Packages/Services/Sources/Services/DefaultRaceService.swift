import Foundation
import Model

/// Concrete `RaceService` that fetches live data from the Neds API via `NetworkService`.
public struct DefaultRaceService: RaceService {
    private let network: NetworkService

    public init(network: NetworkService) {
        self.network = network
    }

    public func fetchNextRaces(count: Int) async throws -> [Race] {
        let request = try APIEndpoint.nextRaces(count: count)
        let response = try await network.fetch(NextRacesResponse.self, request: request)
        return response.races
    }
}
