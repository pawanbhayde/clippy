"use client";

import React, { useState } from "react";
import {
  Combine,
  ScanText,
  Palette,
  Check,
  Copy,
  Sparkles,
  ArrowRight,
} from "lucide-react";

export function FeatureCardsGrid() {
  // Card 1 State (Merger Format)
  const [mergerFormat, setMergerFormat] = useState<"bullet" | "sql" | "csv">("bullet");
  const [copiedMerger, setCopiedMerger] = useState(false);

  // Card 2 State (OCR copy)
  const [copiedOcr, setCopiedOcr] = useState(false);

  // Card 3 State (Color format)
  const [colorFormat, setColorFormat] = useState<"hex" | "swiftui" | "compose">("hex");
  const [copiedColor, setCopiedColor] = useState(false);

  const mergerOutputs = {
    bullet: "- Authentication Token\n- Database Connection\n- API Gateway Host",
    sql: "IN ('Token', 'Database', 'Gateway')",
    csv: "Token, Database, Gateway",
  };

  const colorOutputs = {
    hex: "#6366F1",
    swiftui: "Color(red: 0.388, green: 0.400, blue: 0.945)",
    compose: "Color(0xFF6366F1)",
  };

  const handleCopyMerger = () => {
    navigator.clipboard.writeText(mergerOutputs[mergerFormat]);
    setCopiedMerger(true);
    setTimeout(() => setCopiedMerger(false), 1800);
  };

  const handleCopyColor = () => {
    navigator.clipboard.writeText(colorOutputs[colorFormat]);
    setCopiedColor(true);
    setTimeout(() => setCopiedColor(false), 1800);
  };

  return (
    <section id="features" className="py-16 sm:py-24 relative overflow-hidden">
      <div className="max-w-6xl mx-auto px-6 relative z-10">
        {/* Warm Linen & Parchment Styled Section Container */}
        <div className="rounded-3xl bg-gradient-to-b from-[#F5EFE6] to-[#EFE8DC] p-8 sm:p-14 lg:p-16 border border-[#DDD5C5] shadow-paper-lg relative overflow-hidden">
          {/* Section Heading */}
          <div className="text-center max-w-3xl mx-auto mb-12 sm:mb-16 relative z-10">
            <span className="font-serif italic text-lg sm:text-xl text-[#7A7162] block mb-2">
              Everything your clipboard was missing
            </span>
            <h2 className="font-serif text-4xl sm:text-5xl md:text-6xl text-[#2C2825] font-normal tracking-tight leading-[1.15]">
              Never lose{" "}
              <span className="italic font-serif">a copied thought again</span>
            </h2>
            <p className="mt-4 text-[#635C52] text-base sm:text-lg leading-relaxed max-w-2xl mx-auto">
              Engineered with native AppKit and SwiftUI for zero latency and buttery 120Hz ProMotion responsiveness.
            </p>
          </div>

          {/* 3-Column Feature Cards Grid */}
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6 sm:gap-8 relative z-10">
            {/* ══════════════════════════════════════════════════════════
                CARD 1: Multi-Item Merger & Scratchpad
                ══════════════════════════════════════════════════════════ */}
            <div className="rounded-2xl bg-white p-6 sm:p-7 border border-[#E5DFD4] shadow-paper flex flex-col justify-between hover:shadow-paper-lg transition-all group">
              <div>
                <div className="w-10 h-10 rounded-xl bg-[#F2EDE2] border border-[#DDD5C5] text-[#2C2825] flex items-center justify-center mb-5 group-hover:scale-105 transition-transform">
                  <Combine className="w-5 h-5" />
                </div>

                <div className="text-xs font-mono font-medium text-[#7A7162] uppercase tracking-wider mb-1">
                  Smart Scratchpad
                </div>
                <h3 className="font-serif text-2xl font-bold text-[#2C2825] mb-2.5">
                  Multi-Item Merger
                </h3>
                <p className="text-xs sm:text-sm text-[#5A5348] leading-relaxed mb-6">
                  Select multiple items with ⌘ or ⇧ and combine them instantly into bullet lists, comma-separated values, or SQL expressions without opening a text editor.
                </p>

                {/* Interactive Mini UI */}
                <div className="bg-[#FAF7F2] rounded-xl p-3.5 border border-[#EAE4D9] mb-4">
                  <div className="flex items-center justify-between mb-2">
                    <span className="text-[11px] font-medium text-[#7A7162]">
                      Format Output:
                    </span>
                    <div className="flex gap-1">
                      {(["bullet", "sql", "csv"] as const).map((fmt) => (
                        <button
                          key={fmt}
                          onClick={() => setMergerFormat(fmt)}
                          className={`text-[10px] uppercase font-mono px-2 py-0.5 rounded transition-all ${
                            mergerFormat === fmt
                              ? "bg-[#2C2825] text-[#FAF7F2] font-semibold"
                              : "bg-[#EAE2D2] text-[#635C52] hover:bg-[#DDD5C5]"
                          }`}
                        >
                          {fmt}
                        </button>
                      ))}
                    </div>
                  </div>

                  <pre className="font-mono text-[11px] text-[#2C2825] bg-white p-2.5 rounded-lg border border-[#E0D8CB] whitespace-pre-wrap leading-relaxed">
                    {mergerOutputs[mergerFormat]}
                  </pre>
                </div>
              </div>

              <div className="pt-3 border-t border-[#EAE4D9] flex items-center justify-between">
                <span className="text-[11px] text-[#7A7162]">
                  1-Click Combine & Copy
                </span>
                <button
                  onClick={handleCopyMerger}
                  className="text-xs font-semibold text-[#2C2825] hover:text-black flex items-center gap-1.5 transition-colors"
                >
                  {copiedMerger ? (
                    <>
                      <Check className="w-3.5 h-3.5 text-emerald-700" />
                      <span className="text-emerald-800">Copied!</span>
                    </>
                  ) : (
                    <>
                      <Copy className="w-3.5 h-3.5" />
                      <span>Copy Result</span>
                    </>
                  )}
                </button>
              </div>
            </div>

            {/* ══════════════════════════════════════════════════════════
                CARD 2: Native Apple Vision OCR
                ══════════════════════════════════════════════════════════ */}
            <div className="rounded-2xl bg-white p-6 sm:p-7 border border-[#E5DFD4] shadow-paper flex flex-col justify-between hover:shadow-paper-lg transition-all group">
              <div>
                <div className="w-10 h-10 rounded-xl bg-[#F2EDE2] border border-[#DDD5C5] text-[#2C2825] flex items-center justify-center mb-5 group-hover:scale-105 transition-transform">
                  <ScanText className="w-5 h-5" />
                </div>

                <div className="text-xs font-mono font-medium text-[#7A7162] uppercase tracking-wider mb-1">
                  Offline Vision.framework
                </div>
                <h3 className="font-serif text-2xl font-bold text-[#2C2825] mb-2.5">
                  Searchable Screenshots
                </h3>
                <p className="text-xs sm:text-sm text-[#5A5348] leading-relaxed mb-6">
                  Every screenshot copied to your clipboard is automatically analyzed offline using Apple Vision OCR. Search for text trapped inside any image instantly.
                </p>

                {/* Interactive Mini UI */}
                <div className="bg-[#FAF7F2] rounded-xl p-3.5 border border-[#EAE4D9] mb-4">
                  <div className="flex items-center justify-between mb-2">
                    <span className="text-[11px] font-medium text-[#7A7162] flex items-center gap-1">
                      <Sparkles className="w-3 h-3 text-[#7A7162]" />
                      Extracted Text Stream
                    </span>
                    <span className="text-[9px] font-mono bg-[#EAE2D2] text-[#554E43] px-2 py-0.5 rounded-full">
                      100% Offline
                    </span>
                  </div>

                  <div className="bg-white p-2.5 rounded-lg border border-[#E0D8CB]">
                    <div className="text-[10px] text-[#7A7162] mb-1 font-mono">
                      Query: &quot;auth token&quot; → Found in Screenshot #18
                    </div>
                    <div className="font-mono text-xs text-[#2C2825] bg-[#F7F4EE] px-2 py-1 rounded border border-[#E5DFD4] truncate">
                      Bearer eyJhbGciOiJIUzI1NiIsInR5...
                    </div>
                  </div>
                </div>
              </div>

              <div className="pt-3 border-t border-[#EAE4D9] flex items-center justify-between">
                <span className="text-[11px] text-[#7A7162]">
                  No cloud API calls
                </span>
                <button
                  onClick={() => {
                    navigator.clipboard.writeText(
                      "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
                    );
                    setCopiedOcr(true);
                    setTimeout(() => setCopiedOcr(false), 1800);
                  }}
                  className="text-xs font-semibold text-[#2C2825] hover:text-black flex items-center gap-1.5 transition-colors"
                >
                  {copiedOcr ? (
                    <>
                      <Check className="w-3.5 h-3.5 text-emerald-700" />
                      <span className="text-emerald-800">Copied!</span>
                    </>
                  ) : (
                    <>
                      <Copy className="w-3.5 h-3.5" />
                      <span>Copy Text</span>
                    </>
                  )}
                </button>
              </div>
            </div>

            {/* ══════════════════════════════════════════════════════════
                CARD 3: Live Color Inspector & Dev Utils
                ══════════════════════════════════════════════════════════ */}
            <div className="rounded-2xl bg-white p-6 sm:p-7 border border-[#E5DFD4] shadow-paper flex flex-col justify-between hover:shadow-paper-lg transition-all group">
              <div>
                <div className="w-10 h-10 rounded-xl bg-[#F2EDE2] border border-[#DDD5C5] text-[#2C2825] flex items-center justify-center mb-5 group-hover:scale-105 transition-transform">
                  <Palette className="w-5 h-5" />
                </div>

                <div className="text-xs font-mono font-medium text-[#7A7162] uppercase tracking-wider mb-1">
                  Design & Developer Mode
                </div>
                <h3 className="font-serif text-2xl font-bold text-[#2C2825] mb-2.5">
                  Color Inspector & JSON
                </h3>
                <p className="text-xs sm:text-sm text-[#5A5348] leading-relaxed mb-6">
                  Identifies HEX, RGB, and HSL values with live interactive swatches. Convert instantly to SwiftUI Color, AppKit NSColor, or Jetpack Compose in one click.
                </p>

                {/* Interactive Mini UI */}
                <div className="bg-[#FAF7F2] rounded-xl p-3.5 border border-[#EAE4D9] mb-4">
                  <div className="flex items-center justify-between mb-2">
                    <span className="text-[11px] font-medium text-[#7A7162]">
                      Target Format:
                    </span>
                    <div className="flex gap-1">
                      {(["hex", "swiftui", "compose"] as const).map((fmt) => (
                        <button
                          key={fmt}
                          onClick={() => setColorFormat(fmt)}
                          className={`text-[10px] font-mono px-2 py-0.5 rounded transition-all ${
                            colorFormat === fmt
                              ? "bg-[#2C2825] text-[#FAF7F2] font-semibold"
                              : "bg-[#EAE2D2] text-[#635C52] hover:bg-[#DDD5C5]"
                          }`}
                        >
                          {fmt}
                        </button>
                      ))}
                    </div>
                  </div>

                  <div className="bg-white p-2.5 rounded-lg border border-[#E0D8CB] flex items-center gap-2.5">
                    <div className="w-7 h-7 rounded-md bg-[#6366F1] shadow-xs shrink-0" />
                    <code className="font-mono text-xs text-[#2C2825] truncate">
                      {colorOutputs[colorFormat]}
                    </code>
                  </div>
                </div>
              </div>

              <div className="pt-3 border-t border-[#EAE4D9] flex items-center justify-between">
                <span className="text-[11px] text-[#7A7162]">
                  JSON & DB Parsers
                </span>
                <button
                  onClick={handleCopyColor}
                  className="text-xs font-semibold text-[#2C2825] hover:text-black flex items-center gap-1.5 transition-colors"
                >
                  {copiedColor ? (
                    <>
                      <Check className="w-3.5 h-3.5 text-emerald-700" />
                      <span className="text-emerald-800">Copied!</span>
                    </>
                  ) : (
                    <>
                      <Copy className="w-3.5 h-3.5" />
                      <span>Copy Code</span>
                    </>
                  )}
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
