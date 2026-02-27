import SwiftUI
import Lottie

/// Full-screen loading indicator using a Lottie animation.
public struct LoadingView: View {
    private let message: String
    private let accessibilityText: String

    public init(message: String, accessibilityText: String) {
        self.message = message
        self.accessibilityText = accessibilityText
    }

    public var body: some View {
        VStack(spacing: 20) {
            LottieView(animation: .named("racing_loading", bundle: .module))
                .playing(loopMode: .loop)
                .frame(width: 200, height: 200)
                .accessibilityHidden(true)

            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityLabel(accessibilityText)
    }
}

#if DEBUG
#Preview {
    LoadingView(message: "Loading races...", accessibilityText: "Loading races, please wait")
}
#endif
