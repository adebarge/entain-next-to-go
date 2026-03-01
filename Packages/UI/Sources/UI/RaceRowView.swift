import SwiftUI
import ViewModels

/// A single row in the race list.
public struct RaceRowView: View {
    private let viewModel: RaceRowViewModel

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    public init(viewModel: RaceRowViewModel) {
        self.viewModel = viewModel
    }

    private var icon: some View {
        Image(systemName: viewModel.sfSymbol)
            .foregroundStyle(Color.accentColor)
            .frame(width: 36, height: 36)
            .accessibilityHidden(true)
    }

    private var nameStack: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(viewModel.meetingName)
                .font(.headline)

            Text(viewModel.raceNumberText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    public var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 12) {
                        icon

                        nameStack
                    }

                    CountdownLabel(viewModel: viewModel)
                }

            } else {
                HStack(alignment: .center, spacing: 12) {
                    icon

                    nameStack

                    Spacer()

                    CountdownLabel(viewModel: viewModel)
                }
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(viewModel.accessibilityLabel)
        .accessibilityHint(viewModel.accessibilityHint)
        .accessibilityRemoveTraits(.isButton)
        .accessibilityAddTraits(.updatesFrequently)
    }
}

#if DEBUG
import Model

#Preview {
    List {
        RaceRowView(viewModel: RaceRowViewModel(race: Race(
            id: "preview",
            meetingName: "Randwick",
            raceNumber: 3,
            advertisedStart: Date().addingTimeInterval(83),
            category: .horse
        )))
        RaceRowView(viewModel: RaceRowViewModel(race: Race(
            id: "preview2",
            meetingName: "The Meadows",
            raceNumber: 7,
            advertisedStart: Date().addingTimeInterval(-30),
            category: .greyhound
        )))
    }
}
#endif
