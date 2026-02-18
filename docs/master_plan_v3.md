# 总体开发计划 V3.1
# 杀戮游戏复刻 2.0 —— 原型完整版

**制定日期**：2026-02-18
**修订日期**：2026-02-18（V3.1，依据审查员反馈修订）
**制定者**：项目负责人
**执行角色**：程序员 + 审核师
**本文档取代**：`development_roadmap_v2.md`、`engineering_rectification_plan_v1.md`、`master_plan_v3.md（V3原版）`

**V3 → V3.1 主要变更**：
- Phase 0 改为"基线对齐 + GUT接入"，承认 R2 Phase 0-11 已完成的工作
- 新增"P0/P1/P2 Bug 分级定义"，用量化标准取代"全部清零"
- 战斗核心修复（Buff钩子 + 手动单例 + RunRng统一）设为 Phase 1 最高优先级，先于内容扩容
- 内容目标分两个里程碑：先到"最小可验证集"，再扩到原型完整集

---

## 一、项目目标与原则

### 1.1 原型目标（本计划交付物）

完成**一个可完整游玩的单局流程**，具体标准：

- 1个可选角色，完整起始卡组
- 真实分支地图（每层至少2条路，共15层）
- 战斗系统：完整Buff/效果结算链，无空钩子
- 商店系统：买卡、买遗物、买药水、删卡
- 营火系统：回血、升级卡牌
- 随机事件：至少5种事件脚本
- 遗物：至少8个，触发链完整
- 药水：至少5个，效果完整
- 卡牌：至少20张，覆盖攻击/技能/能力三类型
- 敌人：3种普通敌人 + 1个Boss
- 存档/读档：可在主菜单继续当前存档
- 种子系统：相同种子产生相同地图与战斗顺序

### 1.2 架构原则（不可妥协）

1. **模块边界严格**：场景层只做展示与输入，不直接写核心状态
2. **无领域层手动单例**：战斗核心服务（BuffSystem/EffectStackEngine/CardZonesModel）不使用 `static var _instance` 模式，改为依赖注入；基础设施 autoload（Events/Shaker/Music）保持不变
3. **信号连接有生命周期管理**：有 `connect` 必须有对应 `disconnect`，统一放在 `_connect_signals()` / `_disconnect_signals()` 方法对中
4. **类型安全**：禁止无检查的 `as` 转换，所有 Variant 使用前必须通过 `is` 校验
5. **可测试**：核心域（战斗/Buff/效果/地图）必须有 GUT 单元测试
6. **内容数据驱动**：卡牌/敌人/遗物/事件通过数据表定义，不硬编码

### 1.3 Bug 严重级别定义

本计划使用以下量化标准，不用"全部清零"作为门槛：

| 级别 | 定义 | 进入下一 Phase 的要求 |
|---|---|---|
| **P0（阻断）** | 导致核心流程无法运行的缺陷（崩溃、空钩子使功能完全失效） | **必须为 0** |
| **P1（严重）** | 导致功能行为错误但不崩溃（信号泄漏、类型安全缺失） | Phase 2 开始前必须为 0 |
| **P2（一般）** | 代码质量问题，不影响功能正确性（视觉布局随机调用、print 污染、魔法值） | 允许带入下一 Phase，但同一 P2 不得跨两个 Phase；本 Phase 发现的 P2 必须在本 Phase 或下一 Phase 结束前修复 |

### 1.4 后续扩展预留（架构必须支持）

- 新角色：独立卡池 + 专属起始遗物接口
- 新机制：效果栈与Buff系统设计为开放扩展点（注册即生效，不改系统代码）
- 新内容：内容管线支持单文件新增，不改动业务代码

### 1.5 “15层真实路线”定义（人话版）

“15层”不是 15 张地图，而是**一局里要连续推进的15个楼层决策点**：

- 第1-14层为普通层：每层会出现多个可选节点（战斗/事件/营火/商店等）
- 第15层为 Boss 层：固定 Boss 节点
- 玩家每层选择 1 个可达节点推进，直到 Boss
- “真实分支”意味着：不是线性一本道，至少存在多条可走路径，且中途会出现不同节点类型组合

简化理解：一局路线 = 从第1层走到第15层，期间每层都要做节点选择，并完成对应玩法。

### 1.6 新设计协作门禁（强制）

适用范围：凡是新增或改动**机制设计**（状态机制 / 遗物触发机制 / 药水机制 / 敌人机制 / 事件机制 / 经济规则），一律走以下门禁：

1. **先复核现有实现**（禁止直接开写）  
   程序员先产出 `docs/tasks/<task-id>/design_review.md`，至少包含：
   - 当前实现位置（文件路径 + 关键函数）
   - 当前数据结构与限制
   - 复用点与风险点
2. **再提交设计草案**  
   程序员产出 `docs/tasks/<task-id>/design_proposal.md`，至少包含：
   - 目标效果与非目标（不做什么）
   - 方案A/B（或最少1套方案 + 权衡）
   - 对现有逻辑、存档、种子一致性的影响
3. **你明确批准后才能编码**  
   必须出现负责人明确批准语句（如“批准 task-id 设计”）并记录在 `verification.md`。
4. **审核员二次确认**  
   审核员在编码前确认：已复核、已提案、已批准。任一缺失即阻断编码。

**说明（内容填充例外）**：
- 若仅按既有 schema 做内容填充（例如新增卡牌数据条目、补遗物文本、调整数值），且不引入新机制，则走简化流程：
  - 必须有 `design_proposal.md`
  - 无需 `design_review.md`
  - 无需等待负责人事前批准，可先编码
  - 但合并前仍需审核员确认“确实未引入新机制”

---

## 二、当前项目基线（V3.1 执行起点）

> R2 Phase 0-11 已完成，以下是 V3.1 接手时的真实现状。

