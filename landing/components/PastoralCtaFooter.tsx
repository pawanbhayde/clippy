"use client";

import React from "react";
import Image from "next/image";
import {
  ArrowUpRight,
  Heart,
  Command,
  Sparkles,
  Shield,
  Layers,
} from "lucide-react";
import { GithubIcon } from "@/components/Icons";

export function PastoralCtaFooter() {
  return (
    <footer className="relative pt-20 overflow-hidden bg-[#FAF7F2]">
      {/* ══════════════════════════════════════════════════════════════
          FINAL CALL TO ACTION
          ══════════════════════════════════════════════════════════════ */}
      <div className="max-w-4xl mx-auto px-6 text-center relative z-20 mb-16 sm:mb-20">
        <span className="font-serif italic text-xl text-[#7A7162] block mb-2">
          Your Mac display has a notch. Make it work for you.
        </span>

        <h2 className="font-serif text-4xl sm:text-5xl md:text-6xl text-[#2C2825] font-normal tracking-tight leading-[1.15] mb-6">
          Leave clipboard chaos behind. <br />
          <span className="italic font-serif">
            Turn your notch into a superpower.
          </span>
        </h2>

        <p className="text-base sm:text-lg text-[#635C52] max-w-xl mx-auto mb-10 leading-relaxed">
          Free and open-source under the MIT license. Clone the Xcode repository or download releases on GitHub.
        </p>

        {/* Action Buttons */}
        <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
          <a
            href="https://github.com/pawanbhayde/clippy"
            target="_blank"
            rel="noopener noreferrer"
            className="w-full sm:w-auto inline-flex items-center justify-center gap-2.5 px-8 py-3.5 rounded-full text-sm font-semibold text-[#FAF7F2] bg-[#2C2825] hover:bg-[#181614] shadow-md hover:shadow-lg transition-all group"
          >
            <GithubIcon className="w-4 h-4 transition-transform group-hover:scale-110" />
            <span>View on GitHub</span>
            <span className="text-[11px] font-normal text-[#C5BDB0] pl-1.5 border-l border-[#4A453F]">
              ★ 1.4k • Open Source
            </span>
          </a>

          <a
            href="https://github.com/pawanbhayde/clippy/releases"
            target="_blank"
            rel="noopener noreferrer"
            className="w-full sm:w-auto inline-flex items-center justify-center gap-2 px-6 py-3.5 rounded-full text-sm font-medium text-[#2C2825] bg-white border border-[#DDD5C5] hover:bg-[#F2EDE2] transition-all shadow-xs"
          >
            <span>Releases & Changelog</span>
            <ArrowUpRight className="w-3.5 h-3.5 opacity-60" />
          </a>
        </div>
      </div>

      {/* ══════════════════════════════════════════════════════════════
          PASTORAL COUNTRYSIDE PAINTING BANNER
          ══════════════════════════════════════════════════════════════ */}
      <div className="relative w-full h-[360px] sm:h-[460px] md:h-[540px] overflow-hidden">
        {/* Soft vignette gradient blend from top */}
        <div className="absolute inset-x-0 top-0 h-28 bg-gradient-to-b from-[#FAF7F2] via-[#FAF7F2]/70 to-transparent z-10" />

        <Image
          src="/images/pastoral_landscape.jpg"
          alt="Peaceful countryside cottage painting with rolling green hills and wildflowers"
          fill
          className="object-cover object-bottom"
          priority
        />

        {/* Bottom subtle shadow transition to footer */}
        <div className="absolute inset-x-0 bottom-0 h-32 bg-gradient-to-t from-[#1A1816]/95 via-[#1A1816]/60 to-transparent z-10" />
      </div>

      {/* ══════════════════════════════════════════════════════════════
          EDITORIAL FOOTER LINKS (Dark Timber / Charcoal Bottom)
          ══════════════════════════════════════════════════════════════ */}
      <div className="bg-[#1A1816] text-[#A69C8E] pt-12 pb-16 relative z-20">
        <div className="max-w-6xl mx-auto px-6">
          <div className="grid grid-cols-1 md:grid-cols-12 gap-10 pb-12 border-b border-[#2E2A27]">
            {/* Brand column */}
            <div className="md:col-span-4 space-y-4">
              <div className="flex items-center gap-3">
                <div className="relative w-7 h-7 rounded-lg overflow-hidden border border-white/10">
                  <Image
                    src="/icon.png"
                    alt="Clippy"
                    fill
                    className="object-cover"
                  />
                </div>
                <span className="font-serif text-2xl font-bold tracking-tight text-[#FAF7F2]">
                  Clippy
                </span>
              </div>
              <p className="text-xs sm:text-sm text-[#8C8274] leading-relaxed max-w-sm">
                The supercharged Dynamic Island and notch clipboard manager for modern macOS.
                Handcrafted with 100% native Swift, AppKit, and SwiftUI.
              </p>
              <div className="pt-2 text-xs font-mono text-[#A69C8E] flex items-center gap-2">
                <span className="w-2 h-2 rounded-full bg-emerald-400" />
                <span>macOS Sonoma 14+ & Sequoia 15+</span>
              </div>
            </div>

            {/* Links Columns */}
            <div className="md:col-span-8 grid grid-cols-2 sm:grid-cols-3 gap-8">
              {/* Column 1: Features */}
              <div className="space-y-3">
                <h4 className="font-serif text-sm font-semibold uppercase tracking-wider text-[#FAF7F2]">
                  Features
                </h4>
                <ul className="space-y-2 text-xs">
                  <li>
                    <a
                      href="#paste-queue"
                      className="hover:text-white transition-colors"
                    >
                      Sequential Paste Queue
                    </a>
                  </li>
                  <li>
                    <a
                      href="#features"
                      className="hover:text-white transition-colors"
                    >
                      Smart Multi-Item Merger
                    </a>
                  </li>
                  <li>
                    <a
                      href="#features"
                      className="hover:text-white transition-colors"
                    >
                      Visual Diff Engine
                    </a>
                  </li>
                  <li>
                    <a
                      href="#vision-ocr"
                      className="hover:text-white transition-colors"
                    >
                      Apple Vision OCR
                    </a>
                  </li>
                  <li>
                    <a
                      href="#features"
                      className="hover:text-white transition-colors"
                    >
                      Color Inspector (HEX, RGB)
                    </a>
                  </li>
                  <li>
                    <a
                      href="#security"
                      className="hover:text-white transition-colors"
                    >
                      Notch Drop Zone & Stash
                    </a>
                  </li>
                </ul>
              </div>

              {/* Column 2: Open Source */}
              <div className="space-y-3">
                <h4 className="font-serif text-sm font-semibold uppercase tracking-wider text-[#FAF7F2]">
                  Open Source
                </h4>
                <ul className="space-y-2 text-xs">
                  <li>
                    <a
                      href="https://github.com/pawanbhayde/clippy"
                      target="_blank"
                      rel="noopener noreferrer"
                      className="hover:text-white transition-colors flex items-center gap-1"
                    >
                      <span>GitHub Repository</span>
                      <ArrowUpRight className="w-3 h-3 opacity-60" />
                    </a>
                  </li>
                  <li>
                    <a
                      href="https://github.com/pawanbhayde/clippy/releases"
                      target="_blank"
                      rel="noopener noreferrer"
                      className="hover:text-white transition-colors"
                    >
                      Releases & DMG
                    </a>
                  </li>
                  <li>
                    <a
                      href="https://github.com/pawanbhayde/clippy/blob/main/CONTRIBUTING.md"
                      target="_blank"
                      rel="noopener noreferrer"
                      className="hover:text-white transition-colors"
                    >
                      Contributing Guide
                    </a>
                  </li>
                  <li>
                    <a
                      href="https://github.com/pawanbhayde/clippy/blob/main/LICENSE"
                      target="_blank"
                      rel="noopener noreferrer"
                      className="hover:text-white transition-colors"
                    >
                      MIT License
                    </a>
                  </li>
                  <li>
                    <a
                      href="https://github.com/pawanbhayde/clippy/issues"
                      target="_blank"
                      rel="noopener noreferrer"
                      className="hover:text-white transition-colors"
                    >
                      Report an Issue
                    </a>
                  </li>
                </ul>
              </div>

              {/* Column 3: Shortcuts & Specs */}
              <div className="space-y-3">
                <h4 className="font-serif text-sm font-semibold uppercase tracking-wider text-[#FAF7F2]">
                  Shortcuts
                </h4>
                <ul className="space-y-2 text-xs font-mono">
                  <li className="flex items-center justify-between">
                    <span className="text-[#8C8274]">Toggle Shelf</span>
                    <span className="bg-[#2A2623] px-1.5 py-0.5 rounded text-white text-[11px]">
                      ⌘ ⇧ V
                    </span>
                  </li>
                  <li className="flex items-center justify-between">
                    <span className="text-[#8C8274]">Paste Queue</span>
                    <span className="bg-[#2A2623] px-1.5 py-0.5 rounded text-white text-[11px]">
                      ⌘ ⌥ V
                    </span>
                  </li>
                  <li className="flex items-center justify-between">
                    <span className="text-[#8C8274]">Direct Paste</span>
                    <span className="bg-[#2A2623] px-1.5 py-0.5 rounded text-white text-[11px]">
                      ⏎
                    </span>
                  </li>
                  <li className="flex items-center justify-between">
                    <span className="text-[#8C8274]">Multi-Select</span>
                    <span className="bg-[#2A2623] px-1.5 py-0.5 rounded text-white text-[11px]">
                      ⌘ Click
                    </span>
                  </li>
                  <li className="flex items-center justify-between">
                    <span className="text-[#8C8274]">Quick Look</span>
                    <span className="bg-[#2A2623] px-1.5 py-0.5 rounded text-white text-[11px]">
                      Space
                    </span>
                  </li>
                </ul>
              </div>
            </div>
          </div>

          {/* Bottom Copyright & Guarantee */}
          <div className="pt-8 flex flex-col sm:flex-row items-center justify-between gap-4 text-xs text-[#7A7165]">
            <div className="flex items-center gap-2">
              <span>© {new Date().getFullYear()} Clippy. Free & Open Source under MIT.</span>
            </div>

            <div className="flex items-center gap-6">
              <span className="flex items-center gap-1.5 text-emerald-400">
                <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse" />
                Zero Telemetry Verified
              </span>
              <a
                href="https://github.com/pawanbhayde/clippy"
                target="_blank"
                rel="noopener noreferrer"
                className="hover:text-white transition-colors"
              >
                GitHub
              </a>
              <a
                href="https://github.com/pawanbhayde/clippy/blob/main/LICENSE"
                target="_blank"
                rel="noopener noreferrer"
                className="hover:text-white transition-colors"
              >
                MIT License
              </a>
            </div>
          </div>
        </div>
      </div>
    </footer>
  );
}
