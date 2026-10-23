#!/bin/sh
# Installs the odd-even binary from GitHub Releases.
#   curl -fsSL https://raw.githubusercontent.com/JonathanV1502/Rust-Cross-Platform-Demo/main/install.sh | sh
# Env: ODD_EVEN_VERSION (default: latest), ODD_EVEN_INSTALL_DIR (default: ~/.local/bin)
set -eu

REPO="JonathanV1502/Rust-Cross-Platform-Demo"
RELEASES="https://github.com/$REPO/releases"
VERSION="${ODD_EVEN_VERSION:-latest}"
INSTALL_DIR="${ODD_EVEN_INSTALL_DIR:-$HOME/.local/bin}"

err() {
    echo "error: $*" >&2
    exit 1
}

os=$(uname -s)
arch=$(uname -m)
case "$os/$arch" in
    Darwin/arm64) target=aarch64-apple-darwin ;;
    Darwin/x86_64)
        # An Intel shell under Rosetta on Apple Silicon still reports x86_64.
        if [ "$(sysctl -n sysctl.proc_translated 2>/dev/null || echo 0)" = 1 ]; then
            target=aarch64-apple-darwin
        else
            target=x86_64-apple-darwin
        fi
        ;;
    Linux/x86_64) target=x86_64-unknown-linux-gnu ;;
    MINGW* | MSYS* | CYGWIN*) err "on Windows, download odd-even-x86_64-pc-windows-msvc.exe from $RELEASES" ;;
    *) err "unsupported platform $os/$arch (supported: macOS arm64/x86_64, Linux x86_64). See $RELEASES" ;;
esac

if [ "$VERSION" = latest ]; then
    url="$RELEASES/latest/download/odd-even-$target"
else
    url="$RELEASES/download/$VERSION/odd-even-$target"
fi

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

echo "Downloading $url"
# curl/wget don't set macOS's quarantine flag, so Gatekeeper won't block the unsigned binary.
if command -v curl >/dev/null 2>&1; then
    curl -fsSL -o "$tmp" "$url" || err "download failed (does release '$VERSION' exist?)"
elif command -v wget >/dev/null 2>&1; then
    wget -qO "$tmp" "$url" || err "download failed (does release '$VERSION' exist?)"
else
    err "need curl or wget"
fi

chmod +x "$tmp"
mkdir -p "$INSTALL_DIR"
mv "$tmp" "$INSTALL_DIR/odd-even"
if [ "$os" = Darwin ]; then
    xattr -d com.apple.quarantine "$INSTALL_DIR/odd-even" 2>/dev/null || true
fi

"$INSTALL_DIR/odd-even" 0 >/dev/null || err "installed binary failed to run"
echo "Installed odd-even to $INSTALL_DIR/odd-even"

case ":$PATH:" in
    *":$INSTALL_DIR:"*) ;;
    *)
        echo
        echo "$INSTALL_DIR is not on your PATH. Add this to ~/.zshrc or ~/.bashrc:"
        echo "  export PATH=\"$INSTALL_DIR:\$PATH\""
        ;;
esac
