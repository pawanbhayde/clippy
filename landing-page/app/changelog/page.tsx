import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import FloatingChatButton from "@/components/FloatingChatButton";
import Image from "next/image";

export const metadata = {
  title: "Changelogs - Clippy",
  description: "Read the latest release notes, updates, and improvements for Clippy.",
};

export default function ChangelogPage() {
  return (
    <div className="min-h-screen bg-background text-foreground antialiased selection:bg-emerald-500/20 selection:text-emerald-400 flex flex-col justify-between">
      <div>
        <Navbar />

        <main className="mx-auto max-w-5xl px-6 pt-16 pb-24 sm:px-8 lg:px-12">
          {/* Main Title */}
          <div className="mb-14 sm:mb-20 pt-6">
            <h1 className="font-display text-4xl sm:text-5xl font-medium tracking-tight text-white">
              Changelogs
            </h1>
          </div>

          {/* Changelog Entries List */}
          <div className="divide-y divide-zinc-800/80">
            {/* Entry 1: August 6, 2025 (Exact matching user UI) */}
            <article className="grid grid-cols-1 md:grid-cols-[180px_1fr] gap-6 md:gap-12 pb-20 pt-2">
              {/* Left Column: Date */}
              <div className="text-sm font-normal text-zinc-400 select-none">
                August 6, 2025
              </div>

              {/* Right Column: Content */}
              <div className="space-y-6">
                {/* Main Headline */}
                <h2 className="text-2xl sm:text-3xl font-semibold text-white tracking-tight leading-tight">
                  Clippy is now available for iOS/Android!
                </h2>

                {/* Download links with arrow */}
                <div className="space-y-1.5 pt-1">
                  <div>
                    <a
                      href="#"
                      className="inline-flex items-center gap-1 text-sm text-zinc-300 underline underline-offset-4 hover:text-white transition-colors"
                    >
                      <span>Download on iOS/iPadOS</span>
                      <span className="text-xs no-underline">↗</span>
                    </a>
                  </div>
                  <div>
                    <a
                      href="#"
                      className="inline-flex items-center gap-1 text-sm text-zinc-300 underline underline-offset-4 hover:text-white transition-colors"
                    >
                      <span>Download on Android</span>
                      <span className="text-xs no-underline">↗</span>
                    </a>
                  </div>
                </div>

                {/* Section Subheading */}
                <h3 className="text-lg sm:text-xl font-semibold text-white tracking-tight pt-2">
                  Clippy mobile app, out now!
                </h3>

                {/* Mobile Preview Mockup Graphic */}
                <div className="relative overflow-hidden rounded-2xl border border-white/10 max-w-xl shadow-2xl bg-zinc-950">
                  <img
                    src="/images/changelog-mobile.png"
                    alt="Clippy Mobile App"
                    className="w-full h-auto object-cover"
                  />
                </div>

                {/* Feature Description */}
                <div className="space-y-4 pt-4 max-w-2xl">
                  <h4 className="text-base sm:text-lg font-semibold text-white tracking-tight">
                    Tap and Record
                  </h4>
                  <p className="text-sm sm:text-[15px] leading-relaxed text-zinc-300">
                    Start recording your meetings quickly and easily with Clippy mobile app. Just like on desktop, you can view transcripts and translations in real time. We also crafted the app lightweight and stable, so it&apos;s perfect for mobile use.
                  </p>
                  <p className="text-sm sm:text-[15px] leading-relaxed text-zinc-300">
                    Pro tip: Use Clippy Widget. With a simple tap, you can start recording from your home screen. Give it a try ;)
                  </p>
                </div>
              </div>
            </article>

            {/* Entry 2: July 15, 2025 */}
            <article className="grid grid-cols-1 md:grid-cols-[180px_1fr] gap-6 md:gap-12 py-16">
              <div className="text-sm font-normal text-zinc-400 select-none">
                July 15, 2025
              </div>
              <div className="space-y-4 max-w-2xl">
                <h2 className="text-2xl font-semibold text-white tracking-tight">
                  Dynamic Island Notch Shelf 2.0 &amp; Sequential Queue Paste
                </h2>
                <p className="text-sm sm:text-[15px] leading-relaxed text-zinc-300">
                  Introducing the all-new Dynamic Island expansion for MacBook camera notches. Hover or drag any file to the top of your screen to reveal a suspended productivity shelf. Multi-item sequential queue paste now supports FIFO ordering across all native macOS apps.
                </p>
              </div>
            </article>

            {/* Entry 3: June 22, 2025 */}
            <article className="grid grid-cols-1 md:grid-cols-[180px_1fr] gap-6 md:gap-12 py-16">
              <div className="text-sm font-normal text-zinc-400 select-none">
                June 22, 2025
              </div>
              <div className="space-y-4 max-w-2xl">
                <h2 className="text-2xl font-semibold text-white tracking-tight">
                  Screen Share Invisibility Shield &amp; Local OCR
                </h2>
                <p className="text-sm sm:text-[15px] leading-relaxed text-zinc-300">
                  Never worry about sensitive clips appearing on screen shares again. Clippy automatically detects Zoom, Meet, and Teams window sharing and renders all overlays invisible to meeting participants while keeping them crystal clear on your private display.
                </p>
              </div>
            </article>
          </div>
        </main>
      </div>

      <Footer />
      <FloatingChatButton />
    </div>
  );
}
