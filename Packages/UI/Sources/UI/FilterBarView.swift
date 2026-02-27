import SwiftUI
import Model
import ViewModels

/// A horizontal scroll bar of category toggle chips.
public struct FilterBarView: View {
    private let accessibilityText: String
    private let selectedCategories: Set<RaceCategory>
    private let onToggle: (RaceCategory) -> Void

    public init(
        accessibilityText: String,
        selectedCategories: Set<RaceCategory>,
        onToggle: @escaping (RaceCategory) -> Void
    ) {
        self.accessibilityText = accessibilityText
        self.selectedCategories = selectedCategories
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
        .accessibilityLabel(accessibilityText)
    }
}

// MARK: - Category chip

private struct CategoryChip: View {
    let category: RaceCategory
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            Label(category.localizedName, systemImage: category.sfSymbol)
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
        .accessibilityLabel(category.chipAccessibilityLabel())
        .accessibilityHint(category.chipAccessibilityHint(isSelected: isSelected))
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

#if DEBUG
#Preview {
    @Previewable @State var selected: Set<RaceCategory> = [.horse]
    FilterBarView(
        accessibilityText: "Category filter",
        selectedCategories: selected,
        onToggle: { _ in }
    )
}
#endif
