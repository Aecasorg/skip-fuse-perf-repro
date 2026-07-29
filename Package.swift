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
        // Verification branch: mirror the driver app's entire resolved skip graph —
        // the one set proven green on this machine and CI (2026-07-29).
        .package(url: "https://source.skip.tools/skip.git", exact: "1.9.5"),
        .package(url: "https://source.skip.tools/skip-fuse-ui.git", exact: "1.18.1"),
        .package(url: "https://source.skip.tools/skip-ui.git", exact: "1.59.1"),
        .package(url: "https://source.skip.tools/skip-fuse.git", exact: "1.0.2"),
        .package(url: "https://source.skip.tools/skip-foundation.git", exact: "1.4.2"),
        .package(url: "https://source.skip.tools/skip-model.git", exact: "1.7.6"),
        .package(url: "https://source.skip.tools/skip-bridge.git", exact: "0.17.2"),
        .package(url: "https://source.skip.tools/skip-android-bridge.git", exact: "0.6.4"),
        .package(url: "https://source.skip.tools/skip-lib.git", exact: "1.4.0"),
        .package(url: "https://source.skip.tools/skip-unit.git", exact: "1.6.1")
    ],
    targets: [
        .target(name: "PerfRepro", dependencies: [
            .product(name: "SkipFuseUI", package: "skip-fuse-ui")
        ], resources: [.process("Resources")], plugins: [.plugin(name: "skipstone", package: "skip")]),
    ]
)
