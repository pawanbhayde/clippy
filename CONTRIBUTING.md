# Contributing to Clippy

Thanks for your interest in improving Clippy! This document covers everything you need to build the project, make a change, and open a pull request.

## Project layout

This repo contains two independent projects:

- **`clippy/`** — the macOS app (Swift, AppKit + SwiftUI). This is the main project.
- **`landing-page/`** — the marketing site (Next.js). Independent tooling and conventions; see `landing-page/README.md`.

For an architecture overview of the macOS app (capture pipeline, storage layout, feature module conventions), read [`CLAUDE.md`](CLAUDE.md) — it's written for AI coding assistants but is equally useful as a map of the codebase for human contributors.

## Prerequisites

- macOS 14.0 (Sonoma) or later
- Xcode 15.0+ with Command Line Tools
- For `landing-page/`: Node.js and [pnpm](https://pnpm.io/)

## Building the app

```bash
open clippy.xcodeproj
```

Select the `clippy` scheme and your Mac as the run destination, then `⌘R`. Or build from the CLI:

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild \
  -project clippy.xcodeproj -scheme clippy -configuration Debug build
```

There is currently no automated test suite for the macOS app — verify changes by running the app and exercising the affected feature manually. If you're adding non-trivial logic (parsers, detectors, transformations), consider whether it can be extracted into a pure-Swift type under `Core/` that could be unit tested in the future.

Direct Paste requires granting Clippy the Accessibility permission (System Settings > Privacy & Security > Accessibility) — the app will prompt for this via its onboarding flow on first launch.

## Making changes

- Match the existing architecture: business logic lives in `Core/<Feature>/`, SwiftUI views in `UI/<Feature>/`. See `CLAUDE.md` for the established `Core`/`UI` pairing and the `*Preferences` singleton pattern used for persisted settings.
- Keep the app's privacy guarantee intact: Clippy is 100% on-device with zero telemetry, with the sole exception of the opt-in Gemini BYOK integration in `Core/AI/`. Don't add network calls, analytics, or telemetry elsewhere without discussing it in an issue first.
- Follow standard Swift API design guidelines and the formatting conventions already used in the file you're editing.
- Keep commits focused and write clear commit messages describing the *why*, not just the *what*.

## Submitting a pull request

1. Fork the repo and create a branch off `main`.
2. Make your change, build, and manually verify it (Debug and, for anything touching paste/clipboard capture/storage, ideally a Release build too).
3. Open a PR describing the change, why it's needed, and how you tested it. Link any related issue.
4. Be responsive to review feedback — small, incremental PRs are easier to review than large ones.

## Reporting bugs & requesting features

Use [GitHub Issues](../../issues). For bugs, include your macOS version, Mac model (notch vs. notchless matters for shelf geometry), and steps to reproduce. For security vulnerabilities, see [`SECURITY.md`](SECURITY.md) instead of opening a public issue.

## Code of Conduct

This project follows the [Contributor Covenant](CODE_OF_CONDUCT.md). By participating, you agree to abide by it.
