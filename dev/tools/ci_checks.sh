#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

echo "[ci-checks] running contract and structure gates..."
bash dev/tools/repo_structure_check.sh
bash dev/tools/ui_shell_contract_check.sh
bash dev/tools/run_flow_contract_check.sh
bash dev/tools/run_flow_payload_contract_check.sh
bash dev/tools/run_flow_result_shape_check.sh
bash dev/tools/run_flow_regression_check.sh
bash dev/tools/battle_relic_injection_contract_check.sh
bash dev/tools/module_scene_type_dependency_check.sh
bash dev/tools/dynamic_call_guard_check.sh
bash dev/tools/run_lifecycle_contract_check.sh
bash dev/tools/persistence_contract_check.sh
bash dev/tools/seed_rng_contract_check.sh
bash dev/tools/scene_runstate_write_check.sh
bash dev/tools/scene_nested_state_write_check.sh
bash dev/tools/type_safety_check.sh

if command -v godot >/dev/null 2>&1; then
	 echo "[ci-checks] godot detected, running smoke tests..."
	 GODOT=godot bash dev/tools/run_gut_test_file.sh res://dev/tests/test_gut_smoke.gd 120
	 GODOT=godot bash dev/tools/run_gut_test_file.sh res://dev/tests/unit/test_compile_regression_smoke.gd 120
	 GODOT=godot bash dev/tools/run_gut_test_file.sh res://dev/tests/unit/test_run_flow.gd 180
	else
  echo "[ci-checks] godot not found, skipping engine tests."
fi

echo "[ci-checks] passed."
