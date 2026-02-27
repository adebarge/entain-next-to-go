import Foundation

/// A betting race category supported by the Neds / Entain API.
public enum RaceCategory: String, CaseIterable, Identifiable, Sendable {
    case horse
    case harness
    case greyhound

    public var id: String { rawValue }

    /// The UUID used by the Neds API to identify this category.
    public var categoryId: String {
        switch self {
        case .horse:      return "4a2788f8-e825-4d36-9894-efd4baf1cfae"
        case .harness:    return "161d9be2-e909-4326-8c2c-35ed71fb460b"
        case .greyhound:  return "9daef0d7-bf3c-4f50-921d-8e818c60fe61"
        }
    }

    /// An SF Symbol name appropriate for this category.
    public var sfSymbol: String {
        switch self {
        case .horse:      return "figure.equestrian.sports"
        case .harness:    return "cart"
        case .greyhound:  return "hare"
        }
    }

    /// Initialise from a raw category ID string from the API.
    public init?(categoryId: String) {
        guard let match = RaceCategory.allCases.first(where: { $0.categoryId == categoryId }) else {
            return nil
        }
        self = match
    }
}
