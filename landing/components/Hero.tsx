"use client";

import React, { useState, useRef, useEffect } from "react";
import {
  Terminal,
  Check,
  Copy,
  ExternalLink,
  Volume2,
  VolumeX,
  Play,
  Pause,
  RotateCcw,
} from "lucide-react";
import { AppleIcon, GithubIcon } from "@/components/Icons";

export function Hero() {
  const [copiedBrew, setCopiedBrew] = useState(false);
  const [isMuted, setIsMuted] = useState(true);
  const [isPlaying, setIsPlaying] = useState(true);
  const videoRef = useRef<HTMLVideoElement>(null);

  const handleCopyBrew = () => {
    navigator.clipboard.writeText("brew install clippy");
    setCopiedBrew(true);
    setTimeout(() => setCopiedBrew(false), 2000);
  };

  const toggleSound = () => {
    if (videoRef.current) {
      const nextMuted = !videoRef.current.muted;
      videoRef.current.muted = nextMuted;
      setIsMuted(nextMuted);
    }
  };

  const togglePlay = () => {
    if (videoRef.current) {
      if (videoRef.current.paused) {
        videoRef.current.play();
        setIsPlaying(true);
      } else {
        videoRef.current.pause();
        setIsPlaying(false);
      }
    }
  };

  const restartVideo = () => {
    if (videoRef.current) {
      videoRef.current.currentTime = 0;
      videoRef.current.play();
      setIsPlaying(true);
    }
  };

  return (
    <section className="relative pt-32 pb-20 md:pt-40 md:pb-28 overflow-hidden">
      <div className="max-w-6xl mx-auto px-6 relative z-10">
        {/* Top Announcement Pill */}
        <div className="flex justify-center mb-6">
          <a
            href="https://github.com/pawanbhayde/clippy"
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center gap-2.5 px-4 py-1.5 rounded-full bg-[#F3EDE2] hover:bg-[#EAE2D2] border border-[#DDD5C5] text-[#554E43] text-xs font-medium transition-all shadow-2xs group"
          >
            <span className="flex h-2 w-2 rounded-full bg-emerald-500 animate-pulse" />
            <span className="font-serif italic text-sm text-[#38332B]">
              Open Source for macOS
            </span>
            <span className="text-[#8A8172]">•</span>
            <span>100% Native Swift & AppKit</span>
            <span className="text-[#7A7162] group-hover:translate-x-0.5 transition-transform">
              ↗
            </span>
          </a>
        </div>

        {/* Editorial Serif Main Headline */}
        <div className="text-center max-w-4xl mx-auto mb-6">
          <h1 className="font-serif text-5xl sm:text-6xl md:text-7xl lg:text-[76px] tracking-tight text-[#2C2825] font-normal leading-[1.08]">
            <span className="text-[#827A6D] font-light">(</span> The clipboard{" "}
            <span className="italic font-serif font-normal">pastes itself</span>{" "}
            <span className="text-[#827A6D] font-light">)</span>
          </h1>
        </div>

        {/* Subtitle */}
        <p className="text-center max-w-2xl mx-auto text-[#635C52] text-base sm:text-lg leading-relaxed mb-10 font-normal">
          Transform your MacBook camera notch into an intelligent Dynamic Island shelf.
          Sequential paste queues, multi-item merging, Apple Vision OCR, and visual diffs—all 100% on-device and privacy-first.
        </p>

        {/* Action Buttons */}
        <div className="flex flex-col sm:flex-row items-center justify-center gap-4 mb-16">
          <a
            href="https://github.com/pawanbhayde/clippy"
            target="_blank"
            rel="noopener noreferrer"
            className="w-full sm:w-auto inline-flex items-center justify-center gap-3 px-7 py-3.5 rounded-full text-sm font-semibold text-[#FAF7F2] bg-[#2C2825] hover:bg-[#181614] shadow-md hover:shadow-lg transition-all group"
          >
            <GithubIcon className="w-4 h-4 fill-current transition-transform group-hover:scale-110" />
            <span>View on GitHub</span>
          </a>
        </div>

        {/* ══════════════════════════════════════════════════════════════
            HERO PRODUCT LAUNCH VIDEO SHOWCASE (macOS Window Frame)
            ══════════════════════════════════════════════════════════════ */}
        <div className="relative mx-auto max-w-5xl rounded-2xl bg-gradient-to-b from-[#FAF8F5] to-[#F2EFE9] p-3 sm:p-5 border border-[#E5DFD4] shadow-paper-xl">
          {/* macOS Window Titlebar with Traffic Lights */}
          <div className="flex items-center justify-between pb-3 px-2 border-b border-[#E8E2D6]/80">
            <div className="flex items-center gap-2">
              <div className="w-3 h-3 rounded-full bg-[#FF5F56] border border-[#E0443E]" />
              <div className="w-3 h-3 rounded-full bg-[#FFBD2E] border border-[#DEA123]" />
              <div className="w-3 h-3 rounded-full bg-[#27C93F] border border-[#1AAB29]" />
            </div>

            <div className="text-xs font-medium text-[#7A7162] flex items-center gap-2">
              <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse" />
              <span>Clippy Product Launch • Official Walkthrough</span>
            </div>

            <div className="text-[11px] text-[#8C8373] font-mono flex items-center gap-1.5">
              <span className="px-1.5 py-0.5 rounded bg-[#EAE2D2] text-[#635C52]">0:43</span>
              <span>HD</span>
            </div>
          </div>

          {/* Embedded Video Player Container */}
          <div className="relative bg-black rounded-xl overflow-hidden border border-[#2D2A28] shadow-2xl mt-3 group">
            <video
              ref={videoRef}
              src="/1004.mp4"
              poster="/video_preview.jpg"
              autoPlay
              loop
              muted={isMuted}
              playsInline
              controls
              className="w-full h-auto aspect-video object-cover"
              onPlay={() => setIsPlaying(true)}
              onPause={() => setIsPlaying(false)}
            />

            {/* Quick Floating Controls Bar Overlay */}
            <div className="absolute bottom-4 right-4 flex items-center gap-2 z-20 opacity-90 group-hover:opacity-100 transition-opacity">
              <button
                onClick={togglePlay}
                className="p-2 rounded-full bg-black/70 hover:bg-black text-white backdrop-blur-md border border-white/20 shadow-lg transition-transform hover:scale-105"
                title={isPlaying ? "Pause video" : "Play video"}
              >
                {isPlaying ? (
                  <Pause className="w-3.5 h-3.5" />
                ) : (
                  <Play className="w-3.5 h-3.5 fill-current" />
                )}
              </button>

              <button
                onClick={toggleSound}
                className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-black/70 hover:bg-black text-white text-xs font-medium backdrop-blur-md border border-white/20 shadow-lg transition-transform hover:scale-105"
                title={isMuted ? "Unmute audio" : "Mute audio"}
              >
                {isMuted ? (
                  <>
                    <VolumeX className="w-3.5 h-3.5 text-zinc-300" />
                    <span>Enable Sound</span>
                  </>
                ) : (
                  <>
                    <Volume2 className="w-3.5 h-3.5 text-emerald-400" />
                    <span className="text-emerald-300">Sound On</span>
                  </>
                )}
              </button>

              <button
                onClick={restartVideo}
                className="p-2 rounded-full bg-black/70 hover:bg-black text-white backdrop-blur-md border border-white/20 shadow-lg transition-transform hover:scale-105"
                title="Restart from beginning"
              >
                <RotateCcw className="w-3.5 h-3.5" />
              </button>
            </div>
          </div>

          {/* Sub-bar below window */}
          <div className="mt-4 pt-3 border-t border-[#E5DFD4] flex flex-col sm:flex-row items-center justify-between gap-3 text-xs text-[#7A7162]">
            <div className="flex items-center gap-2 text-center sm:text-left">
              <span className="font-serif italic text-sm text-[#4A4337]">
                Designed for Apple Silicon & Intel Macs
              </span>
              <span className="hidden md:inline">•</span>
              <span className="hidden md:inline">
                Zero Cloud Dependencies • 100% Offline
              </span>
            </div>

            <div className="flex items-center gap-2">
              <a
                href="#paste-queue"
                className="px-3 py-1 rounded-full bg-[#EAE2D2] hover:bg-[#DDD2BE] text-[#3A342B] font-medium transition-colors text-xs"
              >
                See Paste Queue
              </a>
              <a
                href="https://github.com/pawanbhayde/clippy"
                target="_blank"
                rel="noopener noreferrer"
                className="px-3 py-1 rounded-full bg-[#EAE2D2] hover:bg-[#DDD2BE] text-[#3A342B] font-medium transition-colors text-xs flex items-center gap-1"
              >
                <span>View Source</span>
                <ExternalLink className="w-3 h-3 opacity-60" />
              </a>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
