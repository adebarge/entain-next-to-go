import SwiftUI
import Model

/// A horizontal scroll bar of category toggle chips.
public struct FilterBarView: View {
    @Binding private var selectedCategories: Set<RaceCategory>
    private let onToggle: (RaceCategory) -> Void

    public init(
        selectedCategories: Binding<Set<RaceCategory>>,
        onToggle: @escaping (RaceCategory) -> Void
    ) {
        _selectedCategories = selectedCategories
        self.onToggle = onToggle
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(RaceCategory.allCases) { category in
                    CategoryChip(
                        category: category,
                        isSelected: selectedCategories.contains(category),
                        onToggle: { onToggle(category) }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .accessibilityLabel("Category filter")
    }
}

// MARK: - Category chip

private struct CategoryChip: View {
    let category: RaceCategory
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            Label(category.displayName, systemImage: category.sfSymbol)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    isSelected ? Color.accentColor : Color.secondary.opacity(0.15),
                    in: Capsule()
                )
                .foregroundStyle(isSelected ? .white : .primary)
                .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .accessibilityLabel("\(category.displayName) races")
        .accessibilityHint(isSelected ? "Tap to remove filter" : "Tap to filter by \(category.displayName) races")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

#if DEBUG
#Preview {
    @Previewable @State var selected: Set<RaceCategory> = [.horse]
    FilterBarView(selectedCategories: $selected, onToggle: { _ in })
}
#endif
