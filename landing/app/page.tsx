import React from "react";
import { Navbar } from "@/components/Navbar";
import { BotanicalFraming } from "@/components/BotanicalFraming";
import { Hero } from "@/components/Hero";
import { FeatureQueueWorkflow } from "@/components/FeatureQueueWorkflow";
import { FeatureCardsGrid } from "@/components/FeatureCardsGrid";
import { PrivacySecuritySection } from "@/components/PrivacySecuritySection";
import { PastoralCtaFooter } from "@/components/PastoralCtaFooter";

export default function Home() {
  return (
    <div className="relative min-h-screen bg-[#FAF7F2] text-[#2C2825] overflow-hidden selection:bg-[#EAE4D9] selection:text-[#181614]">
      {/* Decorative Botanical Foliage framing left and right borders */}
      <BotanicalFraming />

      {/* Top Fixed / Floating Navbar */}
      <Navbar />

      {/* Main Content Sections */}
      <main className="relative z-10">
        {/* Section 1: Hero with Dynamic Island Shelf Preview */}
        <Hero />

        {/* Section 2: "Hours of work, done in minutes" - Queue Paste & Workflow */}
        <FeatureQueueWorkflow />

        {/* Section 3: "Never lose a copied thought again" - 3-Card Grid */}
        <FeatureCardsGrid />

        {/* Section 4: "Automated power, human privacy" - Vintage Stamp & Security */}
        <PrivacySecuritySection />
      </main>

      {/* Section 5: Pastoral Landscape Banner & Comprehensive Editorial Footer */}
      <PastoralCtaFooter />
    </div>
  );
}
