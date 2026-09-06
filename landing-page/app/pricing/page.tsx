"use client";

import { useState } from "react";
import Navbar from "@/components/Navbar";
import Footer from "@/components/Footer";
import FloatingChatButton from "@/components/FloatingChatButton";

export default function PricingPage() {
  const [billingCycle, setBillingCycle] = useState<"monthly" | "yearly">("yearly");
  const [openFaqIndex, setOpenFaqIndex] = useState<number | null>(null);

  const faqs = [
    {
      question: "What is Clippy?",
      answer:
        "Clippy is an intelligent productivity assistant for macOS that transforms your camera notch and dynamic island into a supercharged clipboard shelf, meeting memory bank, and sequential paste manager.",
    },
    {
      question: "How is this different from other meeting tools?",
      answer:
        "Unlike noisy bots that join calls as attendees, Clippy operates 100% locally and invisibly right from your Mac notch, giving you instant real-time context and smart paste queues without distractions.",
    },
    {
      question: "How fast does it respond?",
      answer:
        "Responses, OCR, and sequential pastes happen in under 100ms thanks to our native Swift architecture and local Apple Silicon hardware acceleration.",
    },
    {
      question: "What sources can I connect?",
      answer:
        "You can connect Slack, Notion, Google Docs, Supabase, HubSpot, Salesforce, Linear, and your native macOS clipboard history.",
    },
    {
      question: "Which platforms does it support?",
      answer:
        "Clippy is designed natively for macOS (macOS 14 Sonoma and macOS 15 Sequoia), taking full advantage of the camera notch and Apple Silicon chips.",
    },
    {
      question: "What languages does it support?",
      answer:
        "Clippy natively supports transcriptions, secret masking, and AI synthesis across 50+ languages with automatic detection.",
    },
    {
      question: "Can others see it during calls?",
      answer:
        "No. Clippy features a built-in screen share invisibility shield that automatically hides overlays, shelf items, and notes from Zoom, Google Meet, and Teams recordings.",
    },
    {
      question: "Does it work for in-person meetings?",
      answer:
        "Yes. With native microphone capture and local audio processing, Clippy listens and transcribes in-person conversations just like video calls.",
    },
    {
      question: "Does it take notes automatically?",
      answer:
        "Yes. Key takeaways, action items, attendee commitments, and decision briefs are automatically captured and organized into your connected knowledge base.",
    },
    {
      question: "Does it learn from past meetings?",
      answer:
        "Yes. Clippy connects historical meeting context, past decisions, and attendee memory to give you instant briefs whenever you meet again.",
    },
  ];

  return (
    <div className="min-h-screen bg-background text-foreground antialiased selection:bg-emerald-500/20 selection:text-emerald-400">
      <Navbar />

      <main className="pt-8 pb-20">
        {/* Hero Section */}
        <section className="mx-auto max-w-7xl px-6 pt-16 pb-12 text-center md:pb-16">
          <h1 className="font-display mx-auto mb-4 text-4xl sm:text-5xl md:text-6xl font-medium tracking-tight text-white">
            Free for 7 days
          </h1>
          <p className="text-zinc-400 text-base sm:text-lg">
            No credit card required. Cancel anytime.
          </p>
        </section>

        {/* [01] PLANS Section */}
        <section className="md:px-8 -my-px md:border-y md:border-zinc-800">
          {/* Header with Monthly / Yearly toggle */}
          <div className="px-6 md:px-16 lg:px-24 xl:px-40 -my-px border border-zinc-800 max-md:border-x-0">
            <div className="bg-background mx-auto w-full max-w-7xl">
              <div className="flex h-14 md:h-16 items-center justify-between font-mono text-xs md:text-sm font-medium tracking-wider">
                <span className="text-primary/50">[01] PLANS</span>

                {/* Billing Interval Toggle */}
                <div className="flex items-center gap-3">
                  <button
                    type="button"
                    onClick={() => setBillingCycle("monthly")}
                    className={`cursor-pointer transition-colors text-xs font-semibold ${
                      billingCycle === "monthly" ? "text-white" : "text-zinc-500 hover:text-zinc-300"
                    }`}
                  >
                    MONTHLY
                  </button>

                  <button
                    type="button"
                    onClick={() => setBillingCycle(billingCycle === "monthly" ? "yearly" : "monthly")}
                    className="relative w-11 h-6 rounded-full bg-zinc-800 p-0.5 transition-colors cursor-pointer border border-zinc-700"
                    aria-label="Toggle billing interval"
                  >
                    <div
                      className={`size-5 rounded-full transition-all ${
                        billingCycle === "yearly"
                          ? "translate-x-5 bg-emerald-400"
                          : "translate-x-0 bg-zinc-400"
                      }`}
                    />
                  </button>

                  <button
                    type="button"
                    onClick={() => setBillingCycle("yearly")}
                    className={`cursor-pointer transition-colors text-xs font-semibold flex items-center gap-1.5 ${
                      billingCycle === "yearly" ? "text-white" : "text-zinc-500 hover:text-zinc-300"
                    }`}
                  >
                    <span>YEARLY</span>
                    <span className="text-emerald-400 font-bold">-20%</span>
                  </button>
                </div>
              </div>
            </div>
          </div>

          {/* 2-Column Pricing Cards */}
          <div className="px-6 md:px-16 lg:px-24 xl:px-40 -my-px border border-zinc-800 max-md:border-x-0 bg-repeat bg-[url(/images/bg-pattern-slash.svg)]">
            <div className="bg-background mx-auto w-full max-w-7xl">
              <div className="-my-px border border-zinc-800 grid gap-px bg-zinc-800 md:grid-cols-2">
                {/* Plan 1: Free */}
                <div className="bg-background flex flex-col justify-between p-8 sm:p-10 lg:p-12">
                  <div>
                    <div className="text-sm font-medium text-zinc-400 mb-6">Free</div>
                    <div className="flex items-baseline gap-1 mb-8">
                      <span className="font-display text-5xl font-semibold text-white tracking-tight">
                        $0
                      </span>
                      <span className="text-zinc-400 text-sm">/month</span>
                    </div>

                    <ul className="space-y-4 mb-10 text-sm text-zinc-300">
                      <li className="flex items-center gap-3">
                        <svg className="size-4 shrink-0 text-zinc-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
                          <circle cx="12" cy="12" r="10" />
                          <path d="m9 12 2 2 4-4" />
                        </svg>
                        <span>200 minutes / month credits</span>
                      </li>
                      <li className="flex items-center gap-3">
                        <svg className="size-4 shrink-0 text-zinc-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
                          <circle cx="12" cy="12" r="10" />
                          <path d="m9 12 2 2 4-4" />
                        </svg>
                        <span>AI meeting notes and summaries</span>
                      </li>
                      <li className="flex items-center gap-3">
                        <svg className="size-4 shrink-0 text-zinc-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
                          <circle cx="12" cy="12" r="10" />
                          <path d="m9 12 2 2 4-4" />
                        </svg>
                        <span>Extract custom insights with AI</span>
                      </li>
                      <li className="flex items-center gap-3">
                        <svg className="size-4 shrink-0 text-zinc-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
                          <circle cx="12" cy="12" r="10" />
                          <path d="m9 12 2 2 4-4" />
                        </svg>
                        <span>Basic integrations (Slack, Gmail, etc)</span>
                      </li>
                    </ul>
                  </div>

                  <button
                    type="button"
                    className="w-full rounded-xl bg-zinc-100 py-3.5 px-6 text-sm font-semibold text-black hover:bg-white active:scale-[0.99] transition-all cursor-pointer shadow-xs"
                  >
                    Get started
                  </button>
                </div>

                {/* Plan 2: Enterprise */}
                <div className="bg-background flex flex-col justify-between p-8 sm:p-10 lg:p-12">
                  <div>
                    <div className="text-sm font-medium text-zinc-400 mb-6">Enterprise</div>
                    <div className="mb-8">
                      <span className="font-display text-4xl sm:text-5xl font-semibold text-white tracking-tight">
                        Contact us
                      </span>
                    </div>

                    <ul className="space-y-4 mb-10 text-sm text-zinc-300">
                      <li className="flex items-center gap-3">
                        <svg className="size-4 shrink-0 text-emerald-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
                          <circle cx="12" cy="12" r="10" />
                          <circle cx="12" cy="12" r="3" fill="currentColor" />
                        </svg>
                        <span className="font-medium text-white">Everything in Team</span>
                      </li>
                      <li className="flex items-center gap-3">
                        <svg className="size-4 shrink-0 text-zinc-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
                          <circle cx="12" cy="12" r="10" />
                          <path d="m9 12 2 2 4-4" />
                        </svg>
                        <span>Unlimited members</span>
                      </li>
                      <li className="flex items-center gap-3">
                        <svg className="size-4 shrink-0 text-zinc-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
                          <circle cx="12" cy="12" r="10" />
                          <path d="m9 12 2 2 4-4" />
                        </svg>
                        <span>Import call logs from other tools</span>
                      </li>
                      <li className="flex items-center gap-3">
                        <svg className="size-4 shrink-0 text-zinc-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
                          <circle cx="12" cy="12" r="10" />
                          <path d="m9 12 2 2 4-4" />
                        </svg>
                        <span>Generate custom AI skills</span>
                      </li>
                    </ul>
                  </div>

                  <button
                    type="button"
                    className="w-full rounded-xl bg-[#00a86b] py-3.5 px-6 text-sm font-semibold text-white hover:bg-[#00965f] active:scale-[0.99] transition-all cursor-pointer shadow-xs"
                  >
                    Book a demo
                  </button>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* [02] FAQ Section */}
        <section className="md:px-8 -my-px md:border-b md:border-zinc-800">
          <div className="px-6 md:px-16 lg:px-24 xl:px-40 -my-px border border-zinc-800 max-md:border-x-0">
            <div className="bg-background mx-auto w-full max-w-7xl">
              <div className="flex h-14 md:h-16 items-center justify-between font-mono text-xs md:text-sm font-medium tracking-wider">
                <span className="text-primary/50">[02] FAQ</span>
              </div>
            </div>
          </div>

          <div className="px-6 md:px-16 lg:px-24 xl:px-40 -my-px border border-zinc-800 max-md:border-x-0 bg-repeat bg-[url(/images/bg-pattern-slash.svg)]">
            <div className="bg-background mx-auto w-full max-w-7xl">
              <div className="-my-px border border-zinc-800 divide-y divide-zinc-800">
                {faqs.map((faq, index) => {
                  const isOpen = openFaqIndex === index;
                  return (
                    <div key={faq.question} className="transition-colors">
                      <button
                        type="button"
                        onClick={() => setOpenFaqIndex(isOpen ? null : index)}
                        className="w-full flex items-center justify-between p-6 text-left hover:bg-zinc-900/50 transition-colors cursor-pointer"
                      >
                        <span className="text-base sm:text-lg font-normal text-zinc-100 tracking-tight">
                          {faq.question}
                        </span>
                        <svg
                          className={`size-4 shrink-0 text-zinc-400 transition-transform duration-200 ${
                            isOpen ? "rotate-180" : ""
                          }`}
                          fill="none"
                          stroke="currentColor"
                          strokeWidth="2"
                          viewBox="0 0 24 24"
                        >
                          <path strokeLinecap="round" strokeLinejoin="round" d="m19 9-7 7-7-7" />
                        </svg>
                      </button>

                      {isOpen && (
                        <div className="px-6 pb-6 pt-1 text-sm sm:text-base text-zinc-400 leading-relaxed">
                          {faq.answer}
                        </div>
                      )}
                    </div>
                  );
                })}
              </div>
            </div>
          </div>
        </section>

        {/* Try Clippy Today CTA Banner */}
        <section className="md:px-8 mt-24 md:mt-36">
          <div className="px-6 md:px-16 lg:px-24 xl:px-40">
            <div className="bg-background mx-auto w-full max-w-7xl">
              <div className="border border-zinc-800 bg-[#141416] rounded-2xl p-8 sm:p-12 md:p-16">
                <div className="mb-8">
                  <h3 className="font-display mb-3 text-3xl sm:text-4xl font-medium tracking-tight text-white">
                    Try Clippy today
                  </h3>
                  <p className="text-zinc-400 text-base sm:text-lg max-w-xl">
                    Fewer awkward pauses. Better answers. Focus on the conversation.
                  </p>
                </div>

                <button
                  type="button"
                  className="inline-flex items-center gap-2.5 rounded-full bg-white px-6 py-2.5 text-sm font-medium text-black hover:bg-zinc-100 active:scale-95 transition-all cursor-pointer shadow-xs"
                >
                  <svg viewBox="0 0 15 20" fill="currentColor" className="size-4 shrink-0">
                    <path d="M10.5088 5.74882C10.6203 5.74882 10.7927 5.76209 11.0262 5.78862C11.2649 5.80984 11.5355 5.86821 11.838 5.96371C12.1404 6.05922 12.4482 6.2131 12.7612 6.42534C13.0743 6.63757 13.3635 6.93471 13.6288 7.31674C13.6022 7.33266 13.5014 7.40429 13.3263 7.53163C13.1565 7.65898 12.9629 7.84469 12.7453 8.08876C12.5278 8.32753 12.3368 8.63263 12.1723 9.00405C12.0131 9.37016 11.9335 9.8079 11.9335 10.3173C11.9335 10.9009 12.0343 11.3944 12.2359 11.7976C12.4429 12.2009 12.6816 12.5272 12.9522 12.7766C13.2282 13.026 13.4722 13.209 13.6845 13.3258C13.902 13.4372 14.0187 13.4956 14.0347 13.5009C14.0294 13.5221 13.9896 13.6415 13.9153 13.859C13.841 14.0713 13.7243 14.3472 13.5651 14.6868C13.4112 15.021 13.2096 15.3712 12.9602 15.7373C12.732 16.061 12.4959 16.3714 12.2519 16.6685C12.0131 16.9657 11.7504 17.2071 11.4639 17.3928C11.1827 17.5838 10.8643 17.6793 10.5088 17.6793C10.2382 17.6793 10.0074 17.6475 9.81641 17.5838C9.62539 17.5202 9.44233 17.4459 9.26724 17.361C9.09744 17.2814 8.90908 17.2098 8.70215 17.1461C8.49521 17.0824 8.23787 17.0506 7.93013 17.0506C7.52687 17.0506 7.18994 17.101 6.91934 17.2018C6.65404 17.3079 6.402 17.414 6.16323 17.5202C5.92446 17.6263 5.64325 17.6793 5.31958 17.6793C4.82612 17.6793 4.39103 17.4857 4.01431 17.0983C3.64289 16.711 3.26086 16.2441 2.86821 15.6976C2.56577 15.2625 2.28986 14.761 2.04048 14.1933C1.7911 13.6256 1.59212 13.0233 1.44355 12.3866C1.29499 11.7499 1.2207 11.1132 1.2207 10.4765C1.2207 9.45771 1.41437 8.59814 1.80171 7.89775C2.18905 7.19205 2.68516 6.6588 3.29004 6.29799C3.89492 5.93188 4.52368 5.74882 5.17632 5.74882C5.52121 5.74882 5.84487 5.80984 6.14731 5.93188C6.45506 6.05392 6.74159 6.17595 7.00688 6.29799C7.27218 6.41472 7.51361 6.47309 7.73115 6.47309C7.93809 6.47309 8.18216 6.41472 8.46338 6.29799C8.7446 6.17595 9.055 6.05392 9.39458 5.93188C9.73947 5.80984 10.1109 5.74882 10.5088 5.74882ZM9.95171 4.45947C9.68641 4.78313 9.35213 5.05108 8.94888 5.26332C8.55093 5.47556 8.1742 5.58168 7.8187 5.58168C7.74442 5.58168 7.67279 5.57372 7.60381 5.55781C7.5985 5.53658 7.59054 5.49944 7.57993 5.44638C7.57463 5.39332 7.57197 5.33495 7.57197 5.27128C7.57197 4.86803 7.65952 4.47538 7.83462 4.09335C8.00972 3.71132 8.21134 3.39296 8.4395 3.13828C8.72072 2.804 9.07622 2.52543 9.50601 2.30258C9.9411 2.07973 10.3576 1.96035 10.7556 1.94443C10.7715 2.03463 10.7794 2.1381 10.7794 2.25483C10.7794 2.66339 10.7025 3.06134 10.5486 3.44868C10.3948 3.83071 10.1958 4.16764 9.95171 4.45947Z" />
                  </svg>
                  <span>Download</span>
                  <svg className="size-3 text-zinc-600" fill="none" stroke="currentColor" strokeWidth="2.5" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" d="m19 9-7 7-7-7" />
                  </svg>
                </button>
              </div>
            </div>
          </div>
        </section>
      </main>

      <Footer />
      <FloatingChatButton />
    </div>
  );
}
