import SwiftUI

/// Full-screen loading indicator using a native SwiftUI animation.
public struct LoadingView: View {
    private let message: String
    private let accessibilityText: String

    public init(message: String, accessibilityText: String) {
        self.message = message
        self.accessibilityText = accessibilityText
    }

    public var body: some View {
        ProgressView {
            Text(message)
                .bold()
        }
        .progressViewStyle(.circular)
        .foregroundStyle(Color.accentColor)
        .accessibilityLabel(accessibilityText)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#if DEBUG
#Preview {
    LoadingView(message: "Loading races...", accessibilityText: "Loading races, please wait")
}
#endif
