import L10n_swift
import Model

extension RaceCategory {
    var localizedName: String {
        switch self {
        case .horse:     return "category.horse".l10n(.ui)
        case .harness:   return "category.harness".l10n(.ui)
        case .greyhound: return "category.greyhound".l10n(.ui)
        }
    }
}