| 维度 | 当前状态 | V3.1 目标 | 差距 |
|---|---|---|---|
| 工具链 | `workflow-check` 完整，含 13 项契约检查 | 新增 `make test` (GUT) | 新增1个目标 |
| 启动流程 | 当前无主菜单/角色选择 UI（默认启动后直接尝试读档或新局） | 主菜单支持：新游戏/继续游戏/角色选择 | 新增入口UI |
| 架构边界 | 场景层契约门禁已建立（shell contract check） | 继续维持 | 无差距 |
| 存档/读档 | 已实现并有冒烟脚本 | 继续维持+验证 | 无差距 |
| 种子/RNG | RunRng 主路径已接入，存在1处视觉布局直接调用（P2） | 统一 | P2修复 |
| BuffSystem | `_run_turn_start_hooks` 和 `_run_after_card_played_hooks` 为空（P0） | 完整实现 | P0修复 |
| 领域层单例 | BuffSystem / EffectStackEngine / CardZonesModel 使用手动 `_instance` 模式 | 依赖注入 | P1重构 |
| 信号生命周期 | RelicPotionSystem 无 `_exit_tree`（P1） | 修复 | P1修复 |
| 卡牌 | 4张 | 20张 | +16张 |
| 敌人 | 3个（2普通 + 1Boss） | 4个（3普通 + 1Boss） | +1普通 |
| 遗物 | 4个 | 8个 | +4个 |
| 药水 | 3个 | 5个 | +2个 |
| 事件 | 5个（已达最低目标） | 5个 | 无差距 |
| 地图层数 | 6层（5普通+1Boss） | 15层 | +9层 |
| 商店功能 | 买卡+删卡，无遗物/药水购买 | 买卡+买遗物+买药水+删卡 | 扩展 |
| GUT测试 | 不存在 | 核心模块覆盖 | 全新建立 |

---

## 三、阶段总览

```
Phase 0 ──→ Phase 1 ──→ Phase 2 ──→ Phase 3a ──→ Phase 3b ──┐
                                  ↘                           ↓
                                   Phase 4（可并行3a/3b）    Phase 5 ──→ Phase 6
```

| 阶段 | 名称 | 前置条件 | 核心交付物 |
|---|---|---|---|
| **Phase 0** | 基线对齐 + GUT 框架接入 | 无 | 现状差异清单、GUT框架可运行 |
| **Phase 1** | P0/P1 修复 + 战斗核心重构 | Phase 0 | P0=0、P1=0、BattleContext 可测试 |
| **Phase 2** | 核心系统后端完整实现 | Phase 1 | 战斗/Buff/效果/地图/奖励后端有GUT覆盖 |
| **Phase 3a** | 最小内容集验证 | Phase 2 | 8卡/3敌/6遗物/4药水/5事件 可完整游玩一局 |
| **Phase 3b** | 原型内容扩容 | Phase 3a | 20卡/4敌/8遗物/5药水 |
| **Phase 4** | 存档验证 + 种子完整性 | Phase 2（可并行3） | 存档往返100%、同seed地图一致 |
| **Phase 5** | 完整流程打通与验证 | Phase 3b + Phase 4 | 从开局打到Boss通关，验收清单全通过 |
| **Phase 6** | UI 对接收尾 | Phase 5 | 所有界面数据正确对接 |
| **Phase F** | 美术/音频/UI重制 | Phase 6，独立规划 | 视觉风格统一 |

---

## 四、Phase 0：基线对齐 + GUT 框架接入

**目标**：确认当前项目可运行状态，建立 GUT 测试基础设施，不重复 R2 已有工作。

---

### 任务 0-1：当前状态盘点与差异文档

**任务ID**：`chore-baseline-alignment-v1`
**任务级别**：L0
**执行人**：程序员

步骤：
1. 运行现有冒烟验证：`bash dev/tools/save_load_replay_smoke.sh`
2. 手动验证最小主流程：启动 → 选角色 → 走地图节点 → 进入战斗 → 出牌 → 结束回合
3. 将上述两步结果记录到 `docs/tasks/chore-baseline-alignment-v1/verification.md`
4. 对照本文档"二、当前项目基线"表格，逐项确认或更正差异

**验收**：差异清单存在，主流程手动验证通过（允许现有Bug）

---

### 任务 0-2：GUT 测试框架接入

**任务ID**：`chore-gut-framework-setup-v1`
**任务级别**：L1
**执行人**：程序员

步骤：
1. 将 GUT（Godot Unit Testing）addon 添加到 `addons/gut/`
2. 在 `dev/tests/` 目录建立结构：
   ```
   dev/tests/
   ├── unit/
   │   ├── test_buff_system.gd     （暂时只写冒烟占位）
   │   ├── test_effect_stack.gd    （暂时只写冒烟占位）
   │   ├── test_card_zones.gd      （暂时只写冒烟占位）
   │   └── test_map_generator.gd   （暂时只写冒烟占位）
   └── integration/
       └── test_battle_flow.gd     （暂时只写冒烟占位）
   ```
3. 写一个真正运行的冒烟测试 `test_gut_smoke.gd`：`assert_true(true, "GUT 框架可用")`
4. 在 `Makefile` 添加 `make test` 目标，通过命令行执行 GUT

**验收**：`make test` 运行成功，冒烟测试通过，目录结构建立完成

---

### Phase 0 出口条件

- [ ] `bash dev/tools/save_load_replay_smoke.sh` 通过
- [ ] 主流程手动验证记录存在
- [ ] `make test` 可运行，冒烟通过
- [ ] `dev/tests/` 目录和占位测试文件存在

### Phase 0 角色分工与验收

| 角色 | 必做工作 | 必交付物 |
|---|---|---|
| 程序员 | 跑冒烟脚本、补 GUT、补 `make test`、记录现状差异 | `plan.md`、`design_review.md`（若涉及新设计可留空说明）、`verification.md` |
| 审核员 | 复跑 `make test` 与冒烟脚本，抽查差异清单是否与仓库一致 | 审核结论写入 `verification.md`（通过/驳回+原因） |

**双角色验收门槛**：
- 程序员与审核员都在 `verification.md` 留下结论
- 任一方标记“阻断”则 Phase 0 不通过

---

## 五、Phase 1：P0/P1 修复 + 战斗核心重构

