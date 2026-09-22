# Security Policy

Clippy handles clipboard content that can include passwords, API keys, and
other secrets (see the Secret Auto-Masking and encryption features described
in `README.md`). Reports of security issues are taken seriously.

## Reporting a Vulnerability

**Please do not open a public GitHub issue for security vulnerabilities.**

Instead, report it privately using one of the following:

1. **[GitHub Security Advisories](../../security/advisories/new)** for this
   repository (preferred) — this lets us coordinate a fix before public
   disclosure.
2. Email **pawanbhayde721@gmail.com** with details of the issue.

Please include:

- A description of the vulnerability and its potential impact
- Steps to reproduce (a minimal proof of concept helps a lot)
- The macOS version and Clippy version/commit you tested against

We'll acknowledge your report as soon as possible and keep you updated as we
work on a fix. Once a fix is released, we'll credit you in the release notes
unless you prefer to remain anonymous.

## Scope

Areas of particular interest for security review:

- `Core/Security/ContentEncryptor.swift` — AES-256-GCM encryption and Keychain
  key handling for sensitive clipboard items.
- `Core/Classification/SensitiveDataDetector.swift` — detection of secrets
  (API tokens, passwords, OTPs) that triggers masking/encryption/auto-purge.
- `Core/Clipboard/ClipboardWriter.swift` — Direct Paste's PID-targeted paste
  injection, which relies on the Accessibility permission.
- `Core/AI/GeminiService.swift` — the only component in the app that makes
  network requests (opt-in, BYOK); anything that could exfiltrate clipboard
  content without explicit user action is a high-severity concern.

Clippy is designed to be 100% on-device with zero telemetry outside of the
opt-in Gemini integration — any code path that silently sends clipboard data
off-device is treated as a security bug, not just a privacy nit.
