extends Node

var slot_index: int

func load_weapon(starting_index: int = 0) -> PackedScene:
	var seed_slots: Dictionary
	if PlayerInventory.seeds.size() <= starting_index:
		return null
	for i in PlayerInventory.seeds:
		if i < starting_index:
			continue
		return PlayerInventory.seeds[i].scene
	return null # if the seed slots have no seeds at all
	
func set_slot_index() -> void:
	slot_index = 0
