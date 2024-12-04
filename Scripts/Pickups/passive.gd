class_name passive_pickup extends pickup_item_class

func on_pickup() -> void:
	ItemEffects.spawn_passive_menu()
