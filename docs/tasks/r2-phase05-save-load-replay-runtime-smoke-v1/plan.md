# 任务规划：save-load-replay 运行时冒烟增强

## 任务 ID
`r2-phase05-save-load-replay-runtime-smoke-v1`

## 目标
把现有结构性冒烟升级为更接近运行时场景的冒烟组合，补齐主链路可复现检查。

## 范围
- **包含**：
  - 保留 fixed seed / rng continuity / map-battle-reward-map 主链
  - 增加至少一个"异常路径"检查（如 restore 失败 fallback）
  - 增加存档版本兼容性检查
  - 增加环境变量种子覆盖检查
  - 明确是否接入 workflow；若不接入，文档强制发布前手动执行
  - 新增任务三件套并通过门禁
- **不包含**：
  - 不改变存档/读档业务逻辑
  - 不改变 RNG 核心实现

## 白名单文件
- dev/tools/save_load_replay_smoke.sh
- docs/work_logs/2026-02.md
- docs/tasks/r2-phase05-save-load-replay-runtime-smoke-v1/

## 实现步骤
1. 分析现有冒烟脚本，确认保留的检查项
2. 设计新增检查项：
   - 异常路径：restore 失败 fallback 检查
   - 版本兼容：MIN_COMPAT_VERSION / SAVE_VERSION 检查
   - 环境种子：STS_RUN_SEED 环境变量覆盖检查
   - 复盘日志连续性：repro_log 在 save/load 后的状态一致性
3. 编写增强版冒烟脚本
4. 更新 seed_replay README 文档
5. 运行验证

## 风险
- 低：仅增强检查脚本，不改业务代码
- 冒烟脚本仍不接入 workflow-check，避免与契约门禁重复

## 验收标准
- [ ] save_load_replay_smoke.sh 增强完成
- [ ] 新增异常路径检查通过
- [ ] 明确文档说明：不接入 workflow，发布前手动执行
- [ ] 任务三件套通过门禁检查
