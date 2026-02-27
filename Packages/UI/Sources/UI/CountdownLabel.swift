import SwiftUI
import ViewModels

/// Displays a live countdown to a race's advertised start time.
///
/// Uses `TimelineView(.everySecond)` so SwiftUI automatically re-renders the
/// countdown string every second without any ViewModel timer.
public struct CountdownLabel: View {
    private let row: RaceRowViewModel

    public init(row: RaceRowViewModel) {
        self.row = row
    }

    public var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let text = row.countdownText(at: context.date)
            let isStarted = row.isStarted(at: context.date)

            Text(text)
                .font(.body.monospacedDigit())
                .foregroundStyle(isStarted ? .red : .primary)
                .accessibilityLabel(text)
        }
    }
}

#if DEBUG
import Model

#Preview {
    CountdownLabel(row: RaceRowViewModel(race: Race(
        id: "preview",
        meetingName: "Randwick",
        raceNumber: 3,
        advertisedStart: Date().addingTimeInterval(83),
        category: .horse
    )))
    .padding()
}
#endif
