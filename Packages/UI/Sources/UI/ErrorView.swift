import SwiftUI
import Lottie

/// Full-screen error state with a Lottie animation, message, and retry button.
public struct ErrorView: View {
    private let title: String
    private let errorDescription: String
    private let retryButtonText: String
    private let retryLabel: String
    private let retryHint: String
    private let screenLabel: String
    private let onRetry: () -> Void

    public init(
        title: String,
        errorDescription: String,
        retryButtonText: String,
        retryLabel: String,
        retryHint: String,
        screenLabel: String,
        onRetry: @escaping () -> Void
    ) {
        self.title = title
        self.errorDescription = errorDescription
        self.retryButtonText = retryButtonText
        self.retryLabel = retryLabel
        self.retryHint = retryHint
        self.screenLabel = screenLabel
        self.onRetry = onRetry
    }

    public var body: some View {
        VStack(spacing: 24) {
            LottieView(animation: .named("error_animation", bundle: .module))
                .playing(loopMode: .loop)
                .frame(width: 180, height: 180)
                .accessibilityHidden(true)

            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)

                Text(errorDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Button(action: onRetry) {
                Label(retryButtonText, systemImage: "arrow.clockwise")
                    .font(.body.weight(.semibold))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityLabel(retryLabel)
            .accessibilityHint(retryHint)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityLabel(screenLabel)
    }
}

#if DEBUG
#Preview {
    ErrorView(
        title: "Something went wrong",
        errorDescription: URLError(.notConnectedToInternet).localizedDescription,
        retryButtonText: "Try Again",
        retryLabel: "Try again",
        retryHint: "Retry loading races",
        screenLabel: "Error: not connected. Tap 'Try Again' to retry.",
        onRetry: {}
    )
}
#endif
