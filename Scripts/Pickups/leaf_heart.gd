class_name leaf_heart_pickup extends pickup_item_class

func on_pickup() -> void:
	var player = Targets.get_player()
	player._player_stats.heal_leaf_hearts(1)
	Game.audio_manager.play(Game.audio_manager.use)
	
	for i in 8:
		player.spawn_sparkle(Color("468232"))
