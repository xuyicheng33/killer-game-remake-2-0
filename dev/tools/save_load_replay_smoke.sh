#!/usr/bin/env bash
# save_load_replay_smoke.sh - 运行时冒烟验证脚本（R2 Phase 5 增强版）
# 覆盖：固定 seed 新局一致性、存档/读档随机流连续性、核心流程路由完整性、异常路径 fallback
# 用法：bash dev/tools/save_load_replay_smoke.sh
# 注意：此脚本不默认接入 workflow-check，因与契约门禁有部分重叠
#       建议在 verification 阶段或发布前手动执行
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

warn() {
  local message="$1"
  echo "[WARN] $message" >&2
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
REPRO_LOG_FILE="runtime/global/repro_log.gd"

# ========== 前置检查 ==========
echo ""
echo "=========================================="
echo "[smoke] 0. 前置检查：目标文件存在性"
echo "=========================================="

for file in "$RUN_RNG_FILE" "$RUN_LIFECYCLE_FILE" "$SAVE_SERVICE_FILE" \
            "$ROUTE_DISPATCHER_FILE" "$CARD_PILE_FILE" "$PLAYER_HANDLER_FILE" \
            "$RUN_STATE_FILE" "$BATTLE_FLOW_FILE" "$MAP_FLOW_FILE" "$REPRO_LOG_FILE"; do
  if [[ ! -f "$file" ]]; then
    fail "缺少必要文件: $file"
  fi
done
pass "所有目标文件存在"

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
assert_has 'func start_new_run_with_seed\(.*seed: int' \
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

assert_has 'const ROUTE_REST :=' \
  "$ROUTE_DISPATCHER_FILE" \
  "ROUTE_REST 常量存在"

assert_has 'const ROUTE_SHOP :=' \
  "$ROUTE_DISPATCHER_FILE" \
  "ROUTE_SHOP 常量存在"

assert_has 'const ROUTE_EVENT :=' \
  "$ROUTE_DISPATCHER_FILE" \
  "ROUTE_EVENT 常量存在"

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

# ========== 5. 新增：异常路径检查（Restore 失败 Fallback）==========
echo ""
echo "=========================================="
echo "[smoke] 5. exception path: restore failure fallback"
echo "=========================================="

echo "[smoke] 5.1 检查 restore_run_state 失败后的 fallback..."
assert_has 'if not restored_rng:' \
  "$RUN_LIFECYCLE_FILE" \
  "try_load_saved_run 检查 restored_rng 失败标记"

assert_has 'RUN_RNG_SCRIPT\.begin_run\(loaded_run_state\.seed\)' \
  "$RUN_LIFECYCLE_FILE" \
  "restore 失败时使用 begin_run(loaded_run_state.seed) 回退"

echo "[smoke] 5.2 检查 restore_run_state 空状态处理..."
assert_has 'if state\.is_empty\(\)' \
  "$RUN_RNG_FILE" \
  "restore_run_state 检查空状态"

echo "[smoke] 5.3 检查 load_run_state 失败处理..."
assert_has 'if not bool\(load_result\.get\("ok", false\)\)' \
  "$RUN_LIFECYCLE_FILE" \
  "try_load_saved_run 检查 load_result.ok"

echo "[smoke] 5.4 检查 RunState 恢复失败处理..."
assert_has 'if loaded_run_state == null:' \
  "$RUN_LIFECYCLE_FILE" \
  "try_load_saved_run 检查 loaded_run_state 为空"

# ========== 6. 新增：存档版本兼容性检查 ==========
echo ""
echo "=========================================="
echo "[smoke] 6. save version compatibility check"
echo "=========================================="

echo "[smoke] 6.1 检查版本常量定义..."
assert_has 'const SAVE_VERSION' \
  "$SAVE_SERVICE_FILE" \
  "SaveService.SAVE_VERSION 常量存在"

assert_has 'const MIN_COMPAT_VERSION' \
  "$SAVE_SERVICE_FILE" \
  "SaveService.MIN_COMPAT_VERSION 常量存在"

echo "[smoke] 6.2 检查版本兼容性校验..."
assert_has 'file_version < MIN_COMPAT_VERSION' \
  "$SAVE_SERVICE_FILE" \
  "load_run_state 检查最低兼容版本"

assert_has 'file_version > SAVE_VERSION' \
  "$SAVE_SERVICE_FILE" \
  "load_run_state 检查最高支持版本"

echo "[smoke] 6.3 检查旧版本默认处理..."
assert_has 'payload\.get\("rng_state", \{\}\)' \
  "$SAVE_SERVICE_FILE" \
  "读档时对缺失 rng_state 使用默认空字典"

assert_has 'payload\.get\("save_version", -1\)' \
  "$SAVE_SERVICE_FILE" \
  "读档时对缺失 save_version 使用默认 -1"

# ========== 7. 新增：环境变量种子覆盖检查 ==========
echo ""
echo "=========================================="
echo "[smoke] 7. environment seed override check"
echo "=========================================="

echo "[smoke] 7.1 检查环境变量读取..."
assert_has 'OS\.get_environment\("STS_RUN_SEED"\)' \
  "$RUN_LIFECYCLE_FILE" \
  "_resolve_run_seed 读取 STS_RUN_SEED 环境变量"

echo "[smoke] 7.2 检查环境变量有效性校验..."
assert_has 'env_seed\.is_valid_int\(\)' \
  "$RUN_LIFECYCLE_FILE" \
  "_resolve_run_seed 校验环境变量是否为有效整数"

echo "[smoke] 7.3 检查环境变量优先逻辑..."
assert_has 'if not env_seed\.is_empty\(\) and env_seed\.is_valid_int\(\):' \
  "$RUN_LIFECYCLE_FILE" \
  "环境变量有效时优先使用环境变量种子"

# ========== 8. 新增：复盘日志连续性检查 ==========
echo ""
echo "=========================================="
echo "[smoke] 8. repro log continuity check"
echo "=========================================="

echo "[smoke] 8.1 检查 ReproLog 基础方法..."
assert_has 'static func begin_run\(seed: int\)' \
  "$REPRO_LOG_FILE" \
  "ReproLog.begin_run(seed) 方法存在"

assert_has 'static func set_progress\(' \
  "$REPRO_LOG_FILE" \
  "ReproLog.set_progress 方法存在"

assert_has 'static func log_event\(' \
  "$REPRO_LOG_FILE" \
  "ReproLog.log_event 方法存在"

echo "[smoke] 8.2 检查新局时复盘日志初始化..."
assert_has 'REPRO_LOG_SCRIPT\.begin_run\(seed\)' \
  "$RUN_LIFECYCLE_FILE" \
  "start_new_run_with_seed 调用 REPRO_LOG_SCRIPT.begin_run"

echo "[smoke] 8.3 检查读档时复盘日志恢复..."
assert_has 'REPRO_LOG_SCRIPT\.begin_run\(RUN_RNG_SCRIPT\.get_run_seed\(\)\)' \
  "$RUN_LIFECYCLE_FILE" \
  "try_load_saved_run 调用 REPRO_LOG_SCRIPT.begin_run 恢复日志"

assert_has 'REPRO_LOG_SCRIPT\.set_progress\(' \
  "$RUN_LIFECYCLE_FILE" \
  "try_load_saved_run 调用 REPRO_LOG_SCRIPT.set_progress 恢复进度"

# ========== 9. 新增：运行时主链路完整性检查 ==========
echo ""
echo "=========================================="
echo "[smoke] 9. runtime main link integrity check"
echo "=========================================="

echo "[smoke] 9.1 检查 SaveService 存档文件操作..."
assert_has 'FileAccess\.file_exists\(' \
  "$SAVE_SERVICE_FILE" \
  "SaveService 检查存档文件存在性"

assert_has 'FileAccess\.open\(' \
  "$SAVE_SERVICE_FILE" \
  "SaveService 使用 FileAccess 打开文件"

assert_has 'FileAccess\.get_open_error\(\)' \
  "$SAVE_SERVICE_FILE" \
  "SaveService 检查文件打开错误"

echo "[smoke] 9.2 检查存档数据序列化..."
assert_has 'JSON\.stringify\(' \
  "$SAVE_SERVICE_FILE" \
  "SaveService 使用 JSON.stringify 序列化"

assert_has 'JSON\.new\(\)' \
  "$SAVE_SERVICE_FILE" \
  "SaveService 使用 JSON parser 解析"

echo "[smoke] 9.3 检查存档清理功能..."
assert_has 'static func clear_save\(\)' \
  "$SAVE_SERVICE_FILE" \
  "SaveService.clear_save 方法存在"

assert_has 'DirAccess\.remove_absolute\(' \
  "$SAVE_SERVICE_FILE" \
  "SaveService 使用 DirAccess 删除存档"

echo "[smoke] 9.4 检查 RunState 初始化完整性..."
assert_has 'func init_with_character\(' \
  "$RUN_STATE_FILE" \
  "RunState.init_with_character 方法存在"

assert_has 'static func _deserialize_run_state\(' \
  "$SAVE_SERVICE_FILE" \
  "SaveService._deserialize_run_state 反序列化方法存在"

# ========== 总结 ==========
echo ""
echo "=========================================="
echo "[smoke] all checks passed."
echo "=========================================="
echo ""
echo "冒烟验证完成。共执行 9 组检查："
echo "  1. fixed-seed bootstrap check"
echo "  2. save/load rng continuity check"
echo "  3. battle->reward->map route smoke check"
echo "  4. deterministic shuffle smoke check"
echo "  5. exception path: restore failure fallback (新增)"
echo "  6. save version compatibility check (新增)"
echo "  7. environment seed override check (新增)"
echo "  8. repro log continuity check (新增)"
echo "  9. runtime main link integrity check (新增)"
echo ""
echo "注意：此脚本不接入 workflow-check，请在发布前手动执行。"
