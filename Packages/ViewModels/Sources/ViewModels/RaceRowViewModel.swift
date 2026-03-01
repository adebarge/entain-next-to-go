import Foundation
import Model

/// A fully-formatted row model for a single race, ready for display.
///
/// All static strings are formatted eagerly in `init(race:)`.
/// The only dynamic string — the countdown — is computed on demand via
/// `countdownText(at:)` so `CountdownLabel` can call it inside `TimelineView`.
public struct RaceRowViewModel: Identifiable, Hashable, Sendable {

    // MARK: - Public properties

    public let id: String
    public let raceNumberText: String       // e.g. "Race 7"
    public let meetingName: String
    public let categoryName: String         // e.g. "Horse"
    public let category: RaceCategory       // kept for filter/test use
    public let sfSymbol: String
    public let accessibilityLabel: String   // e.g. "Race 7, Randwick, Horse race, starts at 3:45 PM"

    // MARK: - Internal (used only for countdown computation)

    let advertisedStart: Date

    // MARK: - Init

    public init(race: Race) {
        id = race.id
        meetingName = race.meetingName
        category = race.category
        sfSymbol = race.category.sfSymbol

        raceNumberText = String(
            format: NSLocalizedString("race.row.number", bundle: .module, comment: ""),
            race.raceNumber
        )

        categoryName = race.category.localizedName

        let startTime = race.advertisedStart.formatted(.dateTime.hour().minute().second())

        accessibilityLabel = String(
            format: NSLocalizedString("race.row.label", bundle: .module, comment: ""),
            race.raceNumber,
            race.meetingName,
            race.category.localizedName,
            startTime
        )

        advertisedStart = race.advertisedStart
    }

    // MARK: - Dynamic countdown

    /// Returns a localised countdown string for the given instant.
    /// Call this inside a `TimelineView` context — never stored on the ViewModel.
    public func countdownText(at now: Date) -> String {
        let interval = advertisedStart.timeIntervalSince(now)
        let isNegative = interval < 0
        let absInterval = abs(interval)
        let minutes = Int(absInterval) / 60
        let seconds = Int(absInterval) % 60

        let minFormat = NSLocalizedString("countdown.minutes", bundle: .module, comment: "")
        let secFormat = NSLocalizedString("countdown.seconds", bundle: .module, comment: "")
        let minLabel = String.localizedStringWithFormat(minFormat, minutes)
        let secLabel = String.localizedStringWithFormat(secFormat, seconds)

        let detail = minutes > 0 ? "\(minLabel) \(secLabel)" : secLabel

        if isNegative {
            return String(
                format: NSLocalizedString("countdown.past", bundle: .module, comment: ""),
                detail
            )
        } else {
            return String(
                format: NSLocalizedString("countdown.future", bundle: .module, comment: ""),
                detail
            )
        }
    }

    /// Returns `true` if the race has already started at the given instant.
    public func isStarted(at now: Date) -> Bool {
        advertisedStart.timeIntervalSince(now) < 0
    }
}
