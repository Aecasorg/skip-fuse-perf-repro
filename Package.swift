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
        // Exact pins: the Skip versions the driver app builds Android with, apart from
        // skip-ui, which is upstream here. skip-lib 1.4.3 does not compile for Android,
        // and skip 1.9.13 needs skip-bridge 0.18.0.
        .package(url: "https://github.com/skiptools/skip.git", exact: "1.9.11"),
        .package(url: "https://github.com/skiptools/skip-fuse-ui.git", exact: "1.19.0"),
        .package(url: "https://github.com/skiptools/skip-ui.git", exact: "1.61.0"),
        .package(url: "https://github.com/skiptools/skip-bridge.git", exact: "0.17.3"),
        .package(url: "https://github.com/skiptools/skip-lib.git", exact: "1.4.2"),
        .package(url: "https://github.com/skiptools/skip-android-bridge.git", exact: "0.6.6")
    ],
    targets: [
        .target(name: "PerfRepro", dependencies: [
            .product(name: "SkipFuseUI", package: "skip-fuse-ui")
        ], resources: [.process("Resources")], plugins: [.plugin(name: "skipstone", package: "skip")]),
    ]
)
