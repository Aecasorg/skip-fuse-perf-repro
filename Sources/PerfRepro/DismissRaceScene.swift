import SkipFuse
import SwiftUI

/// Models the driver-app "must tap twice" bug (CX-4954).
///
/// Material3 does not report a bottom-sheet dismissal when the gesture/back is
/// released — it calls `onDismissRequest` from `invokeOnCompletion`, AFTER the ~300ms
/// hide tween. An app presenting via a derived `isPresented` binding
/// (`get: { item != nil }`, `set: { if !$0 { item = nil } }`) therefore receives the
/// dismissal LATE: if the user selected another row during the slide, `item` already
/// holds the new selection and the late callback clears it — the tap is swallowed and
/// the user must tap again.
///
/// UNGUARDED reproduces the bug. GUARDED carries the fix: ignore a dismissal that
/// arrives after the selection changed to a different item while presented.
struct DismissRaceScene: View {
    @State var guarded = true

    var body: some View {
        VStack(spacing: 12) {
            Toggle("Guarded (fix applied)", isOn: $guarded)
                .padding(.horizontal)
            Text(guarded ? "GUARDED — tap B during A's dismiss should open B"
                         : "UNGUARDED — tap B during A's dismiss should be swallowed")
                .font(.caption)
                .padding(.horizontal)
            RaceHarness(guarded: guarded)
            Spacer()
        }
        .navigationTitle("Dismiss race")
    }
}

struct RaceRow: Identifiable, Equatable {
    let id: Int
    var title: String { "Row \(id)" }
}

struct RaceHarness: View {
    let guarded: Bool
    @State var item: RaceRow?
    @State var cachedItem: RaceRow?
    @State var selectionChangedWhilePresented = false

    let rows = [RaceRow(id: 1), RaceRow(id: 2)]

    var body: some View {
        VStack(spacing: 8) {
            ForEach(rows) { row in
                Button {
                    logger.info("TAP \(row.id) — item was \(self.item?.id ?? -1)")
                    item = row
                } label: {
                    Text(row.title)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                }
            }
        }
        .padding(.horizontal)
        .sheet(isPresented: Binding(
            get: { item != nil },
            set: { presented in
                if presented == false {
                    if guarded, selectionChangedWhilePresented {
                        logger.info("DISMISS ignored (stale) — item stays \(self.item?.id ?? -1)")
                        selectionChangedWhilePresented = false
                    } else {
                        logger.info("DISMISS clears item (was \(self.item?.id ?? -1))")
                        item = nil
                    }
                }
            }
        )) {
            if let shown = item ?? cachedItem {
                VStack {
                    Text("Sheet for \(shown.title)")
                        .font(.headline)
                        .padding()
                    let _ = logger.info("SHEET showing \(shown.id)")
                    Spacer()
                }
            }
        }
        .onChange(of: item) { newItem in
            if let newItem {
                if let cachedItem, cachedItem != newItem {
                    selectionChangedWhilePresented = true
                    logger.info("SELECTION CHANGED while presented: \(cachedItem.id) -> \(newItem.id)")
                }
                cachedItem = newItem
            } else {
                selectionChangedWhilePresented = false
                cachedItem = nil
            }
        }
    }
}
