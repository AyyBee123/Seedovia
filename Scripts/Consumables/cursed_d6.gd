class_name cursed_d6_consumable extends consumable_item_class

func on_use() -> void:
	ItemEffects.decrease_rarity()
