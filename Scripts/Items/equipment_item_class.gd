class_name equipment_item_class extends "res://Scripts/Items/item_class.gd"

@export_enum("HEAD", "ARMS", "BODY", "SHOULDERS", "LEGS", "WAIST", "FEET") var category: String
@export_enum("COMMON", "UNCOMMON", "RARE", "EPIC", "LEGENDARY", "N/A:-1") var rarity: int
@export var properties: Array[String]
@export var special_properties: Array[String]
