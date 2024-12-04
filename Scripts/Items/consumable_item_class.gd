class_name consumable_item_class extends item_class

var category := "CONSUMABLE"
var rarity := 7 # N/A
@export var weight: float = 1.0
@export var shop_price: int
var acc_weight: float
func on_use() -> void:
	pass
