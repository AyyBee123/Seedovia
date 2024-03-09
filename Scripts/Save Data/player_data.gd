class_name player_data extends Resource

# resource variables must have @export to be saved in a file
@export var inventory: Dictionary = PlayerInventory.inventory
@export var equipment: Dictionary = PlayerInventory.equipment
@export var seeds: Dictionary = PlayerInventory.seeds
#@export var passives: Dictionary = 

func get_inventory():
	inventory = PlayerInventory.inventory
	equipment = PlayerInventory.equipment
	seeds = PlayerInventory.seeds
	
func set_inventory():
	PlayerInventory.inventory = inventory
	PlayerInventory.equipment = equipment
	PlayerInventory.seeds = seeds
