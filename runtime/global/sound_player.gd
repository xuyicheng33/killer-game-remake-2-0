extends Node


func _exit_tree() -> void:
	stop()


func play(audio: AudioStream, single=false) -> void:
	if not audio:
		return
		
	if single:
		stop()

	for player: AudioStreamPlayer in get_children():
		if not player.playing:
			player.stream = audio
			player.play()
			break


func stop() -> void:
	for player: AudioStreamPlayer in get_children():
		player.stop()
		player.stream = null
