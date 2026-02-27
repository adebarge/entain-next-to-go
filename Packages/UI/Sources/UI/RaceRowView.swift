import SwiftUI
import ViewModels

/// A single row in the race list.
public struct RaceRowView: View {
    private let row: RaceRowViewModel

    public init(row: RaceRowViewModel) {
        self.row = row
    }

    public var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Category icon
            Image(systemName: row.sfSymbol)
                .font(.title2)
                .foregroundStyle(Color.accentColor)
                .frame(width: 36)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(row.meetingName)
                    .font(.headline)
                    .lineLimit(1)

                Text(row.raceNumberText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            CountdownLabel(row: row)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(row.accessibilityLabel)
        .accessibilityHint(row.accessibilityHint)
    }
}

#if DEBUG
import Model

#Preview {
    List {
        RaceRowView(row: RaceRowViewModel(race: Race(
            id: "preview",
            meetingName: "Randwick",
            raceNumber: 3,
            advertisedStart: Date().addingTimeInterval(83),
            category: .horse
        )))
        RaceRowView(row: RaceRowViewModel(race: Race(
            id: "preview2",
            meetingName: "The Meadows",
            raceNumber: 7,
            advertisedStart: Date().addingTimeInterval(-30),
            category: .greyhound
        )))
    }
}
#endif
