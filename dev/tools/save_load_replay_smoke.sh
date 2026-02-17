#!/usr/bin/env bash
# save_load_replay_smoke.sh - 冒烟验证脚本
# 覆盖：固定 seed 新局一致性、存档/读档随机流连续性、核心流程路由完整性
# 用法：bash dev/tools/save_load_replay_smoke.sh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

# ========== 辅助函数 ==========
fail() {
  local message="$1"
  echo "[FAIL] $message" >&2
  exit 1
}

pass() {
  local message="$1"
  echo "[PASS] $message"
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

assert_not_has() {
  local pattern="$1"
  local file="$2"
  local label="$3"
  if grep -Eq "$pattern" "$file" 2>/dev/null; then
    echo "  [context] unexpected matches in $file:" >&2
    grep -En "$pattern" "$file" >&2 || true
    fail "$label (found forbidden pattern '$pattern' in '$file')"
  fi
  pass "$label"
}

# ========== 目标文件 ==========
RUN_RNG_FILE="runtime/global/run_rng.gd"
RUN_LIFECYCLE_FILE="runtime/modules/run_flow/run_lifecycle_service.gd"
SAVE_SERVICE_FILE="runtime/modules/persistence/save_service.gd"
ROUTE_DISPATCHER_FILE="runtime/modules/run_flow/route_dispatcher.gd"
CARD_PILE_FILE="content/custom_resources/card_pile.gd"
PLAYER_HANDLER_FILE="runtime/scenes/player/player_handler.gd"
RUN_STATE_FILE="runtime/modules/run_meta/run_state.gd"
BATTLE_FLOW_FILE="runtime/modules/run_flow/battle_flow_service.gd"
MAP_FLOW_FILE="runtime/modules/run_flow/map_flow_service.gd"

# ========== 1. Fixed-Seed Bootstrap Check ==========
echo ""
echo "=========================================="
echo "[smoke] 1. fixed-seed bootstrap check"
echo "=========================================="

echo "[smoke] 1.1 检查 RunRng 支持固定种子初始化..."
assert_has 'static func begin_run\(seed: int\)' \
  "$RUN_RNG_FILE" \
  "RunRng.begin_run(seed) 方法存在"

assert_has 'static func get_run_seed\(\)' \
  "$RUN_RNG_FILE" \
  "RunRng.get_run_seed() 方法存在"

assert_has 'const DEFAULT_SEED' \
  "$RUN_RNG_FILE" \
  "RunRng.DEFAULT_SEED 常量存在"

echo "[smoke] 1.2 检查 RunLifecycleService 支持固定种子新局..."
assert_has 'func start_new_run_with_seed\(.*seed: int\)' \
  "$RUN_LIFECYCLE_FILE" \
  "RunLifecycleService.start_new_run_with_seed(seed) 方法存在"

assert_has 'RUN_RNG_SCRIPT\.begin_run\(seed\)' \
  "$RUN_LIFECYCLE_FILE" \
  "start_new_run_with_seed 调用 RunRng.begin_run(seed)"

echo "[smoke] 1.3 检查 RunState 保存 seed..."
assert_has 'var seed: int' \
  "$RUN_STATE_FILE" \
  "RunState.seed 字段存在"

# ========== 2. Save/Load RNG Continuity Check ==========
echo ""
echo "=========================================="
echo "[smoke] 2. save/load rng continuity check"
echo "=========================================="

echo "[smoke] 2.1 检查 RunRng 支持状态导出/恢复..."
assert_has 'static func export_run_state\(\)' \
  "$RUN_RNG_FILE" \
  "RunRng.export_run_state() 方法存在"

assert_has 'static func restore_run_state\(state: Dictionary\)' \
  "$RUN_RNG_FILE" \
  "RunRng.restore_run_state(state) 方法存在"

assert_has '"run_seed"' \
  "$RUN_RNG_FILE" \
  "export_run_state 包含 run_seed"

assert_has '"streams"' \
  "$RUN_RNG_FILE" \
  "export_run_state 包含 streams"

echo "[smoke] 2.2 检查 SaveService 存档时导出 RNG 状态..."
assert_has 'RUN_RNG_SCRIPT\.export_run_state\(\)' \
  "$SAVE_SERVICE_FILE" \
  "_serialize_run_state 调用 RUN_RNG_SCRIPT.export_run_state()"

assert_has '"rng_state"' \
  "$SAVE_SERVICE_FILE" \
  "存档 payload 包含 rng_state 字段"

echo "[smoke] 2.3 检查 SaveService 读档时返回 RNG 状态..."
assert_has 'result\["rng_state"\] = payload\.get\("rng_state"' \
  "$SAVE_SERVICE_FILE" \
  "load_run_state 返回 rng_state 字段"

echo "[smoke] 2.4 检查 RunLifecycleService 读档时恢复 RNG..."
assert_has 'RUN_RNG_SCRIPT\.restore_run_state\(' \
  "$RUN_LIFECYCLE_FILE" \
  "try_load_saved_run 调用 RUN_RNG_SCRIPT.restore_run_state()"

assert_has 'RUN_RNG_SCRIPT\.begin_run\(' \
  "$RUN_LIFECYCLE_FILE" \
  "restore 失败时有 begin_run 回退逻辑"

# ========== 3. Battle->Reward->Map Route Smoke Check ==========
echo ""
echo "=========================================="
echo "[smoke] 3. battle->reward->map route smoke check"
echo "=========================================="

echo "[smoke] 3.1 检查路由常量定义..."
assert_has 'const ROUTE_MAP :=' \
  "$ROUTE_DISPATCHER_FILE" \
  "ROUTE_MAP 常量存在"

assert_has 'const ROUTE_BATTLE :=' \
  "$ROUTE_DISPATCHER_FILE" \
  "ROUTE_BATTLE 常量存在"

assert_has 'const ROUTE_REWARD :=' \
  "$ROUTE_DISPATCHER_FILE" \
  "ROUTE_REWARD 常量存在"

assert_has 'const ROUTE_GAME_OVER :=' \
  "$ROUTE_DISPATCHER_FILE" \
  "ROUTE_GAME_OVER 常量存在"

echo "[smoke] 3.2 检查 BattleFlowService 战斗结束路由..."
assert_has 'func resolve_battle_completion\(' \
  "$BATTLE_FLOW_FILE" \
  "BattleFlowService.resolve_battle_completion 方法存在"

assert_has 'ROUTE_REWARD' \
  "$BATTLE_FLOW_FILE" \
  "BattleFlowService 引用 ROUTE_REWARD"

assert_has 'ROUTE_GAME_OVER' \
  "$BATTLE_FLOW_FILE" \
  "BattleFlowService 引用 ROUTE_GAME_OVER"

echo "[smoke] 3.3 检查 MapFlowService 地图节点路由..."
assert_has 'func enter_map_node\(' \
  "$MAP_FLOW_FILE" \
  "MapFlowService.enter_map_node 方法存在"

assert_has 'route_for_map_node_type\(' \
  "$MAP_FLOW_FILE" \
  "MapFlowService 调用 route_for_map_node_type"

echo "[smoke] 3.4 检查路由结果构造器..."
assert_has 'func make_result\(next_route' \
  "$ROUTE_DISPATCHER_FILE" \
  "RunRouteDispatcher.make_result 方法存在"

assert_has '"next_route"' \
  "$ROUTE_DISPATCHER_FILE" \
  "make_result 返回 next_route 字段"

# ========== 4. Deterministic Shuffle Smoke Check ==========
echo ""
echo "=========================================="
echo "[smoke] 4. deterministic shuffle smoke check"
echo "=========================================="

echo "[smoke] 4.1 检查 CardPile 确定性洗牌实现..."
assert_has 'func shuffle_with_rng\(stream_key: String\)' \
  "$CARD_PILE_FILE" \
  "CardPile.shuffle_with_rng(stream_key) 方法存在"

assert_has 'RunRng\.randi_range\(stream_key' \
  "$CARD_PILE_FILE" \
  "shuffle_with_rng 使用 RunRng.randi_range"

echo "[smoke] 4.2 检查 PlayerHandler 战斗洗牌调用..."
assert_has 'shuffle_with_rng\("battle_start_shuffle"\)' \
  "$PLAYER_HANDLER_FILE" \
  "start_battle 使用 shuffle_with_rng(\"battle_start_shuffle\")"

assert_has 'shuffle_with_rng\("reshuffle_discard"\)' \
  "$PLAYER_HANDLER_FILE" \
  "reshuffle_deck_from_discard 使用 shuffle_with_rng(\"reshuffle_discard\")"

# ========== 总结 ==========
echo ""
echo "=========================================="
echo "[smoke] all checks passed."
echo "=========================================="
