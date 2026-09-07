# Clippy — Productivity Features Roadmap & Backlog

This document tracks upcoming unique and high-impact productivity features planned for **Clippy**. Each feature is designed to leverage macOS capabilities, the MacBook notch / Dynamic Island form factor, and keyboard-first workflows.

---

## Feature Tracking Checklist

- [x] **1. Sequential / Queue Paste ("Paste Queue")**
- [x] **2. Smart Scratchpad & Multi-Item Merger ("Combine & Paste")**
- [x] **3. Built-in Image OCR & Text Extractor**
- [ ] **4. Snippet Templates with Dynamic Placeholders**
- [x] **5. Color Inspector & Palette Converter**
- [x] **6. Secret Auto-Masking & Auto-Purge Timer**
- [x] **7. Notch "Drop Zone" / Temporary Stash**
- [x] **8. Search Operators & App Filters**

---

## Detailed Feature Specifications

### 1. ⚡ Sequential / Queue Paste ("Paste Queue")
* **Goal**: Copy multiple items in succession and paste them one-by-one in the exact same order without switching apps repeatedly.
* **Workflow**:
  1. Activate Queue Mode via global shortcut (e.g., `⌘⌥V`) or button in the island.
  2. Copy several pieces of data (e.g., Name, Email, Address, Phone).
  3. Switch to target app/form. Each subsequent `⌘V` paste pops and inserts the next item in line (`1 → 2 → 3 → ...`).
  4. A subtle badge on the notch island indicates remaining queue count (e.g., `3 left`).
* **Implementation Notes**:
  - Maintain an in-memory `QueueStore` or FIFO array.
  - Temporarily hook pasteboard writes on paste trigger to feed next element in queue.

---

### 2. 🪄 Smart Scratchpad & Multi-Item Merger ("Combine & Paste")
* **Goal**: Combine multiple clipboard items without needing a separate text editor.
* **Workflow**:
  - Multi-select items in Clippy Island holding `⌘` or `⇧`.
  - Choose merge action:
    - **Bullet List**: Prefixes each item with `- ` or `* `.
    - **Join with Delimiter**: Comma-separated (great for SQL `IN (...)` or CSVs), newline, or custom delimiter.
    - **Diff Comparison**: Side-by-side or inline diff between two selected clipboard text/code snippets.
* **Implementation Notes**:
  - Add multi-selection state to `ClipboardGrid.swift`.
  - Provide a floating context bar when `selectedIDs.count > 1`.

---

### 3. 🔍 Built-in Image OCR & Text Extractor
* **Goal**: Extract text directly from screenshots, error dialogs, or diagrams instantly.
* **Workflow**:
  - When an image item is saved, asynchronously run macOS Vision framework OCR.
  - An image card displays a small **"Copy Text"** action button.
  - Text is indexed in search, making screenshots searchable by the words inside them!
* **Implementation Notes**:
  - Use Apple's native `VNRecognizeTextRequest` (`Vision.framework` — fast, offline, and zero external dependencies).
  - Store extracted text in `ClipboardItem.extractedText` and index into `SearchEngine`.

---

### 4. 📌 Snippet Templates with Dynamic Placeholders
* **Goal**: Store frequently used templates with variable replacement.
* **Workflow**:
  - Dedicated "Snippets" tab in collections.
  - Templates support dynamic placeholders:
    - `{date}`, `{time}`, `{clipboard}`, `{cursor}`, `{uuid}`.
  - When selected, Clippy dynamically resolves variables and pastes the populated snippet.
* **Implementation Notes**:
  - Add `isSnippet: Bool` and `templateContent: String?` to collection item metadata.

---

### 5. 🎨 Color Inspector & Palette Converter
* **Goal**: Detect color codes in copied text and provide color previews + format conversions.
* **Workflow**:
  - When hex codes (`#6366F1`), `rgb(...)`, or `hsl(...)` are copied, display a color swatch badge on the card.
  - Quick-copy as:
    - Hex (`#6366F1`)
    - CSS `rgb(99, 102, 241)`
    - Swift `Color(red: ..., green: ..., blue: ...)` / `NSColor`
    - Android / Compose `Color(0xFF6366F1)`
* **Implementation Notes**:
  - Leverage existing `ColorDetector.swift` in `Core/Classification`.

---

### 6. 🛡️ Secret Auto-Masking & Auto-Purge Timer
* **Goal**: Prevent sensitive data (passwords, tokens, OTPs) from lingering in clipboard history.
* **Workflow**:
  - **Masking**: Display sensitive items as `••••••••` by default with click-to-reveal.
  - **Auto-Purge**: Automatically delete 2FA OTPs, password-manager copies, and API keys after 60 seconds (or configurable time).
  - Protects against accidental exposure during screen sharing or presentations.
* **Implementation Notes**:
  - Connect with existing `SensitiveDataDetector.swift` and `PrivacyPreferences.swift`.
  - Add expiration timer per item: `scheduledPurgeAt: Date?`.

---

### 7. ⏱️ Notch "Drop Zone" / Temporary Stash
* **Goal**: Drag files or images to the MacBook notch to temporarily hold them across spaces/apps.
* **Workflow**:
  - Dragging any item from Finder, browser, or app to the top-center notch expands a small "Drop Shelf".
  - Drop to hold; switch to target Space or full-screen app; drag out to complete the move.
  - Automatically clears after being dragged out.
* **Implementation Notes**:
  - Enhance `ShelfWindow` and `MouseTracker` to listen for drag-enter events using `NSDraggingDestination`.

---

### 8. 🔎 Search Operators & App Source Filters
* **Goal**: Rapidly pinpoint specific items out of hundreds in history.
* **Syntax**:
  - `app:xcode` or `app:slack` or `app:chrome`
  - `type:image`, `type:text`, `type:code`
  - `is:favorite`, `has:url`, `has:color`
* **Implementation Notes**:
  - Parse query tokens in `SearchEngine.swift` before running fuzzy text matching.
