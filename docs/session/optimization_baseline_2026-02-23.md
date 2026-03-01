# 优化前基线快照（2026-02-23）

## 环境
- Godot: `4.5.1.stable.official.f62fdbde1`
- 分支：`fix/run_flow-fix-encounter-and-battle-potion-gating-v1`

## 基线结果
- `make test`：通过（157/157，实施前）
- 契约检查：
  - `dev/tools/ui_shell_contract_check.sh` 通过
  - `dev/tools/run_flow_contract_check.sh` 通过
  - `dev/tools/seed_rng_contract_check.sh` 通过
- 冒烟脚本：
  - `dev/tools/save_load_replay_smoke.sh` 在实施前失败
  - 原因：脚本匹配 `RunRng.begin_run(seed)` 固定参数名，实际实现为 `begin_run(run_seed)`

## 本轮优化目标
1. 修复冒烟脚本签名漂移，恢复 smoke 可用性。
2. 建立卡牌/遗物/药水矩阵自动化测试，覆盖全部内容资源。
3. 新增固定 seed 的完整跑局自动化验证。
4. 增加 `make e2e-run` 与 `make full-validation-check` 统一入口。
