#!/usr/bin/env bash
# Sync the repo's plugin tree into the live plugin folder so the running
# shell hot-reloads exactly what's committed.
#
# Source of truth is the repo; ~/.config/omarchy/plugins/<id> is a
# deployment instance the shell watches. Run after changing repo files:
#
#   scripts/sync.sh            # repo -> live plugin folder
#   scripts/sync.sh <folder>   # override the live plugin folder
#
# Then confirm with scripts/validate.sh.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLUGIN_DIR="${1:-$HOME/.config/omarchy/plugins/woganmay.nature-mood}"

# Guard: the rsync --delete below wipes target subdirectories, so never sync
# into a dangerous path. Reject "/", $HOME, the repo root, and any ancestor
# of them (e.g. /home, /home/wogan, /home/wogan/Work).
TARGET="$(realpath -m "$PLUGIN_DIR")"
REPO_CANON="$(realpath -m "$REPO_ROOT")"
HOME_CANON="$(realpath -m "$HOME")"
forbidden_target() {
  [ "$1" = "/" ] && return 0
  for p in "$HOME_CANON" "$REPO_CANON"; do
    [ "$1" = "$p" ] && return 0
    case "$p" in "$1"/*) return 0 ;; esac
  done
  return 1
}
if forbidden_target "$TARGET"; then
  echo "error: refusing to sync into '$TARGET'" >&2
  exit 1
fi

FILES=(manifest.json BarWidget.qml Model.js Panel.qml FadePlayer.qml CoverFlow.qml)

mkdir -p "$PLUGIN_DIR"

for f in "${FILES[@]}"; do
  cp "$REPO_ROOT/$f" "$PLUGIN_DIR/$f"
done

if command -v rsync >/dev/null 2>&1; then
  rsync -a --delete "$REPO_ROOT/sounds/" "$PLUGIN_DIR/sounds/"
  rsync -a --delete "$REPO_ROOT/images/" "$PLUGIN_DIR/images/"
else
  mkdir -p "$PLUGIN_DIR/sounds" "$PLUGIN_DIR/images"
  cp -r "$REPO_ROOT/sounds/." "$PLUGIN_DIR/sounds/"
  cp -r "$REPO_ROOT/images/." "$PLUGIN_DIR/images/"
fi

echo "SYNCED repo -> $PLUGIN_DIR"
echo "Run scripts/validate.sh to confirm."
