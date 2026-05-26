# Content (What's New / Notifications / Helper)

This package embeds `data.json` and serves it through the three macOS-app
endpoints under `/v1/`. Updating content is a redeploy: edit `data.json`,
push the backend image to ACR, retarget the App Service.

## Release policy

When bumping `helper.latestVersion`, **always** also:

- set `helper.blockProxy: true`
- bump the active notification's `id` and `minHelperVersion` to the new version
- update notification body to reference the new version + the user-visible reason
- update `helper.releaseNotes` for the three locales

Why `blockProxy: true` is the default: the client computes
`shouldBlockEnable = needsUpdate && blockProxy`, so flipping `blockProxy` true
only affects users **behind** the latest version. Users already on the latest
helper see no change. This guarantees critical fixes (cert pinning, MITM
correctness, anything that breaks specific apps under the proxy) reach
everyone before they hit it. Only set `blockProxy: false` if the new release
is purely additive and the old helper still works correctly enough that
forcing a download would be obnoxious.

## What's New `version` key

The `whatsNew[].version` field is the **macOS app marketing version** (e.g.
`4.4.0`), not the helper version. The macOS client calls
`/v1/whats-new?version=<Bundle.shortVersion>`, so each app release that wants
its own What's New entry must add a new object keyed by its marketing version.
The handler falls back to the last entry when no exact match is found, so the
list should stay roughly in version-ascending order.

## Locale fallback

`Localized.Pick(locale)` resolves in this order: exact match → language root
(`pt-BR` → `pt`) → `en` → any non-empty value → empty string. Always provide at
least an `en` value; pt/es are best-effort.
