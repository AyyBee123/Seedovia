class_name character_class extends Resource

@export var character_name: String # the character's name
@export var character_sprite: Texture # the idle sprite of the character
@export var starting_inventory: Array[item_class] # Inventory the character starts with
@export var starting_talismans: Array[equipment_item_class] # Talismans the character starts with
@export var starting_seeds: Array[seed_class] # Seeds the character starts with
@export var starting_passives: Array[passive_class] # Passives the character starts with
@export var starting_coins: int = 0 # the number of coins the character starts with
@export var unlocked: bool = true # determines if the character is unlocked by default or if it needs to be unlocked
@export var hidden: bool = false # determines if the character is shown with the unlock condition if locked

func get_texture() -> Texture:
	return character_sprite
