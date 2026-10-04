"use client";

import React, { useState } from "react";
import Image from "next/image";
import {
  Sparkles,
  ArrowRight,
  CheckCircle2,
  ListOrdered,
  Combine,
  SplitSquareVertical,
  ScanText,
  RotateCcw,
  Check,
  ClipboardList,
} from "lucide-react";

interface QueueItem {
  id: number;
  label: string;
  value: string;
  source: string;
}

const initialQueue: QueueItem[] = [
  { id: 1, label: "Client Name", value: "Alexander Wright", source: "Slack" },
  { id: 2, label: "Email Address", value: "alex@acmecorp.dev", source: "Linear" },
  { id: 3, label: "Billing Account", value: "US-9082-8419", source: "Notion" },
  { id: 4, label: "Purchase Amount", value: "$4,250.00", source: "Stripe" },
];

export function FeatureQueueWorkflow() {
  const [selectedFeature, setSelectedFeature] = useState<number>(0);
  const [queueIndex, setQueueIndex] = useState<number>(1); // 0 is completed, 1 is active

  const handleSimulatePaste = () => {
    if (queueIndex < initialQueue.length - 1) {
      setQueueIndex((prev) => prev + 1);
    } else {
      setQueueIndex(0);
    }
  };

  const handleResetQueue = () => {
    setQueueIndex(0);
  };

  const features = [
    {
      title: "Sequential Queue Paste (Paste Queue)",
      desc: "Tired of copying text, switching apps, pasting, switching back, and repeating 10 times? Press ⌘⌥V to enter Queue Mode, copy your data in sequence, then press ⌘V repeatedly in your destination form.",
      icon: ListOrdered,
      tag: "⌘⌥V Hotkey",
    },
    {
      title: "Smart Scratchpad & Multi-Item Merger",
      desc: "Select multiple copied clips with ⌘/⇧ and instantly join them into formatted bulleted lists, comma-separated values, or SQL IN ('a', 'b') expressions with one click.",
      icon: Combine,
      tag: "Combine & Paste",
    },
    {
      title: "Visual Diff Comparison Engine",
      desc: "Select any two text or code snippets in history to open a side-by-side or unified Myers diff viewer with additions, deletions, line numbers, and patch copying.",
      icon: SplitSquareVertical,
      tag: "Side-by-Side Diff",
    },
    {
      title: "Apple Vision OCR & Searchable Screenshots",
      desc: "Hardware-accelerated offline text recognition. Text inside copied screenshots is recognized instantly, indexed for search, and copyable with a single click.",
      icon: ScanText,
      tag: "Offline Vision API",
    },
  ];

  return (
    <section id="paste-queue" className="py-20 sm:py-28 relative overflow-hidden scroll-mt-24">
      <div className="max-w-6xl mx-auto px-6 relative z-10">
        {/* Section Heading */}
        <div className="text-center max-w-3xl mx-auto mb-16 sm:mb-20">
          <span className="font-serif italic text-lg sm:text-xl text-[#7A7162] block mb-2">
            The end of repetitive context switching
          </span>
          <h2 className="font-serif text-4xl sm:text-5xl md:text-6xl text-[#2C2825] font-normal tracking-tight leading-[1.15]">
            Hours of work,{" "}
            <span className="italic font-serif">done in minutes</span>
          </h2>
          <p className="mt-4 text-[#635C52] text-base sm:text-lg leading-relaxed max-w-2xl mx-auto">
            Every day, knowledge workers waste valuable time flipping between browser tabs, spreadsheets, and IDEs.
            Clippy streamlines repetitive data flows into a seamless, tactile rhythm.
          </p>
        </div>

        {/* Two-Column Split Layout */}
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 lg:gap-12 items-center">
          {/* Left Column: Interactive Feature List */}
          <div className="lg:col-span-5 flex flex-col gap-3.5">
            {features.map((item, idx) => {
              const Icon = item.icon;
              const isActive = selectedFeature === idx;
              return (
                <div
                  key={idx}
                  onClick={() => setSelectedFeature(idx)}
                  className={`p-5 rounded-2xl transition-all cursor-pointer border text-left bg-white ${
                    isActive
                      ? "border-[#2C2825] shadow-paper-lg ring-1 ring-[#2C2825]"
                      : "border-[#E5DFD4] shadow-xs hover:border-[#D0C5B4] hover:shadow-paper"
                  }`}
                >
                  <div className="flex items-start gap-3.5">
                    <div
                      className={`w-9 h-9 rounded-xl flex items-center justify-center shrink-0 transition-colors ${
                        isActive
                          ? "bg-[#2C2825] text-[#FAF7F2]"
                          : "bg-[#F2EDE2] text-[#4A4338]"
                      }`}
                    >
                      <Icon className="w-4 h-4" />
                    </div>

                    <div className="flex-1">
                      <div className="flex items-center justify-between gap-2 mb-1.5">
                        <h3 className="font-serif text-lg font-bold text-[#2C2825]">
                          {item.title}
                        </h3>
                        <span
                          className={`text-[10px] font-mono px-2 py-0.5 rounded-full whitespace-nowrap ${
                            isActive
                              ? "bg-[#2C2825] text-[#FAF7F2]"
                              : "bg-[#EAE2D2] text-[#554E43]"
                          }`}
                        >
                          {item.tag}
                        </span>
                      </div>
                      <p className="text-xs sm:text-sm text-[#5A5348] leading-relaxed">
                        {item.desc}
                      </p>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>

          {/* Right Column: Warm Artistic Desk Card with Floating Queue Simulator */}
          <div className="lg:col-span-7">
            <div className="relative rounded-3xl overflow-hidden border border-[#DDD5C5] shadow-paper-xl bg-[#2A241F]">
              {/* Background Oil Painting */}
              <div className="relative w-full h-[460px] sm:h-[500px]">
                <Image
                  src="/images/sunlit_desk.jpg"
                  alt="Cozy sunlit writer desk"
                  fill
                  className="object-cover opacity-90 filter contrast-95"
                />

                {/* Subtle warm lighting vignette */}
                <div className="absolute inset-0 bg-gradient-to-t from-black/60 via-black/20 to-black/10" />

                {/* Floating Interactive Queue Simulator Card */}
                <div className="absolute inset-x-4 sm:inset-x-8 top-8 bottom-8 flex flex-col justify-between">
                  {/* Top Notch Dynamic Island Capsule */}
                  <div className="mx-auto bg-black/90 text-white px-4 py-2 rounded-full border border-white/20 shadow-2xl flex items-center gap-3 backdrop-blur-xl">
                    <div className="w-2 h-2 rounded-full bg-indigo-400 animate-ping" />
                    <span className="font-mono text-xs text-zinc-300">
                      Clippy Paste Queue:{" "}
                      <span className="text-white font-semibold">
                        {initialQueue.length - queueIndex} remaining
                      </span>
                    </span>
                    <span className="text-[10px] px-2 py-0.5 rounded-full bg-indigo-500/30 text-indigo-300 font-mono">
                      ⌘⌥V
                    </span>
                  </div>

                  {/* Glassmorphic Queue List Card */}
                  <div className="bg-white/95 backdrop-blur-2xl rounded-2xl p-5 sm:p-6 shadow-2xl border border-white/60">
                    <div className="flex items-center justify-between pb-3 mb-3 border-b border-[#EAE4D9]">
                      <div className="flex items-center gap-2">
                        <ClipboardList className="w-4 h-4 text-[#7A7162]" />
                        <span className="font-serif text-base font-semibold text-[#2C2825]">
                          Sequential Form Filler
                        </span>
                      </div>
                      <div className="text-[11px] text-[#7A7162] font-mono">
                        Step {queueIndex + 1} of {initialQueue.length}
                      </div>
                    </div>

                    <div className="space-y-2 mb-4">
                      {initialQueue.map((item, index) => {
                        const isPasted = index < queueIndex;
                        const isCurrent = index === queueIndex;
                        const isPending = index > queueIndex;

                        return (
                          <div
                            key={item.id}
                            className={`p-2.5 rounded-xl transition-all border flex items-center justify-between text-xs ${
                              isCurrent
                                ? "bg-indigo-50/90 border-indigo-300 ring-1 ring-indigo-400/50 shadow-xs"
                                : isPasted
                                ? "bg-[#FAF7F2] border-[#EAE4D9] opacity-75"
                                : "bg-[#FAF7F2]/50 border-dashed border-[#DDD5C5] text-[#8C8373]"
                            }`}
                          >
                            <div className="flex items-center gap-3 min-w-0">
                              <span
                                className={`w-5 h-5 rounded-full flex items-center justify-center text-[10px] font-bold shrink-0 ${
                                  isCurrent
                                    ? "bg-indigo-600 text-white"
                                    : isPasted
                                    ? "bg-emerald-600 text-white"
                                    : "bg-[#EAE2D2] text-[#7A7162]"
                                }`}
                              >
                                {isPasted ? "✓" : index + 1}
                              </span>

                              <div className="truncate">
                                <span className="font-medium text-[#7A7162] mr-2">
                                  {item.label}:
                                </span>
                                <span
                                  className={`font-mono ${
                                    isCurrent
                                      ? "text-indigo-950 font-semibold"
                                      : isPasted
                                      ? "text-[#2C2825] line-through opacity-70"
                                      : "text-[#8C8373]"
                                  }`}
                                >
                                  &quot;{item.value}&quot;
                                </span>
                              </div>
                            </div>

                            <div className="flex items-center gap-2 shrink-0 pl-2">
                              <span className="text-[10px] text-[#8C8373] bg-[#EAE4D9] px-2 py-0.5 rounded-md">
                                {item.source}
                              </span>
                              {isCurrent && (
                                <span className="text-[10px] font-semibold text-indigo-700 bg-indigo-100 px-2 py-0.5 rounded-md flex items-center gap-1 animate-pulse">
                                  Press ⌘V ➔
                                </span>
                              )}
                              {isPasted && (
                                <span className="text-[10px] font-semibold text-emerald-700 bg-emerald-100 px-1.5 py-0.5 rounded-md">
                                  Pasted
                                </span>
                              )}
                            </div>
                          </div>
                        );
                      })}
                    </div>

                    {/* Simulation Controls */}
                    <div className="flex items-center justify-between pt-2 border-t border-[#EAE4D9]">
                      <div className="text-[11px] text-[#7A7162]">
                        {queueIndex === initialQueue.length - 1 ? (
                          <span className="text-emerald-700 font-medium flex items-center gap-1">
                            <CheckCircle2 className="w-3.5 h-3.5" /> All items
                            pasted!
                          </span>
                        ) : (
                          <span>Next keystroke pops the next queued item</span>
                        )}
                      </div>

                      <div className="flex items-center gap-2">
                        <button
                          onClick={handleResetQueue}
                          className="px-2.5 py-1 text-xs text-[#7A7162] hover:text-[#2C2825] transition-colors"
                          title="Reset simulation"
                        >
                          <RotateCcw className="w-3.5 h-3.5" />
                        </button>
                        <button
                          onClick={handleSimulatePaste}
                          className="inline-flex items-center gap-1.5 px-3.5 py-1.5 rounded-full text-xs font-semibold text-[#FAF7F2] bg-[#2C2825] hover:bg-[#181614] shadow-xs hover:shadow-md transition-all"
                        >
                          <span>
                            {queueIndex === initialQueue.length - 1
                              ? "Restart Queue"
                              : "Simulate ⌘V"}
                          </span>
                          <ArrowRight className="w-3 h-3" />
                        </button>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
