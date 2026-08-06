# cosmokit CLI

Scriptable access to the simulator operations the CosmoKit app performs, for
Makefiles, git hooks and CI.

The point is workflow stickiness: once `cosmokit capture` is in a project's
scripts, the tool is part of the team's daily loop rather than something
someone remembers to open.

## Build

```sh
swift build -c release
cp .build/release/cosmokit /usr/local/bin/
```

Standalone SwiftPM package: it does not depend on the app target and needs
only Xcode's command line tools at runtime (it shells out to `xcrun simctl`).

## Commands

```
cosmokit list                        List available simulators
cosmokit boot [name|udid]            Boot a simulator (default: first available)
cosmokit shutdown [name|udid]        Shut a simulator down (default: booted)
cosmokit capture [name|udid]         Screenshot to a file
cosmokit record [name|udid]          Record video until Ctrl-C
cosmokit location <lat> <lon> [dev]  Set the simulator's GPS position
cosmokit open <url> [name|udid]      Open a deep link
cosmokit erase [name|udid]           Erase a simulator back to a fresh install
```

`--output <path>` sets the directory for `capture` and `record`.

Device arguments accept a UDID, an exact name, or a partial name; omit them to
use the booted simulator.

## Examples

```sh
# Screenshot every booted simulator into the repo's screenshots folder
cosmokit capture --output ./screenshots

# Put the simulator in Rio before running location tests
cosmokit location -22.9068 -43.1729

# Exercise a deep link in a pre-commit hook
cosmokit open "myapp://item/42"
```

## Scope

Free, and intentionally limited to what plain `simctl` can do. The app's Pro
features (network proxy, device frames, watermark-free exports, Dev Presets)
stay in the app, where the entitlement lives.
