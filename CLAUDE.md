# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

Clippy is a native macOS clipboard manager built as a Dynamic Island / notch-anchored shelf (100% Swift, AppKit + SwiftUI, no Electron/web wrapper). It runs as a menu-bar accessory app (`NSApp.setActivationPolicy(.accessory)`), monitors the system pasteboard, classifies/persists items to disk, and exposes them through a floating notch-shaped panel with search, merge, diff, OCR, and paste-queue features. See `README.md` for the full user-facing feature list.

The repo also contains `landing-page/` — a separate Next.js marketing site with its own `CLAUDE.md`/`AGENTS.md` (it points at `node_modules/next/dist/docs/` because it pins a bleeding-edge Next.js build with breaking API changes vs. training data). Treat it as an independent project; don't mix its conventions into the Swift app.

## Build & run

There is no test target in this project — do not look for or invent `xcodebuild test` commands.

```bash
# Open in Xcode (primary workflow)
open clippy.xcodeproj
# Scheme: "clippy" — ⌘B to build, ⌘R to run

# CLI build (requires full Xcode, not just Command Line Tools)
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer xcodebuild \
  -project clippy.xcodeproj -scheme clippy -configuration Debug build

# Build a distributable Release .app and package it into Clippy.dmg
./scripts/build_dmg.sh
```

Bundle ID: `com.pawan.clippy`. Swift 5.0 toolchain; `MACOSX_DEPLOYMENT_TARGET` is set very high (26.5) in the project settings.

Two Swift Package Manager dependencies (Xcode-managed, see `project.pbxproj`): `sindresorhus/KeyboardShortcuts` (global hotkey binding) and `sindresorhus/LaunchAtLogin-Modern`.

Direct Paste (auto-pasting into the frontmost app) requires the Accessibility permission (System Settings > Privacy & Security > Accessibility), granted via the onboarding flow (`UI/Onboarding/`).

### landing-page

```bash
cd landing-page
pnpm dev     # local dev server
pnpm build
pnpm lint
```

## Architecture

### Composition root & lifecycle

`App/AppDelegate.swift` is the entry point: it sets accessory activation policy, starts `ClipboardService.shared`, constructs and starts a single `ShelfController`, builds the status-bar menu, and shows onboarding on first run. There is no SwiftUI `App` window lifecycle driving the UI — the shelf is an `NSPanel` managed imperatively by `ShelfController`.

`App/ClipboardService.swift` is the composition root for the capture pipeline: it owns a `ClipboardMonitor`, bootstraps `LocalStorage` on `start()`, and runs `StorageCleanup` after every new item. `pause()`/`resume()` are just `stop()`/`start()` aliases used by the menu bar's "Pause Clipboard" toggle.

### Capture pipeline (the core data flow)

`ClipboardMonitor` polls `NSPasteboard.general.changeCount` on a 0.3s timer (no pasteboard change notifications exist on macOS, hence polling). For every genuine change it:
1. Filters out changes Clippy itself caused (`recordOwnWrite`/`ignoredChangeCounts`, and the `.clippyInternalMarker` pasteboard type) so writing back to the pasteboard during paste never re-ingests itself.
2. Reads the pasteboard via `ClipboardReader` into a `ClipboardItem` + `ClipboardPayload` (text/richText/image/fileURL).
3. Runs `ContentClassifier` (which composes `CodeDetector`, `ColorDetector`, `URLDetector`, `SensitiveDataDetector`) to set `item.type` and sensitivity flags.
4. Applies privacy policy from `PrivacyPreferences.shared`: block sensitive items entirely, encrypt via `ContentEncryptor` (AES-256-GCM + Keychain), mask the preview string, and/or schedule auto-purge.
5. Deduplicates by `contentHash` (via `ClipboardHasher`) — an existing item's `lastUsedAt`/`sourceApp` is refreshed instead of creating a duplicate.
6. Persists the payload through `AssetStore` (under `~/Library/Application Support/Clippy/`) and the item's metadata through `MetadataStore` (`metadata.json`), then fires `onNewItem`/`onUpdateItem` callbacks and a `.clippyNewItemSaved` notification.
7. For images, kicks off async Apple Vision OCR (`ImageTextExtractor`) and re-saves the item with `extractedText` once done, and generates a downsampled thumbnail via `ImageCache`/`AssetStore`.

If `PasteQueueManager.shared.isActive` (Queue Mode, `⌘⌥V`), every newly captured item is also enqueued for sequential FIFO paste.

