import SwiftUI
import ViewModels

/// Displays a live countdown to a race's advertised start time.
///
/// Uses `TimelineView(.everySecond)` so SwiftUI automatically re-renders the
/// countdown string every second without any ViewModel timer.
public struct CountdownLabel: View {
    private let viewModel: RaceRowViewModel

    public init(viewModel: RaceRowViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let text = viewModel.countdownText(at: context.date)
            let isStarted = viewModel.isStarted(at: context.date)

            Text(text)
                .font(.body.monospacedDigit())
                .foregroundStyle(isStarted ? .red : Color.accentColor)
                .accessibilityLabel(text)
        }
    }
}

#if DEBUG
import Model

#Preview {
    CountdownLabel(viewModel: RaceRowViewModel(race: Race(
        id: "preview",
        meetingName: "Randwick",
        raceNumber: 3,
        advertisedStart: Date().addingTimeInterval(83),
        category: .horse
    )))
    .padding()
}
#endif
