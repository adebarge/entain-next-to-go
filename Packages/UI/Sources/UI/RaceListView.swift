import L10n_swift
import SwiftUI
import Model
import ViewModels

/// The root view of the app — shows the filter bar and list of upcoming races.
public struct RaceListView: View {
    @State private var viewModel: RaceListViewModel

    public init(viewModel: RaceListViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.visibleRaces.isEmpty {
                    LoadingView()
                } else if let error = viewModel.error, viewModel.visibleRaces.isEmpty {
                    ErrorView(error: error, onRetry: { viewModel.retry() })
                } else {
                    raceList
                }
            }
            .navigationTitle("race.list.title".l10n(.ui))
            #if os(iOS)
            .toolbarTitleDisplayMode(.large)
            #endif
            .safeAreaInset(edge: .top, spacing: 0) {
                FilterBarView(
                    selectedCategories: Binding(
                        get: { viewModel.selectedCategories },
                        set: { _ in } // Changes go via toggleCategory only
                    ),
                    onToggle: { viewModel.toggleCategory($0) }
                )
                .background(.bar)
            }
        }
        .task {
            viewModel.start()
        }
        .onDisappear {
            viewModel.stop()
        }
    }

    private var raceList: some View {
        List {
            ForEach(viewModel.visibleRaces) { race in
                RaceRowView(race: race)
            }
        }
        .listStyle(.plain)
        .overlay {
            if viewModel.visibleRaces.isEmpty && !viewModel.isLoading {
                ContentUnavailableView(
                    "race.list.empty.title".l10n(.ui),
                    systemImage: "flag.checkered",
                    description: Text("race.list.empty.description".l10n(.ui))
                )
            }
        }
        .refreshable {
            _ = await viewModel.fetchRaces()
        }
        .accessibilityLabel("race.list.accessibility".l10n(.ui))
    }
}

#if DEBUG
private final class PreviewRaceService: RaceService, @unchecked Sendable {
    func fetchNextRaces(count: Int) async throws -> [Race] {
        [
            Race(id: "1", meetingName: "Randwick", raceNumber: 3,
                 advertisedStart: Date().addingTimeInterval(83), category: .horse),
            Race(id: "2", meetingName: "The Meadows", raceNumber: 7,
                 advertisedStart: Date().addingTimeInterval(200), category: .greyhound),
            Race(id: "3", meetingName: "Menangle", raceNumber: 2,
                 advertisedStart: Date().addingTimeInterval(350), category: .harness)
        ]
    }
}

#Preview {
    RaceListView(viewModel: RaceListViewModel(service: PreviewRaceService()))
}
#endif
