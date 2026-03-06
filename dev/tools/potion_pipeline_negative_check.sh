#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

INPUT="runtime/modules/content_pipeline/sources/potions/examples/invalid_potions.json"
REPORT="$(mktemp -t potion_negative_report.XXXXXX.json)"
LOG="$(mktemp -t potion_negative_log.XXXXXX.txt)"
trap 'rm -f "$REPORT" "$LOG"' EXIT

if python3 dev/tools/content_import_potions.py --input "$INPUT" --report "$REPORT" >"$LOG" 2>&1; then
  echo "[potion-negative-check] failed: invalid potion input unexpectedly passed." >&2
  cat "$LOG" >&2
  exit 1
fi

if ! rg -q 'POTION_UNKNOWN_FIELD' "$REPORT"; then
  echo "[potion-negative-check] failed: expected POTION_UNKNOWN_FIELD in report." >&2
  cat "$REPORT" >&2
  exit 1
fi

if ! rg -q 'POTION_INVALID_ART_PATH' "$REPORT"; then
  echo "[potion-negative-check] failed: expected POTION_INVALID_ART_PATH in report." >&2
  cat "$REPORT" >&2
  exit 1
fi

echo "[potion-negative-check] passed."
