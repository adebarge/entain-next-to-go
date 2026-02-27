import Foundation
import Testing
@testable import Services

@Suite("APIEndpoint")
struct APIEndpointTests {
    @Test("Builds next races request with required query items")
    func nextRacesRequest() throws {
        let request = try APIEndpoint.nextRaces(count: 10)
        let url = try #require(request.url)
        let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
        let queryItems = Dictionary(uniqueKeysWithValues: (components.queryItems ?? []).map { ($0.name, $0.value) })

        #expect(request.httpMethod == "GET")
        #expect(components.scheme == "https")
        #expect(components.host == "api.neds.com.au")
        #expect(components.path == "/rest/v1/racing/")
        #expect(queryItems["method"] == "nextraces")
        #expect(queryItems["count"] == "10")
    }
}

@Suite("NextRacesResponse")
struct NextRacesResponseTests {
    @Test("Decodes in next_to_go order and skips unknown categories")
    func decodingOrderAndUnknownCategory() throws {
        let payload = """
        {
          "status": 200,
          "data": {
            "next_to_go_ids": ["two", "one", "unknown"],
            "race_summaries": {
              "one": {
                "race_id": "race-1",
                "meeting_name": "Randwick",
                "race_number": 1,
                "category_id": "4a2788f8-e825-4d36-9894-efd4baf1cfae",
                "advertised_start": { "seconds": 1700000100 }
              },
              "two": {
                "race_id": "race-2",
                "meeting_name": "Menangle",
                "race_number": 2,
                "category_id": "161d9be2-e909-4326-8c2c-35ed71fb460b",
                "advertised_start": { "seconds": 1700000000 }
              },
              "unknown": {
                "race_id": "race-3",
                "meeting_name": "Nowhere",
                "race_number": 3,
                "category_id": "not-a-known-category",
                "advertised_start": { "seconds": 1700000200 }
              }
            }
          }
        }
        """

        let data = try #require(payload.data(using: .utf8))
        let response = try JSONDecoder().decode(NextRacesResponse.self, from: data)

        #expect(response.races.map(\.id) == ["race-2", "race-1"])
        #expect(response.races.map(\.meetingName) == ["Menangle", "Randwick"])
        #expect(response.races[0].advertisedStart.timeIntervalSince1970 == 1_700_000_000)
    }
}

@Suite("NetworkService", .serialized)
struct NetworkServiceTests {
    @Test("Throws invalidResponse for non-HTTP URLResponse")
    func invalidResponseError() async throws {
        await URLProtocolStub.setRequestHandler { request in
            let response = URLResponse(
                url: try #require(request.url),
                mimeType: "application/json",
                expectedContentLength: 0,
                textEncodingName: nil
            )
            return (response, Data("{}".utf8))
        }
        defer { Task { await URLProtocolStub.resetRequestHandler() } }

        let service = NetworkService(session: URLSession.stubbed)
        let request = try APIEndpoint.nextRaces(count: 1)

        do {
            let _: NextRacesResponse = try await service.fetch(NextRacesResponse.self, request: request)
            Issue.record("Expected NetworkError.invalidResponse")
        } catch let error as NetworkError {
            guard case .invalidResponse = error else {
                Issue.record("Expected invalidResponse, got \(error)")
                return
            }
        }
    }

    @Test("Throws httpError for non-2xx status")
    func httpStatusError() async throws {
        await URLProtocolStub.setRequestHandler { request in
            let response = HTTPURLResponse(
                url: try #require(request.url),
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            )
            return (try #require(response), Data())
        }
        defer { Task { await URLProtocolStub.resetRequestHandler() } }

        let service = NetworkService(session: URLSession.stubbed)
        let request = try APIEndpoint.nextRaces(count: 1)

        do {
            let _: NextRacesResponse = try await service.fetch(NextRacesResponse.self, request: request)
            Issue.record("Expected NetworkError.httpError")
        } catch let error as NetworkError {
            guard case .httpError(let statusCode) = error else {
                Issue.record("Expected httpError, got \(error)")
                return
            }
            #expect(statusCode == 500)
        }
    }

    @Test("Throws decodingFailed for invalid payload")
    func decodingError() async throws {
        await URLProtocolStub.setRequestHandler { request in
            let response = HTTPURLResponse(
                url: try #require(request.url),
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )
            return (try #require(response), Data("not-json".utf8))
        }
        defer { Task { await URLProtocolStub.resetRequestHandler() } }

        let service = NetworkService(session: URLSession.stubbed)
        let request = try APIEndpoint.nextRaces(count: 1)

        do {
            let _: NextRacesResponse = try await service.fetch(NextRacesResponse.self, request: request)
            Issue.record("Expected NetworkError.decodingFailed")
        } catch let error as NetworkError {
            guard case .decodingFailed = error else {
                Issue.record("Expected decodingFailed, got \(error)")
                return
            }
        }
    }
}

private final class URLProtocolStub: URLProtocol, @unchecked Sendable {
    fileprivate typealias Handler = @Sendable (URLRequest) throws -> (URLResponse, Data)
    private static let storage = RequestHandlerStorage()

    fileprivate static func setRequestHandler(_ handler: @escaping Handler) async {
        await storage.set(handler)
    }

    fileprivate static func resetRequestHandler() async {
        await storage.clear()
    }

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        Task { [request, weak client] in
            guard let handler = await URLProtocolStub.storage.get() else {
                client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
                return
            }
            do {
                let (response, data) = try handler(request)
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                client?.urlProtocol(self, didLoad: data)
                client?.urlProtocolDidFinishLoading(self)
            } catch {
                client?.urlProtocol(self, didFailWithError: error)
            }
        }
    }

    override func stopLoading() {}
}

private actor RequestHandlerStorage {
    typealias Handler = @Sendable (URLRequest) throws -> (URLResponse, Data)
    private var handler: Handler?

    func set(_ handler: @escaping Handler) {
        self.handler = handler
    }

    func get() -> Handler? {
        handler
    }

    func clear() {
        handler = nil
    }
}

private extension URLSession {
    static var stubbed: URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        return URLSession(configuration: configuration)
    }
}
