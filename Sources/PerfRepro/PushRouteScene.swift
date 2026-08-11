import SkipFuse
import SwiftUI

/// Spike: does presenting detail as a NAVIGATION PUSH avoid the three Dialog-window
/// symptoms that a sheet has on Android (CX-4954)?
///
/// A sheet gets its own Android Dialog window, which brings: (a) taps swallowed for
/// ~0.5s after dismissal, (b) a guaranteed blank first frame, (c) the title bar
/// arriving after the content. A push stays in the host window, so in principle none
/// of those apply. This scene is deliberately structured like `DismissRaceScene` so
/// the two routes can be compared with the same content and the same driving script.
///
/// Log markers: `PUSH TAP <id>`, `PUSH DETAIL showing <id>`, `PUSH BACK`.
struct PushRouteScene: View {
    let rows = [RaceRow(id: 1), RaceRow(id: 2)]

    var body: some View {
        VStack(spacing: 8) {
            Text("Detail opens as a navigation push (no Dialog window)")
                .font(.caption)
                .padding(.horizontal)
            ForEach(rows) { row in
                NavigationLink(value: PushDestination(id: row.id)) {
                    Text(row.title)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                }
                .simultaneousGesture(TapGesture().onEnded {
                    logger.info("PUSH TAP \(row.id)")
                })
            }
            Spacer()
        }
        .padding(.horizontal)
        .navigationTitle("Push route")
        .navigationDestination(for: PushDestination.self) { dest in
            PushDetailView(id: dest.id)
        }
    }
}

struct PushDestination: Identifiable, Hashable {
    let id: Int
}

struct PushDetailView: View {
    let id: Int

    var body: some View {
        let _ = logger.info("PUSH DETAIL showing \(id)")
        VStack {
            Text("Detail for Row \(id)")
                .font(.headline)
                .padding()
            Text("Same content shape as the sheet route")
                .font(.caption)
            Spacer()
        }
        .navigationTitle("Order \(id)")
    }
}
