extends Node

var seeds := []
var seed_slot_indices := []

func load_weapons(starting_index: int = 0) -> Array:
	if PlayerInventory.seeds.size() == 0:
		return []
	var keys = PlayerInventory.seeds.keys()
	keys.sort()
	seeds = []
	seed_slot_indices = []
	for i in keys:
		seeds.append(PlayerInventory.seeds[i].scene)
		seed_slot_indices.append(i)
	return seeds
	
func get_weapon(index):
	return seeds[index]
