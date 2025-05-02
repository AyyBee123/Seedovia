class_name equipment_item_class extends item_class

var category := "TALISMAN"
@export_enum("COMMON", "UNCOMMON", "RARE", "EPIC", "LEGENDARY", "UNIQUE", "MYSTIC", "N/A") var rarity: int
@export var properties: Array[String]
@export var special_properties: Array[PackedScene]
var was_already_equipped := false # this is to not abuse getting healed each time the item is equipped
var add_stats := false # this is to add the stats and item passives when the character starts with talismans
var acc_weight: float
