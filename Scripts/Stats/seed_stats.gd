class_name seed_class extends "res://Scripts/Items/item_class.gd"

@export var scene: PackedScene
var category := "SEED"
@export_enum("COMMON", "UNCOMMON", "RARE", "EPIC", "LEGENDARY", "MYSTIC", "UNIQUE", "N/A") var rarity: int
var acc_weight: float
