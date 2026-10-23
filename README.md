# Rust-Cross-Platform-Demo
Demo rust cross platform builds

A tiny CLI that tells you whether an integer is odd or even.

```sh
$ odd-even 7
7 is odd
$ odd-even -4
-4 is even
```

Exit codes: `0` success, `1` input is not an integer, `2` no input given.

## Install

**macOS / Linux**

```sh
curl -fsSL https://raw.githubusercontent.com/JonathanV1502/Rust-Cross-Platform-Demo/main/install.sh | sh
```

**Windows (PowerShell)**

```powershell
powershell -c "irm https://raw.githubusercontent.com/JonathanV1502/Rust-Cross-Platform-Demo/main/install.ps1 | iex"
```

This installs `odd-even` to `~/.local/bin` on macOS/Linux, or `%LOCALAPPDATA%\Programs\odd-even` on Windows (added to your PATH; open a new terminal afterwards). Linux needs glibc 2.34+ (Ubuntu 22.04+, Debian 12+, Fedora 35+).

| Variable | Default | Purpose |
|---|---|---|
| `ODD_EVEN_VERSION` | `latest` | Install a specific release, e.g. `v0.1.0` |
| `ODD_EVEN_INSTALL_DIR` | see above | Install somewhere else |

```sh
curl -fsSL https://raw.githubusercontent.com/JonathanV1502/Rust-Cross-Platform-Demo/main/install.sh | ODD_EVEN_VERSION=v0.1.0 sh
```
```powershell
$env:ODD_EVEN_VERSION = "v0.1.0"; irm https://raw.githubusercontent.com/JonathanV1502/Rust-Cross-Platform-Demo/main/install.ps1 | iex
```

### Manual download

Download the binary for your platform from [Releases](https://github.com/JonathanV1502/Rust-Cross-Platform-Demo/releases). Browser downloads need extra steps that the install scripts avoid:

- **macOS / Linux:** `chmod +x` the file.
- **macOS:** also run `xattr -d com.apple.quarantine <file>`; the binary isn't signed by Apple, so macOS blocks it ("Apple could not verify…" or `killed`).
- **Windows:** if SmartScreen warns, choose **More info → Run anyway**.

## Builds

GitHub Actions (`.github/workflows/build.yml`) builds on every push and PR for:

| Platform    | Target                     |
|-------------|----------------------------|
| Linux       | `x86_64-unknown-linux-gnu` |
| macOS ARM   | `aarch64-apple-darwin`     |
| macOS Intel | `x86_64-apple-darwin`      |
| Windows     | `x86_64-pc-windows-msvc`   |

Each run also tests both install scripts against the fresh binaries on Linux, macOS ARM, macOS Intel, and Windows (pwsh and PowerShell 5.1). Binaries are uploaded as workflow artifacts; pushing a `v*` tag attaches them to a GitHub Release once those tests pass.

Local build: `cargo build --release`
