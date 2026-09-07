# Clippy — Apple Native Features Roadmap & Backlog

This document outlines upcoming high-impact features planned for **Clippy**, leveraging **strictly Apple Native macOS frameworks and APIs**. Every feature is designed to be **100% on-device, private, offline-first, and zero-dependency**, with no external cloud services, API keys, or third-party runtimes required.

> [!IMPORTANT]
> ### 🎨 Card Minimalism & Context Menu Standard
> To preserve Clippy's signature Apple-grade aesthetics and avoid visual clutter:
> - **Zero On-Card Chips**: No chips, badges, or floating utility buttons are rendered directly on clipboard cards.
> - **Hover State Rule**: On card hover, **ONLY** the **Queue Mode (`+` / `✓`) button** and the **Favorite Star button** are displayed in the top-right corner.
> - **Right-Click Context Menu Only**: All feature capabilities (Writing Tools, Translation, Smart Data Detectors, QR Code decoding, Linguistic Analysis, Read Aloud, Color Formats, JSON utilities, OCR) are accessed exclusively via the **Right-Click Context Menu (`.contextMenu`)**.

---

## 🎯 Feature Tracking Checklist

- [x] **1. Apple Intelligence Writing Tools Integration (`NSWritingsToolsCoordinator`)**
- [ ] **2. On-Device Translation Engine (`Translation.framework`)**
- [ ] **3. Smart Data Detectors & Live Actions (`NSDataDetector` + `EventKit` / `MapKit`)**
- [ ] **4. Apple Quick Look Full-Fidelity Preview (`QuickLookUI` / `QLPreviewPanel`)**
- [ ] **5. QR Code & Barcode Intelligence (`Vision.framework`)**
- [ ] **6. Natural Language Linguistic & Sentiment Analysis (`NaturalLanguage.framework`)**
- [ ] **7. Siri Voice Speech Synthesis ("Read Aloud") (`AVSpeechSynthesizer`)**
- [ ] **8. Dynamic Snippet Templates with Native Placeholders**
- [ ] **9. Universal Clipboard & Continuity Device Badging (`NSPasteboard`)**
- [ ] **10. Native macOS Shortcuts & Siri App Intents (`AppIntents.framework`)**

---

## ⚡ Detailed Feature Specifications

### 1. ✍️ Apple Intelligence Writing Tools Integration
* **Apple Framework**: `AppKit` (`NSWritingsToolsCoordinator`, `NSWritingsToolsCoordinator.Context`, macOS 15.1+)
* **Goal**: Provide native, on-device Apple Intelligence text rewriting, proofreading, and summarization directly inside Clippy without external LLMs or API keys.
* **Workflow**:
  - **Right-click** any text card → select **"Apple Writing Tools..."**.
  - A compact notch scratchpad sheet opens displaying the text.
  - The native macOS Apple Intelligence panel activates instantly:
    - **Proofread**: One-click grammar, punctuation, and phrasing fixes.
    - **Rewrite**: Adjust tone to **Friendly**, **Professional**, or **Concise**.
    - **Transform**: Convert text into a **Summary**, **Key Points**, **List**, or **Table**.
  - The refined text is immediately saved back to Clippy and can be directly pasted into the active application.
* **Privacy & Architecture**: Runs 100% locally on Apple Silicon Neural Engine (NPU); zero data leaves the Mac.

---

### 2. 🌐 On-Device Translation Engine
* **Apple Framework**: `Translation.framework` (macOS 14.4+) + `NaturalLanguage.framework`
* **Goal**: Instant offline translation of copied foreign text without cluttering cards with chips.
* **Workflow**:
  - `NLLanguageRecognizer` automatically detects the language in the background.
  - If foreign text is detected, **Right-click** the card → select **"Translate to [System Language]"**.
  - Translates text instantly using Apple's pre-installed system language models.
  - A modal or sub-menu provides:
    - **Copy Translated Text**
    - **Paste Translated Text Directly**
    - **View Original vs. Translated Comparison**
* **Privacy & Architecture**: Fully offline using Apple's downloaded system translation packs; zero external APIs.

---

### 3. 📅 Smart Data Detectors & Live Actions
* **Apple Framework**: `Foundation` (`NSDataDetector`) + `EventKit` + `MapKit`
* **Goal**: Detect actionable entities in copied snippets and provide instant macOS system actions via right-click.
* **Workflow**:
  - Asynchronously runs `NSDataDetector` on clipboard items.
  - **Right-click** reveals contextual action items based on detected data:
    - **Dates & Times**: `📅 Add to Calendar...` / `⏰ Create Reminder...`
    - **Physical Addresses**: `🗺️ Open in Apple Maps` / `Directions to...`
    - **Phone Numbers**: `📞 Call with iPhone` / `FaceTime Audio`
    - **Flight Numbers**: `✈️ View Flight Status` (native macOS live flight card)
    - **Tracking Numbers**: `📦 Track Package` (FedEx, UPS, USPS, DHL)
* **Privacy & Architecture**: Pure native pattern matching with local system deep links.

---

