import Observation
import SkipFuse
import SwiftUI

/// Repro for:
/// - bridged peers never skippable (skip-bridge: fresh Swift_peer + pointer equals + no @Stable)
/// - container-scope invalidation + lazy items re-evaluated every pass (skip-ui)
///
/// One `@Observable` counter ticks every second. The ONLY view reading it is the header
/// `Text`. The 20 cards below are fully static: constant content, no observable reads.
///
/// Expected (iOS): after first render, `StaticCardView` count stays at 20 forever.
/// Actual (Android): `StaticCardView` grows by +20 every tick — every card re-evaluates
/// on each unrelated state change, in both the eager and the lazy/stable-id variants.
/// Watch the log line printed on every tick.
@Observable final class TickModel {
    var tick = 0
}

struct CardItem: Identifiable, Hashable {
    let id: Int
}

struct UnrelatedStateScene: View {
    @State var model = TickModel()
    @State var useLazy = false
    @State var useAndroidEquatable = false
    let items = (0..<20).map { CardItem(id: $0) }

    var body: some View {
        let _ = countEval("UnrelatedStateScene")
        VStack(spacing: 12) {
            // The only reader of `model.tick` in the whole scene.
            Text("Tick: \(model.tick)")
                .font(.headline)
            Toggle("LazyVStack + stable ids", isOn: $useLazy)
                .padding(.horizontal)
            Toggle("androidEquatable on cards", isOn: $useAndroidEquatable)
                .padding(.horizontal)
            if useLazy {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(items) { item in
                            StaticCardView(index: item.id)
                                .androidEquatableIf(useAndroidEquatable, key: item.id)
                        }
                    }
                }
            } else {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(items) { item in
                            StaticCardView(index: item.id)
                                .androidEquatableIf(useAndroidEquatable, key: item.id)
                        }
                    }
                }
            }
        }
        .task {
            while Task.isCancelled == false {
                do { try await Task.sleep(nanoseconds: 1_000_000_000) } catch { break }
                model.tick += 1
                logger.info("tick=\(self.model.tick) evals: \(evalReport())")
            }
        }
        .navigationTitle("Unrelated state tick")
    }
}

/// A card whose content never changes and reads no observable state.
struct StaticCardView: View {
    let index: Int

    var body: some View {
        let _ = countEval("StaticCardView")
        HStack {
            Image(systemName: "square.fill")
            Text("Static card #\(index)")
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.15))
        .padding(.horizontal)
    }
}

extension View {
    /// skip-fuse-ui's `androidEquatable(recomposeOverride:)` (1.18.3+) when `enabled`, on
    /// Android only. iOS SwiftUI has no such modifier, and skips unchanged cards by itself.
    @ViewBuilder
    func androidEquatableIf<Key: Equatable>(_ enabled: Bool, key: Key) -> some View {
        #if os(Android)
        if enabled {
            self.androidEquatable(recomposeOverride: key)
        } else {
            self
        }
        #else
        self
        #endif
    }
}
