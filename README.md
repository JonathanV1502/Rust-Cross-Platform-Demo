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
