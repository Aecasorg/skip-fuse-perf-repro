import SkipFuse
import SwiftUI

/// Repro for: GeometryReader/onGloballyPositioned float-Rect writes with no epsilon
/// → idle recomposition loop (skip-ui).
///
/// Four variants of the GeometryReader-wrapping-content pattern, each with its own
/// body-evaluation counters logged once per second. Nothing mutates state and there is
/// no interaction — any counter still climbing after layout settles is an idle loop.
///
/// V1 is the plain fillSize shape (control — settles). V2–V4 add the ingredient the
/// production case had: the reader's measured bounds depend on its own content
/// (scrollable parent / refreshable offset machinery / proxy-derived text width).
enum GeoVariant: String, CaseIterable, Hashable {
    case v1FillSize
    case v2ScrollView
    case v3Refreshable
    case v4TextFeedback

    var title: String {
        switch self {
        case .v1FillSize: return "V1: plain (control)"
        case .v2ScrollView: return "V2: inside ScrollView"
        case .v3Refreshable: return "V3: refreshable ScrollView"
        case .v4TextFeedback: return "V4: proxy text feedback"
        }
    }
}

struct GeometryLoopScene: View {
    var body: some View {
        List {
            ForEach(GeoVariant.allCases, id: \.self) { v in
                NavigationLink(value: v) {
                    Text(v.title)
                }
            }
        }
        .navigationTitle("GeometryReader variants")
        .navigationDestination(for: GeoVariant.self) { v in
            GeoVariantScene(variant: v)
        }
    }
}

struct GeoVariantScene: View {
    let variant: GeoVariant

    var body: some View {
        let _ = countEval("Geo_\(variant.rawValue)_container")
        Group {
            switch variant {
            case .v1FillSize:
                GeometryReader { proxy in
                    let _ = countEval("Geo_\(variant.rawValue)_content")
                    centered(proxy: proxy)
                }
            case .v2ScrollView:
                ScrollView {
                    GeometryReader { proxy in
                        let _ = countEval("Geo_\(variant.rawValue)_content")
                        centered(proxy: proxy)
                    }
                    .frame(minHeight: 520)
                }
            case .v3Refreshable:
                ScrollView {
                    GeometryReader { proxy in
                        let _ = countEval("Geo_\(variant.rawValue)_content")
                        centered(proxy: proxy)
                    }
                    .frame(minHeight: 520)
                }
                .refreshable {}
            case .v4TextFeedback:
                VStack {
                    Text("header")
                    GeometryReader { proxy in
                        let _ = countEval("Geo_\(variant.rawValue)_content")
                        // The displayed string changes with any sub-pixel bounds change,
                        // which changes the text's measured width
                        let f = proxy.frame(in: .global)
                        VStack {
                            Text("global=\(f.minX),\(f.minY),\(f.width),\(f.height)")
                                .font(.caption)
                            centered(proxy: proxy)
                        }
                    }
                }
            }
        }
        .task {
            while Task.isCancelled == false {
                do { try await Task.sleep(nanoseconds: 1_000_000_000) } catch { break }
                logger.info("idle evals: \(evalReport())")
            }
        }
        .navigationTitle(variant.title)
    }

    @ViewBuilder
    private func centered(proxy: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            Spacer(minLength: proxy.size.height * 0.35)
            Image(systemName: "tray")
                .font(.largeTitle)
            Text("Nothing here yet")
                .font(.headline)
                .padding(.top, 8)
            Text("h=\(proxy.size.height) w=\(proxy.size.width)")
                .font(.caption)
                .padding(.top, 4)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
