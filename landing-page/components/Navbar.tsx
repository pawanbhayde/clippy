import Link from "next/link";

export default function Navbar() {
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
              width="1731"
              height="400"
              viewBox="0 0 1731 400"
              fill="none"
              xmlns="http://www.w3.org/2000/svg"
              className="-mt-0.5 h-6 w-auto md:h-7 [&_path]:transition-all"
            >
              <path
                fillRule="evenodd"
                clipRule="evenodd"
                d="M57.9607 61.0995C100.422 -31.69 238.652 -5.91438 321.947 53.2892C449.492 141.709 447.474 321.35 443 380.576C442.15 391.83 432.665 400 421.379 400H32.2985C19.1525 400 7.79095 390.527 5.815 377.53C-18.0693 220.434 36.8052 190.28 76.3952 160.095C58.0076 130.763 43.2515 108.764 57.9607 61.0995Z"
                fill="#34D399"
              ></path>
              <path
                fillRule="evenodd"
                clipRule="evenodd"
                d="M57.9607 61.0995C100.422 -31.69 238.652 -5.91438 321.947 53.2892C449.492 141.709 447.474 321.35 443 380.576C442.15 391.83 432.665 400 421.379 400H32.2985C19.1525 400 7.79095 390.527 5.815 377.53C-18.0693 220.434 36.8052 190.28 76.3952 160.095C58.0076 130.763 43.2515 108.764 57.9607 61.0995Z"
                fill="url(#paint0_radial_5261_41)"
              ></path>
              <path
                d="M216.504 132.597C188.289 132.597 180.073 164.751 180.072 204.417C180.072 244.084 188.289 276.243 216.504 276.243C244.718 276.241 252.932 244.083 252.932 204.417C252.931 164.752 244.718 132.599 216.504 132.597Z"
                fill="white"
              ></path>
              <path
                d="M332.42 132.597C304.205 132.597 295.987 164.751 295.987 204.417C295.987 244.084 304.204 276.243 332.42 276.243C360.636 276.243 368.852 244.084 368.852 204.417C368.852 164.751 360.635 132.597 332.42 132.597Z"
                fill="white"
              ></path>
              <path
                fillRule="evenodd"
                clipRule="evenodd"
                d="M1446.06 104.338C1469.76 104.338 1490.94 109.991 1509.52 121.361C1528.05 132.552 1542.44 148.065 1552.65 167.837L1553.13 168.766C1563.18 188.314 1568.17 210.213 1568.17 234.401C1568.17 238.704 1567.93 244.156 1567.46 250.737L1567.27 253.431H1376.19C1377.72 262.425 1380.59 270.721 1384.77 278.338L1385.4 279.442C1391.94 290.761 1400.78 299.588 1411.94 305.97C1423.63 312.408 1436.77 315.652 1451.43 315.652C1466.12 315.652 1478.43 312.474 1488.48 306.267C1498.74 299.867 1506.64 291.018 1512.17 279.649L1513.35 277.216L1561.04 296.45L1559.7 299.238C1549.96 319.521 1535.64 335.529 1516.77 347.202L1516.77 347.204C1498.01 358.748 1475.96 364.465 1450.73 364.465C1425.97 364.465 1403.58 358.904 1383.63 347.732L1383.62 347.726L1383.6 347.719C1363.83 336.395 1348.26 320.746 1336.94 300.818L1336.94 300.811L1336.93 300.803C1325.76 280.861 1320.2 258.706 1320.2 234.401C1320.2 209.8 1325.68 187.567 1336.69 167.773C1347.69 148.011 1362.7 132.513 1381.7 121.335C1400.88 109.99 1422.36 104.338 1446.06 104.338ZM1446.06 153.15C1432.36 153.15 1420.11 156.454 1409.22 163.019C1398.48 169.585 1390.04 178.681 1383.89 190.376C1381.48 195.069 1379.55 200.05 1378.11 205.319H1510.61C1509.55 197.269 1507 189.858 1502.94 183.059L1502.93 183.051L1502.93 183.042C1497.44 173.699 1489.81 166.436 1479.99 161.228L1479.98 161.22L1479.96 161.212C1470.16 155.863 1458.88 153.15 1446.06 153.15Z"
                fill="currentColor"
              ></path>
              <path
                d="M1671.93 111.377H1730.6V156.216H1671.93V278.347C1671.93 290.627 1674.59 299.031 1679.33 304.185C1684.19 309.305 1691.93 312.146 1703.16 312.146C1710.96 312.146 1718.94 310.946 1727.11 308.526L1730.84 307.422V358.054L1728.84 358.71C1717.21 362.534 1705.92 364.465 1694.98 364.465C1679.29 364.465 1665.53 361.181 1653.8 354.501L1653.78 354.486C1642.04 347.639 1633.08 337.848 1626.92 325.199C1620.76 312.567 1617.74 297.699 1617.74 280.685V156.216H1577.07V111.377H1617.74V57.9198H1671.93V111.377Z"
                fill="currentColor"
              ></path>
              <path
                d="M703.621 44.4653C725.973 44.4654 746.604 48.3404 765.477 56.1294C784.631 63.6195 801.119 74.7121 814.909 89.4011C828.741 104.135 838.926 122.142 845.499 143.354L846.356 146.121L794.291 162.33L793.341 159.737C785.874 139.346 774.581 123.387 759.513 111.73C744.528 100.138 726.39 94.288 704.942 94.2879C685.147 94.2879 667.452 98.7292 651.787 107.556C636.428 116.377 624.181 128.892 615.036 145.175C606.218 161.396 601.751 180.705 601.751 203.201C601.752 225.701 606.074 245.171 614.615 261.7C623.47 277.975 635.575 290.638 650.949 299.75C666.303 308.557 683.835 312.994 703.621 312.994C723.27 312.994 741.489 307.31 758.34 295.885C775.482 284.169 788.031 268.766 796.03 249.624L796.975 247.365L850.01 259.643L849.001 262.666C841.826 284.191 830.74 302.491 815.725 317.506L815.704 317.527C800.757 332.175 783.558 343.391 764.127 351.164L764.109 351.171L764.091 351.178C744.681 358.643 724.518 362.377 703.621 362.377C681.845 362.377 661.227 358.497 641.794 350.724L641.786 350.721L641.78 350.718C622.663 342.952 605.769 332.04 591.12 317.988L591.109 317.978L591.098 317.968C576.44 303.609 564.929 286.71 556.567 267.299L556.56 267.282L556.552 267.264C548.467 247.799 544.444 226.433 544.444 203.201C544.444 179.971 548.467 158.744 556.559 139.564L556.563 139.553L556.567 139.544C564.931 120.128 576.448 103.366 591.12 89.2935C605.766 74.9511 622.66 63.8913 641.78 56.1237L641.786 56.1209L641.794 56.1181C661.227 48.3449 681.845 44.4653 703.621 44.4653Z"
                fill="currentColor"
              ></path>
              <path
                fillRule="evenodd"
                clipRule="evenodd"
                d="M987.004 107.856C1007.45 107.856 1025.48 112.973 1040.97 123.288L1041.69 123.762C1053.21 131.376 1062.34 141.218 1069.06 153.245V111.377H1125.49V359.295H1069.06V316.572C1062.2 328.894 1052.85 339.024 1041 346.922C1025.5 357.252 1007.47 362.376 987.004 362.377C965.38 362.377 945.642 357.114 927.856 346.563L927.831 346.548L927.806 346.533C910.342 335.693 896.359 320.792 885.861 301.897L885.848 301.873L885.835 301.848C875.598 282.58 870.529 260.234 870.529 234.896C870.529 209.56 875.598 187.352 885.844 168.367L885.848 168.36L885.852 168.353C896.35 149.156 910.343 134.237 927.838 123.68L927.856 123.669C945.642 113.118 965.38 107.856 987.004 107.856ZM998.449 157.238C986.64 157.238 975.233 160.183 964.195 166.121L963.202 166.681C952.998 172.555 944.595 181.079 938.002 192.341L937.994 192.354L937.986 192.368C931.281 203.544 927.835 217.666 927.835 234.896C927.835 251.804 931.269 266.097 938.002 277.892C944.806 289.516 953.541 298.221 964.191 304.108C975.23 310.048 986.638 312.994 998.449 312.994C1010.57 312.994 1021.98 310.039 1032.7 304.111C1043.36 298.224 1052.09 289.518 1058.9 277.892C1065.63 266.096 1069.06 251.804 1069.06 234.896C1069.06 217.666 1065.62 203.545 1058.91 192.368L1058.9 192.354L1058.9 192.341C1052.09 180.715 1043.36 172.008 1032.7 166.121C1021.98 160.193 1010.57 157.238 998.449 157.238Z"
                fill="currentColor"
              ></path>
              <path
                d="M1286.75 104.338C1295.53 104.338 1304.08 105.966 1312.36 109.213L1314.2 109.935V162.857L1310.42 161.664C1301.81 158.946 1293.15 157.591 1284.42 157.591C1271.67 157.591 1260.97 160.734 1252.18 166.885L1252.18 166.891C1243.54 172.89 1236.77 181.888 1231.95 194.093L1231.94 194.104C1227.13 206.137 1224.67 220.866 1224.67 238.375V359.295H1170.71V111.377H1224.67V142.425C1230.95 131.716 1238.85 122.994 1248.39 116.316L1248.4 116.31L1248.41 116.305C1259.95 108.336 1272.76 104.338 1286.75 104.338Z"
                fill="currentColor"
              ></path>
              <defs>
                <radialGradient
                  id="paint0_radial_5261_41"
                  cx="0"
                  cy="0"
                  r="1"
                  gradientTransform="matrix(-362.42 0 -0.406802 -262.298 265.985 400.42)"
                  gradientUnits="userSpaceOnUse"
                >
                  <stop stopColor="#BEF264"></stop>
                  <stop offset="1" stopColor="#BEF264" stopOpacity="0"></stop>
                </radialGradient>
              </defs>
            </svg>
          </Link>
          <div className="flex grow gap-1 max-md:hidden md:px-7">
            <Link
              data-slot="button"
              className="focus-visible:border-ring focus-visible:ring-ring/50 aria-invalid:border-destructive aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 inline-flex shrink-0 items-center justify-center gap-2 border border-transparent text-sm font-medium whitespace-nowrap transition-all outline-none focus-visible:ring-[3px] disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4 hover:bg-primary/5 hover:text-accent-foreground dark:hover:bg-accent/50 h-9 px-4 py-2 has-[>svg]:px-3 text-app-secondary-invert rounded-full text-primary!"
              href="/"
            >Overview</Link
            >
            <a
              data-slot="button"
              className="focus-visible:border-ring focus-visible:ring-ring/50 aria-invalid:border-destructive aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 inline-flex shrink-0 items-center justify-center gap-2 border border-transparent text-sm font-medium whitespace-nowrap transition-all outline-none focus-visible:ring-[3px] disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4 hover:bg-primary/5 hover:text-accent-foreground dark:hover:bg-accent/50 h-9 px-4 py-2 has-[>svg]:px-3 text-app-secondary-invert rounded-full"
              type="button"
              href="#features"
            >Features</a
            >
            <a
              data-slot="button"
              className="focus-visible:border-ring focus-visible:ring-ring/50 aria-invalid:border-destructive aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 inline-flex shrink-0 items-center justify-center gap-2 border border-transparent text-sm font-medium whitespace-nowrap transition-all outline-none focus-visible:ring-[3px] disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4 hover:bg-primary/5 hover:text-accent-foreground dark:hover:bg-accent/50 h-9 px-4 py-2 has-[>svg]:px-3 text-app-secondary-invert rounded-full"
              type="button"
              href="#shortcuts"
            >Shortcuts</a
            >
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
