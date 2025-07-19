class_name red_d6_consumable extends consumable_item_class

func on_use() -> void:
	Game.audio_manager.play(Game.audio_manager.use)
	ItemEffects.reroll_same_rarity()
