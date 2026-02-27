import SwiftUI

/// Full-screen error state with a native SwiftUI animation, message, and retry button.
public struct ErrorView: View {
    private let title: String
    private let message: String
    private let retryButtonText: String
    private let retryLabel: String
    private let retryHint: String
    private let screenLabel: String
    private let onRetry: () -> Void

    public init(
        title: String,
        message: String,
        retryButtonText: String,
        retryLabel: String,
        retryHint: String,
        screenLabel: String,
        onRetry: @escaping () -> Void
    ) {
        self.title = title
        self.message = message
        self.retryButtonText = retryButtonText
        self.retryLabel = retryLabel
        self.retryHint = retryHint
        self.screenLabel = screenLabel
        self.onRetry = onRetry
    }

    public var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.95, green: 0.24, blue: 0.22))
                    .frame(width: 132, height: 132)

                Image(systemName: "exclamationmark")
                    .font(.system(size: 56, weight: .bold))
                    .foregroundStyle(.white)
                    .offset(y: -2)
            }
            .frame(width: 180, height: 180)
            .accessibilityHidden(true)

            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)

                Text(message)
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
        message: "We couldn't load races right now. Please try again.",
        retryButtonText: "Try Again",
        retryLabel: "Try again",
        retryHint: "Retry loading races",
        screenLabel: "Unable to load races. Tap 'Try Again' to retry.",
        onRetry: {}
    )
}
#endif
