class_name max_health_pickup extends pickup_item_class

func on_pickup() -> void:
	var player = Targets.get_player()
	player._player_stats.set_stat("Max_Health", "+", 1)
	player._player_stats.heal(1)
