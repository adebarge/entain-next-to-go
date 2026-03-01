import Foundation

/// A single race in the "Next to Go" feed.
public struct Race: Identifiable, Hashable, Sendable {
    public let id: String
    public let meetingName: String
    public let raceNumber: Int
    public let advertisedStart: Date
    public let category: RaceCategory

    public init(
        id: String,
        meetingName: String,
        raceNumber: Int,
        advertisedStart: Date,
        category: RaceCategory
    ) {
        self.id = id
        self.meetingName = meetingName
        self.raceNumber = raceNumber
        self.advertisedStart = advertisedStart
        self.category = category
    }

}
