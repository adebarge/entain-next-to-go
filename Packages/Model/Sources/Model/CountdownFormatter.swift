import Foundation

/// Formats a time interval (seconds) into a compact countdown string.
///
/// Examples:
/// - `83` → `"1:23"`
/// - `-45` → `"-0:45"`
/// - `0` → `"0:00"`
public enum CountdownFormatter {
    public static func string(from interval: TimeInterval) -> String {
        let isNegative = interval < 0
        let absolute = abs(interval)
        let totalSeconds = Int(absolute)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        let formatted = String(format: "%d:%02d", minutes, seconds)
        return isNegative ? "-\(formatted)" : formatted
    }
}
