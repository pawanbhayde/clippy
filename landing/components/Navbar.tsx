"use client";

import React, { useState, useEffect } from "react";
import Image from "next/image";
import { Sparkles, Menu, X, ArrowUpRight } from "lucide-react";
import { GithubIcon } from "@/components/Icons";

export function Navbar() {
  const [scrolled, setScrolled] = useState(false);
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  useEffect(() => {
    const handleScroll = () => {
      setScrolled(window.scrollY > 20);
    };
    window.addEventListener("scroll", handleScroll);
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  return (
    <header
      className={`fixed top-0 left-0 right-0 z-50 transition-all duration-300 ${scrolled
        ? "bg-[#FAF7F2]/90 backdrop-blur-md border-b border-[#E8E2D6] py-3 shadow-xs"
        : "bg-transparent py-5"
        }`}
    >
      <div className="max-w-6xl mx-auto px-6 flex items-center justify-between">
        {/* Brand */}
        <a
          href="#"
          className="flex items-center gap-3 group focus:outline-hidden"
        >
          <div className="relative w-8 h-8 rounded-lg overflow-hidden shadow-xs border border-[#2C2825]/10 group-hover:scale-105 transition-transform">
            <Image
              src="/icon.png"
              alt="Clippy icon"
              fill
              className="object-cover"
              priority
            />
          </div>
          <div className="flex items-baseline gap-2">
            <span className="font-serif text-2xl font-bold tracking-tight text-[#2C2825]">
              Clippy
            </span>
          </div>
        </a>

        {/* Desktop Navigation Links */}
        <nav className="hidden md:flex items-center gap-8 text-[13.5px] font-medium text-[#5C5549]">
          <a
            href="#features"
            className="hover:text-[#181614] transition-colors py-1"
          >
            Features
          </a>
          <a
            href="#paste-queue"
            className="hover:text-[#181614] transition-colors py-1"
          >
            Paste Queue
          </a>
          <a
            href="#vision-ocr"
            className="hover:text-[#181614] transition-colors py-1"
          >
            Vision OCR
          </a>
          <a
            href="#security"
            className="hover:text-[#181614] transition-colors py-1"
          >
            Privacy & Security
          </a>
          <a
            href="https://github.com/pawanbhayde/clippy"
            target="_blank"
            rel="noopener noreferrer"
            className="hover:text-[#181614] transition-colors py-1 flex items-center gap-1"
          >
            Docs
            <ArrowUpRight className="w-3.5 h-3.5 opacity-60" />
          </a>
        </nav>

        {/* Right CTA Button */}
        <div className="hidden sm:flex items-center gap-3">
          <a
            href="https://github.com/pawanbhayde/clippy"
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center gap-2 px-4 py-2 rounded-full text-xs font-semibold text-[#FAF7F2] bg-[#2C2825] hover:bg-[#181614] shadow-xs hover:shadow-md transition-all group"
          >
            <GithubIcon className="w-3.5 h-3.5 transition-transform group-hover:scale-110" />
            <span>GitHub</span>
          </a>
        </div>

        {/* Mobile menu button */}
        <button
          onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
          className="md:hidden p-2 rounded-lg text-[#2C2825] hover:bg-[#EFEAE0]"
          aria-label="Toggle navigation menu"
        >
          {mobileMenuOpen ? <X className="w-5 h-5" /> : <Menu className="w-5 h-5" />}
        </button>
      </div>

      {/* Mobile Menu Dropdown */}
      {mobileMenuOpen && (
        <div className="md:hidden bg-[#FAF7F2] border-b border-[#E8E2D6] px-6 py-4 flex flex-col gap-3 shadow-lg">
          <a
            href="#features"
            onClick={() => setMobileMenuOpen(false)}
            className="text-sm font-medium text-[#2C2825] py-2 border-b border-[#EFEAE0]"
          >
            Features
          </a>
          <a
            href="#paste-queue"
            onClick={() => setMobileMenuOpen(false)}
            className="text-sm font-medium text-[#2C2825] py-2 border-b border-[#EFEAE0]"
          >
            Paste Queue
          </a>
          <a
            href="#vision-ocr"
            onClick={() => setMobileMenuOpen(false)}
            className="text-sm font-medium text-[#2C2825] py-2 border-b border-[#EFEAE0]"
          >
            Vision OCR
          </a>
          <a
            href="#security"
            onClick={() => setMobileMenuOpen(false)}
            className="text-sm font-medium text-[#2C2825] py-2 border-b border-[#EFEAE0]"
          >
            Privacy & Security
          </a>
          <div className="pt-2">
            <a
              href="https://github.com/pawanbhayde/clippy"
              target="_blank"
              rel="noopener noreferrer"
              className="w-full justify-center inline-flex items-center gap-2 px-4 py-2.5 rounded-full text-xs font-semibold text-[#FAF7F2] bg-[#2C2825]"
            >
              <GithubIcon className="w-4 h-4" />
              View on GitHub (★ 1.4k • Open Source)
            </a>
          </div>
        </div>
      )}
    </header>
  );
}
