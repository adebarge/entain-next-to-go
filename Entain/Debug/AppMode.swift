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

    static func makeConfiguration() -> RaceListConfiguration {
        let expiry = UserDefaults.standard.double(forKey: "vm_expiry_interval")
        let fetch = UserDefaults.standard.double(forKey: "vm_min_fetch_interval")
        let visible = UserDefaults.standard.integer(forKey: "vm_visible_count")
        return RaceListConfiguration(
            expiryInterval: expiry > 0 ? expiry : 60,
            visibleCount: visible > 0 ? visible : 5,
            minimumFetchInterval: fetch > 0 ? fetch : 20
        )
    }
}
#endif
