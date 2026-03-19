#!/bin/bash
set -euo pipefail

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$APP_DIR/lightube"

TARGET_DIR="/usr/local/bin"
TARGET="$TARGET_DIR/lightube"

if [ ! -f "$SRC" ]; then
  echo "Error: lightube script not found at $SRC" >&2
  exit 1
fi

if [ ! -x "$SRC" ]; then
  chmod +x "$SRC"
fi

needs_sudo() {
  [ "$(id -u)" -ne 0 ] && [ ! -w "$TARGET_DIR" ]
}

run() {
  if needs_sudo; then
    sudo "$@"
  else
    "$@"
  fi
}

run mkdir -p "$TARGET_DIR"

# Prefer symlink so updates are instant
if [ -e "$TARGET" ] || [ -L "$TARGET" ]; then
  run rm -f "$TARGET"
fi

run ln -s "$SRC" "$TARGET"

echo "Installed: $TARGET -> $SRC"
echo "You can now run: lightube"

