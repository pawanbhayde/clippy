import type { Metadata } from "next";
import { Newsreader, Plus_Jakarta_Sans } from "next/font/google";
import "./globals.css";

const newsreader = Newsreader({
  subsets: ["latin"],
  variable: "--font-newsreader",
  style: ["normal", "italic"],
  display: "swap",
});

const plusJakartaSans = Plus_Jakarta_Sans({
  subsets: ["latin"],
  variable: "--font-sans",
  display: "swap",
});

export const metadata: Metadata = {
  metadataBase: new URL("https://clippy.app"),
  title: "Clippy — The Supercharged Dynamic Island & Notch Clipboard Manager for macOS",
  description:
    "An open-source, 100% native macOS clipboard manager living in your MacBook camera notch. Sequential paste queues, multi-item merging, Apple Vision OCR, and visual diffs—100% on-device and privacy-first.",
  icons: {
    icon: "/icon.png",
    apple: "/icon.png",
  },
  openGraph: {
    title: "Clippy — The Supercharged Dynamic Island & Notch Clipboard Manager for macOS",
    description:
      "Transform your MacBook camera notch into an intelligent Dynamic Island shelf. 100% Native Swift, AppKit & SwiftUI.",
    images: ["/icon.png"],
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html
      lang="en"
      className={`${newsreader.variable} ${plusJakartaSans.variable} scroll-smooth antialiased`}
    >
      <body className="min-h-screen bg-[#FAF7F2] text-[#2C2825] font-sans overflow-x-hidden selection:bg-[#EAE4D9] selection:text-[#181614]">
        {children}
      </body>
    </html>
  );
}
