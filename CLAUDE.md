# CosmoKit — Product & Development Context

## What is CosmoKit?

CosmoKit is a **paid macOS developer tool** for iOS developers. It's a native Swift/SwiftUI app sold on the Mac App Store with a freemium model (free tier + $2.99/month Pro subscription).

**Think of it as**: The missing control panel for iOS Simulator — like Proxyman + SimPholders + RocketSim combined into one beautiful, native tool.

**Target audience**: iOS developers (indie developers, mobile teams at startups and enterprises) who use Xcode and iOS Simulator daily.

**Competitors**: Proxyman ($59 one-time), RocketSim ($49.99/year), SimPholders (free but unmaintained), Control Room (free but limited). CosmoKit differentiates by being an all-in-one tool at a fraction of the cost.

## Business Model

- **Free tier**: 1 simulator, 5 saved entries per type, watermarked captures
- **Pro tier** ($2.99/month, 3-day free trial): Unlimited simulators, unlimited entries, no watermark, device frames, audio recording, touch indicators, response overrides, saved requests
- **Revenue goal**: Recurring subscription revenue from iOS developer community
- **Distribution**: Mac App Store (sandboxed)

## Core Value Propositions

1. **Save hours daily** — One-click push notifications, deep links, and location mocking instead of manual simctl commands
2. **Beautiful captures** — Device-framed screenshots and GIF recordings for App Store assets, marketing, and bug reports
3. **Network debugging** — Intercept, inspect, and mock HTTP responses from simulator apps (like Proxyman but built-in)
4. **Everything in one place** — No more switching between 5 different tools

## Feature Set (v3.1)

| Feature | Description | Pro? |
|---------|------------|------|
| Push Notifications | Send custom APNS payloads to simulator | 5 free |
| Deep Links | Open custom URL schemes in simulator apps | 5 free |
| Location Simulation | Set GPS coordinates with address search | 5 free |
| Screenshots | Capture with device frames, shadows, aspect ratios | Frames = Pro |
| Video Recording | MP4/GIF with touch overlay and audio | Touch/Audio = Pro |
| App Actions | Install, uninstall, clear data, open container | Free |
| Log Streaming | Live os_log stream with filtering | Free |
| Pasteboard Sync | Copy text between Mac and Simulator | Free |
| Media Seeding | Add photos/videos to simulator library | Free |
| URL Scheme Discovery | Read registered URL schemes from apps | Free |
| Network Proxy | HTTP/HTTPS interception via local proxy | Free |
| Response Overrides | Mock API responses with pattern matching | Pro |
| Saved Requests | Persist intercepted requests for replay | Pro |
| Multi-Simulator | Control multiple simulators simultaneously | Pro |

## Technical Stack

- **Language**: Swift, SwiftUI
- **Persistence**: SwiftData
- **Subscriptions**: StoreKit 2
- **Simulator control**: `xcrun simctl` via Process
- **Network proxy**: NWListener (Network.framework)
- **Certificate generation**: `/usr/bin/openssl` (LibreSSL)
- **Min macOS**: 12.0
- **Sandboxed**: Yes (App Store requirement)
- **Bundle ID**: `apps.mjkweber.CosmoKit`
- **Localized**: English, Portuguese (BR), Spanish

## Project Structure

```
CosmoKit/
├── CosmoKitApp.swift              # App entry, window scenes
├── ContentView.swift              # Settings window
├── Core/
│   ├── Proxy/                     # Network proxy engine
│   │   ├── ProxyServer.swift      # NWListener server (singleton)
│   │   ├── ProxyConnectionHandler.swift  # Per-connection HTTP/HTTPS handler
│   │   ├── HTTPParser.swift       # Raw HTTP parsing
│   │   ├── ProxyOverrideEngine.swift     # URL pattern matching for mocks
│   │   ├── ProxyCertificateManager.swift # SSL cert generation
│   │   └── ProxyModels.swift      # In-memory request records
│   ├── Simulator/
│   │   ├── SimulatorAppsService.swift    # All simctl operations
│   │   └── SimctlExecutor.swift          # Process wrapper
│   ├── Data/                      # SwiftData @Model classes
│   ├── ViewModels/AppViewModel.swift     # Main app state
│   ├── Config/SubscriptionManager.swift  # StoreKit 2
│   └── Localization/              # L10n system
├── Features/
│   ├── ControlPanel/ControlPanelView.swift  # Main tab UI
│   └── Tools/                     # One folder per feature
│       ├── NetworkProxy/          # Proxy tab + windows
│       ├── PushNotifications/
│       ├── DeepLinks/
│       ├── Location/
│       ├── Camera/
│       ├── AppActions/
│       └── SimulatorTools/
└── Localization/                  # en, pt-BR, es .lproj files
```

## Development Guidelines

- **UI style**: Clean, modern macOS aesthetic with gradient accents (`CosmoGradients.primary`). Use existing patterns from `SimulatorToolsView` (sectionContent, toolRow, actionButton).
- **Form style**: `CosmoFormHeader` + `CosmoFormCard` + toolbar Cancel/Save buttons (see `PushNotificationFormView`).
- **Simulator actions**: Always use `SimulatorActionRunner.run()` for multi-device operations.
- **Localization**: Wrap all user-facing strings with `L10n.tr()` or `L10n.format()`. Update all 3 locale files.
- **Pro gating**: Use `SubscriptionManager.shared.isPro` and `canCreateEntry(of:context:)`.
- **Avoid**: `Layout` protocol (requires macOS 13), breaking sandbox, adding unnecessary complexity.
- **Quality bar**: This is a paid product. UI must be polished and professional. No placeholder text, no broken states, no rough edges.

## What Success Looks Like

Every feature we add should make an iOS developer think: "I can't believe I was doing this manually before." The app should feel like a natural extension of Xcode — fast, reliable, and delightful to use. Every interaction should save the developer time and reduce friction in their daily workflow.
