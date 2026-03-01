import SwiftUI

/// Full-screen error state with a native SwiftUI animation, message, and retry button.
public struct ErrorView: View {
    private let title: String
    private let message: String
    private let retryButtonText: String
    private let onRetry: () -> Void

    public init(
        title: String,
        message: String,
        retryButtonText: String,
        onRetry: @escaping () -> Void
    ) {
        self.title = title
        self.message = message
        self.retryButtonText = retryButtonText
        self.onRetry = onRetry
    }

    public var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: "exclamationmark")
                .foregroundStyle(Color.accentColor)
        } description: {
            Text(message)
                .foregroundStyle(Color.accentColor)
        } actions: {
            Button(action: onRetry) {
                Label(retryButtonText, systemImage: "arrow.clockwise")
                    .font(.body.weight(.semibold))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#if DEBUG
#Preview {
    ErrorView(
        title: "Something went wrong",
        message: "We couldn't load races right now. Please try again.",
        retryButtonText: "Try Again",
        onRetry: {}
    )
}
#endif
