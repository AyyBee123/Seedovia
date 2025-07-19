class_name rarity_die_consumable extends consumable_item_class

func on_use() -> void:
	Game.audio_manager.play(Game.audio_manager.use)
	ItemEffects.increase_rarity()
