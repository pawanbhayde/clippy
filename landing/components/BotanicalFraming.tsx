"use client";

import React from "react";
import Image from "next/image";

export function BotanicalFraming() {
  return (
    <div className="pointer-events-none absolute inset-0 overflow-hidden z-0 select-none">
      {/* Top Left Foliage Cluster (Framing the Hero only) */}
      <div className="absolute -top-12 -left-24 w-[320px] h-[540px] opacity-75 mix-blend-multiply hidden 2xl:block">
        <div className="relative w-full h-full transform scale-x-[-1]">
          <Image
            src="/images/botanical_frame.jpg"
            alt=""
            fill
            className="object-cover object-left"
            priority
          />
        </div>
      </div>

      {/* Top Right Foliage Cluster (Framing the Hero only) */}
      <div className="absolute -top-12 -right-24 w-[320px] h-[540px] opacity-75 mix-blend-multiply hidden 2xl:block">
        <div className="relative w-full h-full">
          <Image
            src="/images/botanical_frame.jpg"
            alt=""
            fill
            className="object-cover object-right"
            priority
          />
        </div>
      </div>

      {/* Mid Left Foliage Branch - Pushed strictly to outer edge and masked */}
      <div className="absolute top-[1750px] -left-48 w-[320px] h-[560px] opacity-40 mix-blend-multiply hidden 2xl:block [mask-image:linear-gradient(to_right,black_20%,transparent_90%)]">
        <div className="relative w-full h-full transform scale-x-[-1]">
          <Image
            src="/images/botanical_frame.jpg"
            alt=""
            fill
            className="object-cover object-left"
          />
        </div>
      </div>

      {/* Mid Right Foliage Branch - Pushed strictly to outer edge and masked */}
      <div className="absolute top-[2300px] -right-48 w-[320px] h-[560px] opacity-40 mix-blend-multiply hidden 2xl:block [mask-image:linear-gradient(to_left,black_20%,transparent_90%)]">
        <div className="relative w-full h-full">
          <Image
            src="/images/botanical_frame.jpg"
            alt=""
            fill
            className="object-cover object-right"
          />
        </div>
      </div>

      {/* Subtle Sky gradient overlay in hero */}
      <div className="absolute top-0 left-1/2 -translate-x-1/2 w-full max-w-5xl h-[520px] bg-radial from-[#F0F5FA]/80 via-[#FAF7F2]/40 to-transparent blur-2xl -z-10" />
    </div>
  );
}
