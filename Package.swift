// swift-tools-version: 6.1
// This is a Skip (https://skip.dev) package.
import PackageDescription

let package = Package(
    name: "skip-fuse-perf-repro",
    defaultLocalization: "en",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "PerfRepro", type: .dynamic, targets: ["PerfRepro"]),
    ],
    dependencies: [
        // Exact pins: the repro must build against a known-good matched pair.
        // skip-fuse-ui 1.18.0 + skip-ui 1.59.1 (latest as of 2026-07-23) fail to compile
        // together ("missing argument for parameter 'bridgedAxis'"), so we pin the
        // 1.17.2 / 1.57.0 pair the issues were verified against.
        .package(url: "https://source.skip.tools/skip.git", exact: "1.9.4"),
        .package(url: "https://source.skip.tools/skip-fuse-ui.git", exact: "1.17.2"),
        .package(url: "https://source.skip.tools/skip-ui.git", exact: "1.57.0")
    ],
    targets: [
        .target(name: "PerfRepro", dependencies: [
            .product(name: "SkipFuseUI", package: "skip-fuse-ui")
        ], resources: [.process("Resources")], plugins: [.plugin(name: "skipstone", package: "skip")]),
    ]
)