### 4. 👁️ Apple Quick Look Full-Fidelity Preview
* **Apple Framework**: `QuickLookUI` (`QLPreviewPanel`, `QLPreviewItem`)
* **Goal**: Inspect any clipboard item in full detail using the standard macOS Spacebar gesture or right-click.
* **Workflow**:
  - Select any card and press **`Spacebar`** (or **Right-click → "Quick Look Preview"**).
  - A native Apple Quick Look window pops up showing:
    - High-resolution images and vector graphics.
    - Full PDF documents with multi-page navigation.
    - Syntax-highlighted source code files and formatted Markdown.
    - Audio recordings and video clips with native scrubbers.
  - Pressing `Spacebar` or `Esc` dismisses the preview instantly.
* **Privacy & Architecture**: Native AppKit `QLPreviewPanel` sharing macOS's built-in QuickLook daemon.

---

### 5. 📷 QR Code & Barcode Intelligence
* **Apple Framework**: `Vision.framework` (`VNDetectBarcodesRequest`)
* **Goal**: Automatically scan copied images and screenshots for QR codes and barcodes without on-card chips.
* **Workflow**:
  - Scans image items in the background using `VNDetectBarcodesRequest`.
  - When a QR code or barcode is present, **Right-click** the image card:
    - `🔗 Open Decoded Link` (if a URL)
    - `📋 Copy Decoded Content`
    - `📶 Join Wi-Fi Network` (if Wi-Fi QR code)
* **Privacy & Architecture**: Hardware-accelerated Apple Vision processing in <10ms.

---

### 6. 🧠 Natural Language Linguistic & Sentiment Analysis
* **Apple Framework**: `NaturalLanguage.framework` (`NLTagger`, `NLTokenizer`, `NLLanguageRecognizer`)
* **Goal**: Provide writers, editors, and developers with linguistic statistics and insights.
* **Workflow**:
  - **Right-click** any text card → select **"Text Insights & Statistics"**.
  - Displays a clean native popover with:
    - **Metrics**: Word count, character count, sentence count, reading time (e.g. `1 min read`).
    - **Tone / Sentiment**: Positive, Neutral, or Negative sentiment score.
    - **Named Entities**: People, Organizations, and Locations mentioned.
* **Privacy & Architecture**: Apple's native NaturalLanguage engine running entirely on CPU/ANE.

---

### 7. 🔊 Siri Voice Speech Synthesis ("Read Aloud")
* **Apple Framework**: `AVFoundation` (`AVSpeechSynthesizer`, `AVSpeechUtterance`)
* **Goal**: Listen to copied articles, documentation, or messages using high-fidelity Siri voices.
* **Workflow**:
  - **Right-click** any text card → select **"Read Aloud (Siri Voice)"**.
  - Audio playback starts using high-quality system voices (`AVSpeechSynthesisVoice`).
  - Right-click menu updates to include `Pause`, `Resume`, `Stop`, and `Speed (1.0x / 1.5x / 2.0x)`.
* **Privacy & Architecture**: Built-in macOS speech synthesis engine with zero cloud latency.

---

### 8. 📌 Dynamic Snippet Templates with Native Placeholders
* **Apple Framework**: `Foundation` (`DateFormatter`, `Locale`, `ProcessInfo`)
* **Goal**: Store frequently used canned messages, code boilerplate, and email replies with dynamic variable replacement.
* **Workflow**:
  - Dedicated "Snippets" tab in Clippy's collection bar.
  - Templates support built-in Apple dynamic tokens:
    - `{date}`: Current date formatted in user's system locale (e.g. `September 7, 2026`).
    - `{time}`: Current system time.
    - `{clipboard}`: Injects whatever is currently on the pasteboard.
    - `{uuid}`: Generates a fresh UUID v4.
    - `{current_app}`: Inserts the name of the frontmost application.
    - `{user}`: Current macOS user's full name or username.
  - Selecting a template automatically evaluates the placeholders and pastes the populated result.
* **Privacy & Architecture**: Evaluated locally via standard Foundation formatters.

---

### 9. 📱 Universal Clipboard & Continuity Device Badging
* **Apple Framework**: `AppKit` (`NSPasteboard`, `NSPasteboardItem`)
* **Goal**: Distinguish between items copied on the current Mac and items copied on an iPhone, iPad, or secondary Mac.
* **Workflow**:
  - Detect Apple Continuity Universal Clipboard metadata on incoming pasteboard items.
  - Display a subtle device badge on the card (e.g. `📱 iPhone`, `📱 iPad`, or `💻 Remote Mac`) alongside the timestamp.
  - Filter history specifically by device (e.g. `is:continuity` or `from:iphone`).
* **Privacy & Architecture**: Reads standard Apple pasteboard continuity metadata flags.

---

### 10. ⚡ Native macOS Shortcuts & Siri App Intents
* **Apple Framework**: `AppIntents.framework`
* **Goal**: Deep system automation enabling users to control Clippy through the macOS Shortcuts app, Siri, Raycast, and Alfred.
* **Workflow**:
  - Provide built-in Shortcuts actions:
    - **"Get Latest Clippy Item"**: Returns the most recent clipboard entry.
    - **"Add to Clippy Stash"**: Sends files/text into the notch drop zone.
    - **"Paste Next in Queue"**: Advances the sequential paste queue programmatically.
    - **"Clear History (Keep Favorites)"**: Triggers automated privacy cleaning.
* **Privacy & Architecture**: Native macOS AppIntents integration conforming to Apple's modern automation standards.
