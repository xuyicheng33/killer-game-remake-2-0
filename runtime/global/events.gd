extends Node

## Legacy compatibility layer.
## All signals are forwarded to the domain-specific event buses:
## CardEvents, TooltipEvents, PlayerEvents, EnemyEvents, BattleEvents.

# Card-related (forwarded to CardEvents)
@warning_ignore("unused_signal")
signal card_drag_started(card_ui: CardUI)
@warning_ignore("unused_signal")
signal card_drag_ended(card_ui: CardUI)
@warning_ignore("unused_signal")
signal card_aim_started(card_ui: CardUI)
@warning_ignore("unused_signal")
signal card_aim_ended(card_ui: CardUI)
@warning_ignore("unused_signal")
signal card_played(card: Card)

# Tooltip-related (forwarded to TooltipEvents)
@warning_ignore("unused_signal")
signal card_tooltip_requested(icon: Texture, text: String)
@warning_ignore("unused_signal")
signal relic_tooltip_requested(icon: Texture, text: String)
@warning_ignore("unused_signal")
signal potion_tooltip_requested(icon: Texture, text: String)
@warning_ignore("unused_signal")
signal tooltip_hide_requested

# Player-related (forwarded to PlayerEvents)
@warning_ignore("unused_signal")
signal player_hand_drawn
@warning_ignore("unused_signal")
signal player_hand_discarded
@warning_ignore("unused_signal")
signal player_turn_ended
@warning_ignore("unused_signal")
signal player_hit
@warning_ignore("unused_signal")
signal player_block_applied(amount: int, source: String)
@warning_ignore("unused_signal")
signal player_died

# Enemy-related (forwarded to EnemyEvents)
@warning_ignore("unused_signal")
signal enemy_action_completed(enemy: Enemy)
@warning_ignore("unused_signal")
signal enemy_turn_started
@warning_ignore("unused_signal")
signal enemy_turn_ended
@warning_ignore("unused_signal")
signal enemy_died(enemy: Enemy)

# Battle-related (forwarded to BattleEvents)
@warning_ignore("unused_signal")
signal battle_over_screen_requested(text: String, type: BattleOverPanel.Type)
@warning_ignore("unused_signal")
signal battle_finished(result: int)


func _ready() -> void:
	card_drag_started.connect(func(card_ui): CardEvents.card_drag_started.emit(card_ui))
	card_drag_ended.connect(func(card_ui): CardEvents.card_drag_ended.emit(card_ui))
	card_aim_started.connect(func(card_ui): CardEvents.card_aim_started.emit(card_ui))
	card_aim_ended.connect(func(card_ui): CardEvents.card_aim_ended.emit(card_ui))
	card_played.connect(func(card): CardEvents.card_played.emit(card))

	card_tooltip_requested.connect(func(icon, text): TooltipEvents.card_tooltip_requested.emit(icon, text))
	relic_tooltip_requested.connect(func(icon, text): TooltipEvents.relic_tooltip_requested.emit(icon, text))
	potion_tooltip_requested.connect(func(icon, text): TooltipEvents.potion_tooltip_requested.emit(icon, text))
	tooltip_hide_requested.connect(func(): TooltipEvents.tooltip_hide_requested.emit())

	player_hand_drawn.connect(func(): PlayerEvents.player_hand_drawn.emit())
	player_hand_discarded.connect(func(): PlayerEvents.player_hand_discarded.emit())
	player_turn_ended.connect(func(): PlayerEvents.player_turn_ended.emit())
	player_hit.connect(func(): PlayerEvents.player_hit.emit())
	player_block_applied.connect(func(amount, source): PlayerEvents.player_block_applied.emit(amount, source))
	player_died.connect(func(): PlayerEvents.player_died.emit())

	enemy_action_completed.connect(func(enemy): EnemyEvents.enemy_action_completed.emit(enemy))
	enemy_turn_started.connect(func(): EnemyEvents.enemy_turn_started.emit())
	enemy_turn_ended.connect(func(): EnemyEvents.enemy_turn_ended.emit())
	enemy_died.connect(func(enemy): EnemyEvents.enemy_died.emit(enemy))

	battle_over_screen_requested.connect(func(text, type): BattleEvents.battle_over_screen_requested.emit(text, type))
	battle_finished.connect(func(result): BattleEvents.battle_finished.emit(result))
