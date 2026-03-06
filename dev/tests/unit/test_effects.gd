extends GutTest

var _stats: Stats


func before_each():
	_stats = Stats.new()
	_stats.max_health = 80
	_stats.health = 80
	_stats.block = 0


func after_each():
	_stats = null


# ---------- DamageEffect ----------

func test_damage_effect_null_context_with_valid_target():
	var effect := DamageEffect.new()
	effect.amount = 10

	var target := _create_mock_target()
	effect.execute([target], null)
	assert_eq(_stats.health, 70, "DamageEffect should deal damage via fallback path")
	target.free()


func test_damage_effect_empty_targets():
	var effect := DamageEffect.new()
	effect.amount = 10
	effect.execute([], null)
	pass_test("DamageEffect with empty targets should not crash")


func test_damage_effect_null_target_in_array():
	var effect := DamageEffect.new()
	effect.amount = 5
	effect.execute([null], null)
	pass_test("DamageEffect with null target should not crash")


func test_damage_effect_zero_amount():
	var effect := DamageEffect.new()
	effect.amount = 0

	var target := _create_mock_target()
	effect.execute([target], null)
	assert_eq(_stats.health, 80, "Zero damage should not reduce health")
	target.free()


# ---------- BlockEffect ----------

func test_block_effect_null_context():
	var effect := BlockEffect.new()
	effect.amount = 5
	effect.execute([], null)
	pass_test("BlockEffect with null context should not crash")


func test_block_effect_properties():
	var effect := BlockEffect.new()
	effect.amount = 12
	assert_eq(effect.amount, 12, "Block amount should be set correctly")


# ---------- ApplyStatusEffect ----------

func test_apply_status_null_context():
	var effect := ApplyStatusEffect.new()
	effect.status_id = "weak"
	effect.stacks = 2
	effect.execute([], null)
	pass_test("ApplyStatusEffect with null context should not crash")


func test_apply_status_zero_stacks():
	var effect := ApplyStatusEffect.new()
	effect.status_id = "weak"
	effect.stacks = 0
	effect.execute([], null)
	pass_test("ApplyStatusEffect with 0 stacks should early return")


func test_apply_status_properties():
	var effect := ApplyStatusEffect.new()
	effect.status_id = "strength"
	effect.stacks = 3
	assert_eq(effect.status_id, "strength")
	assert_eq(effect.stacks, 3)


# ---------- GainEnergyEffect ----------

func test_gain_energy_null_context():
	var effect := GainEnergyEffect.new()
	effect.amount = 1
	effect.execute([], null)
	pass_test("GainEnergyEffect with null context should not crash")


func test_gain_energy_zero_amount():
	var effect := GainEnergyEffect.new()
	effect.amount = 0
	effect.execute([], null)
	pass_test("GainEnergyEffect with 0 amount should early return")


func test_gain_energy_negative_amount():
	var effect := GainEnergyEffect.new()
	effect.amount = -1
	effect.execute([], null)
	pass_test("GainEnergyEffect with negative amount should early return")


# ---------- DrawCardEffect ----------

func test_draw_card_null_context():
	var effect := DrawCardEffect.new()
	effect.amount = 2
	effect.execute([], null)
	pass_test("DrawCardEffect with null context should not crash")


func test_draw_card_zero_amount():
	var effect := DrawCardEffect.new()
	effect.amount = 0
	effect.execute([], null)
	pass_test("DrawCardEffect with 0 amount should early return")


# ---------- LoseHpEffect ----------

func test_lose_hp_target_self_null_context():
	var effect := LoseHpEffect.new()
	effect.amount = 5
	effect.target_self = true
	effect.execute([], null)
	pass_test("LoseHpEffect target_self with null context should not crash")


func test_lose_hp_bypasses_block():
	var effect := LoseHpEffect.new()
	effect.amount = 10
	effect.target_self = false

	var target := _create_mock_target()
	_stats.block = 20
	effect.execute([target], null)
	assert_eq(_stats.block, 20, "LoseHpEffect should restore block after damage")
	assert_eq(_stats.health, 70, "LoseHpEffect should deal damage bypassing block")
	target.free()


func test_lose_hp_empty_targets_no_sound():
	var effect := LoseHpEffect.new()
	effect.amount = 5
	effect.target_self = false
	effect.execute([], null)
	pass_test("LoseHpEffect with empty targets should not play sound")


func test_lose_hp_null_target_in_array():
	var effect := LoseHpEffect.new()
	effect.amount = 5
	effect.target_self = false
	effect.execute([null], null)
	pass_test("LoseHpEffect with null target should not crash")


# ---------- ConditionalDamageEffect ----------

func test_conditional_damage_null_context():
	var effect := ConditionalDamageEffect.new()
	effect.base_amount = 6
	effect.condition = "hp_below_half"
	effect.multiplier = 2

	var target := _create_mock_target()
	effect.execute([target], null)
	assert_eq(_stats.health, 74, "ConditionalDamage fallback should deal base_amount")
	target.free()


func test_conditional_damage_properties():
	var effect := ConditionalDamageEffect.new()
	effect.base_amount = 8
	effect.condition = "hp_below_half"
	effect.multiplier = 3
	assert_eq(effect.base_amount, 8)
	assert_eq(effect.condition, "hp_below_half")
	assert_eq(effect.multiplier, 3)


# ---------- StrengthMultiplierDamageEffect ----------

func test_strength_multiplier_null_context():
	var effect := StrengthMultiplierDamageEffect.new()
	effect.base_amount = 5
	effect.max_hits = 3

	var target := _create_mock_target()
	effect.execute([target], null)
	# With null context, strength = 0, so hit_count = 1
	assert_eq(_stats.health, 75, "Should deal base_amount once with no strength")
	target.free()


func test_strength_multiplier_properties():
	var effect := StrengthMultiplierDamageEffect.new()
	effect.base_amount = 4
	effect.max_hits = 5
	assert_eq(effect.base_amount, 4)
	assert_eq(effect.max_hits, 5)


# ---------- MissingHpBlockEffect ----------

func test_missing_hp_block_null_context():
	var effect := MissingHpBlockEffect.new()
	effect.percent = 0.2
	effect.min_block = 5
	effect.execute([], null)
	pass_test("MissingHpBlockEffect with null context should not crash")


func test_missing_hp_block_properties():
	var effect := MissingHpBlockEffect.new()
	effect.percent = 0.3
	effect.min_block = 8
	assert_almost_eq(effect.percent, 0.3, 0.001)
	assert_eq(effect.min_block, 8)


# ---------- Effect base class ----------

func test_base_effect_execute_does_nothing():
	var effect := Effect.new()
	effect.execute([], null)
	pass_test("Base Effect.execute should be a no-op")


# ---------- helpers ----------

func _create_mock_target() -> Node:
	var target := Node.new()
	target.set_meta("stats", _stats)
	target.set_script(_MockTargetScript)
	(target as Node).set("stats", _stats)
	add_child_autofree(target)
	return target


const _MockTargetScript := preload("res://dev/tests/unit/mock_target.gd")
