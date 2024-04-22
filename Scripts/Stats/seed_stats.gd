class_name seed_class extends "res://Scripts/Items/item_class.gd"

@export var scene: PackedScene
var category := "SEED"
@export_enum("COMMON", "UNCOMMON", "RARE", "EPIC", "LEGENDARY","UNIQUE", "N/A:-1") var rarity: int