> **原则**：P0 必须先修，P1 必须在此阶段清零。P1 重构在 P0 修复完成后执行。
> **顺序约束**：战斗核心重构（1-B）依赖 P0 修复（1-A）完成，不得乱序。

---

### 集群 1-A：P0 修复（最高优先，串行先执行）

**执行人**：程序员
**任务ID**：`fix-p0-battle-core-v1`
**任务级别**：L2（影响战斗结算链路）
**审批要求**：负责人回复"批准"后执行

#### Fix 1-A-1：BuffSystem `_run_turn_start_hooks` 实现

**文件**：`runtime/modules/buff_system/buff_system.gd`（约第192行）

**当前**：
```gdscript
func _run_turn_start_hooks(_target: Node) -> void:
    # Hook point reserved for statuses with turn-start behavior.
    pass
```

**修复要求**：
- 遍历目标单位的状态字典
- 触发具有"回合开始"行为的状态效果（目前的状态集中，`poison` 在回合结束处理，此钩子当前可触发 `regenerate` 类回合开始回血状态）
- 添加注释说明此钩子的扩展规则：新增回合开始触发的状态，在此处添加对应分支

**GUT 测试**（Phase 1 结束前必须写）：
- `test_turn_start_hook_fires_for_registered_status()`：注册一个测试用回合开始状态，验证钩子触发

---

#### Fix 1-A-2：BuffSystem `_run_after_card_played_hooks` 实现

**文件**：`runtime/modules/buff_system/buff_system.gd`（约第207行）

**当前**：
```gdscript
func _run_after_card_played_hooks(_target: Node) -> void:
    # Hook point reserved for statuses with post-card behavior.
    pass
```

**修复要求**：
- 遍历目标单位的状态字典，触发具有"出牌后"行为的状态效果
- 目前状态集中暂无此类状态，但钩子必须实现为可调用结构（遍历 + 分发），不能再是 `pass`
- 添加注释：新增出牌后触发的状态（如"每打出一张攻击牌+1力量"），在此处添加对应分支

**GUT 测试**：
- `test_after_card_played_hook_fires_on_attack_card()`

---

### 集群 1-B：P1 修复（1-A 完成后执行）

**执行人**：程序员

#### Fix 1-B-1：领域层手动单例改为依赖注入

**任务ID**：`refactor-battle-context-injection-v1`
**任务级别**：L2
**涉及文件**：`runtime/modules/buff_system/buff_system.gd`、`runtime/modules/effect_engine/effect_stack_engine.gd`、`runtime/modules/card_system/card_zones_model.gd`

**问题**：三个模块均使用 `static var _instance + get_instance()` 手动单例，导致：
- 无法在 GUT 测试中独立实例化（测试污染）
- 战斗结束时实例不释放
- 多次战斗之间状态可能残留

**修复方案**：
1. 新增 `BattleContext` 数据持有对象（`runtime/modules/battle_loop/battle_context.gd`）：
   ```gdscript
   class_name BattleContext
   extends RefCounted

   var effect_stack: EffectStackEngine
   var buff_system: BuffSystem
   var card_zones: CardZonesModel

   func _init() -> void:
       effect_stack = EffectStackEngine.new()
       buff_system = BuffSystem.new()
       card_zones = CardZonesModel.new()
   ```
2. 移除三个类的 `static var _instance` 和 `get_instance()` 方法
3. 战斗场景通过 `BattleContext` 持有服务实例，战斗结束时销毁 `BattleContext`
4. 所有调用 `XxxService.get_instance()` 的地方，改为从 `BattleContext` 读取

**验收**：
- GUT 可以 `BattleContext.new()` 并独立测试 `buff_system`，不影响其他测试
- `make test` 通过

---

#### Fix 1-B-2：信号生命周期规范

**任务ID**：`fix-signal-lifecycle-v1`
**任务级别**：L1

**RelicPotionSystem**（`runtime/modules/relic_potion/relic_potion_system.gd`）：
- 添加 `_exit_tree()` 方法，断开 `_ready()` 中的所有连接
- 统一模式：
  ```gdscript
  func _ready() -> void:
      _connect_signals()

  func _exit_tree() -> void:
      _disconnect_signals()

  func _connect_signals() -> void:
      if not Events.card_played.is_connected(_on_card_played):
          Events.card_played.connect(_on_card_played)
      if not Events.player_hit.is_connected(_on_player_hit):
          Events.player_hit.connect(_on_player_hit)

  func _disconnect_signals() -> void:
      if Events.card_played.is_connected(_on_card_played):
          Events.card_played.disconnect(_on_card_played)
      if Events.player_hit.is_connected(_on_player_hit):
          Events.player_hit.disconnect(_on_player_hit)
  ```

**全局扫描**：检查项目中所有在 `_ready()` 中使用 `connect()` 的节点，确认都有对应的 `_exit_tree()` 断开

---

#### Fix 1-B-3：unsafe 类型转换

**任务ID**：`fix-type-safety-v1`
**任务级别**：L1

**规范**（全项目统一）：
```gdscript
# 禁止
_enemies_cache.append(e as Dictionary)

# 正确
if e is Dictionary:
    _enemies_cache.append(e)
else:
    push_error("[EncounterRegistry] 非法数据格式: %s" % str(e))
```

**检查范围**：全局搜索 `) as ` 模式，逐个确认是否有前置 `is` 检查；无检查的一律修复

---

### 集群 1-C：P2 修复（1-B 完成后，可随后续 Phase 逐步消化）

以下 P2 问题在 Phase 1 期间开始，但允许带入后续 Phase，每阶段结束前清零本阶段新增的 P2：

#### Fix 1-C-1：RunRng 统一入口

**文件**：`runtime/scenes/battle/battle.gd:96`
```gdscript
# 当前（视觉布局用直接随机，P2）
enemy.position = Vector2(start_x + offset_x, base_y + randf_range(-30, 30))

# 修复：改用 RunRng，或将视觉布局的随机与游戏逻辑随机显式分离
# 如果此处仅用于位置抖动且不影响游戏逻辑，至少加注释说明
# 如需严格确定性，改用 RunRng.randf("visual_layout") 映射到区间：
# var jitter := lerpf(-30.0, 30.0, RunRng.randf("visual_layout"))
```

