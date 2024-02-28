class_name player_inventory_data extends Resource

@export var inventory: Dictionary = PlayerInventory.inventory
@export var equipment: Dictionary = PlayerInventory.equipment
@export var seeds: Dictionary = PlayerInventory.seeds

func get_inventory():
	inventory = PlayerInventory.inventory
	equipment = PlayerInventory.equipment
	seeds = PlayerInventory.seeds
	
func set_inventory():
	PlayerInventory.inventory = inventory
	PlayerInventory.equipment = equipment
	PlayerInventory.seeds = seeds
