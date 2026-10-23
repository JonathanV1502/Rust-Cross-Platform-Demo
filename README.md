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

macOS (Apple Silicon or Intel) and Linux x86_64:

```sh
curl -fsSL https://raw.githubusercontent.com/JonathanV1502/Rust-Cross-Platform-Demo/main/install.sh | sh
```

This installs `odd-even` to `~/.local/bin`. Set `ODD_EVEN_INSTALL_DIR` to change the location, or `ODD_EVEN_VERSION=v0.1.0` to pin a release (pass them to `sh`, e.g. `... | ODD_EVEN_INSTALL_DIR=~/bin sh`).

### Manual download

Grab the binary for your platform from [Releases](https://github.com/JonathanV1502/Rust-Cross-Platform-Demo/releases) (`uname -m` tells you `arm64` vs `x86_64` on a Mac), then:

```sh
chmod +x odd-even-aarch64-apple-darwin
mv odd-even-aarch64-apple-darwin ~/.local/bin/odd-even
```

On macOS, a browser-downloaded binary is blocked ("Apple could not verify…", or the shell just says `killed`) because it isn't signed by Apple. Clear the quarantine flag to allow it:

```sh
xattr -d com.apple.quarantine ~/.local/bin/odd-even
```

The install script avoids this, since `curl` doesn't set that flag.

On Windows, download `odd-even-x86_64-pc-windows-msvc.exe`. If SmartScreen warns, choose **More info → Run anyway**.

## Builds

GitHub Actions (`.github/workflows/build.yml`) builds on every push and PR for:

| Platform    | Target                     |
|-------------|----------------------------|
| Linux       | `x86_64-unknown-linux-gnu` |
| macOS ARM   | `aarch64-apple-darwin`     |
| macOS Intel | `x86_64-apple-darwin`      |
| Windows     | `x86_64-pc-windows-msvc`   |

Binaries are uploaded as workflow artifacts. Pushing a `v*` tag also attaches them to a GitHub Release.

Local build: `cargo build --release`
