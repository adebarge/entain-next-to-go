import L10n_swift
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
                Text("error.title".l10n(.ui))
                    .font(.headline)

                Text(error.localizedDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Button(action: onRetry) {
                Label("error.retry.button".l10n(.ui), systemImage: "arrow.clockwise")
                    .font(.body.weight(.semibold))
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityLabel("error.retry.label".l10n(.ui))
            .accessibilityHint("error.retry.hint".l10n(.ui))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityLabel("error.screen.label".l10n(.ui, args: [error.localizedDescription]))
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
