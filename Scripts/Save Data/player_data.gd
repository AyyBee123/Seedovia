class_name player_data extends Resource

var inventory: Dictionary = PlayerInventory.inventory
var equipment: Dictionary = PlayerInventory.equipment
var seeds: Dictionary = PlayerInventory.seeds

func get_inventory():
	inventory = PlayerInventory.inventory
	equipment = PlayerInventory.equipment
	seeds = PlayerInventory.seeds
	
func set_inventory():
	PlayerInventory.inventory = inventory
	PlayerInventory.equipment = equipment
	PlayerInventory.seeds = seeds
