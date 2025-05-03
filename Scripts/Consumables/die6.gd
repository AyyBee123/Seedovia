class_name die6_consumable extends consumable_item_class

func on_use() -> void:
	ItemEffects.damage_enemies(600)
