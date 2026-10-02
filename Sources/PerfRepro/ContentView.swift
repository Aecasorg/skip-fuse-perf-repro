import SwiftUI

enum ReproScene: String, CaseIterable, Hashable {
    case unrelatedState
    case geometryLoop
    case relayHops
    case resizableIconSheet

    var title: String {
        switch self {
        case .unrelatedState: return "1. Unrelated state tick"
        case .geometryLoop: return "2. GeometryReader idle loop"
        case .relayHops: return "3. onChange relay hops"
        case .resizableIconSheet: return "4. Resizable icons"
        }
    }

    var subtitle: String {
        switch self {
        case .unrelatedState: return "Static cards re-evaluate on every unrelated @Observable write"
        case .geometryLoop: return "Idle recomposition loop from unguarded float Rect writes"
        case .relayHops: return "+1 frame per onChange → state → onChange hop"
        case .resizableIconSheet: return "Icons sized by aspect ratio fill their row on Android since skip-ui 1.60.0"
        }
    }
}

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(ReproScene.allCases, id: \.self) { scene in
                        NavigationLink(value: scene) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(scene.title)
                                Text(scene.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                } footer: {
                    Text("Run on iOS and Android side by side. Body-evaluation counters are logged once per second (Xcode console / adb logcat, tag PerfRepro).")
                }
            }
            .navigationTitle("Skip perf repros")
            .navigationDestination(for: ReproScene.self) { scene in
                switch scene {
                case .unrelatedState: UnrelatedStateScene()
                case .geometryLoop: GeometryLoopScene()
                case .relayHops: RelayHopScene()
                case .resizableIconSheet: ResizableIconSheetScene()
                }
            }
        }
    }
}
