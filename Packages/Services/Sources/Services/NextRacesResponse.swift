import Foundation
import Model

// MARK: - Top-level response

/// Raw DTO for the Neds `nextraces` API endpoint.
/// The response looks like:
/// ```json
/// {
///   "status": 200,
///   "data": {
///     "next_to_go_ids": ["id1", "id2", ...],
///     "race_summaries": {
///       "id1": { ... },
///       "id2": { ... }
///     }
///   }
/// }
/// ```
struct NextRacesResponse: Decodable {
    let races: [Race]

    init(from decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: RootKeys.self)
        let data = try root.nestedContainer(keyedBy: DataKeys.self, forKey: .data)

        let orderedIds = try data.decode([String].self, forKey: .nextToGoIds)
        let summaries = try data.decode([String: RaceSummaryDTO].self, forKey: .raceSummaries)

        // Build domain models in next-to-go order, skipping any unknown categories
        races = orderedIds.compactMap { id -> Race? in
            guard let dto = summaries[id],
                  let category = RaceCategory(categoryId: dto.categoryType) else { return nil }
            return Race(
                id: dto.raceId,
                meetingName: dto.meetingName,
                raceNumber: dto.raceNumber,
                advertisedStart: dto.advertisedStart.start,
                category: category
            )
        }
    }

    private enum RootKeys: String, CodingKey {
        case status, data
    }

    private enum DataKeys: String, CodingKey {
        case nextToGoIds = "next_to_go_ids"
        case raceSummaries = "race_summaries"
    }
}

// MARK: - Race summary DTO

private struct RaceSummaryDTO: Decodable {
    let raceId: String
    let meetingName: String
    let raceNumber: Int
    let categoryType: String
    let advertisedStart: AdvertisedStartDTO

    private enum CodingKeys: String, CodingKey {
        case raceId = "race_id"
        case meetingName = "meeting_name"
        case raceNumber = "race_number"
        case categoryType = "category_id"
        case advertisedStart = "advertised_start"
    }
}

private struct AdvertisedStartDTO: Decodable {
    let start: Date

    private enum CodingKeys: String, CodingKey {
        case seconds
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let epochSeconds = try container.decode(TimeInterval.self, forKey: .seconds)
        start = Date(timeIntervalSince1970: epochSeconds)
    }
}
