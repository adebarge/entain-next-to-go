import SwiftUI
import Lottie

/// Full-screen error state with a Lottie animation, message, and retry button.
public struct ErrorView: View {
    private let error: Error
    private let onRetry: () -> Void

    public init(error: Error, onRetry: @escaping () -> Void) {
        self.error = error
        self.onRetry = onRetry
    }

    public var body: some View {
        VStack(spacing: 24) {
            LottieView(animation: .named("error_animation", bundle: .module))
                .playing(loopMode: .loop)
                .frame(width: 180, height: 180)
                .accessibilityHidden(true)

            VStack(spacing: 8) {
                Text("Something went wrong")
                    .font(.headline)

                Text(error.localizedDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Button(action: onRetry) {
                Label("Try Again", systemImage: "arrow.clockwise")
                    .font(.body.weight(.semibold))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityLabel("Try again")
            .accessibilityHint("Retry loading races")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityLabel("Error: \(error.localizedDescription). Tap 'Try Again' to retry.")
    }
}

#if DEBUG
#Preview {
    ErrorView(
        error: URLError(.notConnectedToInternet),
        onRetry: {}
    )
}
#endif
