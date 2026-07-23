import SkipFuse
import SwiftUI

/// Repro for: GeometryReader/onGloballyPositioned float-Rect writes with no epsilon
/// → idle recomposition loop (skip-ui).
///
/// A `GeometryReader` whose content lays out against the reported size — the classic
/// "empty state centered against the available height" pattern. Nothing on this screen
/// mutates state and there is no user interaction.
///
/// Expected (iOS): counters stop after the initial layout settles.
/// Actual (Android): `GeometryContent` keeps climbing while the screen sits idle —
/// sub-pixel Rect jitter feeds the remembered bounds state, which re-runs content,
/// which re-measures. Watch the once-per-second log line.
struct GeometryLoopScene: View {
    var body: some View {
        let _ = countEval("GeometryLoopScene")
        GeometryReader { proxy in
            let _ = countEval("GeometryContent")
            VStack(spacing: 0) {
                Spacer(minLength: proxy.size.height * 0.35)
                Image(systemName: "tray")
                    .font(.largeTitle)
                Text("Nothing here yet")
                    .font(.headline)
                    .padding(.top, 8)
                Text("height=\(proxy.size.height), width=\(proxy.size.width)")
                    .font(.caption)
                    .padding(.top, 4)
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .task {
            while Task.isCancelled == false {
                do { try await Task.sleep(nanoseconds: 1_000_000_000) } catch { break }
                logger.info("idle evals: \(evalReport())")
            }
        }
        .navigationTitle("GeometryReader idle loop")
    }
}
