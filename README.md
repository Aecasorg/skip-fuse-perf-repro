# Skip Fuse performance repros

A minimal [Skip](https://skip.dev) Fuse app (created with `skip init --native-app`)
demonstrating Android-only performance and layout behaviors, each backing an issue filed
against skip.tools. Identical SwiftUI code runs on both platforms; the divergence is
observable through per-view body-evaluation counters logged once per second.

## Scenes → issues

| Scene | Demonstrates | Upstream issue |
|-------|--------------|----------------|
| 1. Unrelated state tick | An `@Observable` counter ticks once per second; the only view reading it is a header `Text`. On Android all 20 static cards below re-evaluate on every tick (eager *and* lazy/stable-id variants). On iOS they never re-evaluate. | skip-bridge: bridged peers never skippable; skip-ui: container-scope invalidation + lazy items re-evaluated every pass *(issue links TBD)* |
| 2. GeometryReader idle loop | A `GeometryReader` whose content lays out against the reported size. On Android the body counters keep climbing while the screen sits completely idle. On iOS they stop after layout settles. | skip-ui: no epsilon on float `Rect` bounds writes *(issue link TBD)* |
| 3. onChange relay hops | A button write relays a → b → c through `.onChange`. On Android each hop lands ~one frame (~16 ms) after the previous; on iOS all stamps share the same transaction. | skip-ui: `.onChange` runs post-apply in `SideEffect` *(issue link TBD)* |
| 4. Resizable icons | Rows with a resizable asset icon sized by `.aspectRatio(contentMode: .fit).frame(height:)`, in a `List`, in a sheet and in the sheet's toolbar, plus a fixed-frame control row. On Android since skip-ui 1.60.0 the icon takes all the free width of its row and draws centred, and the sheet's inline title disappears. On iOS every icon sits at its edge. | skip-ui: resizable images sized by their aspect ratio take the whole `HStack` row *(issue link TBD)* |

## Running

- **iOS:** open `Project.xcworkspace`, run the `PerfRepro` scheme on a simulator; watch
  the Xcode console.
- **Android:** with an emulator/device connected, `skip android build && skip android run`
  (or open `Android/` in Android Studio); watch `adb logcat -s PerfRepro` (the app logs
  under subsystem `tools.skip.perfrepro`).

Each scene logs a line per second like:

```
tick=7 evals: StaticCardView=160 UnrelatedStateScene=8
```

On iOS `StaticCardView` stays at 20 (the initial render). On Android it grows by 20 per
tick.

## Version pins

`Package.swift` pins an exactly matched set — skip 1.9.4, skip-fuse-ui 1.17.2,
skip-ui 1.57.0 — the versions the issue reports were verified against. (The newest pair
at time of writing, skip-fuse-ui 1.18.0 + skip-ui 1.59.1, does not compile together:
`missing argument for parameter 'bridgedAxis'`.)

## Build status

- **iOS/macOS (Swift side): verified** — `swift build` compiles cleanly including
  skipstone transpile + bridge generation for the app module.
- **Android: build route matters.** The blessed route works — both locally and on CI:
  - **Xcode route (green):** `xcodebuild build -project Darwin/PerfRepro.xcodeproj
    -scheme "PerfRepro App" -destination "platform=iOS Simulator,id=<udid>"
    SKIP_ACTION=build` runs the full Android Swift cross-compile
    (`:skipstone:PerfRepro:buildAndroidSwiftPackageDebug`) via the SPM-resolved
    skip binary. CI (skiptools/actions reference workflow, see
    `.github/workflows/skipapp.yml` on the verification branches) builds and
    exports installable APKs the same way.
  - **CLI / bare routes (broken at skip 1.9.4/1.9.5 on the authoring machine):**
    `skip android build` (brew binary + swiftly toolchain) and a bare
    `cd Android && gradle assembleDebug` both fail — per-module
    `SkipBridgeGenerated/*.swift` compile inputs are declared but never emitted
    on these paths. Don't use them as a gate.
  - `Android/local.properties` (gitignored) needs `sdk.dir`, or export
    `ANDROID_HOME`, for any Gradle invocation.
