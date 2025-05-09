class_name max_health_pickup extends pickup_item_class

func on_pickup() -> void:
	var player = Targets.get_player()
	player._player_stats.set_stat("Max_Health", "+", 1)
	player._player_stats.heal(1)
	Game.audio_manager.play(Game.audio_manager.use)
	
	for i in 8:
		player.spawn_sparkle(Color("cf0000"))
