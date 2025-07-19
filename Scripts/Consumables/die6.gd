class_name die6_consumable extends consumable_item_class

func on_use() -> void:
	SfxDeconflicter.play(Game.audio_manager.crit)
	SfxDeconflicter.play(Game.audio_manager.ding_2)
	ItemEffects.damage_enemies(600)
