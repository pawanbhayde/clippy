<div align="center">

# 📎 Clippy

### The Supercharged Dynamic Island & Notch Clipboard Manager for macOS

[![macOS](https://img.shields.io/badge/macOS-14.0%2B%20%28Sonoma%20%2F%20Sequoia%29-black?style=flat&logo=apple)](https://apple.com/macos)
[![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange?style=flat&logo=swift)](https://developer.apple.com/swift/)
[![Architecture](https://img.shields.io/badge/Architecture-100%25%20Native%20AppKit%20%2B%20SwiftUI-blue)](#architecture--tech-stack)
[![Security](https://img.shields.io/badge/Security-AES--256--GCM%20%2B%20Keychain-success)](#-privacy--security-first)
[![Privacy](https://img.shields.io/badge/Privacy-100%25%20On--Device%20%7C%20Zero%20Telemetry-brightgreen)](#-privacy--security-first)
[![License](https://img.shields.io/badge/License-MIT-purple)](LICENSE)

*Transform your MacBook camera notch or top screen bezel into an intelligent, interactive Dynamic Island shelf for lightning-fast clipboard productivity, sequential pasting, multi-item merging, native OCR, live color palettes, developer transformations, and privacy-first secret masking.*

---

</div>

## 📑 Table of Contents

- [📎 Clippy](#-clippy)
    - [The Supercharged Dynamic Island \& Notch Clipboard Manager for macOS](#the-supercharged-dynamic-island--notch-clipboard-manager-for-macos)
  - [📑 Table of Contents](#-table-of-contents)
  - [✨ Overview](#-overview)
  - [🚀 Key Features at a Glance](#-key-features-at-a-glance)
  - [⚡ Feature Deep Dive](#-feature-deep-dive)
    - [1. Dynamic Island Notch Shelf](#1-dynamic-island-notch-shelf)
    - [2. Sequential Queue Paste ("Paste Queue")](#2-sequential-queue-paste-paste-queue)
    - [3. Smart Scratchpad \& Multi-Item Merger ("Combine \& Paste")](#3-smart-scratchpad--multi-item-merger-combine--paste)
    - [4. Visual Diff Comparison Engine](#4-visual-diff-comparison-engine)
    - [5. Built-in Apple Vision OCR \& Searchable Screenshots](#5-built-in-apple-vision-ocr--searchable-screenshots)
    - [6. Color Inspector \& Palette Converter](#6-color-inspector--palette-converter)
    - [7. Secret Auto-Masking \& Auto-Purge Countdown](#7-secret-auto-masking--auto-purge-countdown)
    - [8. Notch "Drop Zone" \& Temporary Stash](#8-notch-drop-zone--temporary-stash)
    - [9. Power Search Operators \& Subsequence Fuzzy Matching](#9-power-search-operators--subsequence-fuzzy-matching)
    - [10. Developer Utilities (JSON \& Connection Strings)](#10-developer-utilities-json--connection-strings)
  - [⌨️ Keyboard Shortcuts](#️-keyboard-shortcuts)
  - [🔎 Search Operators Syntax](#-search-operators-syntax)
  - [🛡️ Privacy \& Security First](#️-privacy--security-first)
  - [📦 Installation & Setup](#-installation--setup)
    - [Method 1: Download Pre-built Release (Recommended)](#method-1-download-pre-built-release-recommended)
    - [Method 2: Install via Homebrew](#method-2-install-via-homebrew)
    - [Method 3: Build & Package DMG from Source (CLI)](#method-3-build--package-dmg-from-source-cli)
    - [Method 4: Build & Run with Xcode (For Contributors)](#method-4-build--run-with-xcode-for-contributors)
    - [Essential Post-Installation Permissions](#-essential-post-installation-permissions)
  - [🏛 Architecture & Tech Stack](#-architecture--tech-stack)

---

## ✨ Overview

Standard macOS clipboard managers live in cluttered windows, separate menus, or popover modals that disrupt your active workspace. **Clippy** is built from the ground up for modern macOS displays and Apple Silicon MacBook notches:

- **Invisible Until Needed**: Clippy rests quietly as a sleek, curved capsule conforming to your camera notch. When collapsed, it passes all mouse events straight through so you can click tabs and controls behind it with zero interference.
- **Expands on Intent**: Hover over the notch, drag files towards it, or press `⌘⇧V` to reveal a rich, glassmorphic productivity shelf.
- **Direct Paste Injection**: Select any item, and Clippy immediately pastes it into your target application (Xcode, Slack, VS Code, Chrome, Terminal) without requiring a second shortcut.

---

## 🚀 Key Features at a Glance

| Feature | Description |
| :--- | :--- |
| 🏝️ **Dynamic Island Shelf** | Native notch-anchored panel with fluid spring animations and multi-monitor awareness. |
| 🔔 **Notch Copy Notification** | Dynamic Island pill pops down on copy, displaying the source app icon & saved text preview. |
| ⚡ **Sequential Paste Queue** | Copy 10 items in a row and paste them sequentially (`1 → 2 → 3...`) into forms or docs with `⌘V`. |
| 🪄 **Multi-Item Merger** | Select multiple items with `⌘`/`⇧` and join as bullet lists, CSVs, or SQL `IN ('a','b')`. |
| 📊 **Visual Diff Engine** | Side-by-side and unified diff comparison between any two clipboard text/code snippets. |
| 🔍 **Apple Vision OCR** | Hardware-accelerated offline OCR makes text inside copied screenshots instantly searchable and copyable. |
| 🎨 **Live Color Inspector** | Identifies HEX, RGB, and HSL. Provides live swatches and 1-click conversions to Swift `Color` or Compose. |
| 🛡️ **Secret Auto-Masking** | Automatically masks API keys, passwords, and OTPs as `••••••••`, with configurable auto-purge timers. |
| 📥 **Notch Drop Zone & Stash** | Drag files or images to the notch to stash them across Spaces/full-screen apps or save to history. |
| 🔎 **Advanced Search Operators** | Query by `app:`, `type:`, `is:`, `has:`, plus subsequence fuzzy text search. |
| 🛠️ **Developer Mode** | JSON pretty-print, minification, TypeScript interfaces, and database connection string parsing. |
| 🔒 **Keychain AES-256-GCM** | Military-grade on-device encryption. Zero cloud storage, zero telemetry, 100% offline. |

---

## ⚡ Feature Deep Dive

### 1. Dynamic Island Notch Shelf
- **Adaptive Screen Geometry**: Detects whether your Mac has a hardware camera notch (`safeAreaInsets.top > 0`) and automatically shapes itself using `NotchShelfShape`. On notchless displays or external monitors, it renders as an elegant floating Dynamic Island pill.
- **Instant Copy Notch Notification**: Whenever you copy text, code, colors, or images from any app, a subtle Dynamic Island notch capsule springs down under your camera notch. It displays the frontmost app's icon, a vibrant status dot, and a single-line preview of the saved text. Click the pill to immediately expand your clipboard shelf, or let it smoothly contract back into the notch after 2.2 seconds.
- **Smart Pass-Through**: When collapsed, Clippy disables its mouse tracking area and shrinks its hit-testing footprint to avoid blocking browser tabs or window controls located near the top of the display.
- **Fluid Spring Physics**: Uses high-performance SwiftUI spring animations coordinated with AppKit's native window server for buttery 120Hz ProMotion response.

### 2. Sequential Queue Paste ("Paste Queue")
Tired of copying text, switching apps, pasting, switching back, and repeating 10 times?
1. Press **`⌘⌥V`** (or click the Queue icon) to enter **Queue Mode**.
2. Copy your desired data points in sequence (e.g., Name, Email, Address, Phone Number).
3. Switch to your destination app or web form.
4. Press **`⌘V`** repeatedly: Clippy pops each item in FIFO order (`1 → 2 → 3 → 4`) and displays a live remaining item counter right on your notch.

### 3. Smart Scratchpad & Multi-Item Merger ("Combine & Paste")
No need to open a text editor just to combine lines:
- Hold **`⌘`** or **`⇧`** to multi-select items in Clippy Island.
- A floating **Merger Action Bar** appears instantly.
- **Merge Actions**:
  - **Bullet Lists**: Format as Hyphen (`- `), Asterisk (`* `), Numbered (`1. `), or Checklist (`- [ ] `).
  - **Delimiter Join**: Join with commas, newlines, paragraphs, pipes (`|`), or semicolons.
  - **SQL Helper**: Wrap items with quotes and output formatted SQL expressions like `IN ('item1', 'item2', 'item3')`.
- One click to **Copy Merged** or **Paste Directly**.

### 4. Visual Diff Comparison Engine
- Select exactly **2 items** in the clipboard grid and click **Compare Diff**.
- View changes in **Side-by-Side** dual panes or a standard **Unified Diff** view.
- Color-coded green additions and red deletions with precise line number tracking and change statistics (`+X / -Y`).
- Copy the diff output or unified patch with a single click.

### 5. Built-in Apple Vision OCR & Searchable Screenshots
- Whenever an image or screenshot enters your clipboard, Clippy runs offline text recognition using Apple's native `VNRecognizeTextRequest` (`Vision.framework`).
- **1-Click "Copy Text"**: Extract text directly from screenshots, diagrams, and error dialogs without external utilities.
- **Search Inside Images**: Search for text that only appeared inside an image, and Clippy will find the matching screenshot in your history.

### 6. Color Inspector & Palette Converter
- Automatically parses Hex codes (`#6366F1`, `#FFF`), CSS `rgb(r, g, b)`, `rgba(...)`, `hsl(...)`, and `hsla(...)`.
- Displays an interactive color swatch right on the clipboard card.
- Click to convert and copy as:
  - **Hex** (`#6366F1` or `#6366f1`)
  - **CSS** `rgb(99, 102, 241)` or `hsl(239, 84%, 67%)`
  - **SwiftUI** `Color(red: 0.388, green: 0.400, blue: 0.945)`
  - **AppKit** `NSColor(red: ..., green: ..., blue: ..., alpha: 1.0)`
  - **Jetpack Compose** `Color(0xFF6366F1)`

### 7. Secret Auto-Masking & Auto-Purge Countdown
Never accidentally flash an API token or password during a screen share, video recording, or meeting:
- **Automatic Detection**: Recognizes API tokens (OpenAI `sk_live_`, GitHub `ghp_`, AWS `AKIA`, Stripe `pk_live_`), passwords (`password = ...`), and 2FA verification codes / OTPs.
- **Masked by Default**: Masked as `••••••••` with click-to-reveal.
- **Auto-Purge Countdown**: Sensitive items are tagged with an automatic expiration timer (default 60 seconds) and permanently erased when the timer expires.

### 8. Notch "Drop Zone" & Temporary Stash
Drag files, images, code selections, or URLs to the camera notch to trigger the dual **Notch Drop Zone**:
- **Left Zone — Temporary Stash**: Holds items temporarily so you can drag them across macOS Spaces, full-screen windows, or desktops, then drag them back out. Stashed items are cleared once dropped or dragged out.
- **Right Zone — Save to Clippy**: Permanently stores the dropped content into your Clippy clipboard history.

### 9. Power Search Operators & Subsequence Fuzzy Matching
Instantly filter thousands of clipboard items using powerful search tokens combined with fuzzy scoring:
- Combine operators: `app:xcode type:code has:url`
- Subsequence fuzzy matching allows searching `dco` to find `docker-compose`.

### 10. Developer Utilities (JSON & Connection Strings)
- **JSON Beautifier & Minifier**: Pretty-prints messy JSON payloads with 2-space indentation or compresses them into single-line minified strings.
- **TypeScript Generator**: Generates TypeScript interfaces directly from copied JSON objects.
- **Connection String Analyzer**: Parses database URLs (`postgresql://`, `mysql://`, `mongodb://`, `redis://`), masks credentials, and extracts host, port, database, and connection parameters.

---

## ⌨️ Keyboard Shortcuts

| Shortcut | Action | Scope |
| :--- | :--- | :--- |
| **`⌘ ⇧ V`** | **Toggle Clippy Notch Shelf** | Global Hotkey |
| **`⌘ ⌥ V`** | **Toggle Sequential Queue Paste Mode** | Global Hotkey |
| **`Return`** | Paste selected item into active application | Clippy Window |
| **`⌘ C`** | Copy selected item to clipboard without pasting | Clippy Window |
| **`Space`** | Open Quick Look / Rich Expanded Preview | Clippy Window |
| **`⌘ Click`** / **`⇧ Click`** | Multi-select items for Merger / Diff | Clippy Window |
| **`⌘ F`** | Focus search input field | Clippy Window |
| **`⌘ D`** | Add or remove item from Favorites | Clippy Window |
| **`⌫` (Delete)** | Delete selected item from history | Clippy Window |
| **`Esc`** | Clear multi-selection or close shelf | Clippy Window |
| **`⌘ ,`** | Open Clippy Preferences | Clippy Window / Menu |

---

## 🔎 Search Operators Syntax

You can combine any number of operators with free-text search queries:

| Operator | Syntax Example | Matches |
| :--- | :--- | :--- |
| **`app:`** | `app:xcode`, `app:slack`, `app:chrome` | Items copied from a specific application |
| **`type:`** | `type:code`, `type:image`, `type:text`, `type:url`, `type:file` | Items matching a specific content type |
| **`is:`** | `is:favorite`, `is:sensitive`, `is:encrypted`, `is:code` | Flagged attributes or characteristics |
| **`has:`** | `has:url`, `has:color`, `has:code`, `has:image` | Items containing specific detected entities |
| *Free Text* | `auth token`, `select * from`, `rgb` | Subsequence fuzzy matching across item content |

**Example Queries**:
```text
app:xcode type:code has:url
type:image app:slack
is:favorite has:color
app:safari utm_source
```

---

## 🛡️ Privacy & Security First

Clippy is built with an uncompromising commitment to privacy:

1. **100% On-Device**: Clippy never makes network requests, sends telemetry, or transmits clipboard content to external servers.
2. **Hardware-Backed Encryption**: Sensitive items can be encrypted at rest using **256-bit AES-GCM** via Apple's `CryptoKit`. Encryption keys are generated on-device and stored securely in the **macOS Keychain**.
3. **Secret Auto-Purge**: Passwords, API tokens, and OTPs automatically expire and are purged from memory and storage.
4. **App Blacklist / Ignore Rules**: Configure Clippy to automatically ignore copies originating from password managers (such as 1Password, Bitwarden, KeePassXC) or private browsing sessions.

---

## 📦 Installation & Setup

Choose your preferred installation method:

### Method 1: Download Pre-built Release (Recommended)

1. Go to the [**Latest GitHub Releases**](https://github.com/pawanbhayde/clippy/releases/latest) and download **`Clippy.dmg`**.
2. Double-click **`Clippy.dmg`** to open it.
3. Drag **`Clippy.app`** into your **`/Applications`** folder.
4. Launch **Clippy** from Spotlight (`⌘ Space` > type "Clippy") or your Applications folder.

> [!NOTE]
> **macOS Gatekeeper First-Launch Note**:  
> Because Clippy is open-source and distributed directly without Apple Developer paid notarization, macOS may show: *"Clippy cannot be opened because Apple cannot check it for malicious software"*.
> - **Quick Terminal command**:
>   ```bash
>   xattr -cr /Applications/Clippy.app
>   ```
> - **Or GUI method**: Right-click (Control-click) `Clippy.app` in `/Applications` > click **Open** > click **Open** again on the confirmation alert.

---

### Method 2: Install via Homebrew

```bash
brew install --cask clippy
```

Or via the official tap:
```bash
brew tap pawanbhayde/clippy
brew install clippy
```

---

### Method 3: Build & Package DMG from Source (CLI)

You can compile a production Release binary and package a standalone `.dmg` installer with one command:

#### Prerequisites
- **macOS 14.0 (Sonoma)** or **macOS 15.0+ (Sequoia)**
- **Apple Silicon (M1/M2/M3/M4)** or **Intel Mac**
- **Xcode 15.0+** with Command Line Tools (`xcode-select --install`)

```bash
# 1. Clone the repository
git clone https://github.com/pawanbhayde/clippy.git
cd clippy

# 2. Run the automated Release build and packaging script
chmod +x scripts/build_dmg.sh
./scripts/build_dmg.sh

# 3. Mount DMG and install
open Clippy.dmg
```

Upon completion, `Clippy.dmg` is generated in the project root directory.

---

### Method 4: Build & Run with Xcode (For Contributors)

1. Open `clippy.xcodeproj` in Xcode:
   ```bash
   open clippy.xcodeproj
   ```
2. In the top toolbar, select the **`clippy`** scheme.
3. Choose your destination as **My Mac**.
4. Press **`⌘ B`** to build or **`⌘ R`** to run in Debug mode.
   *(Dependencies like `KeyboardShortcuts` and `LaunchAtLogin-Modern` are managed via Swift Package Manager and resolve automatically).*

---

### 🔑 Essential Post-Installation Permissions

To enable Clippy's core superpower—**Direct Paste Injection** (automatically pasting selected items directly into Xcode, VS Code, Slack, Chrome, or Terminal without extra keystrokes)—macOS requires the Accessibility permission:

1. Open **System Settings** (`⌘ Space` > type "System Settings").
2. Navigate to **Privacy & Security** > **Accessibility**.
3. Toggle the switch next to **Clippy** to **On**.
4. *(Clippy also includes a guided onboarding sheet on first launch with a direct link).*

> [!TIP]
> **Launch at Login**: To have Clippy live in your notch whenever you boot your Mac, open Clippy Preferences (**`⌘ ,`**) and check **Launch at Login**.

---

## 🏛 Architecture & Tech Stack

Clippy is written in 100% native Swift and AppKit/SwiftUI with no bloated web wrappers or heavy electron frameworks.

```
clippy/
├── App/
│   ├── AppDelegate.swift          # Menu bar accessory setup, status bar menu, lifecycle
│   ├── ClipboardService.swift     # Background capture pipeline coordination
│   └── Onboarding/                # First-run permissions & accessibility setup
│
├── Core/
│   ├── Clipboard/
│   │   ├── ClipboardMonitor.swift # Pasteboard polling & changeCount tracking
│   │   ├── ClipboardWriter.swift  # Direct paste injection & active app switching
│   │   └── PasteQueueManager.swift# Sequential paste FIFO pipeline & state
│   ├── Classification/
│   │   ├── ImageTextExtractor.swift # Native Apple Vision OCR (VNRecognizeTextRequest)
│   │   ├── SensitiveDataDetector.swift # API keys, password & OTP regex classification
│   │   ├── ColorDetector.swift    # HEX, RGB, HSL parsing & swatches
│   │   └── CodeDetector.swift     # Programming language syntax recognition
│   ├── Developer/
│   │   ├── ColorTransformations.swift# Format conversions (Swift, NSColor, Compose)
│   │   ├── JSONTransformations.swift # Format, minify, TypeScript interface generation
│   │   └── ConnectionStringTransformations.swift # Database URL parser
│   ├── Merger/
│   │   ├── MergerEngine.swift     # Bullet lists, delimiters, and SQL formatting
│   │   └── DiffEngine.swift       # Myers-based side-by-side & unified diff engine
│   ├── Search/
│   │   ├── SearchEngine.swift     # Operator parser (app:, type:, is:, has:) + fuzzy ranker
│   │   └── SearchIndex.swift      # Inverted text index for instant search
│   ├── Security/
│   │   └── ContentEncryptor.swift # 256-bit AES-GCM + macOS Keychain integration
│   ├── Stash/
│   │   ├── StashManager.swift     # Temporary Drop Zone state & drag coordination
│   │   └── StashItem.swift        # Dragged files, images, and promised items
│   └── System/
│       ├── GlobalShortcut.swift   # Global hotkey binding (⌘⇧V, ⌘⌥V)
│       └── MouseTracker.swift     # Notch hover detection & event monitors
│
└── UI/
    ├── Shelf/
    │   ├── ShelfController.swift  # Expansion lifecycle, geometry, pass-through state
    │   ├── ShelfWindow.swift      # Floating borderless NSPanel with drag destination
    │   ├── NotchShelfShape.swift  # GeometryPath conforming to MacBook camera notch
    │   └── ShelfView.swift        # Dynamic Island SwiftUI view & controls
    ├── Clipboard/
    │   ├── ClipboardGrid.swift    # Multi-selection grid with keyboard navigation
    │   ├── ClipboardCard.swift    # Card rendering, hover actions & context menus
    │   └── ClipboardPreview.swift # Quick Look & expanded detail modal
    ├── Merger/
    │   ├── MergerBar.swift        # Floating action bar for multi-selected items
    │   └── DiffView.swift         # Side-by-side & unified diff comparison viewer
    ├── Stash/
    │   └── DropZoneOverlay.swift  # Dual drop zone visual targets (Stash vs Clippy)
    └── Settings/                  # General, Privacy, Collections, and Storage Preferences
```

---


<div align="center">

Built with ❤️ for macOS power users.

</div>
