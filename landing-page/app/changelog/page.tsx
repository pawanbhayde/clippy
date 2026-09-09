import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import FloatingChatButton from "@/components/FloatingChatButton";

export const metadata = {
  title: "Changelogs - Clippy",
  description: "Read the latest release notes, updates, and improvements for Clippy.",
};

interface ChangelogHighlight {
  title: string;
  description: string;
}

interface ChangelogEntry {
  version: string;
  isLatest?: boolean;
  date: string;
  title: string;
  description: string;
  highlights?: ChangelogHighlight[];
  image?: string;
  downloadLinks?: { label: string; href: string }[];
}

const changelogEntries: ChangelogEntry[] = [
  {
    version: "v1.4.0",
    isLatest: true,
    date: "September 7, 2026",
    title: "Google Gemini AI Text Studio (BYOK) & Dynamic Island Copy Toast",
    description:
      "Supercharge your clipboard with frontier AI. Clippy now integrates directly with Google Gemini through Bring-Your-Own-Key (BYOK) architecture, featuring an expandable floating studio panel beneath the camera notch and a native Dynamic Island copy toast.",
    highlights: [
      {
        title: "Google Gemini LLM Integration (BYOK)",
        description:
          "Connect your Google AI Studio API key to perform intelligent rewrites, tone conversions, proofreading, and summarization with zero cloud lock-in.",
      },
      {
        title: "Active Model Switcher & Creativity Tuning",
        description:
          "Seamlessly toggle between Gemini 2.5 Flash, 2.5 Pro, 2.0 Flash, 1.5 Flash, and 1.5 Pro with fine-grained temperature sliders in Settings.",
      },
      {
        title: "Floating Writing Studio & One-Click Chips",
        description:
          "Right-click any text card to launch the floating studio directly below the notch. Transform clips in one click (Proofread, Concise, Friendly, Professional, Summary, Key Points, List, Table) or enter custom prompt instructions.",
      },
      {
        title: "Dynamic Island Copy Toast Pill",
        description:
          "Native notification pill animation that pulses at the MacBook camera notch whenever items are copied to the system clipboard.",
      },
      {
        title: "Direct Paste Routing Safeguard",
        description:
          "Enhanced event tap and PID-targeted keystroke simulation to ensure pasted clips route directly to the frontmost application text field.",
      },
    ],
  },
  {
    version: "v1.3.0",
    date: "September 6, 2026",
    title: "Interactive Screenshot Capture Tool & Notch HUD",
    description:
      "Capture screen regions with an interactive crosshair HUD that feeds screenshots directly into your clipboard shelf without cluttering your desktop.",
    highlights: [
      {
        title: "Crosshair Screenshot HUD",
        description:
          "Global shortcut triggers an interactive selection overlay with real-time dimension badges, loupe magnification, and instant capture.",
      },
      {
        title: "Instant Shelf Ingestion",
        description:
          "Captured clips automatically populate the Dynamic Island shelf with instant thumbnail previews, ready for pasting or dragging into any app.",
      },
      {
        title: "Global Hotkey Integration",
        description:
          "Configurable global hotkeys to trigger instant region screenshots or toggle the shelf from any workspace without switching context.",
      },
    ],
  },
  {
    version: "v1.2.0",
    date: "September 5, 2026",
    title: "Drag-and-Drop Stash Manager & Fluid Notch Physics",
    description:
      "Transform your MacBook camera notch into a physical drop target for multi-item workflows, coupled with redesigned spring physics and our official landing page.",
    highlights: [
      {
        title: "Drag-and-Drop Stash Shelf",
        description:
          "Drag files, images, and text directly into the camera notch to hold them in a temporary Stash shelf for batch-dragging and sequential distribution.",
      },
      {
        title: "Advanced Search Operators",
        description:
          "Filter clipboard history with type prefixes (type:image, type:url, type:code), date ranges, and pinned favorites with sub-millisecond query execution.",
      },
      {
        title: "Fluid Spring Notch Physics",
        description:
          "Re-engineered spring curve animations with responsive hover-tracking for seamless expansion and collapse along the MacBook notch bezel.",
      },
      {
        title: "Official Product Landing Page",
        description:
          "Launched the official Clippy web showcase with interactive feature tours, documentation, and live changelogs.",
      },
    ],
  },
  {
    version: "v1.1.0",
    date: "September 4, 2026",
    title: "Privacy Shield, Auto-Purge & On-Device Vision OCR",
    description:
      "Enterprise-grade privacy protections and hardware-accelerated computer vision to keep your clipboard secure, clean, and searchable.",
    highlights: [
      {
        title: "Automatic Secret Masking",
        description:
          "Real-time regex engine detects and obfuscates passwords, API tokens, JWTs, private SSH keys, and credit card numbers in the shelf UI.",
      },
      {
        title: "Time-Based Auto-Purge",
        description:
          "Automatically wipes sensitive clipboard entries after a configurable duration (5m, 15m, 1h) to prevent secret leakage.",
      },
      {
        title: "On-Device Apple Vision OCR",
        description:
          "Extracts and indexes text from copied screenshots and photos locally using Apple Silicon Neural Engine without sending data off-device.",
      },
      {
        title: "Color Palette Inspector",
        description:
          "Automatically detects Hex, RGB, and HSL color values with interactive swatch previews and one-click format conversion.",
      },
      {
        title: "ProMotion ImageCache",
        description:
          "Background downsampling and asynchronous caching engine ensures silky smooth 120Hz ProMotion scrolling.",
      },
    ],
  },
  {
    version: "v1.0.0",
    date: "September 4, 2026",
    title: "Clippy Initial Release: The Dynamic Island Notch Clipboard",
    description:
      "The initial public release of Clippy — turning the MacBook camera notch into an intelligent productivity shelf for clipboard history and sequential paste management.",
    highlights: [
      {
        title: "MacBook Camera Notch Shelf",
        description:
          "Hover over or click the camera notch to expand a native, frosted-glass clipboard shelf directly from the top screen bezel.",
      },
      {
        title: "Direct Paste into Any App",
        description:
          "Simulated keystrokes paste chosen clips instantly into active text fields in Chrome, Slack, Notes, TextEdit, Xcode, and Terminal.",
      },
      {
        title: "Favorites & Star Pinning",
        description:
          "Star frequently used clips, boilerplate, and code snippets for permanent, quick-access placement.",
      },
      {
        title: "Multi-Format Clipboard Engine",
        description:
          "First-class storage for rich text, plain text, PNG/TIFF images, URLs, and file objects with automatic deduplication.",
      },
    ],
  },
  {
    version: "Mobile Companion",
    date: "August 6, 2025",
    title: "Clippy is now available for iOS/Android!",
    description:
      "Start recording your meetings quickly and easily with the Clippy mobile app. View transcripts, live translations, and sync snippets seamlessly across all your devices.",
    image: "/images/changelog-mobile.png",
    downloadLinks: [
      { label: "Download on iOS/iPadOS", href: "#" },
      { label: "Download on Android", href: "#" },
    ],
    highlights: [
      {
        title: "Tap and Record",
        description:
          "Start recording meetings quickly and easily with Clippy mobile app. Just like on desktop, you can view transcripts and translations in real time. We crafted the app lightweight and stable for mobile use.",
      },
      {
        title: "Home Screen Widget",
        description:
          "With a simple tap on the Clippy widget, start recording or access your latest clips directly from your mobile home screen.",
      },
    ],
  },
];

