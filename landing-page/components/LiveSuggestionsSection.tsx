export default function LiveSuggestionsSection() {
  return (
    <section id="features" className="md:px-8 -my-px md:border-y md:border-zinc-800">
      <div
        className="px-6 md:px-16 lg:px-24 xl:px-40 -my-px border border-zinc-800 max-md:border-x-0"
      >
        <div className="bg-background mx-auto w-full max-w-7xl">
          <div
            className="text-primary/50 flex h-12 items-center justify-between font-mono text-xs font-medium tracking-wider md:h-16 md:text-sm"
          >
            <span>[01] NOTCH SHELF &amp; QUEUE</span>
            <span>/ PRODUCTIVITY</span>
          </div>
        </div>
      </div>
      <div
        className="px-6 md:px-16 lg:px-24 xl:px-40 -my-px border border-zinc-800 max-md:border-x-0 bg-repeat bg-[url(/images/bg-pattern-slash.svg)]"
      >
        <div className="bg-background mx-auto w-full max-w-7xl">
          <div className="-my-px border border-zinc-800">
            <h3
              className="font-display mx-auto max-w-2xl px-6 py-12 text-center text-2xl leading-tight font-medium md:text-3xl md:leading-9"
            >
              Clippy turns your camera notch into an{" "}
              <span
                className="group/elements relative font-serif font-light italic"
              >
                intelligent shelf<span
                  className="bg-primary absolute inset-0 z-1 bg-clip-text text-transparent opacity-0 transition-opacity duration-200 mt-0 leading-none"
                  style={{ "backgroundImage": "linear-gradient( 90deg, transparent calc(50% - 40px), rgb(18, 165, 148), rgb(233, 61, 130), rgb(255, 178, 36), transparent calc(50% + 40px) )", "backgroundSize": "200% 100%", "backgroundPosition": "-50% center" }}
                  aria-hidden="true"
                >intelligent shelf</span
                >{" "}
              </span>
              . Never lose a copied snippet again.
            </h3>
          </div>
          <div
            className="-my-px border border-zinc-800 grid gap-px bg-zinc-800 md:grid-cols-2"
          >
            <div className="bg-background flex flex-col">
              <div className="flex grow flex-col px-8 py-7">
                <h5
                  className="font-display mb-2 text-xl leading-tight font-medium tracking-tight text-balance md:mb-2 lg:max-w-2/3 lg:text-2xl"
                >
                  Sequential Queue Paste
                </h5>
                <div
                  className="text-app-secondary-invert grow text-base text-pretty md:text-lg md:leading-snug"
                >
                  <p>
                    Copy clips in sequence and paste them in exact FIFO order with ⌘⌥V without ever switching windows.
                  </p>
                </div>
              </div>
              <div
                className="relative overflow-hidden *:select-none aspect-5/4 shrink-0 font-sans-alt bg-transparent bg-linear-to-b from-green-500/0 from-75% to-green-700/10"
              >
                <div className="absolute top-4 left-6 max-md:scale-90">
                  <div className="relative">
                    <div
                      className="border-app-secondary overflow-hidden rounded-tl-2xl border-t border-l"
                    >
                      <div className="flex items-center gap-2 px-4 py-2">
                        <svg
                          width="24"
                          height="24"
                          viewBox="0 0 24 24"
                          fill="transparent"
                          className="caret-icon caret-icon-arrow-left-icon text-app-secondary-invert size-5"
                        >
                          <path
                            stroke="currentColor"
                            strokeLinecap="round"
                            strokeLinejoin="round"
                            strokeWidth="2"
                            d="M19 12H5m0 0 7 7m-7-7 7-7"
                          ></path>
                        </svg>
                        <svg
                          width="24"
                          height="24"
                          viewBox="0 0 24 24"
                          fill="transparent"
                          className="caret-icon caret-icon-arrow-right-icon text-app-teritary-invert size-5"
                        >
                          <path
                            stroke="currentColor"
                            strokeLinecap="round"
                            strokeLinejoin="round"
                            strokeWidth="2"
                            d="M5 12h14m0 0-7-7m7 7-7 7"
                          ></path>
                        </svg>
                        <div
                          className="bg-app-primary text-app-secondary-invert ml-2 flex h-7 w-80 items-center gap-2 rounded-sm px-2 text-xs font-medium"
                        >
                          <span
                            data-slot="avatar"
                            className="relative flex shrink-0 overflow-hidden bg-muted text-muted-foreground text-xs size-4 rounded-full"
                          ></span>
                          <span
                            className="animate-thinking-gradient opacity-50"
                          >Clippy Sequential Queue</span
                          >
                        </div>
                      </div>
                      <div className="px-8 py-4">
                        <p
                          className="animate-thinking-gradient mb-2 text-base font-medium opacity-80"
                        >
                          1. API Authentication Token
                        </p>
                        <p
                          className="animate-thinking-gradient text-sm leading-normal text-pretty opacity-50"
                        >
                          export const CLOUD_AUTH_KEY = &quot;sk_live_98240f91a2fc71b...&quot;;
                        </p>
                      </div>
                    </div>
                    <div
                      className="to-background absolute top-0 left-0 z-1 size-full bg-linear-to-br from-transparent"
                    ></div>
                  </div>
                </div>
                <div
                  className="absolute -bottom-6 left-6 md:bottom-10 md:left-20"
                >
                  <div
                    className="rounded-3xl border-t border-t-white/30 shadow-2xl absolute left-[9999px]"
                    data-component="liquid-glass-element"
                    style={{ "position": "relative" }}
                  >
                    <div
                      data-vaso="_R_kq9bsnlabsnpb_"
                      style={{ "position": "absolute", "top": "0", "left": "0", "width": "calc(100% + 0px)", "height": "calc(100% + 0px)", "overflow": "hidden", "backdropFilter": "url(#_R_kq9bsnlabsnpb__filter) blur(4px) contrast(1.1) brightness(1.05) saturate(1.1)", "borderRadius": "24px", "cursor": "default", "userSelect": "none" }}
                    ></div>
                    <svg
                      width="0"
                      height="0"
                      style={{ "position": "fixed", "top": "0", "left": "0", "zIndex": "999" }}
                    >
                      <defs>
                        <filter
                          id="_R_kq9bsnlabsnpb__filter"
                          filterUnits="userSpaceOnUse"
                          color-interpolation-filters="sRGB"
                          x="-5%"
                          y="-5%"
                          width="110%"
                          height="110%"
                        >
                          <feImage id="_R_kq9bsnlabsnpb__map"></feImage>
                          <feDisplacementMap
                            in="SourceGraphic"
                            in2="_R_kq9bsnlabsnpb__map"
                            xChannelSelector="R"
                            yChannelSelector="G"
                            result="displaced"
                          ></feDisplacementMap>
                          <feOffset
                            dx="0.5"
                            dy="0.5"
                            in="displaced"
                            result="redShift"
                          ></feOffset>
                          <feOffset
                            dx="0"
                            dy="0"
                            in="displaced"
                            result="greenCenter"
                          ></feOffset>
                          <feOffset
                            dx="-0.5"
                            dy="-0.5"
                            in="displaced"
                            result="blueShift"
                          ></feOffset>
                          <feColorMatrix
                            in="redShift"
                            type="matrix"
                            values="1 0 0 0 0  0 0 0 0 0  0 0 0 0 0  0 0 0 1 0"
                            result="redOnly"
                          ></feColorMatrix>
                          <feColorMatrix
                            in="greenCenter"
                            type="matrix"
                            values="0 0 0 0 0  0 1 0 0 0  0 0 0 0 0  0 0 0 1 0"
                            result="greenOnly"
                          ></feColorMatrix>
                          <feColorMatrix
                            in="blueShift"
                            type="matrix"
                            values="0 0 0 0 0  0 0 0 0 0  0 0 1 0 0  0 0 0 1 0"
                            result="blueOnly"
                          ></feColorMatrix>
                          <feComposite
                            in="redOnly"
                            in2="greenOnly"
                            operator="lighter"
                            result="redGreen"
                          ></feComposite>
                          <feComposite
                            in="redGreen"
                            in2="blueOnly"
                            operator="lighter"
                          ></feComposite>
                        </filter>
                      </defs>
                    </svg>
                    <canvas style={{ "display": "none" }}></canvas>
                    <div
                      data-component="minibar-content"
                      className="font-sans-alt overflow-hidden rounded-3xl bg-black/15 transition-all sm:bg-black/30"
                    >
                      <div
                        className="overflow-hidden"
                        style={{ "opacity": "0", "height": "0px", "width": "0px", "filter": "blur(10px)" }}
                      >
                        <div
                          className="grow space-y-1.5 px-5 py-3 md:max-w-120 w-110 max-w-none"
                        >
                          <div className="z-1 w-full">
                            <div className="space-y-0.5 py-1">
                              <div
                                className="text-app-primary-invert text-base leading-tight font-semibold tracking-tight"
                              >
                                Queue [1 of 3]: Ready to paste
                              </div>
                              <p
                                className="text-app-secondary-invert text-sm font-medium tracking-tight"
                              >
                                Press ⌘⌥V to paste next item in FIFO sequence
                              </p>
                            </div>
                            <div
                              className="text-accent-foreground text-base font-medium tracking-[-0.015em]"
                            >
                              <div className="mb-3">
                                Next in queue: Database Endpoint URL. Notch counter shows remaining items.
                              </div>
                              <div
                                className="-mb-0.5 flex items-center gap-1"
                              >
                                <div
                                  className="border-app-secondary flex w-44 shrink-0 items-center gap-2 rounded-xl border bg-black/10 py-1.5 pr-3 pl-2 *:[text-box-trim:trim-both]"
                                >
                                  <img
                                    src="/media/minibar-citation-supabase.0oxu35g1b-wu-.png"
                                    className="size-5 rounded-full"
                                    alt="Citation"
                                  />
                                  <div className="truncate">
                                    <p
                                      className="text-app-primary-invert truncate text-xs leading-tight font-medium"
                                    >
                                      Database Endpoint
                                    </p>
                                    <p
                                      className="text-app-secondary-invert truncate text-[10px] leading-none"
                                    >
                                      clippy://queue #2
                                    </p>
                                  </div>
                                </div>
                                <div
                                  className="border-app-secondary flex w-44 shrink-0 items-center gap-2 rounded-xl border bg-black/10 py-1.5 pr-3 pl-2 *:[text-box-trim:trim-both]"
                                >
                                  <img
                                    src="/media/minibar-citation-profile.0k~pg~utzg3j1.png"
                                    className="size-5 rounded-full"
                                    alt="Citation"
                                  />
                                  <div className="truncate">
                                    <p
                                      className="text-app-primary-invert truncate text-xs leading-tight font-medium"
                                    >
                                      API Secret Token
                                    </p>
                                    <p
                                      className="text-app-secondary-invert truncate text-[10px] leading-none"
                                    >
                                      clippy://queue #1
                                    </p>
                                  </div>
                                </div>
                              </div>
                            </div>
                          </div>
                          <div
                            className="absolute inset-0 size-full bg-linear-to-b from-transparent from-75% to-emerald-400/15"
                            data-component="minibar-cheatsheet-effect"
                          ></div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            <div className="bg-background flex flex-col">
              <div className="flex grow flex-col px-8 py-7">
                <h5
                  className="font-display mb-2 text-xl leading-tight font-medium tracking-tight text-balance md:mb-2 lg:max-w-2/3 lg:text-2xl"
                >
                  Multi-Item Merger &amp; Scratchpad
                </h5>
                <div
                  className="text-app-secondary-invert grow text-base text-pretty md:text-lg md:leading-snug"
                >
                  <p>
                    Select multiple clips with ⌘ or ⇧ to join them into bullet lists, comma-separated CSVs, or SQL statements instantly.
                  </p>
                </div>
              </div>
              <div
                className="relative overflow-hidden *:select-none aspect-5/4 shrink-0 font-sans-alt bg-transparent bg-linear-to-b from-blue-500/0 from-75% to-blue-600/10"
              >
                <div
                  className="absolute top-5 left-1/2 z-1 flex -translate-x-1/2 items-center gap-2"
                >
                  <span
                    data-slot="avatar"
                    className="relative flex shrink-0 overflow-hidden bg-muted text-muted-foreground text-xs size-10 rounded-full border-t border-white/50"
                  ></span>
                </div>
                <div
                  className="absolute top-12 left-4 z-1 w-max opacity-40 blur-[1.5px]"
                >
                  <div
                    className="rounded-3xl border-t border-t-white/30 shadow-2xl absolute left-[9999px]"
                    data-component="liquid-glass-element"
                    style={{ "position": "relative" }}
                  >
                    <div
                      data-vaso="_R_la9bsnlabsnpb_"
                      style={{ "position": "absolute", "top": "0", "left": "0", "width": "calc(100% + 0px)", "height": "calc(100% + 0px)", "overflow": "hidden", "backdropFilter": "url(#_R_la9bsnlabsnpb__filter) blur(4px) contrast(1.1) brightness(1.05) saturate(1.1)", "borderRadius": "24px", "cursor": "default", "userSelect": "none" }}
                    ></div>
                    <svg
                      width="0"
                      height="0"
                      style={{ "position": "fixed", "top": "0", "left": "0", "zIndex": "999" }}
                    >
                      <defs>
                        <filter
                          id="_R_la9bsnlabsnpb__filter"
                          filterUnits="userSpaceOnUse"
                          color-interpolation-filters="sRGB"
                          x="-5%"
                          y="-5%"
                          width="110%"
                          height="110%"
                        >
                          <feImage id="_R_la9bsnlabsnpb__map"></feImage>
                          <feDisplacementMap
                            in="SourceGraphic"
                            in2="_R_la9bsnlabsnpb__map"
                            xChannelSelector="R"
                            yChannelSelector="G"
                            result="displaced"
                          ></feDisplacementMap>
                          <feOffset
                            dx="0.5"
                            dy="0.5"
                            in="displaced"
                            result="redShift"
                          ></feOffset>
                          <feOffset
                            dx="0"
                            dy="0"
                            in="displaced"
                            result="greenCenter"
                          ></feOffset>
                          <feOffset
                            dx="-0.5"
                            dy="-0.5"
                            in="displaced"
                            result="blueShift"
                          ></feOffset>
                          <feColorMatrix
                            in="redShift"
                            type="matrix"
                            values="1 0 0 0 0  0 0 0 0 0  0 0 0 0 0  0 0 0 1 0"
                            result="redOnly"
                          ></feColorMatrix>
                          <feColorMatrix
                            in="greenCenter"
                            type="matrix"
                            values="0 0 0 0 0  0 1 0 0 0  0 0 0 0 0  0 0 0 1 0"
                            result="greenOnly"
                          ></feColorMatrix>
                          <feColorMatrix
                            in="blueShift"
                            type="matrix"
                            values="0 0 0 0 0  0 0 0 0 0  0 0 1 0 0  0 0 0 1 0"
                            result="blueOnly"
                          ></feColorMatrix>
                          <feComposite
                            in="redOnly"
                            in2="greenOnly"
                            operator="lighter"
                            result="redGreen"
                          ></feComposite>
                          <feComposite
                            in="redGreen"
                            in2="blueOnly"
                            operator="lighter"
                          ></feComposite>
                        </filter>
                      </defs>
                    </svg>
                    <canvas style={{ "display": "none" }}></canvas>
                    <div
                      data-component="minibar-content"
                      className="font-sans-alt overflow-hidden rounded-3xl bg-black/15 transition-all sm:bg-black/30"
                    >
                      <div
                        className="overflow-hidden"
                        style={{ "opacity": "1", "height": "auto", "width": "auto", "filter": "blur(0px)" }}
                      >
                        <div
                          className="bg-app-secondary text-app-primary-invert flex h-7 shrink-0 items-center gap-2 px-3 text-sm font-medium"
                        >
                          Merge as Bullets
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
                <div
                  className="absolute top-32 left-1/2 z-1 w-max -translate-x-1/2 opacity-80 blur-[0.5px]"
                >
                  <div
                    className="rounded-3xl border-t border-t-white/30 shadow-2xl absolute left-[9999px]"
                    data-component="liquid-glass-element"
                    style={{ "position": "relative" }}
                  >
                    <div
                      data-vaso="_R_ta9bsnlabsnpb_"
                      style={{ "position": "absolute", "top": "0", "left": "0", "width": "calc(100% + 0px)", "height": "calc(100% + 0px)", "overflow": "hidden", "backdropFilter": "url(#_R_ta9bsnlabsnpb__filter) blur(4px) contrast(1.1) brightness(1.05) saturate(1.1)", "borderRadius": "24px", "cursor": "default", "userSelect": "none" }}
                    ></div>
                    <svg
                      width="0"
                      height="0"
                      style={{ "position": "fixed", "top": "0", "left": "0", "zIndex": "999" }}
                    >
                      <defs>
                        <filter
                          id="_R_ta9bsnlabsnpb__filter"
                          filterUnits="userSpaceOnUse"
                          color-interpolation-filters="sRGB"
                          x="-5%"
                          y="-5%"
                          width="110%"
                          height="110%"
                        >
                          <feImage id="_R_ta9bsnlabsnpb__map"></feImage>
                          <feDisplacementMap
                            in="SourceGraphic"
                            in2="_R_ta9bsnlabsnpb__map"
                            xChannelSelector="R"
                            yChannelSelector="G"
                            result="displaced"
                          ></feDisplacementMap>
                          <feOffset
                            dx="0.5"
                            dy="0.5"
                            in="displaced"
                            result="redShift"
                          ></feOffset>
                          <feOffset
                            dx="0"
                            dy="0"
                            in="displaced"
                            result="greenCenter"
                          ></feOffset>
                          <feOffset
                            dx="-0.5"
                            dy="-0.5"
                            in="displaced"
                            result="blueShift"
                          ></feOffset>
                          <feColorMatrix
                            in="redShift"
                            type="matrix"
                            values="1 0 0 0 0  0 0 0 0 0  0 0 0 0 0  0 0 0 1 0"
                            result="redOnly"
                          ></feColorMatrix>
                          <feColorMatrix
                            in="greenCenter"
                            type="matrix"
                            values="0 0 0 0 0  0 1 0 0 0  0 0 0 0 0  0 0 0 1 0"
                            result="greenOnly"
                          ></feColorMatrix>
                          <feColorMatrix
                            in="blueShift"
                            type="matrix"
                            values="0 0 0 0 0  0 0 0 0 0  0 0 1 0 0  0 0 0 1 0"
                            result="blueOnly"
                          ></feColorMatrix>
                          <feComposite
                            in="redOnly"
                            in2="greenOnly"
                            operator="lighter"
                            result="redGreen"
                          ></feComposite>
                          <feComposite
                            in="redGreen"
                            in2="blueOnly"
                            operator="lighter"
                          ></feComposite>
                        </filter>
                      </defs>
                    </svg>
                    <canvas style={{ "display": "none" }}></canvas>
                    <div
                      data-component="minibar-content"
                      className="font-sans-alt overflow-hidden rounded-3xl bg-black/15 transition-all sm:bg-black/30"
                    >
                      <div
                        className="overflow-hidden"
                        style={{ "opacity": "1", "height": "auto", "width": "auto", "filter": "blur(0px)" }}
                      >
                        <div
                          className="bg-app-secondary text-app-primary-invert flex h-7 shrink-0 items-center gap-2 px-3 text-sm font-medium"
                        >
                          Join with Commas (, )
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
                <div
                  className="absolute top-18 right-6 z-1 w-max opacity-60 blur-[1px]"
                >
                  <div
                    className="rounded-3xl border-t border-t-white/30 shadow-2xl absolute left-[9999px]"
                    data-component="liquid-glass-element"
                    style={{ "position": "relative" }}
                  >
                    <div
                      data-vaso="_R_15a9bsnlabsnpb_"
                      style={{ "position": "absolute", "top": "0", "left": "0", "width": "calc(100% + 0px)", "height": "calc(100% + 0px)", "overflow": "hidden", "backdropFilter": "url(#_R_15a9bsnlabsnpb__filter) blur(4px) contrast(1.1) brightness(1.05) saturate(1.1)", "borderRadius": "24px", "cursor": "default", "userSelect": "none" }}
                    ></div>
                    <svg
                      width="0"
                      height="0"
                      style={{ "position": "fixed", "top": "0", "left": "0", "zIndex": "999" }}
                    >
                      <defs>
                        <filter
                          id="_R_15a9bsnlabsnpb__filter"
                          filterUnits="userSpaceOnUse"
                          color-interpolation-filters="sRGB"
                          x="-5%"
                          y="-5%"
                          width="110%"
                          height="110%"
                        >
                          <feImage id="_R_15a9bsnlabsnpb__map"></feImage>
                          <feDisplacementMap
                            in="SourceGraphic"
                            in2="_R_15a9bsnlabsnpb__map"
                            xChannelSelector="R"
                            yChannelSelector="G"
                            result="displaced"
                          ></feDisplacementMap>
                          <feOffset
                            dx="0.5"
                            dy="0.5"
                            in="displaced"
                            result="redShift"
                          ></feOffset>
                          <feOffset
                            dx="0"
                            dy="0"
                            in="displaced"
                            result="greenCenter"
                          ></feOffset>
                          <feOffset
                            dx="-0.5"
                            dy="-0.5"
                            in="displaced"
                            result="blueShift"
                          ></feOffset>
                          <feColorMatrix
                            in="redShift"
                            type="matrix"
                            values="1 0 0 0 0  0 0 0 0 0  0 0 0 0 0  0 0 0 1 0"
                            result="redOnly"
                          ></feColorMatrix>
                          <feColorMatrix
                            in="greenCenter"
                            type="matrix"
                            values="0 0 0 0 0  0 1 0 0 0  0 0 0 0 0  0 0 0 1 0"
                            result="greenOnly"
                          ></feColorMatrix>
                          <feColorMatrix
                            in="blueShift"
                            type="matrix"
                            values="0 0 0 0 0  0 0 0 0 0  0 0 1 0 0  0 0 0 1 0"
                            result="blueOnly"
                          ></feColorMatrix>
                          <feComposite
                            in="redOnly"
                            in2="greenOnly"
                            operator="lighter"
                            result="redGreen"
                          ></feComposite>
                          <feComposite
                            in="redGreen"
                            in2="blueOnly"
                            operator="lighter"
                          ></feComposite>
                        </filter>
                      </defs>
                    </svg>
                    <canvas style={{ "display": "none" }}></canvas>
                    <div
                      data-component="minibar-content"
                      className="font-sans-alt overflow-hidden rounded-3xl bg-black/15 transition-all sm:bg-black/30"
                    >
                      <div
                        className="overflow-hidden"
                        style={{ "opacity": "1", "height": "auto", "width": "auto", "filter": "blur(0px)" }}
                      >
                        <div
                          className="bg-app-secondary text-app-primary-invert flex h-7 shrink-0 items-center gap-2 px-3 text-sm font-medium"
                        >
                          SQL IN (&apos;a&apos;, &apos;b&apos;) Format
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
                <div
                  className="absolute -bottom-8 left-1/2 z-1 -translate-x-1/2 scale-90 md:bottom-4 md:scale-95"
                >
                  <div
                    className="rounded-3xl border-t border-t-white/30 shadow-2xl absolute left-[9999px]"
                    data-component="liquid-glass-element"
                    style={{ "position": "relative" }}
                  >
                    <div
                      data-vaso="_R_1da9bsnlabsnpb_"
                      style={{ "position": "absolute", "top": "0", "left": "0", "width": "calc(100% + 0px)", "height": "calc(100% + 0px)", "overflow": "hidden", "backdropFilter": "url(#_R_1da9bsnlabsnpb__filter) blur(4px) contrast(1.1) brightness(1.05) saturate(1.1)", "borderRadius": "24px", "cursor": "default", "userSelect": "none" }}
                    ></div>
                    <svg
                      width="0"
                      height="0"
                      style={{ "position": "fixed", "top": "0", "left": "0", "zIndex": "999" }}
                    >
                      <defs>
                        <filter
                          id="_R_1da9bsnlabsnpb__filter"
                          filterUnits="userSpaceOnUse"
                          color-interpolation-filters="sRGB"
                          x="-5%"
                          y="-5%"
                          width="110%"
                          height="110%"
                        >
                          <feImage id="_R_1da9bsnlabsnpb__map"></feImage>
                          <feDisplacementMap
                            in="SourceGraphic"
                            in2="_R_1da9bsnlabsnpb__map"
                            xChannelSelector="R"
                            yChannelSelector="G"
                            result="displaced"
                          ></feDisplacementMap>
                          <feOffset
                            dx="0.5"
                            dy="0.5"
                            in="displaced"
                            result="redShift"
                          ></feOffset>
                          <feOffset
                            dx="0"
                            dy="0"
                            in="displaced"
                            result="greenCenter"
                          ></feOffset>
                          <feOffset
                            dx="-0.5"
                            dy="-0.5"
                            in="displaced"
                            result="blueShift"
                          ></feOffset>
                          <feColorMatrix
                            in="redShift"
                            type="matrix"
                            values="1 0 0 0 0  0 0 0 0 0  0 0 0 0 0  0 0 0 1 0"
                            result="redOnly"
                          ></feColorMatrix>
                          <feColorMatrix
                            in="greenCenter"
                            type="matrix"
                            values="0 0 0 0 0  0 1 0 0 0  0 0 0 0 0  0 0 0 1 0"
                            result="greenOnly"
                          ></feColorMatrix>
                          <feColorMatrix
                            in="blueShift"
                            type="matrix"
                            values="0 0 0 0 0  0 0 0 0 0  0 0 1 0 0  0 0 0 1 0"
                            result="blueOnly"
                          ></feColorMatrix>
                          <feComposite
                            in="redOnly"
                            in2="greenOnly"
                            operator="lighter"
                            result="redGreen"
                          ></feComposite>
                          <feComposite
                            in="redGreen"
                            in2="blueOnly"
                            operator="lighter"
                          ></feComposite>
                        </filter>
                      </defs>
                    </svg>
                    <canvas style={{ "display": "none" }}></canvas>
                    <div
                      data-component="minibar-content"
                      className="font-sans-alt overflow-hidden rounded-3xl bg-black/15 transition-all sm:bg-black/30"
                    >
                      <div
                        className="overflow-hidden"
                        style={{ "opacity": "1", "height": "auto", "width": "auto", "filter": "blur(0px)" }}
                      >
                        <div
                          className="grow space-y-1.5 px-5 py-3 md:max-w-120 w-96 max-w-none **:data-[component=&quot;minibar-cheatsheet-effect&quot;]:from-blue-400/0 **:data-[component=&quot;minibar-cheatsheet-effect&quot;]:to-blue-400/20 lg:w-110"
                        >
                          <div className="z-1 w-full">
                            <div className="space-y-0.5 py-1">
                              <div
                                className="text-app-primary-invert text-base leading-tight font-semibold tracking-tight"
                              >
                                Merger Preview: 3 items selected
                              </div>
                              <p
                                className="text-app-secondary-invert text-sm font-medium tracking-tight"
                              >
                                Quick Format Preset: Markdown List
                              </p>
                            </div>
                            <div
                              className="text-accent-foreground text-base font-medium tracking-[-0.015em]"
                            >
                              <div className="mb-3 text-pretty">
                                - Client Authentication Token<br />
                                - Production Database Endpoint<br />
                                - Webhook Signature Key
                              </div>
                              <div
                                className="-mb-0.5 flex items-center gap-1"
                              >
                                <div
                                  className="border-app-secondary flex w-44 shrink-0 items-center gap-2 rounded-xl border bg-black/10 py-1.5 pr-3 pl-2 *:[text-box-trim:trim-both]"
                                >
                                  <img
                                    src="/media/minibar-citation-profile2.12kt3uy_2ts4f.png"
                                    className="size-5 rounded-full"
                                    alt="Citation"
                                  />
                                  <div className="truncate">
                                    <p
                                      className="text-app-primary-invert truncate text-xs leading-tight font-medium"
                                    >
                                      3 Clips Merged
                                    </p>
                                    <p
                                      className="text-app-secondary-invert truncate text-[10px] leading-none"
                                    >
                                      Ready to copy or paste
                                    </p>
                                  </div>
                                </div>
                              </div>
                            </div>
                          </div>
                          <div
                            className="absolute inset-0 size-full bg-linear-to-b from-transparent from-75% to-emerald-400/15"
                            data-component="minibar-cheatsheet-effect"
                          ></div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
                <div className="absolute top-10 left-1/2 -translate-x-1/2">
                  <div className="relative">
                    <div
                      className="absolute inset-1/2 -translate-1/2 rounded-full border border-dashed border-blue-600"
                      style={{ "width": "-100px", "height": "-100px", "opacity": "0.1" }}
                    ></div>
                    <div
                      className="absolute inset-1/2 -translate-1/2 rounded-full border border-dashed border-blue-600"
                      style={{ "width": "20px", "height": "20px", "opacity": "0.1" }}
                    ></div>
                    <div
                      className="absolute inset-1/2 -translate-1/2 rounded-full border border-dashed border-blue-600"
                      style={{ "width": "140px", "height": "140px", "opacity": "0.1" }}
                    ></div>
                    <div
                      className="absolute inset-1/2 -translate-1/2 rounded-full border border-dashed border-blue-600"
                      style={{ "width": "260px", "height": "260px", "opacity": "0.1" }}
                    ></div>
                    <div
                      className="absolute inset-1/2 -translate-1/2 rounded-full border border-dashed border-blue-600"
                      style={{ "width": "380px", "height": "380px", "opacity": "0.1" }}
                    ></div>
                    <div
                      className="absolute inset-1/2 -translate-1/2 rounded-full border border-dashed border-blue-600"
                      style={{ "width": "500px", "height": "500px", "opacity": "0.1" }}
                    ></div>
                    <div
                      className="absolute inset-1/2 -translate-1/2 rounded-full border border-dashed border-blue-600"
                      style={{ "width": "620px", "height": "620px", "opacity": "0.1" }}
                    ></div>
                    <div
                      className="absolute inset-1/2 -translate-1/2 rounded-full border border-dashed border-blue-600"
                      style={{ "width": "740px", "height": "740px", "opacity": "0.1" }}
                    ></div>
                    <div
                      className="absolute inset-1/2 -translate-1/2 rounded-full border border-dashed border-blue-600"
                      style={{ "width": "860px", "height": "860px", "opacity": "0.1" }}
                    ></div>
                    <div
                      className="absolute inset-1/2 -translate-1/2 rounded-full border border-dashed border-blue-600"
                      style={{ "width": "980px", "height": "980px", "opacity": "0.1" }}
                    ></div>
                  </div>
                </div>
              </div>
            </div>
            <div className="bg-background flex flex-col">
              <div className="flex grow flex-col px-8 py-7">
                <h5
                  className="font-display mb-2 text-xl leading-tight font-medium tracking-tight text-balance md:mb-2 lg:max-w-2/3 lg:text-2xl"
                >
                  Visual Diff Engine &amp; Comparisons
                </h5>
                <div
                  className="text-app-secondary-invert grow text-base text-pretty md:text-lg md:leading-snug"
                >
                  <div className="flex h-full flex-col">
                    <p>
                      Compare any two copied clips side-by-side or unified with color-coded additions, deletions, and syntax highlights.
                    </p>
                    <div className="grow"></div>
                    <div className="flex flex-wrap gap-x-1 gap-y-2">
                      <button
                        data-slot="button"
                        className="focus-visible:border-ring focus-visible:ring-ring/50 aria-invalid:border-destructive aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 inline-flex shrink-0 items-center justify-center border border-transparent text-sm font-medium whitespace-nowrap transition-all outline-none focus-visible:ring-[3px] disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4 bg-primary text-background hover:bg-primary/90 shadow-xs h-8 gap-1.5 px-3 has-[>svg]:px-2.5 rounded-full"
                        type="button"
                      >
                        <svg
                          width="24"
                          height="24"
                          viewBox="0 0 24 24"
                          fill="transparent"
                          className="caret-icon caret-icon-graduation-hat-solid-icon"
                        >
                          <path
                            fill="currentColor"
                            d="M22.447 9.394a1 1 0 0 0 0-1.788L12.78 2.772a2 2 0 0 0-.502-.187 1.5 1.5 0 0 0-.554 0c-.216.04-.41.139-.502.187L1.553 7.606a1 1 0 0 0 0 1.788l9.73 4.879c.263.131.394.197.532.223a1 1 0 0 0 .37 0c.138-.026.27-.092.532-.223z"
                          ></path>
                          <path
                            fill="currentColor"
                            d="M19.997 14.165c0-.43 0-.644-.09-.773a.5.5 0 0 0-.337-.208c-.156-.023-.348.073-.732.265l-6.059 3.03c-.093.047-.286.146-.502.186a1.5 1.5 0 0 1-.554 0c-.216-.04-.41-.139-.502-.186l-6.06-3.03c-.383-.192-.575-.288-.73-.265a.5.5 0 0 0-.337.208c-.09.13-.09.344-.09.773q0 .96-.004 1.922c-.001.276-.003.623.11.947a2 2 0 0 0 .461.747c.24.245.551.4.798.522q2.766 1.373 5.523 2.761c.203.102.458.23.74.284.243.045.493.045.737 0 .281-.053.536-.182.739-.284a883 883 0 0 1 5.523-2.761c.247-.123.558-.277.798-.522a2 2 0 0 0 .462-.747c.112-.324.11-.671.11-.947q-.004-.96-.004-1.922"
                          ></path>
                        </svg>
                        <span>Side-by-Side</span>
                      </button>
                      <button
                        data-slot="button"
                        className="focus-visible:border-ring focus-visible:ring-ring/50 aria-invalid:border-destructive aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 inline-flex shrink-0 items-center justify-center border-transparent text-sm font-medium whitespace-nowrap transition-all outline-none focus-visible:ring-[3px] disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4 bg-background hover:bg-accent hover:text-accent-foreground dark:border-input dark:bg-input/30 dark:hover:bg-input/50 border shadow-xs h-8 gap-1.5 px-3 has-[>svg]:px-2.5 rounded-full"
                        type="button"
                      >
                        <svg
                          width="24"
                          height="24"
                          viewBox="0 0 24 24"
                          fill="transparent"
                          className="caret-icon caret-icon-help-circle-solid-icon"
                        >
                          <path
                            fill="currentColor"
                            fillRule="evenodd"
                            d="M12 1C5.925 1 1 5.925 1 12s4.925 11 11 11 11-4.925 11-11S18.075 1 12 1m-1.093 7.271a2 2 0 0 1 3.013 1.727V10c0 .47-.365.958-1.055 1.418a6 6 0 0 1-1.262.634 1 1 0 0 0 .633 1.897l.169-.061a8.05 8.05 0 0 0 1.57-.806c.81-.54 1.944-1.55 1.945-3.081a4 4 0 0 0-7.773-1.333 1 1 0 0 0 1.886.664 2 2 0 0 1 .874-1.06M12 16a1 1 0 1 0 0 2h.01a1 1 0 0 0 0-2z"
                            clipRule="evenodd"
                          ></path>
                        </svg>
                        <span>Unified Diff</span>
                      </button>
                      <button
                        data-slot="button"
                        className="focus-visible:border-ring focus-visible:ring-ring/50 aria-invalid:border-destructive aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 inline-flex shrink-0 items-center justify-center border-transparent text-sm font-medium whitespace-nowrap transition-all outline-none focus-visible:ring-[3px] disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4 bg-background hover:bg-accent hover:text-accent-foreground dark:border-input dark:bg-input/30 dark:hover:bg-input/50 border shadow-xs h-8 gap-1.5 px-3 has-[>svg]:px-2.5 rounded-full"
                        type="button"
                      >
                        <svg
                          width="24"
                          height="24"
                          viewBox="0 0 24 24"
                          fill="transparent"
                          className="caret-icon caret-icon-star-7-solid-icon"
                        >
                          <path
                            fill="currentColor"
                            d="M12 1a1 1 0 0 1 1 1v2a1 1 0 1 1-2 0V2a1 1 0 0 1 1-1M5.636 4.222a1 1 0 1 0-1.414 1.414L5.636 7.05A1 1 0 0 0 7.05 5.636zM1 12a1 1 0 0 1 1-1h2a1 1 0 1 1 0 2H2a1 1 0 0 1-1-1M20 11a1 1 0 1 0 0 2h2a1 1 0 1 0 0-2zM18.364 16.95a1 1 0 0 0-1.414 1.414l1.414 1.414a1 1 0 0 0 1.414-1.414zM19.778 5.636a1 1 0 0 0-1.414-1.414L16.95 5.636a1 1 0 0 0 1.414 1.414zM12 19a1 1 0 0 1 1 1v2a1 1 0 1 1-2 0v-2a1 1 0 0 1 1-1M7.05 18.364a1 1 0 1 0-1.414-1.414l-1.414 1.414a1 1 0 0 0 1.414 1.414zM12.897 6.557a1 1 0 0 0-1.794 0l-1.312 2.66-2.936.429a1 1 0 0 0-.553 1.705l2.124 2.068-.502 2.922a1 1 0 0 0 1.451 1.054L12 16.015l2.625 1.38a1 1 0 0 0 1.45-1.054l-.5-2.922 2.123-2.068a1 1 0 0 0-.553-1.705l-2.936-.43z"
                          ></path>
                        </svg>
                        <span>Ignore Whitespace</span>
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            <div
              className="bg-app-primary relative overflow-hidden *:select-none shrink-0 aspect-square bg-[url(&quot;/images/wallpaper.webp&quot;)] bg-cover bg-center"
            >
              <div
                className="absolute inset-0 flex flex-col items-center justify-center gap-3 p-4 md:gap-4 md:p-8"
              >
                <button
                  className="group relative flex items-center gap-1.5 rounded-full bg-white px-4 py-2.5 text-sm font-medium text-zinc-900 shadow-lg transition-all hover:scale-105 hover:shadow-xl md:gap-2 md:px-6 md:py-3 md:text-base"
                  style={{ "opacity": "1", "transform": "none" }}
                >
                  <div
                    className="flex size-4 items-center justify-center rounded-full bg-zinc-900 text-[10px] font-medium text-white md:size-5 md:text-xs"
                  >
                    ?
                  </div>
                  <span>Compare with clip</span>
                  <span className="font-semibold text-green-600"
                  >#3 vs #1</span
                  >
                  <span
                    className="ml-0.5 size-1.5 animate-pulse rounded-full bg-green-500 md:ml-1 md:size-2"
                  ></span>
                  <div
                    className="absolute -right-1 -bottom-1 text-2xl md:-right-2 md:-bottom-2 md:text-3xl"
                  >
                    👆
                  </div>
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
