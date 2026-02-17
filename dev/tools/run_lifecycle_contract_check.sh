#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

APP_FILE="runtime/scenes/app/app.gd"

fail() {
  local message="$1"
  echo "[FAIL] $message" >&2
  exit 1
}

pass() {
  local message="$1"
  echo "[PASS] $message"
}

assert_not_has() {
  local pattern="$1"
  local file="$2"
  local label="$3"
  if grep -Eq "$pattern" "$file" 2>/dev/null; then
    echo "[context] unexpected matches in $file:" >&2
    grep -En "$pattern" "$file" >&2 || true
    fail "$label (found forbidden pattern '$pattern' in '$file')"
  fi
  pass "$label"
}

assert_has() {
  local pattern="$1"
  local file="$2"
  local label="$3"
  if grep -Eq "$pattern" "$file" 2>/dev/null; then
    pass "$label"
    return
  fi
  echo "  pattern: $pattern" >&2
  echo "  file: $file" >&2
  fail "$label"
}

echo "[run_lifecycle_contract] checking forbidden direct dependencies in app.gd..."

# 检查 app.gd 不得直接 preload/use persistence/save_service.gd
assert_not_has 'preload\("res://runtime/modules/persistence/save_service\.gd"\)' \
  "$APP_FILE" \
  "app.gd must not directly preload save_service.gd"

assert_not_has 'preload\("res://runtime/modules/persistence/save_service\.tscn"\)' \
  "$APP_FILE" \
  "app.gd must not directly preload save_service.tscn"

# 检查 app.gd 不得直接 preload/use run_rng.gd
assert_not_has 'preload\("res://runtime/global/run_rng\.gd"\)' \
  "$APP_FILE" \
  "app.gd must not directly preload run_rng.gd"

# 检查 app.gd 不得直接 preload/use repro_log.gd
assert_not_has 'preload\("res://runtime/global/repro_log\.gd"\)' \
  "$APP_FILE" \
  "app.gd must not directly preload repro_log.gd"

# 检查 app.gd 不得直接实例化或使用这些模块的 class_name
assert_not_has 'SaveService\.new\(' \
  "$APP_FILE" \
  "app.gd must not directly instantiate SaveService"

assert_not_has 'RunRng\.new\(' \
  "$APP_FILE" \
  "app.gd must not directly instantiate RunRng"

assert_not_has 'ReproLog\.new\(' \
  "$APP_FILE" \
  "app.gd must not directly instantiate ReproLog"

echo "[run_lifecycle_contract] checking lifecycle service calls through run_flow_service..."

# 检查 app.gd 必须通过 run_flow_service.lifecycle_service 调用生命周期方法
assert_has 'run_flow_service\.lifecycle_service\.start_new_run' \
  "$APP_FILE" \
  "app.gd must call start_new_run through run_flow_service.lifecycle_service"

assert_has 'run_flow_service\.lifecycle_service\.try_load_saved_run' \
  "$APP_FILE" \
  "app.gd must call try_load_saved_run through run_flow_service.lifecycle_service"

assert_has 'run_flow_service\.lifecycle_service\.save_checkpoint' \
  "$APP_FILE" \
  "app.gd must call save_checkpoint through run_flow_service.lifecycle_service"

echo "[run_lifecycle_contract] all checks passed."