export default function ChangelogPage() {
  return (
    <div className="min-h-screen bg-background text-foreground antialiased selection:bg-emerald-500/20 selection:text-emerald-400 flex flex-col justify-between">
      <div className="w-full">
        <Navbar />

        <main className="mx-auto w-full max-w-7xl px-6 pt-28 pb-32 sm:px-8">
          {/* Header Section */}
          <header className="mb-20 pt-6 text-center">
            <div className="inline-flex mb-2 items-center gap-2 px-3 py-1 rounded-full bg-zinc-900/90 border border-zinc-800 text-xs font-medium text-zinc-400 mb-5 shadow-xs">
              <span className="size-1.5 rounded-full bg-emerald-400" />
              What&apos;s New in Clippy
            </div>
            <h1 className="font-display text-4xl sm:text-5xl lg:text-6xl font-semibold tracking-tight text-white mb-4">
              Changelogs
            </h1>
            <p className="text-zinc-400 text-base sm:text-lg max-w-lg mx-auto leading-relaxed">
              Read the latest release notes, updates, and improvements for Clippy.
            </p>
          </header>

          {/* Changelog Entries List */}
          <div className="divide-y divide-zinc-800/70 border-t border-zinc-800/70">
            {changelogEntries.map((entry, idx) => (
              <article
                key={entry.version + idx}
                className="py-16 sm:py-20 first:pt-12"
              >
                {/* Meta Row: Version Pill & Date */}
                <div className="flex flex-wrap items-center gap-3 mb-5">
                  {entry.isLatest ? (
                    <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-semibold bg-emerald-500/10 text-emerald-400 border border-emerald-500/25 font-mono tracking-wide">
                      <span className="size-1.5 rounded-full bg-emerald-400 animate-pulse" />
                      {entry.version} · Latest
                    </span>
                  ) : (
                    <span className="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium bg-zinc-800/90 text-zinc-300 border border-zinc-700/60 font-mono">
                      {entry.version}
                    </span>
                  )}
                  <span className="text-zinc-700 text-xs">/</span>
                  <time className="text-sm font-medium text-zinc-400 select-none">
                    {entry.date}
                  </time>
                </div>

                {/* Main Headline */}
                <h2 className="text-2xl sm:text-3xl font-semibold text-white tracking-tight leading-snug mb-4">
                  {entry.title}
                </h2>

                {/* Summary Paragraph */}
                <p className="text-base leading-relaxed text-zinc-300 font-normal mb-6">
                  {entry.description}
                </p>

                {/* Optional Download links */}
                {entry.downloadLinks && entry.downloadLinks.length > 0 && (
                  <div className="flex flex-wrap items-center gap-3 my-6">
                    {entry.downloadLinks.map((link) => (
                      <a
                        key={link.label}
                        href={link.href}
                        className="inline-flex items-center gap-2 text-sm font-medium text-zinc-200 px-4 py-2 rounded-xl bg-zinc-900 border border-zinc-800 hover:border-zinc-700 hover:text-white transition-all shadow-xs"
                      >
                        <span>{link.label}</span>
                        <span className="text-xs text-zinc-500">↗</span>
                      </a>
                    ))}
                  </div>
                )}

                {/* Optional Graphic Mockup */}
                {entry.image && (
                  <div className="relative overflow-hidden rounded-2xl border border-white/10 w-full shadow-2xl bg-zinc-950 my-8">
                    <img
                      src={entry.image}
                      alt={entry.title}
                      className="w-full h-auto object-cover"
                    />
                  </div>
                )}

                {/* Highlights List - Editorial Typography */}
                {entry.highlights && entry.highlights.length > 0 && (
                  <div className="space-y-4 mt-8 pt-6 border-t border-zinc-800/50">
                    <h3 className="text-xs font-mono font-semibold tracking-wider text-zinc-400 uppercase">
                      Highlights &amp; Fixes
                    </h3>
                    <ul className="space-y-3.5 text-sm sm:text-[15px]">
                      {entry.highlights.map((h) => (
                        <li key={h.title} className="flex items-start gap-3">
                          <span className="mt-2 size-1.5 rounded-full bg-emerald-400 shrink-0" />
                          <div className="leading-relaxed text-zinc-300">
                            <strong className="text-white font-medium">
                              {h.title}:{" "}
                            </strong>
                            <span>{h.description}</span>
                          </div>
                        </li>
                      ))}
                    </ul>
                  </div>
                )}
              </article>
            ))}
          </div>
        </main>
      </div>

      <Footer />
      <FloatingChatButton />
    </div>
  );
}
