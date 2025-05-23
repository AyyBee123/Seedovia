class_name apple_consumable extends consumable_item_class

var used: bool

func on_use() -> void:
	if used:
		return
	var player = Targets.get_player()
	player._player_stats.heal(1) # heal player by 1 hp
	used = true
