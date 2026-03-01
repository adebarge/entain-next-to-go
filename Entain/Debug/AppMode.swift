#if DEBUG
import Foundation
import Model
import Services
import ViewModels

enum AppMode: String {
    case live
    case demo

    static var current: AppMode {
        let raw = UserDefaults.standard.string(forKey: "app_mode") ?? "live"
        return AppMode(rawValue: raw) ?? .live
    }

    func makeService() -> any RaceService {
        switch self {
        case .live: return DefaultRaceService(network: NetworkService())
        case .demo: return DemoRaceService()
        }
    }
}
#endif
