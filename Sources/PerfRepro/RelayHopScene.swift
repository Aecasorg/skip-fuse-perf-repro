import Foundation
import SkipFuse
import SwiftUI

/// Repro for: `.onChange` runs in Compose `SideEffect` (post-apply) → +1 frame of
/// latency per state relay hop (skip-ui).
///
/// Tapping the button writes `a`; `.onChange(of: a)` writes `b`; `.onChange(of: b)`
/// writes `c`. Each step logs a millisecond timestamp.
///
/// Expected (iOS): all four stamps share (almost) the same millisecond — the writes
/// settle within one transaction.
/// Actual (Android): each hop lands ~one frame (~16ms at 60Hz) after the previous,
/// because the onChange action only runs after the triggering recomposition applies.
struct RelayHopScene: View {
    @State var a = 0
    @State var b = 0
    @State var c = 0
    @State var stamps: [String] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("a=\(a)  b=\(b)  c=\(c)")
                .font(.headline)
            Button("Bump a") {
                stamps.removeAll()
                stamp("write a")
                a += 1
            }
            ForEach(stamps, id: \.self) { line in
                Text(line)
                    .font(.caption.monospaced())
            }
            Spacer()
        }
        .padding()
        .onChange(of: a) {
            stamp("onChange(a) → write b")
            b += 1
        }
        .onChange(of: b) {
            stamp("onChange(b) → write c")
            c += 1
        }
        .onChange(of: c) {
            stamp("onChange(c) settled")
        }
        .navigationTitle("onChange relay hops")
    }

    private func stamp(_ label: String) {
        let ms = Date().timeIntervalSince1970 * 1000
        let line = "\(String(format: "%.1f", ms.truncatingRemainder(dividingBy: 100_000))) ms — \(label)"
        stamps.append(line)
        logger.info("\(line)")
    }
}
