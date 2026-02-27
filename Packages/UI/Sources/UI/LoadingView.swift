import SwiftUI

/// Full-screen loading indicator using a native SwiftUI animation.
public struct LoadingView: View {
    private let message: String
    private let accessibilityText: String
    @State private var isPulsing = false
    @State private var isSpinning = false

    public init(message: String, accessibilityText: String) {
        self.message = message
        self.accessibilityText = accessibilityText
    }

    public var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.16, green: 0.21, blue: 0.29).opacity(0.16))
                    .frame(width: 148, height: 148)
                    .scaleEffect(isPulsing ? 1.0 : 0.92)
                    .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: isPulsing)

                Image(systemName: "flag.checkered")
                    .font(.system(size: 64, weight: .semibold))
                    .foregroundStyle(.primary)
                    .scaleEffect(isPulsing ? 1.0 : 0.9)
                    .rotationEffect(.degrees(isSpinning ? 360 : 0))
                    .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: isPulsing)
                    .animation(.linear(duration: 1.6).repeatForever(autoreverses: false), value: isSpinning)
            }
                .frame(width: 200, height: 200)
                .accessibilityHidden(true)

            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityLabel(accessibilityText)
        .onAppear {
            isPulsing = true
            isSpinning = true
        }
    }
}

#if DEBUG
#Preview {
    LoadingView(message: "Loading races...", accessibilityText: "Loading races, please wait")
}
#endif
