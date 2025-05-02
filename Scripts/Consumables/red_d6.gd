class_name red_d6_consumable extends consumable_item_class

func on_use() -> void:
	ItemEffects.reroll_same_rarity()
