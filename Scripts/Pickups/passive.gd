class_name passive_pickup extends pickup_item_class

func on_pickup() -> void:
	Game.audio_manager.play(Game.audio_manager.use)
	ItemEffects.spawn_passive_menu()
