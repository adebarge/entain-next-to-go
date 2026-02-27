import L10n_swift
import SwiftUI
import Lottie

/// Full-screen loading indicator using a Lottie animation.
public struct LoadingView: View {
    public init() {}

    public var body: some View {
        VStack(spacing: 20) {
            LottieView(animation: .named("racing_loading", bundle: .module))
                .playing(loopMode: .loop)
                .frame(width: 200, height: 200)
                .accessibilityHidden(true)

            Text("loading.message".l10n(.ui))
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityLabel("loading.accessibility".l10n(.ui))
    }
}

#if DEBUG
#Preview {
    LoadingView()
}
#endif
