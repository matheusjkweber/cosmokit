# CosmoKit — workspace root

**This directory is not the SDK.** It is `maththedev42/cosmokit`, a **public** repo whose
root is the Next.js landing site (`package.json` is `cosmokit-landing`), and it contains
three independent git repos:

| path | remote | what it is |
|---|---|---|
| `CosmoKit/` | `maththedev42/cosmokit-app` | the iOS SDK and app — the actual product |
| `CosmoKitTestApp/` | `maththedev42/cosmokit-test-app` | the harness app |
| `landing/` | `maththedev42/cosmokit` | **the same remote as this root** |

## Landmines

- **This repo is public.** Internal notes, MRR figures, ad spend and roadmap files left at
  this level are world-readable. Revenue numbers have nearly leaked this way once already.
- **`git status` here does not see the app.** Commits meant for the SDK must be made
  inside `CosmoKit/`. Run `git rev-parse --show-toplevel` before committing and confirm it
  is the repo you meant.
- **`origin/HEAD` points at `gh-pages`, not `main`.** Anything that resolves the default
  branch — a fresh clone, a tool that reads `origin/HEAD` — lands on the landing site's
  deploy branch. Always name the branch explicitly.
- **The landing site exists twice.** This root and `landing/` are checkouts of the same
  repo, so an edit in one is invisible to the other until both are pulled, and both can
  push. Pick one and stay there.
- `cli/` is a SwiftPM package; `backend/` is Go; the landing is Next.js. Three toolchains,
  no shared build.
- The MITM proxy on this machine breaks `docker build` and cuts "offline" mode at the TLS
  layer. `scutil --proxy` is the truth, not the shell's `*_proxy` variables.
