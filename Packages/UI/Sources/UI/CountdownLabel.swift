import SwiftUI
import Model

/// Displays a live countdown to a race's advertised start time.
///
/// Uses `TimelineView(.everySecond)` so SwiftUI automatically re-renders the
/// countdown string every second without any ViewModel timer.
public struct CountdownLabel: View {
    private let race: Race

    public init(race: Race) {
        self.race = race
    }

    public var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let interval = race.advertisedStart.timeIntervalSince(context.date)
            let text = CountdownFormatter.string(from: interval)
            let isNegative = interval < 0

            Text(text)
                .font(.body.monospacedDigit())
                .foregroundStyle(isNegative ? .red : .primary)
                .accessibilityLabel(accessibilityText(interval: interval))
        }
    }

    private func accessibilityText(interval: TimeInterval) -> String {
        let isNegative = interval < 0
        let abs = Swift.abs(interval)
        let minutes = Int(abs) / 60
        let seconds = Int(abs) % 60

        let minLabel = "\(minutes) minute\(minutes == 1 ? "" : "s")"
        let secLabel = "\(seconds) second\(seconds == 1 ? "" : "s")"

        if isNegative {
            let detail = minutes > 0 ? "\(minLabel) \(secLabel)" : secLabel
            return "Started \(detail) ago"
        } else {
            let detail = minutes > 0 ? "\(minLabel) \(secLabel)" : secLabel
            return "Starts in \(detail)"
        }
    }
}

#if DEBUG
#Preview {
    CountdownLabel(race: Race(
        id: "preview",
        meetingName: "Randwick",
        raceNumber: 3,
        advertisedStart: Date().addingTimeInterval(83),
        category: .horse
    ))
    .padding()
}
#endif