---

#### Fix 1-C-2：移除 Debug print

**范围**：全项目搜索 `print(` 语句，改为 `push_warning()` 或添加日志开关

---

#### Fix 1-C-3：魔法值常量化

- `MapGenerator.NORMAL_FLOOR_COUNT := 5` → 目前是常量，但需要配合 Phase 2 扩展为15层时同步修改
- 所有无命名的数字字面量，提取为命名常量

---

### Phase 1 出口条件

- [ ] P0 Bug 数量 = 0
- [ ] P1 Bug 数量 = 0
- [ ] `BattleContext` 可独立实例化，GUT 测试中不需要运行完整游戏场景
- [ ] `make test`：所有测试（含 Phase 1 新增的）通过
- [ ] `make workflow-check TASK_ID=<当前任务ID>` 通过

### Phase 1 角色分工与验收

| 角色 | 必做工作 | 必交付物 |
|---|---|---|
| 程序员 | 按 1-A → 1-B 顺序修复；为每个修复点补测试；维护 P0/P1 缺陷台账 | 缺陷台账（修复前后证据）、测试结果、`handoff.md` |
| 审核员 | 逐条核对 P0/P1 是否闭环；复跑关键测试；确认无新增阻断问题 | 审核报告（按严重级别列问题） |

**双角色验收门槛**：
- 缺陷台账中 P0=0、P1=0
- 审核员复验通过并签字（写入 `verification.md`）

---

## 六、Phase 2：核心系统后端完整实现

> **原则**：只做后端逻辑和数据层，不做 UI。每个系统完成后必须有 GUT 测试。

**执行依赖图**：
```
2-1 EffectStackEngine ──→ 2-2 BuffSystem ──→ 2-4 RelicPotion
                        ↘
                         2-3 BattleLoop 状态机
2-5 MapGenerator（独立）
2-4 RelicPotion ──→ 2-6 RewardEconomy（商店遗物/药水依赖）
```

---

### 任务 2-1：EffectStackEngine 完整实现

**任务ID**：`feat-effect-stack-v2`
**任务级别**：L2
**白名单**：`runtime/modules/effect_engine/`

**在现有队列基础上补充**：

1. **效果优先级**：入队时携带 `priority: int`（0-100），出队按优先级排序
2. **触发链**：效果执行完成后，若派发新事件，新事件自动入队；最大递归深度10层，超限时 `push_error` 并中止（防死循环）
3. **执行日志**：每次效果执行后追加到 `ReproLog`，格式：`{type, source, target, value, turn}`
4. **效果类型枚举**：`DAMAGE / BLOCK / HEAL / DRAW / APPLY_STATUS / REMOVE_STATUS / SPECIAL`

**GUT 测试**：
- `test_effect_executes_in_priority_order()`
- `test_effect_chain_triggers_correctly()`
- `test_effect_chain_depth_limit_prevents_infinite_loop()`

---

### 任务 2-2：BuffSystem 完整实现

**任务ID**：`feat-buff-system-v2`
**任务级别**：L2
**白名单**：`runtime/modules/buff_system/`
**前置**：2-1 完成

**在现有5种状态基础上扩展到10种**：

| 状态 | 触发时机 | 层数消耗规则 |
|---|---|---|
| 力量（Strength） | 出牌造成攻击时加算 | 永久 |
| 敏捷（Dexterity） | 出牌获得格挡时加算 | 永久 |
| 易伤（Vulnerable） | 受到攻击时+50%伤害 | 回合结束-1 |
| 虚弱（Weak） | 造成攻击时-25%伤害 | 回合结束-1 |
| 中毒（Poison） | 回合开始扣血=层数，然后-1 | 回合开始-1至0消除 |
| 燃烧（Burn） | 回合结束扣2血，然后消除 | 回合结束消除 |
| 束缚（Constricted） | 回合结束扣血=层数 | 永久（敌人专用） |
| 金属化（Metallicize） | 回合结束获得格挡=层数 | 永久 |
| 愤怒（Ritual） | 回合结束+力量=层数 | 永久 |
| 再生（Regenerate） | 回合结束回血=层数 | 回合结束-1 |

**注意**：现有 `_run_turn_end_hooks` 已处理 poison/weak/vulnerable，新增状态在此函数中扩展，同时补充 `_run_turn_start_hooks` 实现（Fix 1-A-1 已修复骨架）

**状态叠加规则**：同类叠加层数相加；虚弱 × 易伤 同时生效为乘算（先算虚弱再算易伤）

**GUT 测试**：
- `test_poison_decrements_each_turn()`
- `test_weak_reduces_damage_by_25_percent()`
- `test_vulnerable_increases_received_damage()`
- `test_strength_adds_to_attack_damage()`
- `test_metallicize_grants_block_on_turn_end()`

---

### 任务 2-3：BattleLoop 状态机完整实现

**任务ID**：`feat-battle-loop-state-machine-v2`
**任务级别**：L2
**白名单**：`runtime/modules/battle_loop/`
**前置**：2-2 完成

**阶段定义（严格顺序）**：

```
DRAW_PHASE
  ├─ 抽牌（默认5张）
  ├─ 触发 _run_turn_start_hooks（Buff回合开始结算）
  └─ → ACTION_PHASE

ACTION_PHASE
  ├─ 玩家出牌（消耗能量）
  ├─ 玩家使用药水
  └─ 玩家点击"结束回合" → ENEMY_PHASE

ENEMY_PHASE
  ├─ 所有敌人按意图行动
  ├─ 触发敌方回合钩子
  └─ → RESOLVE_PHASE

RESOLVE_PHASE
  ├─ 弃置手牌（保留牌除外）
  ├─ 触发 _run_turn_end_hooks（Buff回合结束结算，层数递减）
  ├─ 检查胜负条件
  └─ 若未结束 → DRAW_PHASE
```

**必须实现**：
- `PhaseStateMachine` 类，每个阶段有 `enter()` / `exit()` 方法
- 阶段切换通过信号广播，不直接调用 UI
- 胜利/失败检测集中在 `RESOLVE_PHASE`

