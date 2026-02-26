import SwiftUI
import Services
import ViewModels
import UI

@main
struct EntainApp: App {
    private let viewModel = RaceListViewModel(
        service: DefaultRaceService(network: NetworkService())
    )

    var body: some Scene {
        WindowGroup {
            RaceListView(viewModel: viewModel)
        }
    }
}
