class_name rarity_die_consumable extends consumable_item_class

func on_use() -> void:
	ItemEffects.increase_rarity()