**GUT 测试**：
- `test_phase_transitions_in_correct_order()`
- `test_buffs_triggered_at_correct_phase()`
- `test_battle_ends_when_player_hp_reaches_zero()`

---

### 任务 2-4：RelicPotion 系统完整实现

**任务ID**：`feat-relic-potion-v2`
**任务级别**：L2
**白名单**：`runtime/modules/relic_potion/`
**前置**：2-2 完成

**遗物触发时机枚举（系统必须支持）**：

| 常量名 | 触发时机 |
|---|---|
| `ON_BATTLE_START` | 每次战斗开始 |
| `ON_TURN_START` | 玩家回合开始 |
| `ON_TURN_END` | 玩家回合结束 |
| `ON_CARD_PLAYED` | 打出一张牌 |
| `ON_ATTACK_PLAYED` | 打出攻击牌 |
| `ON_SKILL_PLAYED` | 打出技能牌 |
| `ON_DAMAGE_TAKEN` | 玩家受伤 |
| `ON_BLOCK_APPLIED` | 玩家获得格挡 |
| `ON_ENEMY_KILLED` | 击杀一个敌人 |
| `ON_RUN_START` | 开局 |
| `ON_SHOP_ENTER` | 进入商店 |
| `ON_BOSS_KILLED` | 击杀Boss |

**架构**：
- `RelicBase`（Resource）：子类重写对应 `on_<event>()` 函数
- `RelicRegistry`：通过 ID 查找遗物定义，注册制
- 遗物效果通过 `EffectStack` 派发，不直接修改 RunState

**GUT 测试**：
- `test_relic_fires_on_correct_trigger_event()`
- `test_potion_applies_effect_via_effect_stack()`

---

### 任务 2-5：MapGenerator 扩展为15层真实分支

**任务ID**：`feat-map-graph-v2`
**任务级别**：L2
**白名单**：`runtime/modules/map_event/`

**修改内容**：

```gdscript
# 当前
const NORMAL_FLOOR_COUNT := 5

# 修改为
const NORMAL_FLOOR_COUNT := 14  # 14层普通 + 1层Boss = 15层
```

**分支规则**：
- 每个节点连接下一层的1-2个节点（当前已有3条lane，维持此结构）
- 保证从起点到Boss存在至少2条完全不同路径
- 保持有向无环图（当前实现已有，确认无回路即可）

**节点类型权重（可配置常量）**：

| 节点类型 | 普通层权重 | 精英层（第8层以后）权重 |
|---|---|---|
| 普通战斗 | 45% | 35% |
| 精英战斗 | 8% | 20% |
| 休息点 | 15% | 12% |
| 商店 | 5% | 5% |
| 事件 | 27% | 28% |

**GUT 测试**：
- `test_map_has_15_layers()`
- `test_map_has_multiple_paths_to_boss()`
- `test_same_seed_produces_same_map()`

---

### 任务 2-6：RewardEconomy 商店扩展

**任务ID**：`feat-reward-economy-v2`
**任务级别**：L2
**白名单**：`runtime/modules/reward_economy/`、`runtime/modules/run_flow/`
**前置**：2-4 完成（2-5 可并行，不阻塞本任务）

**在现有买卡+删卡基础上，新增**：

1. **遗物购买**：
   - 商店生成1-2个遗物报价（从 RelicRegistry 随机）
   - 价格：100-300金币（按稀有度）
   - 购买：扣金币，遗物加入 `RunState.relics`

2. **药水购买**：
   - 商店生成1-2个药水报价
   - 价格：50金币（固定）
   - 购买：扣金币，药水加入 `RunState.potions`（上限3个）

3. **商店库存生成规格**：3张卡 + 1个遗物 + 1个药水（可配置）

**GUT 测试**：
- `test_shop_purchase_relic_deducts_gold()`
- `test_shop_purchase_potion_respects_inventory_limit()`
- `test_card_removal_cost_increases_after_first_use()`

---

### Phase 2 出口条件

- [ ] `make test`：Phase 2 所有新增 GUT 测试通过
- [ ] 手动验证：完整一场战斗，Buff正确触发，效果结算正确
- [ ] 手动验证：生成地图，有15层，有分支路径可选
- [ ] 手动验证：商店页面可购买卡/遗物/药水，删卡正确扣费

### Phase 2 角色分工与验收

| 角色 | 必做工作 | 必交付物 |
|---|---|---|
| 程序员 | 按 2-1~2-6 依赖顺序实现后端；每个子任务补 GUT；维护接口契约说明 | 每个子任务三件套 + 测试清单 |
| 审核员 | 每完成一个子任务即审一次（不等全部完成）；检查契约、边界、可测性 | 分任务审核记录，阻断项清单 |

**双角色验收门槛**：
- 2-1~2-6 全部有“程序员完成 + 审核员通过”标记
- Phase 2 出口 4 条全部通过

---

## 七、Phase 3a：最小内容集验证

> **目标**：用最小内容集验证完整流程可跑通，尽早发现系统集成问题。

**前置**：Phase 2 完成
**验收标准**：8张卡 / 3敌人（当前已达标，仅需确认在地图中正常出现） / 6遗物 / 4药水 / 5事件（事件已达标，只确认正常运行）

---

### 任务 3a-1：卡牌扩展至8张（在现有4张基础上新增4张）

**任务ID**：`content-cards-warrior-set1-v1`
**白名单**：`content/`（数据文件）、`runtime/modules/content_pipeline/sources/`

**新增4张卡要求**：覆盖目前缺失的牌型
- 1张技能牌（获得格挡）
- 1张能力牌（永久增益）
- 1张消耗牌（Exhaust 关键词）
- 1张X费牌

**内容通过 content_pipeline 数据表定义，不硬编码**

---

### 任务 3a-2：遗物扩展至6个（在现有4个基础上新增2个）

**任务ID**：`content-relics-set1-v1`
**白名单**：`content/`

