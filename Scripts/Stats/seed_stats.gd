class_name seed_class extends item_class

@export var scene: PackedScene
var category := "SEED"
@export_enum("COMMON", "UNCOMMON", "RARE", "EPIC", "LEGENDARY", "UNIQUE", "MYSTIC", "N/A") var rarity: int
var acc_weight: float

func get_texture() -> Texture:
	return texture
