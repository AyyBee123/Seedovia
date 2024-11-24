class_name passive extends "res://Scripts/Items/pickup_item_class.gd"

func on_pickup() -> void:
	ItemEffects.spawn_passive_menu()
