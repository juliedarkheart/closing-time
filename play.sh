#!/usr/bin/env bash
# Launch Closing Time on the current display.
# Usage: ./play.sh [seed]        e.g. ./play.sh 1001
set -uo pipefail

GODOT_BIN="${GODOT_BIN:-godot}"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SEED="${1:-}"

if ! command -v "$GODOT_BIN" >/dev/null 2>&1; then
    echo "Godot executable not found: $GODOT_BIN (set GODOT_BIN)" >&2
    exit 2
fi

args=(--path "$PROJECT_DIR")
if [ -n "$SEED" ]; then
    args+=(-- "--shift-seed=$SEED")
    echo "Closing Time — fixed shift seed $SEED"
else
    echo "Closing Time — random shift (seeded from the clock)"
fi

exec "$GODOT_BIN" "${args[@]}"
