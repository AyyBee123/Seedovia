class_name leaf_heart_pickup extends pickup_item_class

func on_pickup() -> void:
	var player = Targets.get_player()
	player._player_stats.heal_leaf_hearts(1)
