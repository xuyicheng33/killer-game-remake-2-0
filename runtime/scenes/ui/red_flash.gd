extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect
@onready var timer: Timer = $Timer


func _ready() -> void:
	_connect_signals()


func _exit_tree() -> void:
	_disconnect_signals()


func _connect_signals() -> void:
	if not Events.player_hit.is_connected(_on_player_hit):
		Events.player_hit.connect(_on_player_hit)
	if not timer.timeout.is_connected(_on_timer_timeout):
		timer.timeout.connect(_on_timer_timeout)


func _disconnect_signals() -> void:
	if Events.player_hit.is_connected(_on_player_hit):
		Events.player_hit.disconnect(_on_player_hit)
	if timer.timeout.is_connected(_on_timer_timeout):
		timer.timeout.disconnect(_on_timer_timeout)


func _on_player_hit() -> void:
	color_rect.color.a = 0.2
	timer.start()


func _on_timer_timeout() -> void:
	color_rect.color.a = 0.0
