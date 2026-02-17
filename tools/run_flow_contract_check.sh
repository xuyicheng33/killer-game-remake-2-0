#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

MAP_FLOW_FILE="modules/run_flow/map_flow_service.gd"
BATTLE_FLOW_FILE="modules/run_flow/battle_flow_service.gd"
ROUTE_FILE="modules/run_flow/route_dispatcher.gd"

assert_has() {
  local pattern="$1"
  local file="$2"
  local label="$3"
  if rg -n "$pattern" "$file" >/dev/null; then
    echo "[PASS] $label"
    return
  fi
  echo "[FAIL] $label" >&2
  echo "  pattern: $pattern" >&2
  echo "  file: $file" >&2
  exit 1
}

echo "[run_flow_contract] checking map node type -> next_route mapping..."
assert_has "MapNodeData.NodeType.BATTLE, MapNodeData.NodeType.ELITE, MapNodeData.NodeType.BOSS" "$ROUTE_FILE" "battle/elite/boss route group"
assert_has "return ROUTE_BATTLE" "$ROUTE_FILE" "battle route return"
assert_has "MapNodeData.NodeType.REST" "$ROUTE_FILE" "rest route branch"
assert_has "return ROUTE_REST" "$ROUTE_FILE" "rest route return"
assert_has "MapNodeData.NodeType.SHOP" "$ROUTE_FILE" "shop route branch"
assert_has "return ROUTE_SHOP" "$ROUTE_FILE" "shop route return"
assert_has "MapNodeData.NodeType.EVENT" "$ROUTE_FILE" "event route branch"
assert_has "return ROUTE_EVENT" "$ROUTE_FILE" "event route return"

echo "[run_flow_contract] checking map_flow payload contract..."
assert_has "\"node_type\": node.type" "$MAP_FLOW_FILE" "map_flow enter payload node_type"
assert_has "\"reward_gold\": node.reward_gold" "$MAP_FLOW_FILE" "map_flow enter payload reward_gold"
assert_has "\"bonus_log\": bonus_log" "$MAP_FLOW_FILE" "non-battle completion bonus_log payload"
assert_has "RunRouteDispatcher.ROUTE_MAP" "$MAP_FLOW_FILE" "non-battle completion next_route map"

echo "[run_flow_contract] checking battle_flow win/lose routes..."
assert_has "RunRouteDispatcher.ROUTE_REWARD" "$BATTLE_FLOW_FILE" "battle win next_route reward"
assert_has "\"reward_gold\": maxi\\(0, reward_gold\\)" "$BATTLE_FLOW_FILE" "battle win payload reward_gold"
assert_has "RunRouteDispatcher.ROUTE_GAME_OVER" "$BATTLE_FLOW_FILE" "battle lose next_route game_over"
assert_has "\"game_over_text\": _build_game_over_text\\(run_state\\)" "$BATTLE_FLOW_FILE" "battle lose payload game_over_text"

echo "[run_flow_contract] all checks passed."
