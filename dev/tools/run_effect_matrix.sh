#!/bin/bash
# run_effect_matrix.sh - 运行卡牌/遗物/药水全量矩阵测试并输出报告
# 用法: bash dev/tools/run_effect_matrix.sh [timeout_seconds]

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

GODOT="${GODOT:-godot}"
TIMEOUT="${1:-240}"
REPORT_DIR="dev/reports"
REPORT_FILE="${REPORT_DIR}/effect_matrix_report.json"

mkdir -p "$REPORT_DIR"

declare -a CASE_NAMES=("card_matrix" "relic_matrix" "potion_matrix")
declare -a CASE_PATHS=(
	"res://dev/tests/integration/test_card_matrix.gd"
	"res://dev/tests/integration/test_relic_matrix.gd"
	"res://dev/tests/integration/test_potion_matrix.gd"
)

timestamp_utc() {
	date -u +"%Y-%m-%dT%H:%M:%SZ"
}

escape_json() {
	local raw="$1"
	printf '%s' "$raw" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

echo "[Matrix] Running effect matrix tests (timeout: ${TIMEOUT}s)"
echo "[Matrix] Using GODOT=${GODOT}"

overall_failed=0
results_json=""

for i in "${!CASE_NAMES[@]}"; do
	name="${CASE_NAMES[$i]}"
	path="${CASE_PATHS[$i]}"
	start_epoch="$(date +%s)"
	start_utc="$(timestamp_utc)"

	echo "[Matrix] -> ${name} (${path})"
	if GODOT="$GODOT" bash dev/tools/run_gut_test_file.sh "$path" "$TIMEOUT"; then
		status="passed"
	else
		status="failed"
		overall_failed=1
	fi

	end_epoch="$(date +%s)"
	duration_sec=$((end_epoch - start_epoch))
	end_utc="$(timestamp_utc)"

	entry=$(cat <<EOF
{"name":"$(escape_json "$name")","test":"$(escape_json "$path")","status":"$status","started_at":"$start_utc","finished_at":"$end_utc","duration_sec":$duration_sec}
EOF
)
	if [ -n "$results_json" ]; then
		results_json="${results_json},${entry}"
	else
		results_json="${entry}"
	fi
done

generated_at="$(timestamp_utc)"
summary_status="passed"
if [ "$overall_failed" -ne 0 ]; then
	summary_status="failed"
fi

cat >"$REPORT_FILE" <<EOF
{
  "generated_at": "$generated_at",
  "godot": "$(escape_json "$GODOT")",
  "timeout_sec": $TIMEOUT,
  "status": "$summary_status",
  "results": [
    $results_json
  ]
}
EOF

echo "[Matrix] Report written: ${REPORT_FILE}"

if [ "$overall_failed" -ne 0 ]; then
	echo "[Matrix] FAILED: one or more matrix tests failed"
	exit 1
fi

echo "[Matrix] All matrix tests passed"