新增2个遗物，覆盖目前没有的触发时机：`ON_TURN_START`（如：每回合开始获得3格挡）、`ON_ENEMY_KILLED`（如：击杀敌人抽1张牌）

---

### 任务 3a-3：药水扩展至4个（在现有3个基础上新增1个）

**任务ID**：`content-potions-set1-v1`
**白名单**：`content/`

新增1个药水，建议：力量药水（本场战斗+2力量）

---

### Phase 3a 出口条件（集成验证）

手动走完一局完整流程（含所有节点类型）：
- [ ] 战斗：使用各类牌，Buff正确生效
- [ ] 奖励：三选一卡牌可选
- [ ] 商店：买卡/遗物/药水，删卡
- [ ] 营火：回血，升级卡牌
- [ ] 事件：选择选项，效果生效
- [ ] 遗物：触发时有数值变化
- [ ] Boss：进入Boss战，可击败，游戏结束画面

### Phase 3a 角色分工与验收

| 角色 | 必做工作 | 必交付物 |
|---|---|---|
| 程序员 | 完成最小内容集导入与接线；确保内容通过管线而非硬编码 | 内容清单（ID列表）+ 导入报告 |
| 审核员 | 校验数量达标、出现路径正确、无 schema 违规 | 抽样复验记录（至少覆盖战斗/商店/事件） |

**双角色验收门槛**：
- 8卡/3敌/6遗物/4药水/5事件全部可在运行中验证到
- 审核员确认“最小集可完整跑一局”

---

## 八、Phase 3b：原型内容扩容

**前置**：Phase 3a 出口条件全部通过

---

### 任务 3b-1：卡牌扩展至20张（新增12张）

**任务ID**：`content-cards-warrior-set2-v1`
**白名单**：`content/`

**最终20张卡分布**：

| 类型 | 最终数量 | 关键词要求 |
|---|---|---|
| 攻击牌 | 10张 | 普通攻击×4、多段攻击×2、斩击（条件触发）×2、X费×1、强化（消耗后升级）×1 |
| 技能牌 | 7张 | 获得格挡×3、抽牌×1、回能量×1、施加状态×2 |
| 能力牌 | 3张 | 永久力量×1、永久敏捷×1、特殊机制×1 |

**每张卡必须字段（与现有 content_import_cards.py 对齐）**：
`id, name, type, rarity, cost, target, text, effects`

**可选字段**：`tags, starter_copies`

---

### 任务 3b-2：新增第3种普通敌人

**任务ID**：`content-enemy-third-normal-v1`
**白名单**：`content/`

第3种普通敌人（建议：施毒型，快速施加中毒叠层）：
- 血量：28-34
- 行为：高权重施毒，低权重普攻
- 约束：不可连续施毒超过2次

---

### 任务 3b-3：遗物扩展至8个（新增2个）

**任务ID**：`content-relics-set2-v1`
**白名单**：`content/`

覆盖以下触发时机：`ON_RUN_START`（开局永久增益）、`ON_SHOP_ENTER`（商店折扣）

---

### 任务 3b-4：药水扩展至5个（新增1个）

**任务ID**：`content-potions-set2-v1`
**白名单**：`content/`

建议：爆炸药水（对所有敌人造成10点伤害）

---

### Phase 3b 出口条件

- [ ] 卡牌 ≥ 20张，已在游戏内从奖励/商店中出现
- [ ] 普通敌人 ≥ 3种，在地图普通战斗节点随机出现
- [ ] 遗物 ≥ 8个，触发链正确
- [ ] 药水 ≥ 5个，效果正确

### Phase 3b 角色分工与验收

| 角色 | 必做工作 | 必交付物 |
|---|---|---|
| 程序员 | 在 3a 基础上扩容至目标规模；修复扩容带来的平衡与兼容问题 | 最终内容总表（按类型统计） |
| 审核员 | 复核“数量达标 + 触发链正确 + 出现概率合理” | 内容审计报告（含随机抽样日志） |

**双角色验收门槛**：
- 四项出口条件全部满足
- 审核员确认“内容规模达标且无阻断缺陷”

---

## 九、Phase 4：存档验证 + 种子完整性

**前置**：Phase 2 完成（可与 Phase 3 并行）

---

### 任务 4-1：存档系统验证与加固

**任务ID**：`feat-save-load-validate-v1`
**任务级别**：L1

当前存档系统已实现，本任务目标：

1. 运行 `bash dev/tools/save_load_replay_smoke.sh` 并确认所有检查点通过
2. 手动验证：游戏中途退出 → 重进 → 状态完全一致（含楼层/HP/金币/卡组/遗物/药水/已走路径）
3. 确认存档版本字段存在，且读取不兼容版本时有明确提示而非崩溃
4. 修复冒烟测试中发现的任何存档字段遗漏（如扩容后的遗物/药水字段是否正确序列化）

**GUT 测试**：
- `test_save_and_load_run_state_roundtrip()`：存读档后 RunState 关键字段完全一致

---

### 任务 4-2：种子完整性验证

**任务ID**：`feat-seed-consistency-validate-v1`
**任务级别**：L1

1. 验证相同 seed 开两局，前3层地图节点类型和位置一致
2. 确认 `battle.gd:96` 的视觉布局随机调用已标注（P2修复：加注释或改用 RunRng）
3. 全项目搜索直接 `randi()` / `randf()` 调用，确认没有影响游戏逻辑的遗漏（视觉布局类允许但须标注）

**GUT 测试**：
- `test_same_seed_produces_identical_map()`

---

### Phase 4 出口条件

- [ ] 存档冒烟脚本全通过
- [ ] 手动验证存档完整（含遗物/药水/已走路径）
- [ ] 相同 seed 地图结构一致（手动或 GUT 验证）

### Phase 4 角色分工与验收

| 角色 | 必做工作 | 必交付物 |
|---|---|---|
| 程序员 | 执行存档与种子一致性验证，修复发现的问题 | 回归记录（修复前/后）+ 复现实验步骤 |
| 审核员 | 用独立 seed 复验地图一致性与存档还原完整性 | 复验结论（通过/失败）与证据 |

