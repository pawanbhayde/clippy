"use client";

import React, { useState } from "react";
import Image from "next/image";
import {
  ShieldCheck,
  Lock,
  WifiOff,
  Clock,
  KeyRound,
  Eye,
  EyeOff,
  CheckCircle2,
  FileCheck,
} from "lucide-react";

export function PrivacySecuritySection() {
  const [revealed, setRevealed] = useState(false);

  return (
    <section id="security" className="py-20 sm:py-28 relative overflow-hidden scroll-mt-24">
      <div className="max-w-6xl mx-auto px-6 relative z-10">
        {/* Vintage Bee Emblem / Mascot Crest */}
        <div className="flex justify-center mb-6">
          <div className="relative w-20 h-20 sm:w-24 sm:h-24 opacity-90 transition-transform hover:scale-105">
            <Image
              src="/images/vintage_bee.jpg"
              alt="Clippy Vintage Seal"
              fill
              className="object-contain mix-blend-multiply"
            />
          </div>
        </div>

        {/* Section Heading */}
        <div className="text-center max-w-3xl mx-auto mb-16 sm:mb-20">
          <h2 className="font-serif text-4xl sm:text-5xl md:text-6xl text-[#2C2825] font-normal tracking-tight leading-[1.15]">
            Automated power,{" "}
            <span className="italic font-serif">human privacy</span>
          </h2>
          <p className="mt-4 text-[#635C52] text-base sm:text-lg leading-relaxed max-w-2xl mx-auto">
            Your clipboard holds your most intimate data—passwords, personal messages, and company secrets.
            Clippy treats it with ironclad, uncompromised security.
          </p>
        </div>

        {/* 3-Column Layout with Center Postage Stamp */}
        <div className="grid grid-cols-1 md:grid-cols-12 gap-8 lg:gap-12 items-center">
          {/* Column 1: Zero Telemetry & Offline */}
          <div className="md:col-span-4 text-center md:text-left space-y-4">
            <div className="inline-flex items-center justify-center w-10 h-10 rounded-xl bg-[#EAE2D2] text-[#3A342B] mb-2">
              <WifiOff className="w-5 h-5" />
            </div>
            <h3 className="font-serif text-2xl font-bold text-[#2C2825]">
              100% On-Device & Zero Telemetry
            </h3>
            <p className="text-sm text-[#635C52] leading-relaxed">
              Clippy makes zero network requests. No background analytics beacons, no crash report pinging, and no cloud syncing servers.
              Audit the open-source code yourself on GitHub or verify with Little Snitch.
            </p>
            <div className="pt-2">
              <span className="inline-flex items-center gap-1.5 text-xs font-semibold text-[#5A5245] bg-[#EAE2D2]/70 px-3 py-1.5 rounded-full border border-[#D8CEBC]">
                <CheckCircle2 className="w-3.5 h-3.5 text-emerald-700" />
                Zero network permissions requested
              </span>
            </div>
          </div>

          {/* Column 2: Center Vintage Postage Stamp */}
          <div className="md:col-span-4 flex flex-col items-center justify-center">
            <div className="relative group">
              <div className="relative w-64 sm:w-72 aspect-[3/4] rounded-xl overflow-hidden shadow-paper-xl border border-[#DDD5C5] bg-[#F7F3EB] p-2 flex items-center justify-center transform group-hover:scale-102 transition-transform duration-300">
                <Image
                  src="/images/vintage_stamp.jpg"
                  alt="Vintage postage stamp with handshake contract"
                  fill
                  className="object-contain p-1"
                />
              </div>
            </div>
            <span className="text-[11px] font-mono text-[#7A7162] mt-4 tracking-wide text-center">
              AES-256-GCM Hardware-Backed Keychain Encryption
            </span>
          </div>

          {/* Column 3: Secret Auto-Masking & Auto-Purge */}
          <div className="md:col-span-4 text-center md:text-left space-y-4">
            <div className="inline-flex items-center justify-center w-10 h-10 rounded-xl bg-[#EAE2D2] text-[#3A342B] mb-2">
              <Lock className="w-5 h-5" />
            </div>
            <h3 className="font-serif text-2xl font-bold text-[#2C2825]">
              Secret Auto-Masking & Auto-Purge
            </h3>
            <p className="text-sm text-[#635C52] leading-relaxed">
              OpenAI tokens, GitHub PATs, AWS secrets, and 2FA OTP codes are automatically detected on capture and masked as <code className="bg-[#EAE2D2] px-1 py-0.5 rounded text-xs font-mono">••••••••</code>.
              Configurable countdown timers permanently erase secrets from memory.
            </p>

            {/* Interactive Mask Demo */}
            <div className="bg-white/80 p-3 rounded-xl border border-[#DDD5C5] shadow-xs flex items-center justify-between">
              <div className="font-mono text-xs text-[#2C2825] truncate">
                {revealed ? "ghp_92b8A1eF4kLmP09x..." : "ghp_••••••••••••••••"}
              </div>
              <button
                onClick={() => setRevealed(!revealed)}
                className="text-[#7A7162] hover:text-[#2C2825] p-1 transition-colors"
                title="Click to reveal"
              >
                {revealed ? (
                  <EyeOff className="w-3.5 h-3.5" />
                ) : (
                  <Eye className="w-3.5 h-3.5" />
                )}
              </button>
            </div>

            <div className="pt-2">
              <span className="inline-flex items-center gap-1.5 text-xs font-semibold text-[#5A5245] bg-[#EAE2D2]/70 px-3 py-1.5 rounded-full border border-[#D8CEBC]">
                <Clock className="w-3.5 h-3.5 text-amber-700" />
                60s Default Auto-Purge Countdown
              </span>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
