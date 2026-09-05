export default function PrivacySection() {
  return (
          <section id="privacy" className="md:px-8 -my-px md:border-y md:border-zinc-800">
            <div
              className="px-6 md:px-16 lg:px-24 xl:px-40 -my-px border border-zinc-800 max-md:border-x-0 bg-repeat bg-[url(/images/bg-pattern-dot.svg)]"
            >
              <div className="bg-background mx-auto w-full max-w-7xl">
                <div className="my-16 lg:my-36">
                  <div
                    className="-my-px border border-zinc-800 px-6 pt-5 md:px-11 md:py-10"
                  >
                    <div className="mb-16">
                      <h3
                        className="font-display text-app-secondary-invert mb-4 text-2xl leading-tight font-medium tracking-tight md:text-3xl"
                      >
                        <span className="text-accent-foreground font-[550]"
                        >Private by design.{" "}
                        </span>
                        Zero telemetry. Zero cloud sync. 100% on-device clipboard security backed by Apple Silicon &amp; macOS Keychain.
                      </h3>
                    </div>
                  </div>
                  <div
                    className="-my-px border border-zinc-800 grid gap-px bg-zinc-800 md:grid-cols-2"
                  >
                    <div className="bg-background flex flex-col">
                      <div className="grow px-6 pt-5">
                        <h5
                          className="font-display mb-1 text-lg leading-tight font-medium tracking-tight md:mb-2 md:text-xl"
                        >
                          Secret Auto-Masking &amp; Auto-Purge
                        </h5>
                        <p
                          className="text-app-secondary-invert leading-snug md:text-lg"
                        >
                          Automatically masks passwords, OTPs, and API tokens as •••••••• with configurable 60-second auto-purge.
                        </p>
                      </div>
                      <div
                        className="relative h-40 shrink-0 overflow-hidden md:h-48"
                      >
                        <img
                          src="/media/lock-03.0ifu3rll7xn9w.png"
                          alt="Secret Auto-Masking &amp; Auto-Purge"
                          className="absolute top-1/2 h-28 w-full -translate-y-1/2 object-contain object-center md:h-40"
                        />
                      </div>
                    </div>
                    <div className="bg-background flex flex-col">
                      <div className="grow px-6 pt-5">
                        <h5
                          className="font-display mb-1 text-lg leading-tight font-medium tracking-tight md:mb-2 md:text-xl"
                        >
                          Password Manager Blacklist
                        </h5>
                        <p
                          className="text-app-secondary-invert leading-snug md:text-lg"
                        >
                          Automatically ignores clipboard copies originating from 1Password, Bitwarden, Apple Keychain, and KeePassXC.
                        </p>
                      </div>
                      <div
                        className="relative h-40 shrink-0 overflow-hidden md:h-48"
                      >
                        <img
                          src="/media/lock-04.00dc0cyz~2yvs.png"
                          alt="Password Manager Blacklist"
                          className="absolute top-1/2 h-40 w-full -translate-y-1/2 object-contain object-center"
                        />
                      </div>
                    </div>
                    <div className="bg-background flex flex-col">
                      <div className="grow px-6 pt-5">
                        <h5
                          className="font-display mb-1 text-lg leading-tight font-medium tracking-tight md:mb-2 md:text-xl"
                        >
                          Hardware-Backed Encryption
                        </h5>
                        <p
                          className="text-app-secondary-invert leading-snug md:text-lg"
                        >
                          256-bit AES-GCM encryption via Apple CryptoKit with cryptographic keys stored securely in your macOS Keychain.
                        </p>
                      </div>
                      <div
                        className="relative h-40 shrink-0 overflow-hidden md:h-48"
                      >
                        <img
                          src="/media/lock-01.0~6xbq9e4u_ej.png"
                          alt="Hardware-Backed Encryption"
                          className="absolute top-1/2 h-20 w-full -translate-y-1/2 object-cover object-center md:h-28"
                        />
                      </div>
                    </div>
                    <div className="bg-background flex flex-col">
                      <div className="grow px-6 pt-5">
                        <h5
                          className="font-display mb-1 text-lg leading-tight font-medium tracking-tight md:mb-2 md:text-xl"
                        >
                          100% Offline Apple Vision OCR
                        </h5>
                        <p
                          className="text-app-secondary-invert leading-snug md:text-lg"
                        >
                          Text recognition on copied screenshots runs entirely offline on Apple Silicon Neural Engine. Zero data ever leaves your Mac.
                        </p>
                      </div>
                      <div
                        className="relative h-40 shrink-0 overflow-hidden md:h-48"
                      >
                        <img
                          src="/media/lock-02.0d.t.8abn9.vt.png"
                          alt="100% Offline Apple Vision OCR"
                          className="absolute top-1/2 h-28 w-full -translate-y-1/2 object-contain object-center md:h-36"
                        />
                      </div>
                    </div>
                  </div>
                  <div></div>
                </div>
              </div>
            </div>
          </section>
  );
}
