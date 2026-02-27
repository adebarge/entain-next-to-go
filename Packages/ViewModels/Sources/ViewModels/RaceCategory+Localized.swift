import Foundation
import Model

public extension RaceCategory {

    /// The localised display name for this category (e.g. "Horse").
    var localizedName: String {
        switch self {
        case .horse:
            return NSLocalizedString("category.horse", bundle: .module, comment: "")
        case .harness:
            return NSLocalizedString("category.harness", bundle: .module, comment: "")
        case .greyhound:
            return NSLocalizedString("category.greyhound", bundle: .module, comment: "")
        }
    }

    /// Accessibility label for the filter chip (e.g. "Horse races").
    func chipAccessibilityLabel() -> String {
        String(
            format: NSLocalizedString("filter.chip.label", bundle: .module, comment: ""),
            localizedName
        )
    }

    /// Accessibility hint for the filter chip, depending on current selection state.
    func chipAccessibilityHint(isSelected: Bool) -> String {
        if isSelected {
            return NSLocalizedString("filter.chip.hint.remove", bundle: .module, comment: "")
        } else {
            return String(
                format: NSLocalizedString("filter.chip.hint.add", bundle: .module, comment: ""),
                localizedName
            )
        }
    }
}
