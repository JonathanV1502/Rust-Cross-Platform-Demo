#!/bin/sh
# Usage: tests/install_test.sh <install-dir>  (set ODD_EVEN_BASE_URL to test unreleased builds)
set -eu

dir=$1
bin="$dir/odd-even"

fail() {
    echo "FAIL: $*" >&2
    exit 1
}

ODD_EVEN_INSTALL_DIR="$dir" sh install.sh

[ -x "$bin" ] || fail "$bin not installed or not executable"
[ "$("$bin" 5)" = "5 is odd" ] || fail "odd-even 5"
[ "$("$bin" -4)" = "-4 is even" ] || fail "odd-even -4"
code=0; "$bin" abc 2>/dev/null || code=$?
[ "$code" = 1 ] || fail "odd-even abc exited $code, want 1"
code=0; "$bin" 2>/dev/null || code=$?
[ "$code" = 2 ] || fail "odd-even (no args) exited $code, want 2"

if [ "$(uname -s)" = Darwin ]; then
    ! xattr -p com.apple.quarantine "$bin" >/dev/null 2>&1 || fail "quarantine flag is set"
fi

if (unset ODD_EVEN_BASE_URL; ODD_EVEN_VERSION=v0.0.0-nope ODD_EVEN_INSTALL_DIR="$dir/bad" sh install.sh) >/dev/null 2>&1; then
    fail "install of a nonexistent version succeeded"
fi

echo "PASS: $("$bin" 5) ($(file -b "$bin" | cut -d, -f1))"
