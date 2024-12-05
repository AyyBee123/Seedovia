class_name mysterious_rock_consumable extends consumable_item_class

func on_use() -> void:
	ItemEffects.dupe_items()
