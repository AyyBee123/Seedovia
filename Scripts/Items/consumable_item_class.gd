class_name consumable_item_class extends item_class

var category := "CONSUMABLE"
var rarity := 7 # N/A
@export var weight: float = 1.0
@export var shop_price: int
var acc_weight: float
var used: bool = false
func on_use() -> void: # called from the inventory script
	pass
