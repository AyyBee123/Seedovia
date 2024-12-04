class_name apple extends consumable_item_class

func on_use() -> void:
	var player = Targets.get_player()
	player._player_stats.heal(1) # heal player by 1 hp
