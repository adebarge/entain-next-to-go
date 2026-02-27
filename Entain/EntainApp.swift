import SwiftUI
import Services
import ViewModels
import UI

@main
struct EntainApp: App {
    private let viewModel: RaceListViewModel

    init() {
        #if DEBUG
        let service = AppMode.current.makeService()
        let config = AppMode.makeConfiguration()
        #else
        let service: any RaceService = DefaultRaceService(network: NetworkService())
        let config = RaceListConfiguration.default
        #endif
        viewModel = RaceListViewModel(service: service, configuration: config)
    }

    var body: some Scene {
        WindowGroup {
            RaceListView(viewModel: viewModel)
        }
    }
}
