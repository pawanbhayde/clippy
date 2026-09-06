"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

export default function Navbar() {
  const pathname = usePathname();
  return (
    <>
      <div
        className="bg-background fixed top-0 left-0 z-50 w-full border-b px-6 border-zinc-800 not-dark:border-zinc-200"
      >
        <nav
          className="mx-auto flex h-14 max-w-7xl grid-cols-2 items-center justify-between gap-2"
        >
          <Link
            data-state="closed"
            data-slot="context-menu-trigger"
            style={{ "WebkitTouchCallout": "none" }}
            href="/"
          >
            <svg
              width="1491"
              height="494"
              viewBox="0 0 1491 494"
              fill="none"
              xmlns="http://www.w3.org/2000/svg"
              className="-mt-0.5 h-6 w-auto md:h-7 [&_path]:transition-all"
            >
              <path
                fillRule="evenodd"
                clipRule="evenodd"
                d="M10 209.64Q10 163.40 30.01 127.16Q50.02 90.92 85.81 70.69Q121.60 50.46 166.96 50.46Q222.53 50.46 262.11 79.81Q301.68 109.15 315.02 159.84L231.43 159.84Q222.09 140.28 204.97 130.05Q187.85 119.82 166.07 119.82Q130.94 119.82 109.15 144.28Q87.37 168.73 87.37 209.64Q87.37 250.55 109.15 275Q130.94 299.46 166.07 299.46Q187.85 299.46 204.97 289.23Q222.09 279 231.43 259.44L315.02 259.44Q301.68 310.13 262.11 339.25Q222.53 368.37 166.96 368.37Q121.60 368.37 85.81 348.14Q50.02 327.91 30.01 291.90Q10 255.88 10 209.64"
                fill="currentColor"
              ></path>
              <path
                fillRule="evenodd"
                clipRule="evenodd"
                d="M361.70 37.12L437.74 37.12L437.74 366.15L361.70 366.15"
                fill="currentColor"
              ></path>
              <path
                fillRule="evenodd"
                clipRule="evenodd"
                d="M531.11 92.26Q511.10 92.26 498.43 80.47Q485.76 68.69 485.76 51.35Q485.76 33.57 498.43 21.78Q511.10 10 531.11 10Q550.67 10 563.34 21.78Q576.02 33.57 576.02 51.35Q576.02 68.69 563.34 80.47Q550.67 92.26 531.11 92.26M492.87 118.05L568.90 118.05L568.90 366.15L492.87 366.15"
                fill="currentColor"
              ></path>
              <path
                fillRule="evenodd"
                clipRule="evenodd"
                d="M700.07 153.17Q711.18 135.83 730.75 125.16Q750.31 114.49 776.55 114.49Q807.23 114.49 832.12 130.05Q857.02 145.61 871.47 174.51Q885.93 203.41 885.93 241.65Q885.93 279.89 871.47 309.02Q857.02 338.14 832.12 353.92Q807.23 369.71 776.55 369.71Q750.76 369.71 730.97 359.04Q711.18 348.37 700.07 331.47L700.07 484.42L624.04 484.42L624.04 118.05L700.07 118.05L700.07 153.17M808.56 241.65Q808.56 213.20 792.77 196.97Q776.99 180.74 753.87 180.74Q731.19 180.74 715.41 197.19Q699.62 213.64 699.62 242.10Q699.62 270.55 715.41 287.01Q731.19 303.46 753.87 303.46Q776.55 303.46 792.55 286.78Q808.56 270.11 808.56 241.65"
                fill="currentColor"
              ></path>
              <path
                fillRule="evenodd"
                clipRule="evenodd"
                d="M1001.97 153.17Q1013.09 135.83 1032.65 125.16Q1052.22 114.49 1078.45 114.49Q1109.13 114.49 1134.03 130.05Q1158.93 145.61 1173.38 174.51Q1187.83 203.41 1187.83 241.65Q1187.83 279.89 1173.38 309.02Q1158.93 338.14 1134.03 353.92Q1109.13 369.71 1078.45 369.71Q1052.66 369.71 1032.88 359.04Q1013.09 348.37 1001.97 331.47L1001.97 484.42L925.94 484.42L925.94 118.05L1001.97 118.05L1001.97 153.17M1110.46 241.65Q1110.46 213.20 1094.68 196.97Q1078.90 180.74 1055.77 180.74Q1033.10 180.74 1017.31 197.19Q1001.53 213.64 1001.53 242.10Q1001.53 270.55 1017.31 287.01Q1033.10 303.46 1055.77 303.46Q1078.45 303.46 1094.46 286.78Q1110.46 270.11 1110.46 241.65"
                fill="currentColor"
              ></path>
              <path
                fillRule="evenodd"
                clipRule="evenodd"
                d="M1399.03 118.05L1481.29 118.05L1325.67 483.98L1243.85 483.98L1300.77 357.70L1199.84 118.05L1284.76 118.05L1342.12 273.22"
                fill="currentColor"
              ></path>
            </svg>
          </Link>
          <div className="flex grow gap-1 max-md:hidden md:px-7">
            <Link
              data-slot="button"
              className={`focus-visible:border-ring focus-visible:ring-ring/50 inline-flex shrink-0 items-center justify-center gap-2 border border-transparent text-sm font-medium whitespace-nowrap transition-all outline-none focus-visible:ring-[3px] disabled:pointer-events-none disabled:opacity-50 h-9 px-4 py-2 rounded-full ${
                pathname === "/"
                  ? "bg-white/10 text-white font-semibold"
                  : "text-zinc-400 hover:text-white hover:bg-white/5"
              }`}
              href="/"
            >
              Home
            </Link>
            <Link
              data-slot="button"
              className={`focus-visible:border-ring focus-visible:ring-ring/50 inline-flex shrink-0 items-center justify-center gap-2 border border-transparent text-sm font-medium whitespace-nowrap transition-all outline-none focus-visible:ring-[3px] disabled:pointer-events-none disabled:opacity-50 h-9 px-4 py-2 rounded-full ${
                pathname === "/pricing"
                  ? "bg-white/10 text-white font-semibold"
                  : "text-zinc-400 hover:text-white hover:bg-white/5"
              }`}
              href="/pricing"
            >
              Pricing
            </Link>
            <Link
              data-slot="button"
              className={`focus-visible:border-ring focus-visible:ring-ring/50 inline-flex shrink-0 items-center justify-center gap-2 border border-transparent text-sm font-medium whitespace-nowrap transition-all outline-none focus-visible:ring-[3px] disabled:pointer-events-none disabled:opacity-50 h-9 px-4 py-2 rounded-full ${
                pathname === "/changelog"
                  ? "bg-white/10 text-white font-semibold"
                  : "text-zinc-400 hover:text-white hover:bg-white/5"
              }`}
              href="/changelog"
            >
              Changelog
            </Link>
          </div>
          <div className="flex items-center justify-end gap-1">
            <button
              data-slot="dropdown-menu-trigger"
              className="focus-visible:border-ring focus-visible:ring-ring/50 aria-invalid:border-destructive aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 inline-flex shrink-0 items-center justify-center border border-transparent text-sm font-medium whitespace-nowrap transition-all outline-none focus-visible:ring-[3px] disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4 hover:bg-primary/5 hover:text-accent-foreground dark:hover:bg-accent/50 h-8 has-[>svg]:px-2.5 gap-1.5 rounded-full px-2.5"
              type="button"
              id="radix-_R_ekqbsnpb_"
              aria-haspopup="menu"
              aria-expanded="false"
              data-state="closed"
            >
              <svg
                width="24"
                height="24"
                viewBox="0 0 24 24"
                fill="transparent"
                className="caret-icon caret-icon-globe-solid-icon size-4"
              >
                <path
                  fill="currentColor"
                  fillRule="evenodd"
                  d="M12 1c6.075 0 11 4.925 11 11s-4.925 11-11 11S1 18.075 1 12 5.925 1 12 1M3.055 11a9.01 9.01 0 0 1 6.67-7.71A16.3 16.3 0 0 0 7.05 11zm0 2a9.01 9.01 0 0 0 6.67 7.71A16.3 16.3 0 0 1 7.05 13zm11.22 7.71a9.01 9.01 0 0 0 6.67-7.71H16.95a16.3 16.3 0 0 1-2.676 7.71m6.67-9.71H16.95a16.3 16.3 0 0 0-2.676-7.71A9.01 9.01 0 0 1 20.945 11M12 3.55A14.3 14.3 0 0 1 14.942 11H9.058A14.3 14.3 0 0 1 12 3.55m0 16.9A14.3 14.3 0 0 1 9.058 13h5.884A14.3 14.3 0 0 1 12 20.45"
                  clipRule="evenodd"
                ></path>
              </svg>
              <span className="text-sm">macOS 14+</span>
            </button>
            <button
              data-slot="button"
              className="focus-visible:border-ring focus-visible:ring-ring/50 aria-invalid:border-destructive aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 inline-flex shrink-0 items-center justify-center gap-2 border border-transparent text-sm font-medium whitespace-nowrap transition-all outline-none focus-visible:ring-[3px] disabled:pointer-events-none disabled:opacity-50 bg-white text-black hover:bg-zinc-100 active:scale-95 shadow-xs h-9 px-4 rounded-full max-md:hidden cursor-pointer"
              type="button"
            >
              <svg
                viewBox="0 0 15 20"
                fill="currentColor"
                className="size-5 shrink-0 "
                aria-hidden="true"
              >
                <path d="M10.5088 5.74882C10.6203 5.74882 10.7927 5.76209 11.0262 5.78862C11.2649 5.80984 11.5355 5.86821 11.838 5.96371C12.1404 6.05922 12.4482 6.2131 12.7612 6.42534C13.0743 6.63757 13.3635 6.93471 13.6288 7.31674C13.6022 7.33266 13.5014 7.40429 13.3263 7.53163C13.1565 7.65898 12.9629 7.84469 12.7453 8.08876C12.5278 8.32753 12.3368 8.63263 12.1723 9.00405C12.0131 9.37016 11.9335 9.8079 11.9335 10.3173C11.9335 10.9009 12.0343 11.3944 12.2359 11.7976C12.4429 12.2009 12.6816 12.5272 12.9522 12.7766C13.2282 13.026 13.4722 13.209 13.6845 13.3258C13.902 13.4372 14.0187 13.4956 14.0347 13.5009C14.0294 13.5221 13.9896 13.6415 13.9153 13.859C13.841 14.0713 13.7243 14.3472 13.5651 14.6868C13.4112 15.021 13.2096 15.3712 12.9602 15.7373C12.732 16.061 12.4959 16.3714 12.2519 16.6685C12.0131 16.9657 11.7504 17.2071 11.4639 17.3928C11.1827 17.5838 10.8643 17.6793 10.5088 17.6793C10.2382 17.6793 10.0074 17.6475 9.81641 17.5838C9.62539 17.5202 9.44233 17.4459 9.26724 17.361C9.09744 17.2814 8.90908 17.2098 8.70215 17.1461C8.49521 17.0824 8.23787 17.0506 7.93013 17.0506C7.52687 17.0506 7.18994 17.101 6.91934 17.2018C6.65404 17.3079 6.402 17.414 6.16323 17.5202C5.92446 17.6263 5.64325 17.6793 5.31958 17.6793C4.82612 17.6793 4.39103 17.4857 4.01431 17.0983C3.64289 16.711 3.26086 16.2441 2.86821 15.6976C2.56577 15.2625 2.28986 14.761 2.04048 14.1933C1.7911 13.6256 1.59212 13.0233 1.44355 12.3866C1.29499 11.7499 1.2207 11.1132 1.2207 10.4765C1.2207 9.45771 1.41437 8.59814 1.80171 7.89775C2.18905 7.19205 2.68516 6.6588 3.29004 6.29799C3.89492 5.93188 4.52368 5.74882 5.17632 5.74882C5.52121 5.74882 5.84487 5.80984 6.14731 5.93188C6.45506 6.05392 6.74159 6.17595 7.00688 6.29799C7.27218 6.41472 7.51361 6.47309 7.73115 6.47309C7.93809 6.47309 8.18216 6.41472 8.46338 6.29799C8.7446 6.17595 9.055 6.05392 9.39458 5.93188C9.73947 5.80984 10.1109 5.74882 10.5088 5.74882ZM9.95171 4.45947C9.68641 4.78313 9.35213 5.05108 8.94888 5.26332C8.55093 5.47556 8.1742 5.58168 7.8187 5.58168C7.74442 5.58168 7.67279 5.57372 7.60381 5.55781C7.5985 5.53658 7.59054 5.49944 7.57993 5.44638C7.57463 5.39332 7.57197 5.33495 7.57197 5.27128C7.57197 4.86803 7.65952 4.47538 7.83462 4.09335C8.00972 3.71132 8.21134 3.39296 8.4395 3.13828C8.72072 2.804 9.07622 2.52543 9.50601 2.30258C9.9411 2.07973 10.3576 1.96035 10.7556 1.94443C10.7715 2.03463 10.7794 2.1381 10.7794 2.25483C10.7794 2.66339 10.7025 3.06134 10.5486 3.44868C10.3948 3.83071 10.1958 4.16764 9.95171 4.45947Z" />
              </svg>
              <span>Download</span>
            </button>
          </div>
        </nav>
      </div>
      <div className="h-14"></div>
      <div></div>
    </>
  );
}
