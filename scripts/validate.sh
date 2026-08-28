#!/usr/bin/env bash
# Validate an Omarchy plugin folder: manifest rules + QML lint against the shell.
#
# qmllint cannot resolve the shell's qs.Ui / qs.Commons modules from the
# qmldir-declared layout (/usr/share/omarchy/shell/{Ui,Commons}), so this
# copies them into a directory-shaped import path first.
#
# Usage: scripts/validate.sh [plugin-dir]
# Default: the live dev clone.
set -euo pipefail

PLUGIN_DIR="${1:-$HOME/.config/omarchy/plugins/woganmay.nature-mood}"
SHIM="${TMPDIR:-/tmp}/qmlshim"

omarchy plugin validate "$PLUGIN_DIR"

mkdir -p "$SHIM/qs"
cp -r /usr/share/omarchy/shell/Ui "$SHIM/qs/Ui"
cp -r /usr/share/omarchy/shell/Commons "$SHIM/qs/Commons"

for f in "$PLUGIN_DIR"/*.qml; do
  [ -f "$f" ] || continue
  /usr/lib/qt6/bin/qmllint -I "$SHIM" -I /usr/share/omarchy/shell "$f"
done

echo "VALIDATION OK: $PLUGIN_DIR"
