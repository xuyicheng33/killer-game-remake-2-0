# 任务交接

## 基本信息

- 任务 ID：`fix-tooltip-event-signature-v1`
- 主模块：`runtime/global/events.gd`
- 提交人：Codex
- 日期：2026-02-19

## 当前状态

- 状态：`已完成`

## 改动摘要

- 统一 `card_tooltip_requested` 信号签名，从 `card_tooltip_requested(card: Card)` 修改为 `card_tooltip_requested(icon: Texture, text: String)`
- 修复了信号定义与实际 emit/handler 签名不匹配的问题

## 变更文件

- `runtime/global/events.gd:9`

## 风险与影响范围

- 该信号被 `tooltip.gd`、`card_base_state.gd`、`reward_screen.gd`、`shop_screen.gd` 等多处使用
- 所有调用点已验证签名一致

## 建议提交信息

- `fix(events): align card_tooltip_requested signal signature with usage`

## 审核员结论

- 结论：通过，信号签名统一完成。
