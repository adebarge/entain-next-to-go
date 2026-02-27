import SwiftUI
import Model
import ViewModels

/// The root view of the app — shows the filter bar and list of upcoming races.
public struct RaceListView: View {
    private let viewModel: RaceListViewModel

    public init(viewModel: RaceListViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.visibleRaces.isEmpty {
                    LoadingView(
                        message: RaceListViewModel.loadingMessage,
                        accessibilityText: RaceListViewModel.loadingAccessibilityLabel
                    )
                } else if viewModel.error != nil, viewModel.visibleRaces.isEmpty {
                    ErrorView(
                        title: RaceListViewModel.errorTitle,
                        message: RaceListViewModel.errorMessage,
                        retryButtonText: RaceListViewModel.errorRetryButtonText,
                        retryLabel: RaceListViewModel.errorRetryLabel,
                        retryHint: RaceListViewModel.errorRetryHint,
                        screenLabel: RaceListViewModel.errorScreenLabel,
                        onRetry: { viewModel.retry() }
                    )
                } else {
                    raceList
                }
            }
            .navigationTitle(RaceListViewModel.listTitle)
            #if os(iOS)
            .toolbarTitleDisplayMode(.inline)
            #endif
            .safeAreaInset(edge: .top, spacing: 0) {
                FilterBarView(
                    accessibilityText: RaceListViewModel.filterBarAccessibilityLabel,
                    selectedCategories: viewModel.selectedCategories,
                    isDisabled: viewModel.isFilterBarDisabled,
                    onToggle: { viewModel.toggleCategory($0) }
                )
                .background(.bar)
            }
        }
        .onAppear {
            viewModel.start()
        }
        .onDisappear {
            viewModel.stop()
        }
    }

    private var raceList: some View {
        List {
            ForEach(viewModel.visibleRaces) { rowVM in
                RaceRowView(row: rowVM)
            }
        }
        .listStyle(.plain)
        .overlay {
            if viewModel.visibleRaces.isEmpty && !viewModel.isLoading {
                ContentUnavailableView(
                    RaceListViewModel.emptyTitle,
                    systemImage: "flag.checkered",
                    description: Text(RaceListViewModel.emptyDescription)
                )
            }
        }
        .accessibilityLabel(RaceListViewModel.listAccessibilityLabel)
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
