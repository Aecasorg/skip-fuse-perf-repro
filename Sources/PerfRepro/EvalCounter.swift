import Foundation

/// Counts view `body` evaluations per view type.
///
/// SwiftUI bodies run on the main thread on both platforms, so a plain global is
/// sufficient for a diagnostic repro (no synchronization needed).
nonisolated(unsafe) private var evalCounts: [String: Int] = [:]

/// Record one body evaluation for `key`. Call as the first line of a `body`:
/// `let _ = countEval("MyView")`
func countEval(_ key: String) {
    evalCounts[key, default: 0] += 1
}

/// Snapshot of all counters, formatted for logging.
func evalReport() -> String {
    evalCounts
        .sorted { $0.key < $1.key }
        .map { "\($0.key)=\($0.value)" }
        .joined(separator: " ")
}
