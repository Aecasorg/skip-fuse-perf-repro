# Skip Fuse performance repros

A minimal [Skip](https://skip.dev) Fuse app (created with `skip init --native-app`)
demonstrating three Android-only performance behaviors, each backing an issue filed
against skip.tools. Identical SwiftUI code runs on both platforms; the divergence is
observable through per-view body-evaluation counters logged once per second.

## Scenes → issues

| Scene | Demonstrates | Upstream issue |
|-------|--------------|----------------|
| 1. Unrelated state tick | An `@Observable` counter ticks once per second; the only view reading it is a header `Text`. On Android all 20 static cards below re-evaluate on every tick (eager *and* lazy/stable-id variants). On iOS they never re-evaluate. | skip-bridge: bridged peers never skippable; skip-ui: container-scope invalidation + lazy items re-evaluated every pass *(issue links TBD)* |
| 2. GeometryReader idle loop | A `GeometryReader` whose content lays out against the reported size. On Android the body counters keep climbing while the screen sits completely idle. On iOS they stop after layout settles. | skip-ui: no epsilon on float `Rect` bounds writes *(issue link TBD)* |
| 3. onChange relay hops | A button write relays a → b → c through `.onChange`. On Android each hop lands ~one frame (~16 ms) after the previous; on iOS all stamps share the same transaction. | skip-ui: `.onChange` runs post-apply in `SideEffect` *(issue link TBD)* |

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
