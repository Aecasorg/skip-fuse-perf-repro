import Observation
import SkipFuse
import SwiftUI

/// Repro for the presentation open path (skip-ui#487):
///
/// (c) The sheet applies `.presentationDetents([.medium])` + `.presentationDragIndicator(.hidden)`.
///     Its content logs the observed GeometryReader height on every body evaluation.
///     Stock skip-ui: the first evaluation(s) see full-height geometry, then a jump to the
///     medium detent once the collected preference settles a composition later.
///     Patched: medium geometry from the very first evaluation (preferences are harvested
///     from the content's modifier chain and seeded before the first composition).
///
/// (a) A 1s `@Observable` ticker churns the presenter while the sheet is open. The
///     `SheetContent`/`SheetGeometry` counters in the per-second log line measure how
///     presenter recompositions amplify into the open sheet's content.
@Observable final class PresenterTickModel {
    var tick = 0
}

struct SheetScene: View {
    @State var model = PresenterTickModel()
    @State var showSheet = false

    var body: some View {
        let _ = countEval("SheetPresenter")
        VStack(spacing: 16) {
            Text("Presenter tick: \(model.tick)")
                .font(.headline)
            Button("Present sheet") {
                showSheet = true
            }
            Spacer()
        }
        .padding()
        .sheet(isPresented: $showSheet) {
            SheetBody()
                .presentationDetents([.medium])
                .presentationDragIndicator(.hidden)
        }
        .task {
            while Task.isCancelled == false {
                do { try await Task.sleep(nanoseconds: 1_000_000_000) } catch { break }
                model.tick += 1
                logger.info("sheet tick=\(self.model.tick) evals: \(evalReport())")
            }
        }
        .navigationTitle("Sheet: churn + detent")
    }
}

struct SheetBody: View {
    var body: some View {
        let _ = countEval("SheetContent")
        GeometryReader { proxy in
            let _ = countEval("SheetGeometry")
            let _ = logSheetGeometry(proxy.size.height)
            VStack {
                Text("sheet h=\(proxy.size.height)")
                    .font(.caption)
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
    }
}

/// Logs the height seen by each sheet-content evaluation. The (c) fingerprint is whether
/// the FIRST logged height already reflects the medium detent or a full-height value that
/// jumps on a later evaluation.
private func logSheetGeometry(_ height: CGFloat) -> Bool {
    logger.info("sheet geometry: h=\(height)")
    return true
}
