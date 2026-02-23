extends Node

# Card-related events
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
@warning_ignore("unused_signal")
signal card_tooltip_requested(icon: Texture, text: String)
@warning_ignore("unused_signal")
signal relic_tooltip_requested(icon: Texture, text: String)
@warning_ignore("unused_signal")
signal potion_tooltip_requested(icon: Texture, text: String)
@warning_ignore("unused_signal")
signal tooltip_hide_requested

# Player-related events
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

# Enemy-related events
@warning_ignore("unused_signal")
signal enemy_action_completed(enemy: Enemy)
@warning_ignore("unused_signal")
signal enemy_turn_started
@warning_ignore("unused_signal")
signal enemy_turn_ended
@warning_ignore("unused_signal")
signal enemy_died(enemy: Enemy)

# Battle-related events
@warning_ignore("unused_signal")
signal battle_over_screen_requested(text: String, type: BattleOverPanel.Type)
@warning_ignore("unused_signal")
signal battle_finished(result: int)
