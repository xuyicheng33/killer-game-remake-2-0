extends GutTest

const VIEW_MODEL_SCRIPT := preload("res://runtime/modules/ui_shell/viewmodel/relic_potion_view_model.gd")


func test_project_exposes_compact_and_battle_projections() -> void:
	var view_model: RelicPotionViewModel = VIEW_MODEL_SCRIPT.new() as RelicPotionViewModel
	var run_state := RunState.new()
	run_state.relic_capacity = 6
	run_state.potion_capacity = 3

	var relic := RelicData.new()
	relic.id = "hud_relic"
	relic.title = "勇气徽章"
	relic.description = "回合开始时获得 2 点格挡。"
	run_state.relics = [relic]

	var potion := PotionData.new()
	potion.id = "hud_potion"
	potion.title = "治疗药水"
	potion.description = "恢复 10 点生命。"
	run_state.potions = [potion]

	var projection := view_model.project(run_state, "最新日志：战斗奖励已结算")
	assert_true(projection.has("compact_projection"), "应提供 compact_projection")
	assert_true(projection.has("battle_projection"), "应提供 battle_projection")

	var compact_projection: Dictionary = projection.get("compact_projection", {})
	var battle_projection: Dictionary = projection.get("battle_projection", {})
	assert_true(str(compact_projection.get("summary_text", "")).contains("遗物 1/6"), "compact_projection 应包含遗物摘要")
	assert_true(str(compact_projection.get("summary_text", "")).contains("药水 1/3"), "compact_projection 应包含药水摘要")
	assert_eq(str(battle_projection.get("relic_title", "")), "遗物 1/6")
	assert_eq(str(battle_projection.get("potion_title", "")), "药水 1/3")

	var relic_items: Variant = battle_projection.get("relic_items", [])
	assert_true(relic_items is Array and relic_items.size() == 1, "battle_projection 应投影遗物列表")
	if relic_items is Array and relic_items.size() == 1:
		var item: Dictionary = relic_items[0]
		assert_eq(str(item.get("tooltip_title", "")), "勇气徽章")
		assert_eq(str(item.get("tooltip_body", "")), "回合开始时获得 2 点格挡。")
