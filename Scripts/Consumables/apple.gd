class_name apple extends "res://Scripts/Items/consumable_item_class.gd"

func on_use(target) -> void:
	
	target._player_stats.heal(1) # heal player by 1 hp
