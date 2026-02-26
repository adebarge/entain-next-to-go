import SwiftUI
import Model

/// A single row in the race list.
public struct RaceRowView: View {
    private let race: Race

    public init(race: Race) {
        self.race = race
    }

    public var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Category icon
            Image(systemName: race.category.sfSymbol)
                .font(.title2)
                .foregroundStyle(Color.accentColor)
                .frame(width: 36)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(race.meetingName)
                    .font(.headline)
                    .lineLimit(1)

                Text("Race \(race.raceNumber)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            CountdownLabel(race: race)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
        .accessibilityHint("Race \(race.raceNumber) at \(race.meetingName)")
    }

    private var accessibilityDescription: String {
        "Race \(race.raceNumber), \(race.meetingName), \(race.category.displayName) race"
    }
}

#if DEBUG
#Preview {
    List {
        RaceRowView(race: Race(
            id: "preview",
            meetingName: "Randwick",
            raceNumber: 3,
            advertisedStart: Date().addingTimeInterval(83),
            category: .horse
        ))
        RaceRowView(race: Race(
            id: "preview2",
            meetingName: "The Meadows",
            raceNumber: 7,
            advertisedStart: Date().addingTimeInterval(-30),
            category: .greyhound
        ))
    }
}
#endif