**双角色验收门槛**：
- 同 seed 一致性可被独立复现
- 存档恢复关键字段完整，审核员复验通过

---

## 十、Phase 5：完整流程打通与验证

**前置**：Phase 3b + Phase 4 全部完成
**本阶段不写新功能**，只做集成调试与流程验证。

### 完整验收清单（程序员 + 审核师共同执行）

> 本 Phase 验收不依赖主菜单；主菜单/角色选择/继续游戏入口在 Phase 6 验收。

**开局与地图**：
- [ ] 在编辑器运行当前入口场景（`app.tscn`）并触发新局，能生成15层地图
- [ ] 相同 seed 开两局，地图结构一致
- [ ] 地图显示节点类型图标，当前位置标记正确

**战斗流程**：
- [ ] 抽5张牌，能量重置
- [ ] 打出攻击牌，敌人HP正确减少
- [ ] 虚弱状态下攻击，伤害-25%
- [ ] 中毒敌人回合开始扣血，层数递减至0后消除
- [ ] 易伤状态下受到攻击，伤害+50%
- [ ] 燃烧：回合结束扣2血后消除
- [ ] 力量/敏捷：永久增益，每回合正确累积
- [ ] 打出能力牌：效果永久生效
- [ ] 打出消耗牌（Exhaust）：进入消耗堆，不进弃牌堆
- [ ] X费牌：消耗所有能量，效果对应增强
- [ ] 敌人Boss：血量低于50%触发第二阶段，行为变化
- [ ] 战斗胜利 → 奖励页面

**奖励与推进**：
- [ ] 三选一卡牌可选，加入卡组
- [ ] 跳过选牌无额外效果
- [ ] 战后金币正确增加

**地图节点**：
- [ ] 商店：买卡（扣金币、加入卡组）
- [ ] 商店：买遗物（扣金币、加入遗物栏）
- [ ] 商店：买药水（扣金币、加入药水槽）
- [ ] 商店：删卡（扣75金币、卡牌从卡组移除）
- [ ] 营火：休息（回血量正确）
- [ ] 营火：升级卡牌（数值变化可见）
- [ ] 事件：选择选项，效果正确生效

**遗物与药水**：
- [ ] 每个遗物至少触发一次，效果可见
- [ ] 药水使用，效果立即生效
- [ ] 药水槽上限正确

**存档**：
- [ ] 战斗中途退出 → 重进 → 所有状态完全恢复

**通关**：
- [ ] 击败Boss → 游戏结束画面 → 显示统计数据（层数/伤害/牌数）

### Phase 5 角色分工与验收

| 角色 | 必做工作 | 必交付物 |
|---|---|---|
| 程序员 | 按完整验收清单跑全流程，记录每项结果与异常 | 全量验收记录（逐项打勾） |
| 审核员 | 独立重复跑同一清单（至少一轮），确认不是偶然通过 | 独立复验记录 + 问题清单 |

**双角色验收门槛**：
- 验收清单全部通过
- 审核员独立复验通过（允许不同 seed）

---

## 十一、Phase 6：UI 对接收尾

**前置**：Phase 5 通过
**原则**：只做数据对接，不涉及美术资源替换

### 任务 6-1：主菜单 + 角色选择 + 继续游戏入口

**任务ID**：`feat-main-menu-entry-flow-v1`
**任务级别**：L2
**白名单**：`runtime/scenes/app/`、`runtime/scenes/menu/`、`runtime/modules/run_flow/`

**必须实现**：
- 主菜单包含：`新游戏`、`继续游戏`、`角色选择` 三个入口
- `继续游戏` 在无存档时禁用或提示
- `角色选择` 至少支持现有角色注册表中的角色（当前 `warrior` / `mage`）
- 新游戏后正确进入地图流程，并保留当前存档/种子初始化逻辑
- 不允许菜单场景直接写 `RunState`，仍通过 run_flow/lifecycle 服务编排

### 各界面必须展示的数据

| 界面 | 必须正确显示的数据 |
|---|---|
| 主菜单 | 新游戏/继续游戏按钮状态、角色选择状态、存档可用提示 |
| 战斗 HUD | HP/格挡/能量/手牌数/弃牌数/消耗数/敌人意图/Buff图标+层数 |
| 奖励页 | 三张卡牌信息（名称/费用/描述）/跳过按钮 |
| 地图界面 | 节点类型标识/已走路径高亮/当前位置/可选节点（可点击） |
| 商店界面 | 卡/遗物/药水列表+价格/金币余额/删卡价格（随次数增加） |
| 卡组查看 | 完整卡组列表/每张卡的升级状态 |
| 遗物/药水栏 | 持有列表/悬停显示说明文字 |
| 事件界面 | 事件描述/选项文字/选项前置条件（如有） |

### Phase 6 出口条件

- [ ] 主菜单/角色选择/继续游戏流程可用
- [ ] 各界面数据对接项全部通过手动验收
- [ ] `make workflow-check TASK_ID=<当前任务ID>` 通过

### Phase 6 角色分工与验收

| 角色 | 必做工作 | 必交付物 |
|---|---|---|
| 程序员 | 完成 UI 数据绑定与入口流程，修复显示/交互错误 | UI 对接清单 + 截图/录屏 |
| 审核员 | 逐界面核对数据正确性与交互完整性，重点查边界状态（无存档、满药水、空卡组等） | UI 审核报告（按界面列问题） |

**双角色验收门槛**：
- Phase 6 出口条件全部通过
- 审核员确认“无阻断级 UI 错误”

---

## 十二、技术规范（工程师必读）

### 12.1 分支命名（强制执行）

```
功能任务：feat/<module>-<task-id>
Bug修复：fix/<module>-<task-id>
文档/工具：chore/<scope>-<task-id>
```

### 12.2 任务交付物（每个任务必须包含）

```
docs/tasks/<task-id>/
├── plan.md         # 执行前：目标、边界、步骤、风险
├── handoff.md      # 执行后：改动文件、已知问题、下一步
└── verification.md # 验证记录：步骤、实际结果、GUT输出截图
```

### 12.3 任务级别与审批规则

