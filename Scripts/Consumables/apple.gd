class_name apple_consumable extends consumable_item_class

func on_use() -> void:
	Game.audio_manager.play(Game.audio_manager.use)
	var player = Targets.get_player()
	player._player_stats.heal(1) # heal player by 1 hp