Direct/queue pasting writes back to the pasteboard and PID-targets the previously-frontmost app (`ClipboardWriter`) — `ClipboardMonitor.recordOwnWrite` must be called for any such write so the monitor doesn't loop back on itself.

### Storage layout

`Core/Storage/LocalStorage.swift` defines the on-disk layout under `~/Library/Application Support/Clippy/` (auto-migrated from a legacy `Supaste/` folder): `metadata.json` (all `ClipboardItem` records), `collections.json`, plus `items/`, `images/`, `files/`, `thumbnails/`, `stash/` subdirectories. `MetadataStore`/`CollectionStore` read/write the JSON files; `AssetStore` writes/reads the actual payload blobs (including encrypted variants); `StorageCleanup` prunes history against configured size/count limits after every capture; `ImageCache` is an in-memory thumbnail cache layered on top.

This layer is pure Foundation (no UI/AppKit dependency), by design — `LocalStorage.rootURL` is a mutable `var` specifically so it can be redirected for tests/scripts, even though no test target currently exists.

### Shelf / UI shell

`UI/Shelf/ShelfController.swift` is the largest single file (~700 lines) — it owns the shelf's `NSPanel` (`ShelfWindow`), expand/collapse state, notch-vs-pill geometry (`NotchShelfShape`, screen detection via `ScreenManager`), mouse pass-through when collapsed (`MouseTracker`), drag-and-drop into the notch (drop zone / stash), and hosts the SwiftUI `ShelfView` inside the panel. Read this file before touching shelf show/hide, sizing, or drag behavior — animation timing constants live alongside it in `ShelfAnimation.swift`.

`UI/Shelf/ShelfView.swift` is the SwiftUI root rendered inside the panel; it composes the clipboard grid, search bar, merger bar, copy-notification pill, screenshot HUD, and (newer) Writing Tools / AI panels based on shelf mode.

`Core/System/GlobalShortcut.swift` binds the global hotkeys (`⌘⇧V` toggle shelf, `⌘⌥V` toggle queue mode) via the KeyboardShortcuts package; `MouseTracker` detects hover over the physical notch to trigger expansion.

### Feature modules under `Core/`

Each subdirectory under `Core/` is a self-contained feature engine with a matching `UI/` counterpart of the same name (e.g. `Core/Merger` + `UI/Merger`, `Core/Stash` + `UI/Stash`, `Core/Search` + `UI/Search`). When adding a feature, follow this pairing rather than putting business logic in the SwiftUI views:

- `Classification/` — content-type detection and sensitivity flagging (`ContentClassifier` is the entry point; it delegates to `CodeDetector`, `ColorDetector`, `URLDetector`, `ImageTextExtractor`, `SensitiveDataDetector`).
- `Search/` — `SearchEngine` parses operator syntax (`app:`, `type:`, `is:`, `has:`) plus subsequence fuzzy text matching, backed by `SearchIndex`.
- `Merger/` — `MergerEngine` (bullet/delimiter/SQL joins) and `DiffEngine` (Myers diff for the compare view).
- `Security/` — `ContentEncryptor` (AES-256-GCM via CryptoKit + Keychain-stored key).
- `Developer/` — JSON pretty-print/minify/TS-interface generation, DB connection-string parsing, color format conversions — pure transformation functions, no persistence.
- `AI/` — `GeminiService`/`GeminiPreferences`: optional BYOK integration with Google Gemini; this is the only component that makes network requests — everything else in the app is offline-only by design, so keep new network calls confined here and gated behind explicit user opt-in/API key configuration.
- `Meeting/` (+ `UI/Meeting/`, `Models/MeetingNote.swift`) — newer, in-progress feature area; check current file contents before assuming its shape, as it's still being built out.

### Preferences pattern

Feature areas that need persisted user settings use a `*Preferences` singleton (`PrivacyPreferences`, `DeveloperPreferences`, `GeminiPreferences`) rather than a single global settings blob — follow this pattern for new settings rather than adding to `SettingsView` state directly. `UI/Settings/` has one view per preferences domain (`GeneralSettings`, `PrivacySettings`, `StorageSettings`, `CollectionsSettings`, `GeminiSettingsView`, plus the newer `MeetingSettingsView`).

## Privacy invariant

The app is designed to be 100% on-device with zero telemetry — the only intentional exception is the opt-in Gemini BYOK integration in `Core/AI/`. Do not introduce new network calls, analytics, or telemetry elsewhere in the codebase without calling this out explicitly, as it breaks a documented product guarantee (see README "Privacy & Security First").
