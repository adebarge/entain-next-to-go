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
                        message: viewModel.loadingMessage,
                        accessibilityText: viewModel.loadingAccessibilityLabel
                    )
                } else if viewModel.error != nil, viewModel.visibleRaces.isEmpty {
                    ErrorView(
                        title: viewModel.errorTitle,
                        message: viewModel.errorMessage,
                        retryButtonText: viewModel.errorRetryButtonText,
                        retryLabel: viewModel.errorRetryLabel,
                        retryHint: viewModel.errorRetryHint,
                        screenLabel: viewModel.errorScreenLabel,
                        onRetry: { viewModel.retry() }
                    )
                } else {
                    raceList
                }
            }
            .navigationTitle(viewModel.listTitle)
            #if os(iOS)
            .toolbarTitleDisplayMode(.inline)
            #endif
            .safeAreaInset(edge: .top, spacing: 0) {
                FilterBarView(
                    accessibilityText: viewModel.filterBarAccessibilityLabel,
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
            ForEach(viewModel.visibleRaces) { rowViewModel in
                RaceRowView(viewModel: rowViewModel)
            }
        }
        .listStyle(.plain)
        .overlay {
            if viewModel.visibleRaces.isEmpty && !viewModel.isLoading {
                ContentUnavailableView(
                    viewModel.emptyTitle,
                    systemImage: "flag.checkered",
                    description: Text(viewModel.emptyDescription)
                )
            }
        }
        .accessibilityLabel(viewModel.listAccessibilityLabel)
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
