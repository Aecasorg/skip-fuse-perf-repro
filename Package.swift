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
        // Verification branch: matched trio pinned; the rest float to a fresh resolve.
        .package(url: "https://source.skip.tools/skip.git", exact: "1.9.5"),
        .package(url: "https://source.skip.tools/skip-fuse-ui.git", exact: "1.18.1"),
        .package(url: "https://github.com/Aecasorg/skip-ui.git", exact: "1.59.1004")
    ],
    targets: [
        .target(name: "PerfRepro", dependencies: [
            .product(name: "SkipFuseUI", package: "skip-fuse-ui")
        ], resources: [.process("Resources")], plugins: [.plugin(name: "skipstone", package: "skip")]),
    ]
)
