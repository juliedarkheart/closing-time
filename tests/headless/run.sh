#!/usr/bin/env bash
# Headless verification for the Closing Time prototype.
# Runs the Godot editor import plus every headless test in tests/headless.
# Fails if any test exits non-zero or prints a SCRIPT ERROR.
set -uo pipefail

GODOT_BIN="${GODOT_BIN:-godot}"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LOG="${TMPDIR:-/tmp}/closing-time-headless.log"
TEST_TIMEOUT="${TEST_TIMEOUT:-60}"

if ! command -v "$GODOT_BIN" >/dev/null 2>&1; then
    echo "Godot executable not found: $GODOT_BIN (set GODOT_BIN)" >&2
    exit 2
fi

: >"$LOG"
status=0

echo "== editor import ==" | tee -a "$LOG"
timeout 180 "$GODOT_BIN" --headless --path "$PROJECT_DIR" --editor --quit >>"$LOG" 2>&1
editor_status=$?
echo "editor=$editor_status" | tee -a "$LOG"
if [ "$editor_status" -ne 0 ]; then
    status=1
fi

for test in "$PROJECT_DIR"/tests/headless/*_test.gd; do
    name="$(basename "$test")"
    echo "== $name ==" | tee -a "$LOG"
    timeout "$TEST_TIMEOUT" "$GODOT_BIN" --headless --path "$PROJECT_DIR" --script "$test" -- --shift-seed=1001 2>&1 \
        | grep -vE '^(Godot Engine v|$)' | tee -a "$LOG"
    test_status="${PIPESTATUS[0]}"
    echo "status=$test_status" | tee -a "$LOG"
    if [ "$test_status" -ne 0 ]; then
        status=1
    fi
done

script_errors="$(grep -c 'SCRIPT ERROR' "$LOG" || true)"
echo "script_errors=$script_errors"
if [ "$script_errors" -ne 0 ]; then
    status=1
fi

echo "full log: $LOG"
if [ "$status" -eq 0 ]; then
    echo "HEADLESS SUITE PASSED"
else
    echo "HEADLESS SUITE FAILED"
fi
exit "$status"
