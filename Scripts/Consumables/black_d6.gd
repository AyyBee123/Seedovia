class_name black_d6_consumable extends consumable_item_class

func on_use() -> void:
	ItemEffects.reroll_doors()
