class_name character_class extends Resource

@export var starting_inventory: Array[item_class] # Inventory the character starts with
@export var starting_talismans: Array[equipment_item_class] # Talismans the character starts with
@export var starting_seeds: Array[seed_class] # Seeds the character starts with
@export var starting_passives: Array[PackedScene] # Passives the character starts with
@export var starting_coins: int = 0 # the number of coins the character starts with
@export var unlocked: bool = true
