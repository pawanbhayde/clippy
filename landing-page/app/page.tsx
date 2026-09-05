import Navbar from "@/components/Navbar";
import HeroSection from "@/components/HeroSection";
import LiveSuggestionsSection from "@/components/LiveSuggestionsSection";
import PrepareSection from "@/components/PrepareSection";
import MemorySection from "@/components/MemorySection";
import PrivacySection from "@/components/PrivacySection";
import CtaSection from "@/components/CtaSection";
import Footer from "@/components/Footer";
import FloatingChatButton from "@/components/FloatingChatButton";

export default function LandingPage() {
  return (
    <div className="min-h-screen bg-background text-foreground antialiased selection:bg-emerald-500/20 selection:text-emerald-400">
      <Navbar />
      <main>
        <HeroSection />
        <LiveSuggestionsSection />
        <PrepareSection />
        <MemorySection />
        <PrivacySection />
        <CtaSection />
      </main>
      <Footer />
      <FloatingChatButton />
    </div>
  );
}
