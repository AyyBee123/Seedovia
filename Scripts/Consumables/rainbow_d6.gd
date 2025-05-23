class_name rainbow_d6_consumable extends consumable_item_class

var used: bool

func on_use() -> void:
	if used:
		return
	ItemEffects.dupe_items()
	used = true
