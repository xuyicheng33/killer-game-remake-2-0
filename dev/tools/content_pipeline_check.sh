#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

REPORT_DIR="runtime/modules/content_pipeline/reports"
mkdir -p "$REPORT_DIR"

echo "[content-pipeline-check] running all content importers..."

failed=0

echo "[content-pipeline-check] 1/6 cards..."
if python3 dev/tools/content_import_cards.py --report "$REPORT_DIR/card_import_report.json" >/dev/null 2>&1; then
  echo "[content-pipeline-check]   cards: ok"
else
  echo "[content-pipeline-check]   cards: FAILED"
  python3 dev/tools/content_import_cards.py --report "$REPORT_DIR/card_import_report.json" 2>&1 || true
  failed=1
fi

echo "[content-pipeline-check] 2/6 enemies..."
if python3 dev/tools/content_import_enemies.py --input runtime/modules/content_pipeline/sources/enemies/examples/act1_enemies.json --report "$REPORT_DIR/enemy_import_report.json" >/dev/null 2>&1; then
  echo "[content-pipeline-check]   enemies: ok"
else
  echo "[content-pipeline-check]   enemies: FAILED"
  python3 dev/tools/content_import_enemies.py --input runtime/modules/content_pipeline/sources/enemies/examples/act1_enemies.json --report "$REPORT_DIR/enemy_import_report.json" 2>&1 || true
  failed=1
fi

echo "[content-pipeline-check] 3/6 relics..."
if python3 dev/tools/content_import_relics.py --input runtime/modules/content_pipeline/sources/relics/examples/common_relics.json --report "$REPORT_DIR/relic_import_report.json" >/dev/null 2>&1; then
  echo "[content-pipeline-check]   relics: ok"
else
  echo "[content-pipeline-check]   relics: FAILED"
  python3 dev/tools/content_import_relics.py --input runtime/modules/content_pipeline/sources/relics/examples/common_relics.json --report "$REPORT_DIR/relic_import_report.json" 2>&1 || true
  failed=1
fi

echo "[content-pipeline-check] 4/6 potions..."
if python3 dev/tools/content_import_potions.py --input runtime/modules/content_pipeline/sources/potions/examples/base_potions.json --report "$REPORT_DIR/potion_import_report.json" >/dev/null 2>&1; then
  echo "[content-pipeline-check]   potions: ok"
else
  echo "[content-pipeline-check]   potions: FAILED"
  python3 dev/tools/content_import_potions.py --input runtime/modules/content_pipeline/sources/potions/examples/base_potions.json --report "$REPORT_DIR/potion_import_report.json" 2>&1 || true
  failed=1
fi

echo "[content-pipeline-check] 5/6 events..."
if python3 dev/tools/content_import_events.py --input runtime/modules/content_pipeline/sources/events/examples/baseline_events.json --report "$REPORT_DIR/event_import_report.json" >/dev/null 2>&1; then
  echo "[content-pipeline-check]   events: ok"
else
  echo "[content-pipeline-check]   events: FAILED"
  python3 dev/tools/content_import_events.py --input runtime/modules/content_pipeline/sources/events/examples/baseline_events.json --report "$REPORT_DIR/event_import_report.json" 2>&1 || true
  failed=1
fi

echo "[content-pipeline-check] 6/6 potion negative contract..."
if bash dev/tools/potion_pipeline_negative_check.sh >/dev/null 2>&1; then
  echo "[content-pipeline-check]   potion negative contract: ok"
else
  echo "[content-pipeline-check]   potion negative contract: FAILED"
  bash dev/tools/potion_pipeline_negative_check.sh 2>&1 || true
  failed=1
fi

if [[ "$failed" -eq 1 ]]; then
  echo "[content-pipeline-check] FAILED: one or more importers failed."
  echo "[content-pipeline-check] reports: $REPORT_DIR/"
  exit 1
fi

echo "[content-pipeline-check] ok: all importers passed."
echo "[content-pipeline-check] reports: $REPORT_DIR/"
