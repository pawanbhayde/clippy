import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  metadataBase: new URL("https://clippy.app"),
  title: "Clippy - The Supercharged Dynamic Island & Notch Clipboard Manager for macOS",
  description:
    "Transform your MacBook camera notch into an intelligent productivity shelf for sequential pasting, multi-item merging, native OCR, and privacy-first secret masking.",
  icons: {
    icon: "/icon.png",
  },
  openGraph: {
    title: "Clippy - The Supercharged Dynamic Island & Notch Clipboard Manager for macOS",
    description:
      "Transform your MacBook camera notch into an intelligent productivity shelf for sequential pasting, multi-item merging, native OCR, and privacy-first secret masking.",
    siteName: "Clippy",
    images: [
      {
        url: "/opengraph-image.png",
        width: 1200,
        height: 630,
        type: "image/png",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "Clippy - The Supercharged Dynamic Island & Notch Clipboard Manager for macOS",
    description:
      "Transform your MacBook camera notch into an intelligent productivity shelf for sequential pasting, multi-item merging, native OCR, and privacy-first secret masking.",
    images: ["/opengraph-image.png"],
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className="dark h-full antialiased" translate="no">
      <body className="figtree_29be9955-module__IqsvRG__variable google_sans_flex_fa0cf1c-module__jJJIPW__variable inter_5e5c70bf-module__7IeqwW__variable dm_mono_ce800e7e-module__jKZSQW__variable ppeditorialnew_558c2226-module__kq_8Eq__variable font-sans antialiased dark min-h-full flex flex-col bg-background text-foreground">
        {children}
      </body>
    </html>
  );
}