| 级别 | 定义 | 规则 |
|---|---|---|
| L0 | 纯文档、注释、单文件小修 | 直接执行 |
| L1 | 单模块内代码改动，影响面可控 | 先写 plan.md 再执行 |
| L2 | 跨模块、存档结构、战斗结算链路 | 必须等负责人回复"批准"后执行 |

### 12.4 协作分工与提交职责（强制）

为支持“程序员 AI + 审核员 AI”并行协作，统一采用以下职责边界：

- 程序员（代码编写员）职责：
  - 负责实现代码、补测试、更新任务文档草稿（`plan.md` / `handoff.md` / `verification.md`）
  - **不负责执行 git 提交，不创建 commit，不推送**
- 审核员职责：
  - 负责代码审查与复验（先阻断问题，后一般问题）
  - 审核通过后，负责执行提交动作（commit）并维护任务文档最终版本
  - 若审核不通过，明确驳回原因并退回程序员修复

默认流程：
1. 程序员完成实现并更新文档草稿
2. 审核员审核与复验
3. 审核通过后由审核员提交代码并更新文档最终结论
4. 任一阻断问题未关闭，不得提交

### 12.5 禁止事项（自动门禁或审核师必查）

- 禁止在单次任务中修改多个无关模块
- 禁止领域层使用 `static var _instance` 手动单例（Phase 1 修复后不得新增）
- 禁止在 `scenes/` 脚本中直接写 `RunState` 属性（已有 shell contract check 门禁）
- 禁止无前置 `is` 检查的 `as` 类型转换
- 禁止不成对的信号连接（有 `connect` 必须有对应 `disconnect`）
- 禁止新增 `print()` 调试语句（使用 `push_warning()` 或Logger）
- 禁止硬编码内容数据（卡/敌/遗物/事件必须走 content_pipeline 数据表）

### 12.6 Code Review 检查点（审核师每个 PR 必查）

1. **边界**：改动文件是否在任务白名单内？
2. **信号**：新增信号连接是否有对应断开？是否用了 `_connect_signals()` / `_disconnect_signals()` 对？
3. **类型安全**：有无裸 `as` 转换？Variant 使用前有 `is` 检查吗？
4. **测试**：新增逻辑是否有对应 GUT 测试？`make test` 通过了吗？
5. **单例**：是否新增了 `static var _instance` 或直接访问了 `Engine.get_singleton`？
6. **UI边界**：`scenes/` 脚本是否直接修改了 Domain 状态？（`make workflow-check` 会自动检查）
7. **内容**：新内容是否走了数据表？
8. **文档**：`plan.md` / `handoff.md` / `verification.md` 是否都有且已填写？

### 12.7 扩展接口规范（为后续新机制预留）

以下接口设计为**注册即生效**，新增内容不改系统代码：

- **EffectStack**：新效果类型在 `EffectType` 枚举添加，提供 `Callable` 即可
- **BuffSystem**：新状态通过 `BuffDefinition` Resource 定义，注册到 `BuffRegistry`
- **RelicSystem**：新遗物继承 `RelicBase`，重写对应触发函数，注册到 `RelicRegistry`
- **MapEvent**：新事件通过数据表定义，事件脚本为独立 Resource，不改 `MapEventService`

### 12.8 新设计审批格式（强制）

凡触发 1.6 新设计门禁的任务，`verification.md` 必须出现以下结构：

```markdown
## 设计前置检查
- [ ] design_review.md 已提交
- [ ] design_proposal.md 已提交
- [ ] 负责人批准语句已记录（原文粘贴）
- [ ] 审核员确认可编码
```

缺任一项，程序员不得进入编码阶段。

若属于“内容填充简化流程”（1.6 说明中的例外），`verification.md` 使用以下结构：

```markdown
## 内容填充前置检查（简化）
- [ ] design_proposal.md 已提交
- [ ] 审核员确认：仅内容填充，未引入新机制
```

缺任一项，不得合并。

### 12.9 Phase 派工最小指令（给不同 AI 直接用）

**给程序员 AI**：
`执行 docs/master_plan_v3.md 的 Phase X（程序员职责），严格按任务白名单修改，完成后更新 docs/tasks/<task-id>/plan.md、handoff.md、verification.md，并等待审核。`

**给审核员 AI**：
`审核 docs/master_plan_v3.md 的 Phase X（审核员职责），先列阻断问题，再列一般问题；逐项对照验收标准并给出通过/驳回结论。`

**给程序员+审核员联动 AI**：
`按 docs/master_plan_v3.md 执行 Phase X：先完成程序员职责，再按审核员职责复验；未通过不得进入下一 Phase。`

---

## 十三、里程碑检查点

| 里程碑 | 条件 | 意义 |
|---|---|---|
| **M0** | Phase 0 完成：GUT 冒烟通过，现状差异清单确认 | 基础设施就绪，可以安全重构 |
| **M1** | Phase 1 完成：P0=0，P1=0，BattleContext 可测试 | 代码库干净，战斗核心可信赖 |
| **M2** | Phase 2 完成：6个核心系统有 GUT 覆盖 | 系统基础稳固 |
| **M3a** | Phase 3a + Phase 4 完成：最小内容集可完整跑一局 | 验证集成无重大问题 |
| **M3b** | Phase 3b 完成：原型内容规模达标 | 内容填充完成 |
| **M4** | Phase 5 完成：验收清单全部手动通过 | 原型可完整游玩 |
| **M5** | Phase 6 完成：UI 完整对接 | 原型交付 |

---

## 十四、后续阶段（Phase F）——美术/音频/UI重制

> 此阶段在 M5 完成后独立启动，不在本计划执行范围内，届时单独规划。

- UI 视觉主题重建（色板/字体/控件样式/动效）
- 角色/敌人/卡牌美术资产替换
- 音效与 BGM
- 中文文本校对与本地化规范

---

*文档版本：V3.1 | 制定日期：2026-02-18 | 上一版本：V3（已废弃）*
*执行过程中如发现本文档与实际情况有冲突，以负责人当次指令为准，并更新本文档。*
