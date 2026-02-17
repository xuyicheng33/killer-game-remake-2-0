#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

MAP_FLOW_FILE="modules/run_flow/map_flow_service.gd"
BATTLE_FLOW_FILE="modules/run_flow/battle_flow_service.gd"
ROUTE_FILE="modules/run_flow/route_dispatcher.gd"

fail() {
  local message="$1"
  echo "[FAIL] $message" >&2
  exit 1
}

assert_has() {
  local pattern="$1"
  local file="$2"
  local label="$3"
  if rg -n "$pattern" "$file" >/dev/null; then
    echo "[PASS] $label"
    return
  fi
  echo "  pattern: $pattern" >&2
  echo "  file: $file" >&2
  fail "$label"
}

assert_unique_route_constant() {
  local const_name="$1"
  local route_value="$2"
  local pattern="^const ${const_name}[[:space:]]*:=[[:space:]]*\"${route_value}\"$"
  local matches
  matches="$(rg -n --glob '*.gd' "$pattern" modules/run_flow scenes || true)"

  if [[ -z "$matches" ]]; then
    fail "missing ${const_name} constant definition for value '${route_value}'"
  fi

  local match_count
  match_count="$(printf '%s\n' "$matches" | awk 'NF{count++} END{print count+0}')"
  if [[ "$match_count" -ne 1 ]]; then
    echo "[context] route constant matches for ${const_name}:" >&2
    printf '%s\n' "$matches" >&2
    fail "${const_name} should have a single definition in route_dispatcher"
  fi

  if [[ "$matches" != "$ROUTE_FILE:"* ]]; then
    echo "[context] ${const_name} unexpected location: $matches" >&2
    fail "${const_name} must be defined in ${ROUTE_FILE}"
  fi

  echo "[PASS] ${const_name} single-point definition"
}

echo "[run_flow_contract] checking route constants single-point definition..."
assert_unique_route_constant "ROUTE_MAP" "map"
assert_unique_route_constant "ROUTE_BATTLE" "battle"
assert_unique_route_constant "ROUTE_REWARD" "reward"
assert_unique_route_constant "ROUTE_REST" "rest"
assert_unique_route_constant "ROUTE_SHOP" "shop"
assert_unique_route_constant "ROUTE_EVENT" "event"
assert_unique_route_constant "ROUTE_GAME_OVER" "game_over"
assert_has "\"next_route\": next_route" "$ROUTE_FILE" "route dispatcher output contains next_route key"

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
assert_has "var payload := \\{" "$MAP_FLOW_FILE" "map_flow defines payload dictionary"
assert_has "\"accepted\": true" "$MAP_FLOW_FILE" "map_flow enter payload accepted"
assert_has "\"node_id\": node.id" "$MAP_FLOW_FILE" "map_flow enter payload node_id"
assert_has "\"node_type\": node.type" "$MAP_FLOW_FILE" "map_flow enter payload node_type"
assert_has "\"reward_gold\": node.reward_gold" "$MAP_FLOW_FILE" "map_flow enter payload reward_gold"
assert_has "payload\\[\"advanced_floor\"\\] = true" "$MAP_FLOW_FILE" "map_flow placeholder branch payload advanced_floor"
assert_has "\"node_type\": node_type" "$MAP_FLOW_FILE" "non-battle completion payload node_type"
assert_has "\"bonus_log\": bonus_log" "$MAP_FLOW_FILE" "non-battle completion bonus_log payload"
assert_has "RunRouteDispatcher.ROUTE_MAP" "$MAP_FLOW_FILE" "non-battle completion next_route map"

echo "[run_flow_contract] checking battle_flow win/lose routes..."
assert_has "RunRouteDispatcher.ROUTE_REWARD" "$BATTLE_FLOW_FILE" "battle win next_route reward"
assert_has "\"reward_gold\": maxi\\(0, reward_gold\\)" "$BATTLE_FLOW_FILE" "battle win payload reward_gold"
assert_has "RunRouteDispatcher.ROUTE_GAME_OVER" "$BATTLE_FLOW_FILE" "battle lose next_route game_over"
assert_has "\"game_over_text\": _build_game_over_text\\(run_state\\)" "$BATTLE_FLOW_FILE" "battle lose payload game_over_text"
assert_has "\"reward_log\": reward_log" "$BATTLE_FLOW_FILE" "battle reward apply payload reward_log"
assert_has "RunRouteDispatcher.ROUTE_MAP" "$BATTLE_FLOW_FILE" "battle reward apply next_route map"

echo "[run_flow_contract] all checks passed."
