import Foundation

/// Builds URLRequests for the Neds racing API.
enum APIEndpoint {
    private static let baseURL = "https://api.neds.com.au/rest/v1/racing/"

    /// Returns a URLRequest to fetch the next `count` races.
    static func nextRaces(count: Int) throws -> URLRequest {
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "method", value: "nextraces"),
            URLQueryItem(name: "count", value: String(count))
        ]
        guard let url = components?.url else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.cachePolicy = .reloadIgnoringLocalCacheData
        return request
    }
}
