class_name pickup_item_class extends "res://Scripts/Items/item_class.gd"

var category := "PICKUP"
var rarity := 7 # N/A
@export var weight: float = 1.0
@export var shop_price: int
var acc_weight: float
func on_pickup() -> void:
	pass
