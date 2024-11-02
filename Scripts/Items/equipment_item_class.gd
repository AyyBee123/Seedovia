class_name equipment_item_class extends "res://Scripts/Items/item_class.gd"

var category := "TALISMAN"
@export_enum("COMMON", "UNCOMMON", "RARE", "EPIC", "LEGENDARY", "MYSTIC", "UNIQUE", "N/A") var rarity: int
@export var properties: Array[String]
@export var special_properties: Array[PackedScene]
var was_already_equipped := false # this is to not abuse getting healed each time the item is equipped
var acc_weight: float
