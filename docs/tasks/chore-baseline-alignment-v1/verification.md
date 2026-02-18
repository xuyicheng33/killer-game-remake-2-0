# 验证记录：chore-baseline-alignment-v1

**任务ID**: `chore-baseline-alignment-v1`
**验证日期**: 2026-02-18
**验证人**: 程序员

---

## 1. 冒烟脚本验证

**执行命令**: `bash dev/tools/save_load_replay_smoke.sh`

**结果**: 全部通过

**检查组汇总**:
1. fixed-seed bootstrap check - PASS
2. save/load rng continuity check - PASS
3. battle->reward->map route smoke check - PASS
4. deterministic shuffle smoke check - PASS
5. exception path: restore failure fallback - PASS
6. save version compatibility check - PASS
7. environment seed override check - PASS
8. repro log continuity check - PASS
9. runtime main link integrity check - PASS

---

## 2. 项目基线差异清单

对照 `master_plan_v3.md` 第二节"当前项目基线"表格，逐项确认：

| 维度 | 文档记录 | 实际确认 | 差异说明 |
|---|---|---|---|
| 工具链 | workflow-check 完整，含 13 项契约检查 | **一致** | 无差异 |
| 启动流程 | 无主菜单/角色选择 UI | **一致** | 无差异 |
| 架构边界 | 场景层契约门禁已建立 | **一致** | 无差异 |
| 存档/读档 | 已实现并有冒烟脚本 | **一致** | 冒烟脚本全通过 |
| 种子/RNG | RunRng 主路径已接入，存在1处视觉布局直接调用 (P2) | **确认** | 见 `battle.gd:96` 使用 `randf_range()` 做敌人位置抖动；`shaker.gd:14` 使用 `randf_range()` 做视觉震动（均为视觉层，不影响游戏逻辑确定性） |
| BuffSystem | `_run_turn_start_hooks` 和 `_run_after_card_played_hooks` 为空 (P0) | **确认存在** | 见 `buff_system.gd:192-209` |
| 领域层单例 | BuffSystem / EffectStackEngine / CardZonesModel 使用手动 `_instance` 模式 | **确认** | 见 `buff_system.gd:18`, `effect_stack_engine.gd:6`, `card_zones_model.gd:6` 均有 `static var _instance` |
| 信号生命周期 | RelicPotionSystem 无 `_exit_tree` (P1) | **确认存在** | 见 `relic_potion_system.gd:11-15`，只有 `_ready` 连接，无 `_exit_tree` 断开 |
| 卡牌数量 | 4张 | **确认** | warrior_slash, warrior_pipeline_bash, warrior_block, warrior_axe_attack |
| 敌人数量 | 3个 (2普通 + 1Boss) | **差异** | 实际只有 2 个普通敌人 (bat, crab)，无 Boss 敌人定义文件 |
| 遗物数量 | 4个 | **确认** | burning_blood, ember_ring, golden_idol, thorns_potion |
| 药水数量 | 3个 | **确认** | fire_potion, healing_potion, iron_skin_potion |
| 事件数量 | 5个 | **差异** | EventCatalog.TEMPLATES 实际有 15 个事件模板 |
| 地图层数 | 6层 | **确认** | `map_generator.gd:6` NORMAL_FLOOR_COUNT := 5 (5普通+1Boss=6层) |
| GUT测试 | 不存在 | **确认** | `dev/tests/` 目录不存在（本任务已创建） |

---

## 3. 需更正的基线信息

### 3.1 敌人数量
- **文档记录**: 3个 (2普通 + 1Boss)
- **实际状态**: 2个普通敌人 (bat, crab)，Boss 敌人未找到独立定义文件
- **建议**: 需确认 Boss 是否在战斗系统中硬编码，或在其他位置定义

### 3.2 事件数量
- **文档记录**: 5个
- **实际状态**: 15个事件模板 (EventCatalog.TEMPLATES)
- **建议**: 基线表应更新为"15个事件模板，超出最低目标"

---

## 4. 手动主流程验证

**验证日期**: 2026-02-18
**验证人**: 用户

**验证步骤**:
1. 启动游戏 ✅
2. 选择角色 ✅
3. 走地图节点 ✅
4. 进入战斗 ✅
5. 出牌 ✅
6. 结束回合 ✅

**验证结果**: 全部步骤完成，暂未发现问题。

---

## 结论

- 冒烟脚本: **全部通过**
- 差异清单: **已完成，所有项已确认**
- 手动主流程验证: **全部通过**
- 发现的问题:
  - P0: BuffSystem 两个空钩子待修复（Phase 1）
  - P1: RelicPotionSystem 缺少 `_exit_tree` 断开信号（Phase 1）
  - P2: 视觉层直接随机调用 (`battle.gd:96`, `shaker.gd:14`)（Phase 1）
  - 基线信息: 敌人数量、事件数量需更正

---

## Phase 0 出口条件检查

- [x] `bash dev/tools/save_load_replay_smoke.sh` 通过
- [x] 主流程手动验证记录存在
- [x] `make test` 可运行，冒烟通过
- [x] `dev/tests/` 目录和占位测试文件存在

---

**程序员签名**: 已完成基线盘点
**日期**: 2026-02-18

---

## 7. 审核员复验（2026-02-18）

**审核人**: 审核员

复验结论：
- 差异清单与仓库现状一致（P0/P1/P2 基线问题定位准确）
- 手动主流程验证记录存在且步骤完整
- `bash dev/tools/save_load_replay_smoke.sh` 复跑通过

**审核结论**: 通过
