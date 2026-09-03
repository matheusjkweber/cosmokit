---
name: cosmokit-simulator
description: Use when driving or verifying an iOS app UI on the simulator, including requests to use a simulator, tap, screenshot the app, or test this screen.
---

# CosmoKit simulator control

Use this skill when an iOS simulator must be driven or its visible state
verified. It uses the XCUITest driver and never depends on the CosmoKit app.

## Setup

```sh
cosmokit doctor
cosmokit agent start
```

## Loop

1. Read the screen with `cosmokit ui tree --mode act`.
2. Decide from the returned refs and labels.
3. Act with `cosmokit ui tap <ref>`, `cosmokit ui type "text"`, or another `ui` command.
4. Read one fresh `cosmokit ui tree` after the action.
5. Use `cosmokit ui screenshot` only when visual layout, spacing, or rendering matters.

## Cost and safety rules

- Prefer refs from the latest tree over coordinates.
- Prefer `act` over `debug`; use `debug` only when identifiers or containers matter.
- Pass `--max` on long screens.
- Take one tree per step and do not poll screenshots.
- A ref belongs to the snapshot that produced it; never reuse it after the UI changes.

## Recovery

- `refStale`: take a new tree and use its new ref.
- `driverUnavailable`: run `cosmokit agent start` and retry once.
- If the keyboard is not up, tap the text field first, then type.
- If the app is missing, use the existing `boot`, `install`, and `launch` commands.

## Other simulator tools

- `boot` — boot a simulator.
- `install` — install an app bundle.
- `launch` — launch an app by bundle identifier.
- `push` — deliver an APNs payload.
- `open` — open a deep link.
- `location` — set a fixed coordinate.
- `defaults` — inspect app preferences.
- `logs` — read a bounded simulator log window.

## Finish

```sh
cosmokit agent stop
```
